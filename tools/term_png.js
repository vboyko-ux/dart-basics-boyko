// Перетворює РЕАЛЬНИЙ текстовий вивід програми (збережений у .txt) на PNG у стилі терміналу.
// Довгий вивід розбивається на сторінки. Використання:
//   node tools/term_png.js <in.txt> <out_prefix> "<заголовок>" [рядків_на_сторінку]
// Результат: <out_prefix>.png або <out_prefix>_1.png, <out_prefix>_2.png ...
const fs = require('fs');
const path = require('path');

// @resvg/resvg-js встановлено в оточенні Ulyana Tools, а не в цьому проєкті.
const { Resvg } = require(
  'C:/Users/x333u_2hrn6gs/AppData/Local/UlyanaAI/bridge/node_modules/@resvg/resvg-js',
);

const [, , input, prefix, title = 'Terminal', perPageArg = '40'] = process.argv;
const perPage = Number(perPageArg);
const esc = (s) => s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');

const lines = fs
  .readFileSync(input, 'utf8')
  .replace(/\x1b\[[0-9;]*m/g, '')
  .split(/\r?\n/)
  .map((l) => l.replace(/\t/g, '    '))
  .map((l) => (l.length > 140 ? l.slice(0, 137) + '...' : l));
while (lines.length && !lines[lines.length - 1].trim()) lines.pop();

const pages = [];
for (let i = 0; i < lines.length; i += perPage) pages.push(lines.slice(i, i + perPage));

const color = (l) =>
  /^(===|---)/.test(l) || /^\[\d\]/.test(l)
    ? '#7fd1ff'
    : /помилк|Відмова|ERROR|Exception/i.test(l)
      ? '#ffb86c'
      : '#e6e6e6';

pages.forEach((page, p) => {
  const lh = 21;
  const W = 1500;
  const H = 62 + page.length * lh + 18;
  const label = pages.length > 1 ? `${title}  (${p + 1}/${pages.length})` : title;
  const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="${W}" height="${H}">
<rect width="${W}" height="${H}" fill="#1e1e1e"/>
<rect width="${W}" height="36" fill="#333"/>
<circle cx="20" cy="18" r="6" fill="#ff5f56"/><circle cx="40" cy="18" r="6" fill="#ffbd2e"/><circle cx="60" cy="18" r="6" fill="#27c93f"/>
<text x="85" y="23" fill="#ccc" font-family="Segoe UI, Arial" font-size="15">${esc(label)}</text>
${page
  .map(
    (l, i) =>
      `<text x="14" y="${62 + i * lh}" fill="${color(l)}" font-family="Consolas, monospace" font-size="15" xml:space="preserve">${esc(l)}</text>`,
  )
  .join('\n')}
</svg>`;
  const out = pages.length > 1 ? `${prefix}_${p + 1}.png` : `${prefix}.png`;
  fs.mkdirSync(path.dirname(out), { recursive: true });
  fs.writeFileSync(out, new Resvg(svg, { font: { loadSystemFonts: true } }).render().asPng());
  console.log('ok', out, page.length, 'рядків');
});
