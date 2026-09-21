import React, { useCallback, useRef } from 'react';
import { Animated, Pressable } from 'react-native';
import type { PressableProps, ViewStyle, StyleProp } from 'react-native';
import { haptics } from '../haptics';
import { useMotion } from '../useTheme';

export interface PressProps extends Omit<PressableProps, 'style'> {
  children: React.ReactNode;
  style?: StyleProp<ViewStyle>;
  /** ขนาดตอนกด — 1 คือไม่ย่อ */
  scale?: number;
  /** สั่นตอนกด ปิดได้ด้วย 'none' */
  haptic?: 'none' | 'selection' | 'light' | 'medium' | 'heavy';
  /** ขยายพื้นที่กดให้ถึง 44pt โดยไม่ขยายภาพ */
  expandHitSlop?: boolean;
}

/**
 * ฟีดแบ็กตอนกดของทั้งระบบ — เทียบเท่า PressEffect ใน Flutter
 * ใช้ Animated ของ RN บน native driver (transform รองรับเต็มที่) จึงไม่ต้องพึ่ง Reanimated
 */
export function Press({
  children,
  style,
  scale = 0.97,
  haptic = 'selection',
  expandHitSlop = false,
  onPressIn,
  onPressOut,
  disabled,
  ...rest
}: PressProps) {
  const motion = useMotion();
  const value = useRef(new Animated.Value(1)).current;

  const animate = useCallback(
    (to: number, duration: number) => {
      Animated.timing(value, {
        toValue: to,
        duration,
        useNativeDriver: true,
      }).start();
    },
    [value],
  );

  const handleIn = useCallback<NonNullable<PressableProps['onPressIn']>>(
    (e) => {
      if (haptic === 'selection') haptics.selection();
      else if (haptic !== 'none') haptics.impact(haptic);
      animate(scale, motion.duration.micro);
      onPressIn?.(e);
    },
    [animate, haptic, motion.duration.micro, onPressIn, scale],
  );

  const handleOut = useCallback<NonNullable<PressableProps['onPressOut']>>(
    (e) => {
      animate(1, motion.duration.fast);
      onPressOut?.(e);
    },
    [animate, motion.duration.fast, onPressOut],
  );

  return (
    <Pressable
      {...rest}
      disabled={disabled}
      onPressIn={handleIn}
      onPressOut={handleOut}
      hitSlop={expandHitSlop ? 8 : undefined}
      // Android ต้องปิด ripple เพราะเราคุมฟีดแบ็กเองด้วย scale
      android_ripple={null}
      accessibilityRole={rest.accessibilityRole ?? 'button'}
    >
      <Animated.View style={[style, { transform: [{ scale: value }] }]}>{children}</Animated.View>
    </Pressable>
  );
}
