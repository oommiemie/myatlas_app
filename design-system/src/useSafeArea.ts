/**
 * ระยะปลอดภัยของขอบจอ
 *
 * ตัวจริงควรใช้ react-native-safe-area-context แต่ design system ไม่ผูก dependency
 * จึงให้แอปเสียบ implementation เข้ามาตอนตั้งค่า
 *
 *   import { useSafeAreaInsets } from 'react-native-safe-area-context';
 *   setSafeAreaHook(useSafeAreaInsets);
 */
export interface SafeAreaInsets {
  top: number;
  bottom: number;
  left: number;
  right: number;
}

const ZERO: SafeAreaInsets = { top: 0, bottom: 0, left: 0, right: 0 };
let hook: () => SafeAreaInsets = () => ZERO;

export function setSafeAreaHook(next: () => SafeAreaInsets): void {
  hook = next;
}

export function useSafeArea(): SafeAreaInsets {
  return hook();
}
