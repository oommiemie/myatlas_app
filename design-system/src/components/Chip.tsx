import React from 'react';
import type { StyleProp, ViewStyle } from 'react-native';
import { useThemeContext } from '../ThemeProvider';
import { Press } from './Press';
import { Text } from './Text';

export interface ChipProps {
  label: string;
  selected?: boolean;
  onPress?: () => void;
  /** ชิปบอกสถานะ จะใช้ชุดสี status แทนสีแบรนด์ */
  tone?: 'neutral' | 'brand' | 'success' | 'warning' | 'error' | 'info';
  leading?: React.ReactNode;
  style?: StyleProp<ViewStyle>;
}

export function Chip({ label, selected = false, onPress, tone = 'neutral', leading, style }: ChipProps) {
  const { theme } = useThemeContext();
  const c = theme.colors;

  const toneMap = {
    neutral: { bg: c.surface.sunken, fg: c.text.tertiary },
    brand: { bg: c.action.secondaryBg, fg: c.action.secondaryFg },
    success: { bg: c.status.successBg, fg: c.status.successFg },
    warning: { bg: c.status.warningBg, fg: c.status.warningFg },
    error: { bg: c.status.errorBg, fg: c.status.errorFg },
    info: { bg: c.status.infoBg, fg: c.status.infoFg },
  } as const;

  const picked = selected ? toneMap.brand : toneMap[tone];

  const container: ViewStyle = {
    height: theme.size.control.xs,
    paddingHorizontal: theme.space['12'],
    borderRadius: theme.radius.role.chip,
    backgroundColor: picked.bg,
    flexDirection: 'row',
    alignItems: 'center',
    gap: theme.space['4'],
  };

  const content = (
    <>
      {leading}
      <Text variant="label_sm" style={{ color: picked.fg }}>
        {label}
      </Text>
    </>
  );

  if (!onPress) {
    return (
      <Press style={[container, style]} disabled haptic="none">
        {content}
      </Press>
    );
  }
  return (
    <Press
      style={[container, style]}
      onPress={onPress}
      scale={0.96}
      expandHitSlop
      accessibilityState={{ selected }}
    >
      {content}
    </Press>
  );
}
