const fs = require('fs');
async function run() {
  const res = await fetch('https://levihsu-ootdiffusion.hf.space/info');
  const info = await res.json();
  fs.writeFileSync('c:/Users/jinay/OneDrive/Desktop/AngaFit/AngaFit/info_output.json', JSON.stringify(info.named_endpoints['/process_hd'], null, 2));
}
run();
