// Генерує UML-діаграму класів (docs/uml.svg і docs/uml.png) за описом нижче.
const fs = require('fs');
const { Resvg } = require('C:/Users/x333u_2hrn6gs/AppData/Local/UlyanaAI/bridge/node_modules/@resvg/resvg-js');

const esc = (s) => s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;');
const classes = {
  Person: { x: 330, y: 30, w: 340, abstract: true,
    fields: ['+id: String', '+firstName: String', '+lastName: String', '+birthDate: DateTime'],
    methods: ['+fullName: String', '+age: int', '+ageOn(date): int', '+role: String {abstract}'] },
  Student: { x: 30, y: 300, w: 340,
    fields: ['+enrollmentYear: int', '+enrolledCourses: List<String>', '+grades: Map<String,double>', '+skills: Set<String>'],
    methods: ['+gpa: double', '+enrollInCourse(id)', '+addGrade(id, grade)', '+getPassedCourses()', '+toJson() / fromJson()'] },
  Professor: { x: 630, y: 300, w: 340,
    fields: ['+department: String', '+taughtCourses: List<String>', '+salary: double'],
    methods: ['+role => "Professor"', '+assignCourse(id)', '+countStudents(students)'] },
  Course: { x: 30, y: 660, w: 340,
    fields: ['+id, name, description: String', '+credits: int', '+instructor: String', '+prerequisites: List<String>'],
    methods: ['+hasPrerequisites(): bool', '+canStudentEnroll(student): bool'] },
  University: { x: 630, y: 620, w: 340,
    fields: ['+name: String', '+students: List<Student>', '+professors: List<Professor>', '+courses: List<Course>'],
    methods: ['+addStudent / removeStudent', '+findStudentById(id)', '+getStudentsByCourse(id)', '+getAvailableCoursesForStudent(id)', '+enroll(studentId, courseId)', '+generateStatistics()'] },
};
const LH = 22, HEAD = 40;
let body = '';
for (const [name, c] of Object.entries(classes)) {
  c.h = HEAD + c.fields.length * LH + 14 + c.methods.length * LH + 10;
  c.sepY = c.y + HEAD + c.fields.length * LH + 7;
  body += `<rect x="${c.x}" y="${c.y}" width="${c.w}" height="${c.h}" fill="#fff" stroke="#2b5d8a" stroke-width="2"/>`;
  body += `<rect x="${c.x}" y="${c.y}" width="${c.w}" height="${HEAD}" fill="#dbe9f6" stroke="#2b5d8a" stroke-width="2"/>`;
  body += `<text x="${c.x + c.w / 2}" y="${c.y + 26}" text-anchor="middle" font-family="Segoe UI, Arial" font-size="18" font-weight="bold" ${c.abstract ? 'font-style="italic"' : ''}>${esc((c.abstract ? '«abstract» ' : '') + name)}</text>`;
  c.fields.forEach((f, i) => body += `<text x="${c.x + 12}" y="${c.y + HEAD + 18 + i * LH}" font-family="Consolas, monospace" font-size="14">${esc(f)}</text>`);
  body += `<line x1="${c.x}" y1="${c.sepY}" x2="${c.x + c.w}" y2="${c.sepY}" stroke="#2b5d8a"/>`;
  c.methods.forEach((m, i) => body += `<text x="${c.x + 12}" y="${c.sepY + 20 + i * LH}" font-family="Consolas, monospace" font-size="14">${esc(m)}</text>`);
}
const cx = (n) => classes[n].x + classes[n].w / 2;
const bottom = (n) => classes[n].y + classes[n].h;
// Спадкування: порожній трикутник від Student/Professor до Person.
const inh = (from) => {
  const x1 = cx(from), y1 = classes[from].y, y2 = bottom('Person'), x2 = cx('Person');
  const midY = (y1 + y2) / 2 + 15;
  return `<polyline points="${x1},${y1} ${x1},${midY} ${x2},${midY} ${x2},${y2 + 14}" fill="none" stroke="#2b5d8a" stroke-width="2"/>` +
    `<polygon points="${x2},${y2} ${x2 - 10},${y2 + 16} ${x2 + 10},${y2 + 16}" fill="#fff" stroke="#2b5d8a" stroke-width="2"/>`;
};
body += inh('Student') + inh('Professor');
// Композиція/агрегація University -> Student, Professor, Course.
const line = (x1, y1, x2, y2, label) =>
  `<line x1="${x1}" y1="${y1}" x2="${x2}" y2="${y2}" stroke="#7a4d12" stroke-width="2"/><text x="${(x1 + x2) / 2 + 6}" y="${(y1 + y2) / 2 - 6}" font-family="Segoe UI" font-size="13" fill="#7a4d12">${label}</text>`;
const u = classes.University;
body += line(u.x, u.y + 60, classes.Student.x + classes.Student.w, classes.Student.y + classes.Student.h - 40, '0..* students');
body += line(u.x + u.w / 2, u.y, cx('Professor'), bottom('Professor'), '0..* professors');
body += line(u.x, u.y + 150, classes.Course.x + classes.Course.w, classes.Course.y + 60, '0..* courses');
body += line(classes.Course.x + 120, classes.Course.y, classes.Student.x + 120, bottom('Student'), 'canStudentEnroll');

const W = 1000, H = 940;
const svg = `<svg xmlns="http://www.w3.org/2000/svg" width="${W}" height="${H}"><rect width="${W}" height="${H}" fill="#fafafa"/>
<text x="500" y="22" text-anchor="middle" font-family="Segoe UI" font-size="16" fill="#333">UML: діаграма класів університету (lib/models)</text>${body}</svg>`;
fs.writeFileSync('docs/uml.svg', svg);
fs.writeFileSync('docs/uml.png', new Resvg(svg, { font: { loadSystemFonts: true } }).render().asPng());
console.log('ok docs/uml.svg docs/uml.png');
