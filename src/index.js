const { onFrequencyChange } = require("./audio");
const { Elm } = require("./Main.elm");

const app = Elm.Main.init({
  flags: {},
  node: document.querySelector("main#elm")
});

let unsubscribe;

app.ports.startListeningForFrequencyChanges.subscribe(() => {
  unsubscribe = onFrequencyChange(frequency => {
    app.ports.onFrequencyChange.send(frequency);
  });
});

app.ports.stopListeningForFrequencyChanges.subscribe(() => {
  unsubscribe && unsubscribe();
});
