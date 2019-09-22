const { onFrequencyChange } = require("./audio");
const { Elm } = require("./Main.elm");

const app = Elm.Main.init({
  flags: {},
  node: document.querySelector("main#elm")
});

app.ports.startListeningForFrequencyChanges.subscribe(() => {
  onFrequencyChange(frequency => {
    app.ports.onFrequencyChange.send(frequency);
  });
});
