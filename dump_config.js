const fs = require('fs');
async function run() {
  const res = await fetch('https://levihsu-ootdiffusion.hf.space/config');
  const config = await res.json();
  const hd_dep = config.dependencies.find(d => d.api_name === '/process_hd');
  console.log("process_hd index:", config.dependencies.indexOf(hd_dep));
  console.log("process_hd inputs:", hd_dep.inputs.length);
  const dc_dep = config.dependencies.find(d => d.api_name === '/process_dc');
  console.log("process_dc index:", config.dependencies.indexOf(dc_dep));
}
run();
