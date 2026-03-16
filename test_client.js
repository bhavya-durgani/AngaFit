const { Client } = require("@gradio/client");

async function run() {
  try {
    const client = await Client.connect("yisol/IDM-VTON");
    const result = await client.predict("/tryon", { 
      dict: {
        background: "https://hips.hearstapps.com/hmg-prod/images/robert-pattinson-1510233069.jpg",
        layers: [],
        composite: null
      }, 
      garm_img: "https://upload.wikimedia.org/wikipedia/commons/2/24/Blue_Tshirt.jpg", 
      garment_des: "Blue T-shirt", 
      is_checked: true, 
      is_checked_crop: false, 
      denoise_steps: 30, 
      seed: 42, 
    });
    console.log("Success Result:", JSON.stringify(result, null, 2));
  } catch (e) {
    console.log("Caught Error:", e.message, e.stack);
  }
}
run();
