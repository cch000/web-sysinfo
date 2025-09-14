const express = require("express");
const os = require("os");
const app = express();
const { promisify } = require('util');
const exec = promisify(require('child_process').exec)

app.use(express.json());

function pretty(n) {
  return Number(n.toPrecision(4))
}

app.get('/status', async (req, res) => {

  let output = await exec('systemctl is-system-running')
    .then(x => x.stdout.trim())
    .catch(y => (y.stdout || y.stderr).trim());

  let availmem = pretty(os.freemem() / (1024 * 1024 * 1024))

  let totalmem = pretty(os.totalmem() / (1024 * 1024 * 1024))

  let usedmem = pretty(totalmem - availmem)


  if (output == "running" || output == "degraded") {
    res.json({
      status: output,
      availmem: availmem,
      totalmem: totalmem,
      usedmem: usedmem,
      loadvg: os.loadavg()
    });
  } else {
    console.error("Error: " + output)
    res.status(500).send()
  }
});

const PORT = 8114;
app.listen(PORT, '0.0.0.0', () => {
});
