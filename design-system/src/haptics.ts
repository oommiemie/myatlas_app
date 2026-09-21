/**
 * แรงสั่นตอบสนอง — เสียบ implementation จริงเข้ามาเองตอนตั้งค่าแอป
 * เพื่อไม่ให้ design system ผูกกับ expo-haptics หรือ library ตัวใดตัวหนึ่ง
 *
 *   import * as Haptics from 'expo-haptics';
 *   setHapticsImpl({
 *     selection: () => Haptics.selectionAsync(),
 *     impact: (s) => Haptics.impactAsync(map[s]),
 *     notify: (t) => Haptics.notificationAsync(map[t]),
 *   });
 */
export type HapticStrength = 'light' | 'medium' | 'heavy';
export type HapticNotice = 'success' | 'warning' | 'error';

export interface HapticsImpl {
  selection(): void;
  impact(strength: HapticStrength): void;
  notify(type: HapticNotice): void;
}

const noop: HapticsImpl = { selection() {}, impact() {}, notify() {} };
let impl: HapticsImpl = noop;

export function setHapticsImpl(next: HapticsImpl): void {
  impl = next;
}

export const haptics: HapticsImpl = {
  selection: () => impl.selection(),
  impact: (s) => impl.impact(s),
  notify: (t) => impl.notify(t),
};
