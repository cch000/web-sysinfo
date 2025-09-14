const express = require("express");
const os = require("os");
const app = express();
const { promisify } = require('util');
const exec = promisify(require('child_process').exec)

app.use(express.json());

app.get('/status', async (req, res) => {

  let output = exec('systemctl is-system-running').then(x => x.stdout).catch(
    x => console.error("Error: " + x.stderr)
  );

  let availmem = (os.freemem() / (1024 * 1024 * 1024))
    .toPrecision(4)

  let totalmem = (os.totalmem() / (1024 * 1024 * 1024))
    .toPrecision(4)

  let usedmem = (totalmem - availmem).toPrecision(4)

  res.json({
    status: output,
    availmem: Number(availmem),
    totalmem: Number(totalmem),
    usedmem: Number(usedmem),
    loadvg: os.loadavg()
  });
});

const PORT = 8114;
app.listen(PORT, '0.0.0.0', () => {
});
