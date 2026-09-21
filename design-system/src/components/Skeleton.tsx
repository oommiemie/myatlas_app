import React, { useEffect, useRef } from 'react';
import { Animated, Easing, View } from 'react-native';
import type { StyleProp, ViewStyle } from 'react-native';
import { useThemeContext } from '../ThemeProvider';
import { useMotion } from '../useTheme';

export interface SkeletonProps {
  width?: number | `${number}%`;
  height?: number;
  /** ทรง — 'text' จะใช้ radius เล็ก 'circle' จะกลม */
  shape?: 'text' | 'box' | 'circle';
  style?: StyleProp<ViewStyle>;
}

export function Skeleton({ width = '100%', height = 16, shape = 'text', style }: SkeletonProps) {
  const { theme } = useThemeContext();
  const { reduceMotion, pattern } = useMotion();
  const pulse = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    if (reduceMotion) return;
    const loop = Animated.loop(
      Animated.sequence([
        Animated.timing(pulse, {
          toValue: 1,
          duration: pattern.skeleton.duration / 2,
          easing: Easing.inOut(Easing.ease),
          useNativeDriver: true,
        }),
        Animated.timing(pulse, {
          toValue: 0,
          duration: pattern.skeleton.duration / 2,
          easing: Easing.inOut(Easing.ease),
          useNativeDriver: true,
        }),
      ]),
    );
    loop.start();
    return () => loop.stop();
  }, [pulse, reduceMotion, pattern.skeleton.duration]);

  const radius =
    shape === 'circle' ? 9999 : shape === 'text' ? theme.radius.xs : theme.radius.role.tile;

  const box: ViewStyle = {
    width,
    height: shape === 'circle' ? width as number : height,
    borderRadius: radius,
    backgroundColor: theme.colors.surface.sunken,
    overflow: 'hidden',
  };

  if (reduceMotion) return <View style={[box, style]} accessibilityLabel="กำลังโหลด" />;

  return (
    <Animated.View
      accessibilityLabel="กำลังโหลด"
      style={[box, style, { opacity: pulse.interpolate({ inputRange: [0, 1], outputRange: [1, 0.45] }) }]}
    />
  );
}
