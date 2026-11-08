// Підсумок покриття з coverage/lcov.info у docs/coverage.md.
// Запуск: node tools/coverage_summary.js
const fs = require('fs');

const records = fs.readFileSync('coverage/lcov.info', 'utf8').split('end_of_record');
const rows = [];
let totalFound = 0;
let totalHit = 0;

for (const record of records) {
  const file = record.match(/SF:(.+)/);
  if (!file) continue;
  let found = 0;
  let hit = 0;
  for (const line of record.split('\n')) {
    const da = line.match(/^DA:\d+,(\d+)/);
    if (da) {
      found++;
      if (Number(da[1]) > 0) hit++;
    }
  }
  const name = file[1].trim().replace(/\\/g, '/').replace(/^.*\/lib\//, 'lib/');
  rows.push([name, hit, found]);
  totalFound += found;
  totalHit += hit;
}
rows.sort((a, b) => a[0].localeCompare(b[0]));

const pct = (h, f) => (f ? ((h / f) * 100).toFixed(1) : '100.0');
let out = '# Покриття тестами\n\n';
out += 'Команди:\n\n```bash\ndart test --coverage=coverage\n';
out += 'dart run coverage:format_coverage --lcov --in=coverage --out=coverage/lcov.info --report-on=lib\n';
out += 'node tools/coverage_summary.js\n```\n\n';
out += '| Файл | Покрито рядків | Усього рядків | % |\n|---|---:|---:|---:|\n';
for (const [name, hit, found] of rows) {
  out += `| ${name} | ${hit} | ${found} | ${pct(hit, found)} |\n`;
}
out += `| **Разом** | **${totalHit}** | **${totalFound}** | **${pct(totalHit, totalFound)}** |\n`;
fs.writeFileSync('docs/coverage.md', out);
console.log(out);
