const fs = require('fs');

async function testDCParams() {
  const sessionHash = "test12345dc";
  const joinRes = await fetch('https://levihsu-ootdiffusion.hf.space/queue/join', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      data: [
         {"path": "https://raw.githubusercontent.com/gradio-app/gradio/main/test/test_files/bus.png", "meta": {"_type": "gradio.FileData"}},
         {"path": "https://raw.githubusercontent.com/gradio-app/gradio/main/test/test_files/bus.png", "meta": {"_type": "gradio.FileData"}},
         "Upper-body", // The 3rd param required by process_dc
        1, 20, 2.0, -1
      ],
      fn_index: 1, // process_dc
      session_hash: sessionHash
    })
  });
  
  const resJoined = await joinRes.json();
  console.log("Joined DC:", resJoined);
  if (!resJoined.event_id) return;
  
  const pollUrl = `https://levihsu-ootdiffusion.hf.space/queue/data?session_hash=${sessionHash}`;
  const pollReq = await fetch(pollUrl);
  const text = await pollReq.text();
  const lines = text.split('\n');
  for (let line of lines) {
    if (line.startsWith('data: ')) {
      const data = JSON.parse(line.substring(6));
      if (data.msg === 'process_completed' || data.msg === 'process_errored') {
        console.log("Result DC:", JSON.stringify(data));
      }
    }
  }
}

testDCParams();
