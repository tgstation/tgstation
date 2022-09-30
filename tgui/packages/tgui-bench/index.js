/**
 * @file
 * @copyright 2021 Aleksej Komarov
 * @license MIT
 */

const fs = require('fs');
const path = require('path');
const { exec } = require('child_process');
const { fastify } = require('fastify');

process.chdir(__dirname);

const sleep = (time) => new Promise((resolve) => setTimeout(resolve, time));

const IE_TIMEOUT_SECONDS = 60;

const setup = async () => {
  const server = fastify();

  let hasResponded = false;

  let assets = '';
  assets += `<script>\n`;
  assets += `Byond.loadJs('tgui-bench.bundle.js');\n`;
  assets += `Byond.loadCss('tgui-bench.bundle.css');\n`;
  assets += `</script>\n`;

  const publicDir = path.resolve(__dirname, '../../public');
  const page = fs.readFileSync(path.join(publicDir, 'tgui.html'), 'utf-8')
    .replace('<!-- tgui:assets -->\n', assets);

  server.register(require('fastify-static'), {
    root: publicDir,
  });

  server.get('/', async (req, res) => {
    return res.type('text/html').send(page);
  });

  server.post('/message', async (req, res) => {
    if (!hasResponded) {
      process.stdout.write('\n');
      hasResponded = true;
    }
    const { type, ...rest } = req.body;
    if (type === 'suite-start') {
      console.log(`=> Test '${rest.file}'`);
      return res.send();
    }
    if (type === 'suite-cycle') {
      console.log(rest.message);
      return res.send();
    }
    if (type === 'suite-complete') {
      console.log(rest.message);
      return res.send();
    }
    if (type === 'finished') {
      await res.send();
      process.exit(0);
    }
    // Unhandled message
    console.log(req.body);
    return res.send();
  });

  try {
    await server.listen(3002, '0.0.0.0');
  }
  catch (err) {
    console.error(err);
    process.exit(1);
  }

  if (process.platform === 'win32') {
    exec(`start "" "iexplore" "http://127.0.0.1:3002"`);
  }

  console.log('Waiting for Internet Explorer to respond.');
  for (let i = 0; i < IE_TIMEOUT_SECONDS; i++) {
    await sleep(1000);
    if (hasResponded) {
      return;
    }
    process.stdout.write('.');
  }
  process.stdout.write('\n');
  console.error('Did not receive a response, exiting.');
  process.exit(1);
};

setup();
