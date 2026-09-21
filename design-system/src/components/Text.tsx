import React from 'react';
import { Text as RNText } from 'react-native';
import type { TextProps as RNTextProps, TextStyle } from 'react-native';
import { useThemeContext } from '../ThemeProvider';
import type { TypographyRole } from '../theme';

export interface TextProps extends RNTextProps {
  /** บทบาทตัวอักษรจากระบบ เช่น 'title_md' 'body_md' 'caption' */
  variant?: TypographyRole;
  /** สีจากชุด text ของธีม */
  tone?: keyof ReturnType<typeof useTextTones>;
  children?: React.ReactNode;
}

function useTextTones() {
  return useThemeContext().theme.colors.text;
}

/**
 * ตัวอักษรที่ผูกกับโทเคนเสมอ — ห้ามใส่ fontSize/fontFamily เองในแอป
 * ถ้าต้องการขนาดใหม่ ให้เพิ่ม role ใน tokens/typography.json แทน
 */
export function Text({ variant = 'body_md', tone = 'primary', style, ...rest }: TextProps) {
  const { theme } = useThemeContext();
  const base = theme.typography[variant] as TextStyle;
  return <RNText {...rest} style={[base, { color: theme.colors.text[tone] }, style]} />;
}
