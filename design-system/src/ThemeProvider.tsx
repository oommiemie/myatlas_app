import React, {
  createContext, useCallback, useContext, useEffect, useMemo, useState,
} from 'react';
import { AccessibilityInfo, useColorScheme } from 'react-native';
import { darkTheme, lightTheme } from './theme';
import type { ColorScheme, Theme } from './theme';

/** ผู้ใช้เลือกได้ 3 แบบ — ตามเครื่อง / สว่าง / มืด */
export type ThemePreference = 'system' | 'light' | 'dark';

/** ที่เก็บค่าที่ผู้ใช้เลือก เสียบ AsyncStorage หรือ MMKV เข้ามาก็ได้ */
export interface ThemeStorage {
  getItem(key: string): Promise<string | null>;
  setItem(key: string, value: string): Promise<void>;
}

const STORAGE_KEY = 'myatlas.theme.preference';

export interface ThemeContextValue {
  theme: Theme;
  scheme: ColorScheme;
  preference: ThemePreference;
  setPreference(next: ThemePreference): void;
  /** true เมื่อผู้ใช้เปิด "ลดการเคลื่อนไหว" ในการตั้งค่าเครื่อง */
  reduceMotion: boolean;
}

const ThemeContext = createContext<ThemeContextValue | null>(null);

export interface ThemeProviderProps {
  children: React.ReactNode;
  /** ค่าเริ่มต้นก่อนอ่านจาก storage */
  initialPreference?: ThemePreference;
  storage?: ThemeStorage;
}

export function ThemeProvider({
  children,
  initialPreference = 'system',
  storage,
}: ThemeProviderProps) {
  const systemScheme = useColorScheme();
  const [preference, setPreferenceState] = useState<ThemePreference>(initialPreference);
  const [reduceMotion, setReduceMotion] = useState(false);

  // คืนค่าที่ผู้ใช้เคยเลือกไว้
  useEffect(() => {
    if (!storage) return;
    let alive = true;
    storage.getItem(STORAGE_KEY).then((saved) => {
      if (alive && (saved === 'system' || saved === 'light' || saved === 'dark')) {
        setPreferenceState(saved);
      }
    });
    return () => {
      alive = false;
    };
  }, [storage]);

  // ติดตามการตั้งค่า "ลดการเคลื่อนไหว" ของระบบ (ข้อกำหนด WCAG 2.2 — 2.3.3)
  useEffect(() => {
    let alive = true;
    AccessibilityInfo.isReduceMotionEnabled().then((on) => {
      if (alive) setReduceMotion(on);
    });
    const sub = AccessibilityInfo.addEventListener('reduceMotionChanged', setReduceMotion);
    return () => {
      alive = false;
      sub.remove();
    };
  }, []);

  const setPreference = useCallback(
    (next: ThemePreference) => {
      setPreferenceState(next);
      void storage?.setItem(STORAGE_KEY, next);
    },
    [storage],
  );

  const scheme: ColorScheme =
    preference === 'system' ? (systemScheme === 'dark' ? 'dark' : 'light') : preference;

  const value = useMemo<ThemeContextValue>(
    () => ({
      theme: scheme === 'dark' ? darkTheme : lightTheme,
      scheme,
      preference,
      setPreference,
      reduceMotion,
    }),
    [scheme, preference, setPreference, reduceMotion],
  );

  return <ThemeContext.Provider value={value}>{children}</ThemeContext.Provider>;
}

export function useThemeContext(): ThemeContextValue {
  const ctx = useContext(ThemeContext);
  if (!ctx) throw new Error('ต้องครอบด้วย <ThemeProvider> ก่อนใช้ hook ของธีม');
  return ctx;
}
