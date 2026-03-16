const fs = require('fs');

async function testFnIndex(index) {
  try {
    const sessionHash = "test12345" + index;
    const joinRes = await fetch('https://levihsu-ootdiffusion.hf.space/queue/join', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        data: [
          {"path": "https://raw.githubusercontent.com/gradio-app/gradio/main/test/test_files/bus.png"}, // human
          {"path": "https://raw.githubusercontent.com/gradio-app/gradio/main/test/test_files/bus.png"}, // garment
          1, // n_samples
          20, // n_steps
          2.0, // image_scale
          -1 // seed
        ],
        fn_index: index,
        session_hash: sessionHash
      })
    });
    const resJoined = await joinRes.json();
    console.log(`\n--- fn_index ${index} --- Joined:`, resJoined.event_id);
    if (!resJoined.event_id) return;
    
    const pollUrl = `https://levihsu-ootdiffusion.hf.space/queue/data?session_hash=${sessionHash}`;
    const pollReq = await fetch(pollUrl);
    const text = await pollReq.text();
    const lines = text.split('\n');
    for (let line of lines) {
      if (line.startsWith('data: ')) {
        const data = JSON.parse(line.substring(6));
        if (data.msg === 'process_completed' || data.msg === 'process_errored') {
          console.log(`fn_index ${index} Result:`, JSON.stringify(data).substring(0, 300));
        }
      }
    }
  } catch (e) {
    console.log(`fn_index ${index} error:`, e.message);
  }
}

async function run() {
  for (let i = 0; i < 4; i++) {
    await testFnIndex(i);
  }
}
run();
