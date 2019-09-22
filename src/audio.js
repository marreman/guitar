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
