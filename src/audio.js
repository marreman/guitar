const Pitchfinder = require("pitchfinder");
const detectPitch = Pitchfinder.AMDF();

let lastFrequency = null;

exports.onFrequencyChange = f => {
  const bufferSize = 4096;
  const audioContext = new window.AudioContext();
  const analyser = audioContext.createAnalyser();
  const scriptProcessor = audioContext.createScriptProcessor(bufferSize, 1, 1);

  navigator.mediaDevices.getUserMedia({ audio: true }).then(stream => {
    audioContext.createMediaStreamSource(stream).connect(analyser);
    analyser.connect(scriptProcessor);
    scriptProcessor.connect(audioContext.destination);
    scriptProcessor.addEventListener("audioprocess", event => {
      const data = event.inputBuffer.getChannelData(0);
      const frequency = detectPitch(data);

      if (frequency !== lastFrequency) {
        lastFrequency = frequency;
        f(frequency);
      }
    });
  });
};

exports.getNote = frequency => {
  const A4 = 440;
  const semitone = 69;
  const noteStrings = [
    "C",
    "C♯",
    "D",
    "D♯",
    "E",
    "F",
    "F♯",
    "G",
    "G♯",
    "A",
    "A♯",
    "B"
  ];
  const note = 12 * (Math.log(frequency / A4) / Math.log(2));
  const a = Math.round(note) + semitone;
  console.log(a);
  return noteStrings[a % 12];
};
