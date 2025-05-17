/** @type {import("eslint").ESLint.ConfigData} */
export default {
      root: true,
      env: {
            node: true,
            es2021: true,
      },
      extends: [
            "eslint:recommended",
      ],
      parserOptions: {
            ecmaVersion: "latest",
      },
      rules: {
            // هنا تضيف قواعدك أو تعديلاتك الخاصة
      },
};
