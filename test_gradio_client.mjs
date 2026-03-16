import { Client } from "@gradio/client";

async function run() {
  try {
    const app = await Client.connect("levihsu/OOTDiffusion");
    
    const result = await app.predict("/process_hd", [
      "https://levihsu-ootdiffusion.hf.space/file=/tmp/gradio/2e0cca23e744c036b3905c4b6167371632942e1c/model_1.png", // filepath  in 'Model' Image component
      "https://levihsu-ootdiffusion.hf.space/file=/tmp/gradio/180d4e2a1139071a8685a5edee7ab24bcf1639f5/03244_00.jpg", // filepath  in 'Garment' Image component
      1, // number (numeric value between 1 and 4) in 'Images' Slider component
      20, // number (numeric value between 20 and 40) in 'Steps' Slider component
      2, // number (numeric value between 1.0 and 5.0) in 'Guidance scale' Slider component
      -1, // number (numeric value between -1 and 2147483647) in 'Seed' Slider component
    ]);
    
    console.log("SUCCESS:", JSON.stringify(result, null, 2));
  } catch (e) {
    console.error("ERROR:", e);
  }
}

run();
