const functions = require('firebase-functions/v1');
const admin = require('firebase-admin');
admin.initializeApp();

const STORE_ID = 'cafb6e90-0ab1-11f0-b25a-8b76462b3bd5';

exports.scheduledFunction = functions.pubsub
      .schedule('every 96 hours')
      .timeZone('Africa/Cairo')
      .onRun(async (context) => {
            try {
                  await updateTrendingProductsFromStore();
                  await updateOnSaleProductsFromStore();
                  console.log("Trending & On-Sale products updated successfully.");
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

      const storeSnap = await db
            .collection('stores').doc(STORE_ID)
            .collection('products')
            .get();

      const batch = db.batch();

      // جلب أول 30 منتج حسب salesCount
      const productsToUpdate = storeSnap.docs
            .sort((a, b) => b.data().salesCount - a.data().salesCount)
            .slice(0, 30);

      // حذف المنتجات القديمة إذا كانت أكثر من 30
      const currentDocs = await trendingColl.get();
      if (currentDocs.size > 30) {
            const docsToDelete = currentDocs.docs.slice(30); // أخذ جميع المنتجات التي تتجاوز 30
            docsToDelete.forEach(doc => {
                  batch.delete(doc.ref); // حذف المستندات القديمة
            });
      }

      // تحديث أو إضافة المنتجات الجديدة
      for (const storeDoc of productsToUpdate) {
            const storeData = storeDoc.data();
            const productId = storeData.productId;

            const globalDoc = await db.collection('products')
                  .where('productId', '==', productId)
                  .limit(1)
                  .get();

            const globalData = globalDoc.empty ? {} : globalDoc.docs[0].data();

            const combinedData = {
                  ...globalData, // (اسم، وصف، تصنيف، صورة...)
                  ...storeData,  // (سعر، توفر، خصم...)
                  storeId: STORE_ID,
                  updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            };

            const docRef = trendingColl.doc(productId);
            batch.set(docRef, combinedData, { merge: true });
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
      const storeProductsRef = db.collection('stores').doc(STORE_ID).collection('products');
      const saleSnap = await storeProductsRef
            .where('isOnSale', '==', true)
            .limit(30)
            .get();

      if (saleSnap.empty) {
            console.log(`No on-sale products found in store ${STORE_ID}.`);
            return;
      }

      const batch = db.batch();

      // جلب أول 30 منتج عليه عرض
      const productsToUpdate = saleSnap.docs.slice(0, 30);

      // حذف المنتجات القديمة إذا كانت أكثر من 30
      const currentDocs = await onSaleColl.get();
      if (currentDocs.size > 30) {
            const docsToDelete = currentDocs.docs.slice(30); // أخذ جميع المنتجات التي تتجاوز 30
            docsToDelete.forEach(doc => {
                  batch.delete(doc.ref); // حذف المستندات القديمة
            });
      }

      // تحديث أو إضافة المنتجات الجديدة
      for (const doc of productsToUpdate) {
            const storeData = doc.data();
            const productId = storeData.productId;

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

            const combinedData = {
                  staticData: globalData,
                  dynamicData: storeData,
                  storeId: STORE_ID,
                  updatedAt: admin.firestore.FieldValue.serverTimestamp(),
            };

            const docRef = onSaleColl.doc(doc.id);
            batch.set(docRef, combinedData, { merge: true });
      }

      await batch.commit();
      console.log(`تم تحديث ${productsToUpdate.length} منتج بعرض من متجر ${STORE_ID}.`);
}
