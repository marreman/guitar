const Pitchfinder = require("pitchfinder");
const detectPitch = Pitchfinder.AMDF();

let lastFrequency = null;

exports.onFrequencyChange = f =>
  navigator.mediaDevices.getUserMedia({ audio: true }).then(stream => {
    const context = new window.AudioContext();
    const analyser = context.createAnalyser();
    const processor = context.createScriptProcessor(4096, 1, 1);
    const node = context.createMediaStreamSource(stream);

    const process = event => {
      const frequency = detectPitch(event.inputBuffer.getChannelData(0));

      if (frequency !== lastFrequency) {
        lastFrequency = frequency;
        f(frequency);
      }
    };

    node.connect(analyser);
    analyser.connect(processor);
    processor.connect(context.destination);
    processor.addEventListener("audioprocess", process);

    return () => {
      processor.removeEventListener("audioprocess", process);
      processor.disconnect();
      analyser.disconnect();
      stream.getTracks().forEach(track => track.stop());
      context.close();
    };
  });
