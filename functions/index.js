const functions = require('firebase-functions/v1');
const admin = require('firebase-admin');
admin.initializeApp();

const STORE_ID = 'cafb6e90-0ab1-11f0-b25a-8b76462b3bd5';

exports.scheduledFunction = functions.pubsub
      .schedule('every 24 hours')
      .timeZone('Africa/Cairo')
      .onRun(async () => {
            try {
                  await updateTrendingProductsFromStore();
                  await updateOnSaleProductsFromStore();
                  console.log("Trending & On‑Sale products updated successfully.");
            } catch (error) {
                  console.error("Error in scheduledFunction:", error);
            }
      });

/**
 * 1) جلب كل منتجات المتجر، ترتيبها حسب salesCount،
 *    أخذ أول 30، ثم تحديثها في الكولكشن trending_products.
 */
async function updateTrendingProductsFromStore() {
      const db = admin.firestore();
      const trendingColl = db.collection('trending_products');

      // جلب كل منتجات المتجر
      const storeSnap = await db
            .collection('stores').doc(STORE_ID)
            .collection('products')
            .get();

      const batch = db.batch();

      // ترتيب حسب salesCount وأخذ أول 30
      const productsToUpdate = storeSnap.docs
            .sort((a, b) => b.data().salesCount - a.data().salesCount)
            .slice(0, 30);

      // حذف أي مستندات قديمة تتجاوز الـ 30
      const currentDocs = await trendingColl.get();
      if (currentDocs.size > 30) {
            currentDocs.docs.slice(30).forEach(doc => {
                  batch.delete(doc.ref);
            });
      }

      // تحديث أو إضافة المنتجات الجديدة
      for (const storeDoc of productsToUpdate) {
            const storeData = storeDoc.data();
            const productId = storeData.productId;

            // جلب البيانات الثابتة من الكولكشن العام
            const globalSnap = await db
                  .collection('products')
                  .where('productId', '==', productId)
                  .limit(1)
                  .get();
            const globalData = globalSnap.empty ? {} : globalSnap.docs[0].data();

            // دمج البيانات الثابتة والديناميكية في خريطة واحدة
            const combinedData = {
                  ...globalData,      // اسم، وصف، تصنيف، صورة...
                  ...storeData,       // سعر، توفر، خصم، salesCount...
                  storeId: STORE_ID,
                  updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            };

            batch.set(trendingColl.doc(productId), combinedData, { merge: true });
      }

      await batch.commit();
      console.log(`تم تحديث ${productsToUpdate.length} منتج تريند.`);
}

/**
 * 2) جلب أول 30 منتج عليه عرض من متجر التاجر،
 *    ثم تحديثها في الكولكشن on_sale_products.
 */
async function updateOnSaleProductsFromStore() {
      const db = admin.firestore();
      const onSaleColl = db.collection('on_sale_products');
      const storeRef = db.collection('stores').doc(STORE_ID).collection('products');

      // جلب أول 30 منتج عليه عرض
      const saleSnap = await storeRef
            .where('isOnSale', '==', true)
            .limit(30)
            .get();

      if (saleSnap.empty) {
            console.log(`No on‑sale products found in store ${STORE_ID}.`);
            return;
      }

      const batch = db.batch();

      // حذف أي مستندات قديمة تتجاوز الـ 30
      const currentDocs = await onSaleColl.get();
      if (currentDocs.size > 30) {
            currentDocs.docs.slice(30).forEach(doc => {
                  batch.delete(doc.ref);
            });
      }

      // تحديث أو إضافة المنتجات الجديدة
      for (const storeDoc of saleSnap.docs) {
            const storeData = storeDoc.data();
            const productId = storeData.productId;

            // جلب البيانات الثابتة من الكولكشن العام
            const globalSnap = await db
                  .collection('products')
                  .where('productId', '==', productId)
                  .limit(1)
                  .get();
            if (globalSnap.empty) {
                  console.warn(`Global product not found for productId ${productId}`);
                  continue;
            }
            const globalData = globalSnap.docs[0].data();

            // دمج البيانات الثابتة والديناميكية في خريطة واحدة
            const combinedData = {
                  ...globalData,
                  ...storeData,
                  storeId: STORE_ID,
                  updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            };

            batch.set(onSaleColl.doc(productId), combinedData, { merge: true });
      }

      await batch.commit();
      console.log(`تم تحديث ${saleSnap.docs.length} منتج بعرض من متجر ${STORE_ID}.`);
}
