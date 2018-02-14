var CFClient = require("cloudflare");
var key = require("./cloudflareKey.js");

var client = new CFClient({
  email: "matt.romein@gmail.com",
  key: key
});

client.deleteCache("4f42ed840feeab07f328dac14c3f5693", {"purge_everything":true}).then(data => {
  if(data !== true){
    console.error("📛 cloudflare cache not cleared 📛");
  } else {
    console.log("🤓 cloudflare cache successfully cleared 🤓");
  }
});