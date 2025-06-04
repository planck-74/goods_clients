/** @type {import("eslint").ESLint.ConfigData} */
module.exports = {
      env: {
            node: true,
            es2021: true,
      },
      extends: [
            "eslint:recommended",
      ],
      parserOptions: {
            ecmaVersion: "latest",
            sourceType: "commonjs"
      },
      rules: {
            "no-unused-vars": "warn",
            "no-console": "off",
            "indent": ["error", 6],
            "quotes": ["error", "double"]
      },
};
