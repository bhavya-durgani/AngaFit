const fs = require('fs');
async function run() {
  const res = await fetch('https://levihsu-ootdiffusion.hf.space/info');
  const info = await res.json();
  fs.writeFileSync('c:/Users/jinay/OneDrive/Desktop/AngaFit/AngaFit/deps.json', JSON.stringify(info.dependencies, null, 2));
}
run();
