const fs = require('fs');
async function test() {
  // 1. Download images
  const hRes = await fetch("https://hips.hearstapps.com/hmg-prod/images/robert-pattinson-1510233069.jpg");
  const hBlob = await hRes.blob();
  const gRes = await fetch("https://upload.wikimedia.org/wikipedia/commons/2/24/Blue_Tshirt.jpg");
  const gBlob = await gRes.blob();

  // 2. Upload to Gradio
  const formData = new FormData();
  formData.append('files', hBlob, 'human.jpg');
  formData.append('files', gBlob, 'garment.jpg');
  const upRes = await fetch('https://yisol-idm-vton.hf.space/upload', {
    method: 'POST',
    body: formData
  });
  const paths = await upRes.json();
  console.log("Upload paths:", paths);

  // 3. Join queue
  const joinRes = await fetch('https://yisol-idm-vton.hf.space/queue/join', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      data: [
        {
          background: {"path": paths[0]},
          layers: [],
          composite: null
        },
        {"path": paths[1]},
        "upper body clothing",
        true,
        false,
        30,
        42
      ],
      fn_index: 3,
      session_hash: "test12345"
    })
  });
  console.log("Join:", await joinRes.json());
  
  const pollUrl = `https://yisol-idm-vton.hf.space/queue/data?session_hash=test12345`;
  const pollReq = await fetch(pollUrl);
  const text = await pollReq.text();
  const lines = text.split('\n');
  for (const line of lines) {
    if (line.startsWith('data: ')) {
      const data = JSON.parse(line.substring(5));
      if (data.msg === 'process_completed' || data.msg === 'process_errored') {
        fs.writeFileSync('output.json', JSON.stringify(data, null, 2));
        console.log("Wrote output.json");
      }
    }
  }
}
test();
