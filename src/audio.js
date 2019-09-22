function start() {
  console.log("starting");

  document.documentElement.onclick = undefined;

  const bufferSize = 4096;
  const audioContext = new window.AudioContext();
  const analyser = audioContext.createAnalyser();
  const scriptProcessor = audioContext.createScriptProcessor(bufferSize, 1, 1);

  Aubio().then(aubio => {
    const pitchDetector = new aubio.Pitch(
      "default",
      bufferSize,
      1,
      audioContext.sampleRate
    );

    record(pitchDetector);
  });

  function record(pitchDetector) {
    console.log("recording");

    navigator.mediaDevices.getUserMedia({ audio: true }).then(stream => {
      audioContext.createMediaStreamSource(stream).connect(analyser);
      analyser.connect(scriptProcessor);
      scriptProcessor.connect(audioContext.destination);
      scriptProcessor.addEventListener("audioprocess", event => {
        const frequency = pitchDetector.do(event.inputBuffer.getChannelData(0));
        console.log(frequency);
      });
    });
  }
}

document.documentElement.onclick = start;
