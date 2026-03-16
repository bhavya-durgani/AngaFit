const fs = require('fs');

async function test() {
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
      api_name: "/process_hd", // Gradio 4 supports api_name instead of fn_index
      session_hash: "test12345"
    })
  });
  const resJoined = await joinRes.json();
  console.log("Join:", resJoined);
  if(!resJoined.event_id) return;
  
  const pollUrl = `https://levihsu-ootdiffusion.hf.space/queue/data?session_hash=test12345`;
  const pollReq = await fetch(pollUrl);
  const text = await pollReq.text();
  console.log("Poll:");
  const lines = text.split('\n');
  for(let line of lines) {
    if(line.startsWith('data: ')) {
      console.log(line.substring(6));
    }
  }
}
test();
