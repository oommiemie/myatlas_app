# MyAtlas Design System

โทเคนและธีมสำหรับ React Native สกัดจากโค้ด Flutter ของ MyAtlas (142 ไฟล์ / 78,000 บรรทัด)

```
tokens/          แหล่งความจริงเดียว — แก้ที่นี่เท่านั้น
scripts/build.mjs  ตัวแปลง token → theme (ไม่มี dependency)
src/theme.ts     ไฟล์ที่สร้างอัตโนมัติ ห้ามแก้ด้วยมือ
src/components/  component ชุดแกน 8 ตัว
dist/            token ที่แก้ reference แล้ว สำหรับ import เข้า Figma
```

## เริ่มใช้งาน

```bash
node scripts/build.mjs      # หรือ npm run build
```

```tsx
import { ThemeProvider, ToastProvider, setHapticsImpl, setSafeAreaHook } from '@myatlas/design-system';
import * as Haptics from 'expo-haptics';
import { useSafeAreaInsets } from 'react-native-safe-area-context';
import AsyncStorage from '@react-native-async-storage/async-storage';

setHapticsImpl({
  selection: () => Haptics.selectionAsync(),
  impact: (s) => Haptics.impactAsync(s as Haptics.ImpactFeedbackStyle),
  notify: (t) => Haptics.notificationAsync(t as Haptics.NotificationFeedbackType),
});
setSafeAreaHook(useSafeAreaInsets);

export default function App() {
  return (
    <ThemeProvider storage={AsyncStorage}>
      <ToastProvider>{/* … */}</ToastProvider>
    </ThemeProvider>
  );
}
```

## การใช้ในคอมโพเนนต์

```tsx
const createStyles = (t: Theme) => ({
  card: {
    backgroundColor: t.colors.surface.raised,
    borderRadius: t.radius.role.card,
    padding: t.layout.inset.card,
    ...t.elevation.sm,
  },
});

function Example() {
  const styles = useStyles(createStyles);   // ประกาศ createStyles นอกคอมโพเนนต์เสมอ
  return <View style={styles.card} />;
}
```

## กติกา

### ต้องทำ

- ใช้ค่าจากธีมเสมอ — `t.space['16']` ไม่ใช่ `16`
- ประกาศ `createStyles` ไว้นอกคอมโพเนนต์ ไม่งั้นแคชของ `useStyles` ไม่ทำงาน
- ทุกปุ่มต้องมีพื้นที่กด ≥ 44×44 ถ้าภาพเล็กกว่านั้นใช้ `expandHitSlop` ไม่ใช่ขยายภาพ
- ใช้ `useMotion()` แทน `motion` ตรงๆ เพื่อให้เคารพการตั้งค่าลดการเคลื่อนไหวของผู้ใช้
- สถานะต้องมีไอคอนหรือข้อความกำกับเสมอ ห้ามสื่อด้วยสีอย่างเดียว

### ห้ามทำ

- ห้ามใส่ค่าสี ขนาด หรือระยะเป็นตัวเลขดิบในคอมโพเนนต์
- ห้ามใส่ `fontSize` เอง — ถ้าต้องการขนาดใหม่ให้เพิ่ม role ใน `tokens/typography.json`
- ห้ามแก้ `src/theme.ts` ด้วยมือ มันถูกสร้างใหม่ทุกครั้งที่ build
- ห้ามใส่ `letterSpacing` บวกกับข้อความไทย จะทำให้สระและวรรณยุกต์หลุดจากพยัญชนะ
- ห้ามใช้ `radius.full` กับการ์ด — สงวนไว้ให้ปุ่ม chip badge avatar และแถบ progress

## กฎเชิงออกแบบที่ฝังอยู่ในโทเคน

| เรื่อง | กฎ |
|---|---|
| กริด | ทุกระยะหารด้วย 4 ลงตัว |
| ระยะกับความหมาย | 4 = ก้อนเดียวกัน · 8 = สัมพันธ์กัน · 16 = คนละการ์ด · 24+ = คนละเรื่อง |
| Radius ซ้อนกัน | `radius ใน = radius นอก − padding` |
| เงา | แหล่งแสงเดียวจากด้านบน x-offset = 0 เสมอ · blur ≈ 2.5-3 เท่าของ y |
| เงาบนพื้นสี | ใช้เงาย้อมสีเดียวกับพื้น ห้ามดำล้วน |
| โหมดมืด | ไม่ใช้เงา — ยกชั้นด้วยความสว่างของพื้นผิว |
| Motion | ของออกเร็วกว่าของเข้าเสมอ |
| Contrast | ตัวอักษร 4.5:1 · ขอบและไอคอนที่สื่อความหมาย 3:1 (WCAG 2.2 AA) |

ชุดสีปัจจุบันผ่านการตรวจ contrast แล้ว **34/34 คู่** ทั้งโหมดสว่างและมืด

## แก้โทเคน

1. แก้ไฟล์ใน `tokens/`
2. `node scripts/build.mjs`
3. ตรวจว่า `src/theme.ts` เปลี่ยนตามที่ตั้งใจ แล้ว commit ทั้งสองอย่าง

build script จะ throw ทันทีถ้าอ้างโทเคนที่ไม่มีอยู่จริงหรือมี reference วนซ้ำ

## นำเข้า Figma

`dist/tokens.resolved.json` เป็นค่าที่แก้ reference แล้ว นำเข้าผ่านปลั๊กอิน Tokens Studio หรือแปลงเป็น Figma Variables ได้ทันที ทำให้ไฟล์ออกแบบกับโค้ดใช้ค่าชุดเดียวกัน
