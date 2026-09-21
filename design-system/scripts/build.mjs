/**
 * MyAtlas design tokens → React Native theme.
 *
 * อ่านไฟล์ token ทั้งหมดใน tokens/ แก้ reference แบบ {group.key} ให้เป็นค่าจริง
 * แล้วเขียนออกเป็น src/theme.ts (ใช้ใน RN) และ dist/tokens.resolved.json (ใช้ import เข้า Figma)
 *
 * ไม่มี dependency — รันด้วย `node scripts/build.mjs`
 */
import { readFileSync, writeFileSync, readdirSync, mkdirSync } from 'node:fs';
import { join, dirname } from 'node:path';
import { fileURLToPath } from 'node:url';

const root = join(dirname(fileURLToPath(import.meta.url)), '..');
const TOKENS = join(root, 'tokens');

// ── โหลดและรวมทุกไฟล์ ───────────────────────────────────────────────────────
const raw = {};
for (const f of readdirSync(TOKENS).filter((f) => f.endsWith('.json'))) {
  const doc = JSON.parse(readFileSync(join(TOKENS, f), 'utf8'));
  for (const [k, v] of Object.entries(doc)) {
    if (k.startsWith('$')) continue;
    raw[k] = k in raw ? deepMerge(raw[k], v) : v;
  }
}
function deepMerge(a, b) {
  const out = { ...a };
  for (const [k, v] of Object.entries(b)) {
    out[k] = k in out && isObj(out[k]) && isObj(v) ? deepMerge(out[k], v) : v;
  }
  return out;
}
const isObj = (v) => v && typeof v === 'object' && !Array.isArray(v);

// ── แก้ reference ───────────────────────────────────────────────────────────
function lookup(path) {
  let node = raw;
  for (const part of path.split('.')) {
    if (!isObj(node) || !(part in node)) throw new Error(`ไม่พบโทเคน: ${path}`);
    node = node[part];
  }
  if (!isObj(node) || !('$value' in node)) throw new Error(`โทเคนไม่มี $value: ${path}`);
  return node.$value;
}
function resolve(value, depth = 0) {
  if (depth > 12) throw new Error('reference วนซ้ำ');
  if (typeof value === 'string') {
    const m = /^\{([^}]+)\}$/.exec(value);
    return m ? resolve(lookup(m[1]), depth + 1) : value;
  }
  if (Array.isArray(value)) return value.map((v) => resolve(v, depth + 1));
  if (isObj(value)) {
    return Object.fromEntries(Object.entries(value).map(([k, v]) => [k, resolve(v, depth + 1)]));
  }
  return value;
}

/** เดินทั้งต้นไม้ คืนเฉพาะ $value ที่แก้ reference แล้ว */
function flatten(node) {
  if (isObj(node) && '$value' in node) return resolve(node.$value);
  if (isObj(node)) {
    const out = {};
    for (const [k, v] of Object.entries(node)) {
      if (k.startsWith('$')) continue;
      out[k] = flatten(v);
    }
    return out;
  }
  return node;
}

const T = flatten(raw);

// ── ตัวช่วยเขียน TS ─────────────────────────────────────────────────────────
const s = (v) => JSON.stringify(v, null, 2).replace(/"([A-Za-z_$][\w$]*)":/g, '$1:');
const banner = `/**
 * ไฟล์นี้สร้างอัตโนมัติจาก design-system/tokens — ห้ามแก้ด้วยมือ
 * แก้ที่ tokens/*.json แล้วรัน: node scripts/build.mjs
 * สร้างเมื่อ ${new Date().toISOString().slice(0, 10)}
 */
import { Platform } from 'react-native';
import type { TextStyle, ViewStyle } from 'react-native';
`;

// ── typography → TextStyle ──────────────────────────────────────────────────
function walkTypography(node, prefix = [], out = {}) {
  for (const [k, v] of Object.entries(node)) {
    if (!isObj(v)) continue;
    // โทเคนหนึ่งตัวอาจเป็นทั้งค่าและกลุ่มแม่ (เช่น caption กับ caption.sm) จึงต้องทำทั้งสองอย่าง
    if (isObj(v.$value) && 'fontSize' in v.$value) out[[...prefix, k].join('.')] = v;
    walkTypography(v, [...prefix, k], out);
  }
  return out;
}
const typoRaw = walkTypography(raw.typography);
const typography = {};
for (const [name, node] of Object.entries(typoRaw)) {
  const v = resolve(node.$value);
  const face = node.$extensions?.['com.myatlas']?.androidFontFace ?? 'IBMPlexSansThaiLooped-Regular';
  typography[name.replace(/\./g, '_')] = {
    fontFamily: { __platform: ['IBMPlexSansThaiLooped', face] },
    fontWeight: String(v.fontWeight),
    fontSize: v.fontSize,
    lineHeight: v.lineHeight,
    letterSpacing: v.letterSpacing,
    includeFontPadding: false,
  };
}
const typographyTs = Object.entries(typography)
  .map(([k, v]) => {
    const [ios, android] = v.fontFamily.__platform;
    return `  '${k}': {
    fontFamily: Platform.select({ ios: '${ios}', android: '${android}', default: '${ios}' }),
    fontWeight: '${v.fontWeight}',
    fontSize: ${v.fontSize},
    lineHeight: ${v.lineHeight},
    letterSpacing: ${v.letterSpacing},
    includeFontPadding: false,
  }`;
  })
  .join(',\n');

