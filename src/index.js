const { onFrequencyChange } = require("./audio");
const { Elm } = require("./Main.elm");

const app = Elm.Main.init({
  flags: {},
  node: document.querySelector("main#elm")
});

let audio;

app.ports.startListeningForFrequencyChanges.subscribe(() => {
  audio = onFrequencyChange(frequency => {
    app.ports.onFrequencyChange.send(frequency);
  });
});

app.ports.stopListeningForFrequencyChanges.subscribe(() => {
  audio && audio.then(disconnect => disconnect());
});
