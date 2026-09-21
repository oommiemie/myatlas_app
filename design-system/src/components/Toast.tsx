import React, {
  createContext, useCallback, useContext, useEffect, useMemo, useRef, useState,
} from 'react';
import { Animated, View } from 'react-native';
import { useSafeArea } from '../useSafeArea';
import { useThemeContext } from '../ThemeProvider';
import { useMotion } from '../useTheme';
import { haptics } from '../haptics';
import { Text } from './Text';

export type ToastTone = 'success' | 'error' | 'warning' | 'info';

export interface ToastOptions {
  message: string;
  tone?: ToastTone;
  /** มิลลิวินาที — ค่าเริ่มต้น 2600 */
  duration?: number;
}

interface ToastContextValue {
  show(options: ToastOptions | string): void;
  hide(): void;
}

const ToastContext = createContext<ToastContextValue | null>(null);

export function useToast(): ToastContextValue {
  const ctx = useContext(ToastContext);
  if (!ctx) throw new Error('ต้องครอบด้วย <ToastProvider> ก่อนใช้ useToast');
  return ctx;
}

export function ToastProvider({ children }: { children: React.ReactNode }) {
  const [toast, setToast] = useState<Required<ToastOptions> | null>(null);
  const timer = useRef<ReturnType<typeof setTimeout> | null>(null);

  const hide = useCallback(() => {
    if (timer.current) clearTimeout(timer.current);
    setToast(null);
  }, []);

  const show = useCallback(
    (options: ToastOptions | string) => {
      const next = typeof options === 'string' ? { message: options } : options;
      const tone = next.tone ?? 'success';
      if (timer.current) clearTimeout(timer.current);
      haptics.notify(tone === 'error' ? 'error' : tone === 'warning' ? 'warning' : 'success');
      setToast({ message: next.message, tone, duration: next.duration ?? 2600 });
      timer.current = setTimeout(() => setToast(null), next.duration ?? 2600);
    },
    [],
  );

  useEffect(() => () => {
    if (timer.current) clearTimeout(timer.current);
  }, []);

  const value = useMemo(() => ({ show, hide }), [show, hide]);

  return (
    <ToastContext.Provider value={value}>
      {children}
      {toast ? <ToastView {...toast} onHide={hide} /> : null}
    </ToastContext.Provider>
  );
}

function ToastView({ message, tone, onHide }: Required<ToastOptions> & { onHide(): void }) {
  const { theme } = useThemeContext();
  const motion = useMotion();
  const insets = useSafeArea();
  const anim = useRef(new Animated.Value(0)).current;

  useEffect(() => {
    Animated.timing(anim, {
      toValue: 1,
      duration: motion.duration.normal,
      useNativeDriver: true,
    }).start();
  }, [anim, motion.duration.normal]);

  const toneKey = `${tone}Bg` as const;
  const fgKey = `${tone}Fg` as const;

  return (
    <Animated.View
      pointerEvents="box-none"
      accessibilityLiveRegion="polite"
      accessibilityRole="alert"
      style={{
        position: 'absolute',
        left: theme.layout.inset.screen,
        right: theme.layout.inset.screen,
        bottom: insets.bottom + theme.space['16'],
        zIndex: theme.zIndex.toast,
        opacity: anim,
        transform: [
          { translateY: anim.interpolate({ inputRange: [0, 1], outputRange: [16, 0] }) },
        ],
      }}
    >
      <View
        style={{
          backgroundColor: theme.colors.status[toneKey],
          borderColor: theme.colors.status[`${tone}Border` as const],
          borderWidth: theme.borderWidth.default,
          borderRadius: theme.radius.role.card,
          paddingVertical: theme.space['12'],
          paddingHorizontal: theme.layout.inset.card,
          ...(theme.elevation.lg as object),
        }}
      >
        <Text variant="body_sm" style={{ color: theme.colors.status[fgKey] }} onPress={onHide}>
          {message}
        </Text>
      </View>
    </Animated.View>
  );
}
