import React, { useState } from 'react';
import { TextInput, View } from 'react-native';
import type { StyleProp, TextInputProps, ViewStyle } from 'react-native';
import { useThemeContext } from '../ThemeProvider';
import { Text } from './Text';

export interface TextFieldProps extends Omit<TextInputProps, 'style'> {
  label?: string;
  /** ข้อความช่วยเหลือใต้ช่อง */
  hint?: string;
  /** ข้อความผิดพลาด — จะแทนที่ hint และเปลี่ยนขอบเป็นสีแดง */
  error?: string;
  leading?: React.ReactNode;
  trailing?: React.ReactNode;
  containerStyle?: StyleProp<ViewStyle>;
}

export function TextField({
  label,
  hint,
  error,
  leading,
  trailing,
  containerStyle,
  onFocus,
  onBlur,
  editable = true,
  ...rest
}: TextFieldProps) {
  const { theme } = useThemeContext();
  const c = theme.colors;
  const [focused, setFocused] = useState(false);

  const borderColor = error
    ? c.border.danger
    : focused
      ? c.border.focus
      : c.border.default;

  const field: ViewStyle = {
    minHeight: theme.size.control.lg,
    flexDirection: 'row',
    alignItems: 'center',
    gap: theme.space['8'],
    paddingHorizontal: theme.layout.inset.field,
    borderRadius: theme.radius.role.field,
    borderWidth: focused || error ? theme.borderWidth.strong : theme.borderWidth.default,
    borderColor,
    backgroundColor: editable ? c.surface.sunken : c.action.primaryDisabled,
  };

  return (
    <View style={containerStyle}>
      {label ? (
        <Text variant="label_md" tone="secondary" style={{ marginBottom: theme.space['4'] }}>
          {label}
        </Text>
      ) : null}

      <View style={field}>
        {leading}
        <TextInput
          {...rest}
          editable={editable}
          onFocus={(e) => {
            setFocused(true);
            onFocus?.(e);
          }}
          onBlur={(e) => {
            setFocused(false);
            onBlur?.(e);
          }}
          placeholderTextColor={c.text.placeholder}
          style={[
            theme.typography.body_md,
            { flex: 1, color: c.text.primary, paddingVertical: theme.space['8'] },
          ]}
          accessibilityLabel={label}
        />
        {trailing}
      </View>

      {error || hint ? (
        <Text
          variant="caption"
          tone={error ? 'danger' : 'tertiary'}
          style={{ marginTop: theme.space['4'] }}
        >
          {error ?? hint}
        </Text>
      ) : null}
    </View>
  );
}
