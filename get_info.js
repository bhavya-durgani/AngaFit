const fs = require('fs');
async function run() {
  const res = await fetch('https://levihsu-ootdiffusion.hf.space/info');
  const info = await res.json();
  console.log("Named Endpoints:");
  console.log(JSON.stringify(info.named_endpoints, (k,v) => k === 'parameters' || k === 'returns' ? undefined : v, 2));
  
  console.log("\nDependencies:");
  if (info.dependencies) {
    info.dependencies.forEach((dep, i) => {
      console.log(`${i}: api_name=${dep.api_name}, inputs=${dep.inputs.length}`);
    });
  }
}
run();
