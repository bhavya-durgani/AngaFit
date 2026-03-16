const fs = require('fs');
async function run() {
  const session_hash = Math.random().toString(36).substring(2);
  const payload = {
    "data": [
      {
        "path": "/tmp/gradio/2e0cca23e744c036b3905c4b6167371632942e1c/model_1.png",
        "url": "https://levihsu-ootdiffusion.hf.space/file=/tmp/gradio/2e0cca23e744c036b3905c4b6167371632942e1c/model_1.png",
        "size": null,
        "orig_name": "model_1.png",
        "mime_type": "image/png",
        "is_stream": false,
        "meta": { "_type": "gradio.FileData" }
      },
      {
        "path": "/tmp/gradio/180d4e2a1139071a8685a5edee7ab24bcf1639f5/03244_00.jpg",
        "url": "https://levihsu-ootdiffusion.hf.space/file=/tmp/gradio/180d4e2a1139071a8685a5edee7ab24bcf1639f5/03244_00.jpg",
        "size": null,
        "orig_name": "03244_00.jpg",
        "mime_type": "image/jpeg",
        "is_stream": false,
        "meta": { "_type": "gradio.FileData" }
      },
      1,
      20,
      2.0,
      -1
    ],
    "fn_index": 0,
    "session_hash": session_hash
  };

  const res = await fetch('https://levihsu-ootdiffusion.hf.space/queue/join', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify(payload)
  });
  
  const evtSource = await fetch(`https://levihsu-ootdiffusion.hf.space/queue/data?session_hash=${session_hash}`);
  const reader = evtSource.body.getReader();
  const decoder = new TextDecoder();
  let text = '';
  while (true) {
    const {value, done} = await reader.read();
    if (done) break;
    const chunk = decoder.decode(value);
    text += chunk;
    if (chunk.includes('process_completed') || chunk.includes('process_errored')) {
      fs.writeFileSync('c:/Users/jinay/OneDrive/Desktop/AngaFit/AngaFit/hf_error.json', chunk);
      break;
    }
  }
}
run();
