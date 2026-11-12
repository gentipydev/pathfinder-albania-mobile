// Regenerates the Pathfinder Albania icon and splash rasters from
// assets/images/_common/app-logo.svg (the single source of the mark).
//
//   mkdir -p /tmp/pf-logo && cd /tmp/pf-logo && npm i @resvg/resvg-js@2.6.2
//   node <repo>/assets/marketing/render_logo.mjs <repo>/assets/images/_common/app-logo.svg /tmp/pf-logo
//   then copy app-icon-*.png, app-logo*.png into assets/marketing/ and
//   pathfinder-icon.png into assets/images/widget/, and run
//   dart run icons_launcher:create && dart run flutter_native_splash:create
//
// preview-*.png files are review images only; they are not used by the app.
import { readFileSync, writeFileSync } from 'node:fs';
import { Resvg } from '@resvg/resvg-js';

const [,, svgPath, outDir] = process.argv;
const src = readFileSync(svgPath, 'utf8');
// Everything between <defs> and </svg>: the mask + star + peaks.
const inner = src.slice(src.indexOf('<defs>'), src.lastIndexOf('</svg>'));
// Mark bounding box in the 1024 source space (star top y=100 .. base y=800).
const BBOX = { x: 96, y: 105, w: 832, h: 695 };

const OFFWHITE = '#F8ECE5', TERRACOTTA = '#E4935D';

function mark({ markWidth, canvas, dx = 0, dy = 0, mono = null }) {
  const s = markWidth / BBOX.w;
  const tx = canvas / 2 - (BBOX.x + BBOX.w / 2) * s + dx;
  const ty = canvas / 2 - (BBOX.y + BBOX.h / 2) * s + dy;
  let body = inner;
  if (mono) body = body.replaceAll(TERRACOTTA, mono).replaceAll(OFFWHITE, mono);
  return `<g transform="translate(${tx.toFixed(2)} ${ty.toFixed(2)}) scale(${s.toFixed(5)})">${body}</g>`;
}

function svg(size, children, { height = size } = {}) {
  return `<svg xmlns="http://www.w3.org/2000/svg" width="${size}" height="${height}" viewBox="0 0 ${size} ${height}">${children}</svg>`;
}

function png(svgText, width, file) {
  const r = new Resvg(svgText, { fitTo: { mode: 'width', value: width } });
  const data = r.render().asPng();
  writeFileSync(`${outDir}/${file}`, data);
  console.log(file.padEnd(32), `${width}px`, `${(data.length / 1024).toFixed(0)} KB`);
}

const gradient = `<defs><linearGradient id="bg" x1="0" y1="0" x2="1" y2="1"><stop offset="0" stop-color="#34302C"/><stop offset="1" stop-color="#19171A"/></linearGradient></defs><rect width="1024" height="1024" fill="url(#bg)"/>`;

// 1. App icon (iOS/macOS/Android legacy/web): gradient tile, mark at 68 %.
const icon = svg(1024, gradient + mark({ markWidth: 696, canvas: 1024, dy: 10 }));
png(icon, 1024, 'app-icon-1024.png');
png(icon, 512, 'app-icon-512.png');
png(icon, 192, 'preview-icon-192.png');
png(icon, 48, 'preview-icon-48.png');

// 2. Android adaptive foreground (safe zone = central 66 %) + monochrome.
png(svg(1024, mark({ markWidth: 640, canvas: 1024, dy: 10 })), 1024, 'app-icon-adaptive-fg.png');
png(svg(1024, mark({ markWidth: 640, canvas: 1024, dy: 10, mono: '#FFFFFF' })), 1024, 'app-icon-monochrome.png');

// 3. Native splash mark (4x density, same 736 px footprint as before) and Android 12.
const SPLASH_W = 736, SPLASH_H = 620;
png(svg(SPLASH_W, mark({ markWidth: 736, canvas: SPLASH_W, dy: (SPLASH_H - SPLASH_W) / 2 }), { height: SPLASH_H }), SPLASH_W, 'app-logo.png');
png(svg(1152, mark({ markWidth: 580, canvas: 1152 })), 1152, 'app-logo-android12.png');

// 4. iOS home-screen widget icon (single colour, off-white).
png(svg(240, mark({ markWidth: 220, canvas: 240, mono: OFFWHITE })), 240, 'pathfinder-icon.png');

// 5. Previews for the review gate.
png(svg(1024, `<rect width="1024" height="1024" fill="#272625"/>` + mark({ markWidth: 560, canvas: 1024 })), 512, 'preview-splash.png');
png(svg(1024, `<rect width="1024" height="1024" fill="#1E1B18"/>` + mark({ markWidth: 760, canvas: 1024 })), 640, 'preview-mark-dark.png');
png(svg(1024, `<rect width="1024" height="1024" fill="#F8ECE5"/>` + mark({ markWidth: 760, canvas: 1024, mono: '#1E1B18' })), 320, 'preview-mark-mono-light.png');
