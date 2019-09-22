const Pitchfinder = require("pitchfinder");
const detectPitch = Pitchfinder.AMDF();

let lastFrequency = null;

exports.onFrequencyChange = async f => {
  const stream = await navigator.mediaDevices.getUserMedia({ audio: true });
  const context = new window.AudioContext();
  const analyser = context.createAnalyser();
  const processor = context.createScriptProcessor(4096, 1, 1);
  const audioSource = context.createMediaStreamSource(stream);
  const process = event => {
    const frequency = detectPitch(event.inputBuffer.getChannelData(0));

    if (frequency !== lastFrequency) {
      lastFrequency = frequency;
      f(frequency);
    }
  };

  audioSource.connect(analyser);
  analyser.connect(processor);
  processor.connect(context.destination);
  processor.addEventListener("audioprocess", process);

  return () => {
    processor.removeEventListener("audioprocess", process);
    stream.getTracks().forEach(track => track.stop());
    processor.disconnect();
    analyser.disconnect();
    audioSource.disconnect();
    context.close();
  };
};