// ── elevation → ViewStyle ───────────────────────────────────────────────────
function elevationTs(group) {
  return Object.entries(group)
    .map(([name, v]) => {
      const ios = v.ios ?? {};
      const android = v.android ?? {};
      const iosStyle = {
        shadowColor: ios.shadowColor ?? 'transparent',
        shadowOffset: ios.shadowOffset ?? { width: 0, height: 0 },
        shadowOpacity: ios.shadowOpacity ?? 0,
        shadowRadius: ios.shadowRadius ?? 0,
      };
      const androidStyle = {
        elevation: android.elevation ?? 0,
        ...(android.shadowColor ? { shadowColor: android.shadowColor } : {}),
      };
      const surface = v.surface ? `\n    // โหมดมืดยกชั้นด้วยพื้นผิว: ${v.surface}` : '';
      return `  ${JSON.stringify(name)}: Platform.select({
    ios: ${s(iosStyle).replace(/\n/g, '\n    ')},
    android: ${s(androidStyle).replace(/\n/g, '\n    ')},
    default: {},
  }) as ViewStyle,${surface}`;
    })
    .join('\n');
}

// ── เขียนไฟล์ ───────────────────────────────────────────────────────────────
const out = `${banner}
// ─── Primitives ─────────────────────────────────────────────────────────────
export const palette = ${s(Object.fromEntries(Object.entries(T.color).filter(([k]) => !['semantic', 'accent', 'medicine'].includes(k))))} as const;

// ─── Semantic colours ───────────────────────────────────────────────────────
/** โครงของชุดสี — light กับ dark มีคีย์เหมือนกันเป๊ะ ต่างแค่ค่า */
export interface ColorTokens {
${Object.entries(T.color.semantic.light)
  .map(([group, entries]) =>
    `  ${group}: {\n` +
    Object.keys(entries).map((k) => `    ${k}: string;`).join('\n') +
    `\n  };`)
  .join('\n')}
}

export const lightColors: ColorTokens = ${s(T.color.semantic.light)};
export const darkColors: ColorTokens = ${s(T.color.semantic.dark)};
export const accent = ${s(T.color.accent)} as const;
export const medicineColors = ${s(T.color.medicine)} as const;

// ─── Layout ─────────────────────────────────────────────────────────────────
export const space = ${s(T.space)} as const;
export const layout = ${s(T.layout)} as const;
export const size = ${s(T.size)} as const;
export const zIndex = ${s(T.zIndex)} as const;

// ─── Shape ──────────────────────────────────────────────────────────────────
export const radius = ${s(T.radius)} as const;
export const borderWidth = ${s(T.borderWidth)} as const;

// ─── Typography ─────────────────────────────────────────────────────────────
export const fontFamily = ${s(T.font.family)} as const;
export const fontWeight = ${s(T.font.weight)} as const;
export const fontSize = ${s(T.font.size)} as const;

export const typography = {
${typographyTs},
} satisfies Record<string, TextStyle>;

// ─── Elevation ──────────────────────────────────────────────────────────────
export const elevationLight = {
${elevationTs(T.elevation.light)}
};

export const elevationDark = {
${elevationTs(T.elevation.dark)}
};

export const elevationTinted = {
${elevationTs(T.elevation.tinted)}
};

// ─── Motion ─────────────────────────────────────────────────────────────────
export const motion = ${s(T.motion)} as const;

// ─── Themes ─────────────────────────────────────────────────────────────────
const shared = {
  palette, accent, medicineColors, space, layout, size, zIndex,
  radius, borderWidth, fontFamily, fontWeight, fontSize, typography, motion,
} as const;

export type ColorScheme = 'light' | 'dark';
export type ElevationLevel = keyof typeof elevationLight;

export type Theme = {
  scheme: ColorScheme;
  colors: ColorTokens;
  elevation: Record<ElevationLevel, ViewStyle>;
  elevationTinted: typeof elevationTinted;
} & typeof shared;

export const lightTheme: Theme = {
  scheme: 'light', colors: lightColors, elevation: elevationLight, elevationTinted, ...shared,
};
export const darkTheme: Theme = {
  scheme: 'dark', colors: darkColors, elevation: elevationDark, elevationTinted, ...shared,
};

export const themes: Record<ColorScheme, Theme> = { light: lightTheme, dark: darkTheme };

export type TypographyRole = keyof typeof typography;
export type SpaceToken = keyof typeof space;
export type RadiusToken = keyof typeof radius;
`;

mkdirSync(join(root, 'src'), { recursive: true });
mkdirSync(join(root, 'dist'), { recursive: true });
writeFileSync(join(root, 'src/theme.ts'), out);
writeFileSync(join(root, 'dist/tokens.resolved.json'), JSON.stringify(T, null, 2));

const count = (o) => (isObj(o) ? Object.values(o).reduce((n, v) => n + count(v), 0) : 1);
console.log(`src/theme.ts               ${out.split('\n').length} บรรทัด`);
console.log(`dist/tokens.resolved.json  ${count(T)} ค่า`);
console.log(`typography roles           ${Object.keys(typography).length}`);
