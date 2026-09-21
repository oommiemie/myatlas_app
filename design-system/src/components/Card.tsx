import React from 'react';
import { View } from 'react-native';
import type { StyleProp, ViewProps, ViewStyle } from 'react-native';
import { useThemeContext } from '../ThemeProvider';
import type { ElevationLevel } from '../theme';
import { Press } from './Press';

export interface CardProps extends ViewProps {
  children?: React.ReactNode;
  /** ระดับความลอย — โหมดมืดจะยกด้วยความสว่างพื้นผิวให้อัตโนมัติ */
  elevation?: ElevationLevel;
  /** ใส่ padding มาตรฐานของการ์ด */
  padded?: boolean;
  /** กดได้ — จะได้ฟีดแบ็กย่อขนาดอัตโนมัติ */
  onPress?: () => void;
  style?: StyleProp<ViewStyle>;
}

export function Card({
  children,
  elevation = 'sm',
  padded = true,
  onPress,
  style,
  ...rest
}: CardProps) {
  const { theme, scheme } = useThemeContext();
  const base: ViewStyle = {
    backgroundColor:
      scheme === 'dark' && elevation !== 'none'
        ? surfaceForElevation(theme, elevation)
        : theme.colors.surface.raised,
    borderRadius: theme.radius.role.card,
    padding: padded ? theme.layout.inset.card : 0,
    ...(theme.elevation[elevation] as ViewStyle),
  };

  if (onPress) {
    return (
      <Press style={[base, style]} onPress={onPress} scale={0.98} {...rest}>
        {children}
      </Press>
    );
  }
  return (
    <View {...rest} style={[base, style]}>
      {children}
    </View>
  );
}

/** โหมดมืด: ยิ่งลอยสูง พื้นยิ่งสว่าง (แทนการใช้เงา) */
function surfaceForElevation(
  theme: ReturnType<typeof useThemeContext>['theme'],
  level: ElevationLevel,
): string {
  switch (level) {
    case 'xs':
    case 'sm':
      return theme.colors.surface.raised;
    case 'md':
      return theme.colors.surface.raisedAlt;
    case 'lg':
    case 'xl':
      return theme.colors.surface.overlay;
    default:
      return theme.colors.surface.base;
  }
}
