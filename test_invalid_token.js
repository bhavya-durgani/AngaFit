const fs = require('fs');

async function testInvalidToken() {
  const sessionHash = "test12345invalid";
  const joinRes = await fetch('https://levihsu-ootdiffusion.hf.space/queue/join', {
    method: 'POST',
    headers: { 
      'Content-Type': 'application/json',
      'Authorization': 'Bearer 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' // The invalid token from the app
    },
    body: JSON.stringify({
      data: [
         {"path": "https://raw.githubusercontent.com/gradio-app/gradio/main/test/test_files/bus.png", "meta": {"_type": "gradio.FileData"}},
         {"path": "https://raw.githubusercontent.com/gradio-app/gradio/main/test/test_files/bus.png", "meta": {"_type": "gradio.FileData"}},
        1, 20, 2.0, -1
      ],
      fn_index: 0,
      session_hash: sessionHash
    })
  });
  
  const resJoined = await joinRes.json();
  console.log("Joined:", resJoined);
  if (!resJoined.event_id) return;
  
  const pollUrl = `https://levihsu-ootdiffusion.hf.space/queue/data?session_hash=${sessionHash}`;
  const pollReq = await fetch(pollUrl);
  const text = await pollReq.text();
  const lines = text.split('\n');
  for (let line of lines) {
    if (line.startsWith('data: ')) {
      const data = JSON.parse(line.substring(6));
      if (data.msg === 'process_completed' || data.msg === 'process_errored') {
        console.log("Result:", JSON.stringify(data));
      }
    }
  }
}

testInvalidToken();
