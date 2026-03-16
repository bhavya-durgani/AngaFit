const fs = require('fs');
async function run() {
  const res = await fetch('https://levihsu-ootdiffusion.hf.space/config');
  const config = await res.json();
  config.dependencies.forEach((d, i) => console.log(i, d.api_name, d.id, d.inputs.length));
}
run();
