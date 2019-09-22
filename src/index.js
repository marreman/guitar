const { Elm } = require("./Main.elm");
require("./audio");

const app = Elm.Main.init({
  flags: {},
  node: document.querySelector("main#elm")
});
