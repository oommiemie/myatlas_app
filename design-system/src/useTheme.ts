import { useMemo } from 'react';
import { StyleSheet } from 'react-native';
import type { ImageStyle, TextStyle, ViewStyle } from 'react-native';
import { useThemeContext } from './ThemeProvider';
import { motion } from './theme';
import type { ColorScheme, Theme } from './theme';

/** ธีมทั้งก้อนของโหมดปัจจุบัน */
export function useTheme(): Theme {
  return useThemeContext().theme;
}

/** เฉพาะสี — ใช้บ่อยที่สุด */
export function useColors(): Theme['colors'] {
  return useThemeContext().theme.colors;
}

/** เงาที่ถูกต้องตามโหมด (โหมดมืดยกชั้นด้วยพื้นผิว ไม่ใช่เงา) */
export function useElevation(): Theme['elevation'] {
  return useThemeContext().theme.elevation;
}

/** สลับโหมดสว่าง/มืด */
export function useColorSchemeControl() {
  const { scheme, preference, setPreference } = useThemeContext();
  return { scheme, preference, setPreference };
}

type NamedStyles = Record<string, ViewStyle | TextStyle | ImageStyle>;

// แคชสไตล์ต่อ (factory, โหมด) เพื่อไม่ให้สร้าง StyleSheet ใหม่ทุกครั้งที่ re-render
const cache = new WeakMap<object, Partial<Record<ColorScheme, NamedStyles>>>();

/**
 * สร้างสไตล์จากธีม โดยจำผลไว้ต่อโหมด
 *
 *   const createStyles = (t: Theme) => ({ card: { backgroundColor: t.colors.surface.raised } });
 *   ...
 *   const styles = useStyles(createStyles);
 *
 * ประกาศ createStyles ไว้นอกคอมโพเนนต์เสมอ ไม่งั้นแคชจะไม่ทำงาน
 */
export function useStyles<T extends NamedStyles>(factory: (theme: Theme) => T): T {
  const { theme, scheme } = useThemeContext();
  return useMemo(() => {
    let byScheme = cache.get(factory);
    if (!byScheme) {
      byScheme = {};
      cache.set(factory, byScheme);
    }
    if (!byScheme[scheme]) {
      byScheme[scheme] = StyleSheet.create(factory(theme)) as NamedStyles;
    }
    return byScheme[scheme] as T;
  }, [factory, theme, scheme]);
}

/**
 * ค่า motion ที่เคารพการตั้งค่า "ลดการเคลื่อนไหว" ของผู้ใช้
 * เมื่อผู้ใช้เปิดไว้ ทุก duration จะกลายเป็น 0 และ spring จะแข็งขึ้นจนแทบไม่แกว่ง
 */
export interface SpringConfig {
  damping: number;
  stiffness: number;
  mass: number;
}

export interface MotionValues {
  duration: Record<keyof typeof motion.duration, number>;
  easing: typeof motion.easing;
  spring: Record<keyof typeof motion.spring, SpringConfig>;
  pattern: typeof motion.pattern;
  reduceMotion: boolean;
}

/** ไม่แกว่งเลย — ใช้แทน spring ทุกตัวเมื่อผู้ใช้ปิดการเคลื่อนไหว */
const STILL: SpringConfig = { damping: 100, stiffness: 1000, mass: 1 };

export function useMotion(): MotionValues {
  const { reduceMotion } = useThemeContext();
  return useMemo(() => {
    const duration = {} as Record<keyof typeof motion.duration, number>;
    for (const key of Object.keys(motion.duration) as (keyof typeof motion.duration)[]) {
      duration[key] = reduceMotion ? 0 : motion.duration[key];
    }
    const spring = {} as Record<keyof typeof motion.spring, SpringConfig>;
    for (const key of Object.keys(motion.spring) as (keyof typeof motion.spring)[]) {
      spring[key] = reduceMotion ? STILL : motion.spring[key];
    }
    return { duration, easing: motion.easing, spring, pattern: motion.pattern, reduceMotion };
  }, [reduceMotion]);
}
