// functions/babel.config.js
module.exports = {
  presets: [
    // adjust node version to match your Cloud Functions runtime
    ["@babel/preset-env", {targets: {node: "14"}}],
  ],
};
