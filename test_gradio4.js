const fs = require('fs');

async function testGradio4() {
  const fileData = {
    path: "https://raw.githubusercontent.com/gradio-app/gradio/main/test/test_files/bus.png",
    meta: { _type: "gradio.FileData" }
  };

  try {
    const postRes = await fetch('https://levihsu-ootdiffusion.hf.space/call/process_hd', {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({
        data: [
          fileData, // human
          fileData, // garment
          1, // n_samples
          20, // n_steps
          2.0, // image_scale
          -1 // seed
        ]
      })
    });
    
    if (postRes.status !== 200) {
      console.log("POST failed:", postRes.status, await postRes.text());
      return;
    }
    
    const { event_id } = await postRes.json();
    console.log("Joined with event_id:", event_id);
    
    const streamRes = await fetch(`https://levihsu-ootdiffusion.hf.space/call/process_hd/${event_id}`);
    const text = await streamRes.text();
    console.log("Stream Output (first 1000 chars):\n", text.substring(0, 1000));
  } catch (e) {
    console.log("Error:", e.message);
  }
}

testGradio4();
