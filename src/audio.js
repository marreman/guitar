const Pitchfinder = require("pitchfinder");
const detectPitch = Pitchfinder.AMDF();

let lastFrequency = null;

exports.onFrequencyChange = f => {
  const context = new window.AudioContext();
  const analyser = context.createAnalyser();
  const processor = context.createScriptProcessor(4096, 1, 1);
  const process = event => {
    const frequency = detectPitch(event.inputBuffer.getChannelData(0));

    if (frequency !== lastFrequency) {
      lastFrequency = frequency;
      f(frequency);
    }
  };

  navigator.mediaDevices.getUserMedia({ audio: true }).then(stream => {
    context.createMediaStreamSource(stream).connect(analyser);
    analyser.connect(processor);
    processor.connect(context.destination);
    processor.addEventListener("audioprocess", process);
  });

  return () => processor.removeEventListener("audioprocess", process);
};
