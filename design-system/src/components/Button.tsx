import React from 'react';
import { ActivityIndicator, View } from 'react-native';
import type { StyleProp, TextStyle, ViewStyle } from 'react-native';
import { useThemeContext } from '../ThemeProvider';
import { Press } from './Press';
import { Text } from './Text';

export type ButtonVariant = 'primary' | 'secondary' | 'ghost' | 'destructive';
export type ButtonSize = 'sm' | 'md' | 'lg';

export interface ButtonProps {
  label: string;
  onPress?: () => void;
  variant?: ButtonVariant;
  size?: ButtonSize;
  disabled?: boolean;
  loading?: boolean;
  /** เต็มความกว้างของแม่ */
  block?: boolean;
  /** ไอคอนหน้า/หลังข้อความ ส่งเป็น element มาได้เลย */
  leading?: React.ReactNode;
  trailing?: React.ReactNode;
  style?: StyleProp<ViewStyle>;
  testID?: string;
}

const HEIGHT: Record<ButtonSize, 'sm' | 'md' | 'lg'> = { sm: 'sm', md: 'md', lg: 'lg' };

export function Button({
  label,
  onPress,
  variant = 'primary',
  size = 'lg',
  disabled = false,
  loading = false,
  block = false,
  leading,
  trailing,
  style,
  testID,
}: ButtonProps) {
  const { theme } = useThemeContext();
  const c = theme.colors;
  const inactive = disabled || loading;

  const skin: Record<ButtonVariant, { bg: string; fg: string; border?: string }> = {
    primary: { bg: c.action.primaryBg, fg: c.action.primaryFg },
    secondary: { bg: c.action.secondaryBg, fg: c.action.secondaryFg },
    ghost: { bg: 'transparent', fg: c.action.ghostFg },
    destructive: { bg: c.action.destructiveBg, fg: c.action.destructiveFg },
  };
  const { bg, fg } = skin[variant];

  const container: ViewStyle = {
    height: theme.size.control[HEIGHT[size]],
    minWidth: theme.size.touchTarget.min,
    paddingHorizontal: size === 'sm' ? theme.space['12'] : theme.space['20'],
    borderRadius: theme.radius.role.button,
    backgroundColor: inactive && variant !== 'ghost' ? c.action.primaryDisabled : bg,
    alignItems: 'center',
    justifyContent: 'center',
    flexDirection: 'row',
    alignSelf: block ? 'stretch' : 'flex-start',
    // เงาย้อมสีเฉพาะปุ่มหลักที่ยังกดได้
    ...(variant === 'primary' && !inactive ? (theme.elevationTinted.brand as ViewStyle) : {}),
  };

  const labelStyle: TextStyle = {
    ...theme.typography.button,
    color: inactive ? c.text.disabled : fg,
  };

  return (
    <Press
      testID={testID}
      style={[container, style]}
      onPress={inactive ? undefined : onPress}
      disabled={inactive}
      scale={0.97}
      accessibilityState={{ disabled: inactive, busy: loading }}
      accessibilityLabel={label}
    >
      {loading ? (
        <ActivityIndicator color={fg} size="small" />
      ) : (
        <>
          {leading ? <View style={{ marginRight: theme.space['8'] }}>{leading}</View> : null}
          <Text style={labelStyle}>{label}</Text>
          {trailing ? <View style={{ marginLeft: theme.space['8'] }}>{trailing}</View> : null}
        </>
      )}
    </Press>
  );
}
