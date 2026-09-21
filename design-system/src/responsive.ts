import { useMemo } from 'react';
import { useWindowDimensions } from 'react-native';
import { layout } from './theme';

/** ช่วงความกว้างหน้าจอ อิง window size class ของ Material 3 */
export type Breakpoint = 'compact' | 'medium' | 'expanded' | 'large';

const ORDER: Breakpoint[] = ['compact', 'medium', 'expanded', 'large'];

/** แปลงความกว้าง (dp) เป็นชื่อช่วง */
export function breakpointFor(width: number): Breakpoint {
  if (width >= layout.breakpoint.large) return 'large';
  if (width >= layout.breakpoint.expanded) return 'expanded';
  if (width >= layout.breakpoint.medium) return 'medium';
  return 'compact';
}

export interface ResponsiveInfo {
  width: number;
  height: number;
  breakpoint: Breakpoint;
  /** true ตั้งแต่แท็บเล็ตแนวตั้งขึ้นไป */
  isTablet: boolean;
  isLandscape: boolean;
  /** จำนวนคอลัมน์ของกริดในช่วงนี้ */
  columns: number;
  /** ระยะระหว่างคอลัมน์ */
  gutter: number;
  /** ขอบซ้ายขวาของหน้าจอ */
  margin: number;
}

export function useResponsive(): ResponsiveInfo {
  const { width, height } = useWindowDimensions();
  return useMemo(() => {
    const breakpoint = breakpointFor(width);
    const grid = layout.grid[breakpoint];
    return {
      width,
      height,
      breakpoint,
      isTablet: breakpoint !== 'compact',
      isLandscape: width > height,
      columns: grid.columns,
      gutter: grid.gutter,
      margin: grid.margin,
    };
  }, [width, height]);
}

export function useBreakpoint(): Breakpoint {
  return useResponsive().breakpoint;
}

/**
 * เลือกค่าตามช่วงหน้าจอ โดยไล่ลงหาช่วงที่เล็กกว่าถ้าช่วงปัจจุบันไม่ได้กำหนดไว้
 *
 *   const cols = useResponsiveValue({ compact: 1, medium: 2, expanded: 3 });
 */
export function useResponsiveValue<T>(
  values: Partial<Record<Breakpoint, T>> & { compact: T },
): T {
  const bp = useBreakpoint();
  const i = ORDER.indexOf(bp);
  for (let k = i; k >= 0; k--) {
    const v = values[ORDER[k]];
    if (v !== undefined) return v;
  }
  return values.compact;
}

/** ความกว้างของหนึ่งคอลัมน์ (รวมกรณีกินหลายคอลัมน์) */
export function useColumnWidth(span = 1): number {
  const { width, columns, gutter, margin } = useResponsive();
  const usable = width - margin * 2 - gutter * (columns - 1);
  const one = usable / columns;
  return one * span + gutter * (span - 1);
}
