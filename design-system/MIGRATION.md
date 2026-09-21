# แผนย้าย Flutter → React Native

เอกสารนี้เก็บเฉพาะสิ่งที่โค้ดบอกไม่ได้ — เหตุผลของการตัดสินใจ ตารางเทียบเคียง และลำดับงาน
ค่าจริงทั้งหมดอยู่ใน `tokens/` และ `src/theme.ts` ไม่มีการเขียนซ้ำที่นี่

โปรเจ็กต์ปลายทาง: `~/Desktop/MyAtlas_React` — Expo SDK 57 · RN 0.86.3 · React 19 · Reanimated 4 · expo-router

---

## 1. สถานะโปรเจ็กต์ปลายทาง และจุดที่ชนกัน

โปรเจ็กต์ RN มีการ port ไว้แล้วบางส่วน ซึ่ง**ชื่อชนกับ design system** ต้องตัดสินใจก่อนใช้งานจริง

| ของเดิมใน MyAtlas_React | ของใหม่ใน design system | ข้อแตกต่าง | ทางออกที่แนะนำ |
|---|---|---|---|
| `src/core/theme/colors.ts` — `AppColors` | `lightColors` / `darkColors` | ของเดิม port ตรงจาก Dart 1:1 (35 ค่า ไม่มีชั้น semantic) ของใหม่มี 3 ชั้นและผ่าน contrast | ย้ายทีละหน้าจอ เก็บ `AppColors` ไว้จนกว่าจะไม่มีใครเรียก |
| `src/core/theme/ThemeProvider.tsx` — `useTheme(): Palette` | `useTheme(): Theme` | ชื่อเหมือนกันแต่คืนคนละรูป | เปลี่ยนชื่อของเดิมเป็น `useLegacyPalette` ระหว่างเปลี่ยนผ่าน |
| `src/core/responsive/useResponsive.ts` | `useResponsive()` | breakpoint ต่างกัน: เดิม 375/768 (compact/regular/large) ใหม่ 600/840/1200 ตาม Material 3 | ใช้ของใหม่ ของเดิมอิงความกว้างมือถือ ไม่ใช่ class ของอุปกรณ์ |
| `src/core/theme/typography.ts` — DM Sans | `typography` 18 role | **DM Sans ไม่มีอักขระไทย** ของเดิมปล่อยให้ไทยตกไปใช้ฟอนต์ระบบ | ดูข้อ 2 |
| `src/core/widgets/PressEffect.tsx` | `Press` | ของเดิมมีอยู่แล้ว | เทียบ API แล้วเลือกตัวเดียว |

### เรื่องที่ต้องตัดสินใจก่อนอื่น: ฟอนต์

แอป Flutter ใช้ **IBM Plex Sans Thai Looped** สำหรับตัวอักษร และ **Nunito** สำหรับตัวเลข
แต่โปรเจ็กต์ RN ตอนนี้ใช้ **DM Sans** ซึ่งไม่มีอักขระไทยเลย ทำให้ข้อความไทยตกไปใช้ฟอนต์ระบบ

ผลคือหน้าตาแอปจะไม่เหมือน Flutter และแต่ละแพลตฟอร์มจะไม่เหมือนกันเองด้วย (iOS ใช้ SF Thai, Android ใช้ Noto Thai)

ทางเลือก

1. **ย้าย IBM Plex Sans Thai Looped มาด้วย** (แนะนำ) — ไฟล์อยู่ใน `myatlas_app/assets/fonts/ibmplex/` แล้ว โหลดผ่าน `expo-font` ได้ตรง ได้หน้าตาเหมือน Flutter ทุกประการ
2. อยู่กับ DM Sans ต่อ แล้วยอมรับว่าไทยเป็นฟอนต์ระบบ — เร็วกว่าแต่เสียอัตลักษณ์

โทเคนตั้งค่าไว้ตามทางเลือกที่ 1 ถ้าเลือกทางที่ 2 แก้ที่ `tokens/typography.json` จุดเดียว

**ข้อจำกัดที่หนีไม่พ้น** — RN ไม่รองรับ font fallback แบบ Flutter (`fontFamilyFallback`) ดังนั้นแผน "ตัวอักษร IBM Plex + ตัวเลข Nunito" ทำแบบเดิมไม่ได้ ต้องเลือก

- รวมสองฟอนต์เป็นไฟล์เดียวด้วย fonttools (แนะนำ — โค้ดไม่ต้องแก้)
- หรือแยก `<Text>` เฉพาะตัวเลขเด่น โดยใช้ `fontFamily.numeric` ที่เตรียมไว้แล้ว

---

## 2. ตารางเทียบเคียง Flutter → React Native

### พื้นฐาน

| Flutter | React Native | หมายเหตุ |
|---|---|---|
| `Container(decoration:)` | `<View style={{}}>` | เงาต้องแยก iOS/Android — ใช้ `t.elevation.*` |
| `Column` / `Row` | `<View style={{flexDirection}}>` | RN เป็น flex เสมอ default `column` เหมือนกัน |
| `Expanded` | `flex: 1` | |
| `SizedBox(height: 16)` | `gap` ของ flex | RN 0.71+ รองรับ `gap` แล้ว ใช้แทน spacer view |
| `Stack` / `Positioned` | `position: 'absolute'` | RN ไม่มี `clipBehavior: none` — ของล้นขอบต้องไม่ใส่ `overflow:'hidden'` |
| `ListView.builder` | `FlatList` | |
| `ListView.separated` | `FlatList` + `ItemSeparatorComponent` | |
| `SingleChildScrollView` | `ScrollView` | |
| `CustomScrollView` + Sliver | `Animated.ScrollView` + Reanimated | ไม่มี sliver ต้องเขียน header เอง |
| `SliverPersistentHeader` | `useAnimatedScrollHandler` + `interpolate` | เช่น `LargeTitleHeader` |
| `CustomPaint` | `react-native-svg` `<Path>` | เช่น เส้นปะบัตรคิว วงแหวน progress |
| `AnimatedContainer` | `Animated.View` + Reanimated layout | |
| `AnimatedSwitcher` | Reanimated `entering` / `exiting` | |
| `Hero` | `react-native-shared-element` หรือ expo-router transition | |

### เฉพาะทาง — เทียบกับ dependency ที่โปรเจ็กต์มีอยู่แล้ว

| Flutter | React Native | สถานะใน MyAtlas_React |
|---|---|---|
| `BackdropFilter(ImageFilter.blur)` | `expo-blur` | ติดตั้งแล้ว |
| `LinearGradient` | `expo-linear-gradient` | ติดตั้งแล้ว |
| `SvgPicture` | `react-native-svg` | ติดตั้งแล้ว |
| `HapticFeedback` | `expo-haptics` | ติดตั้งแล้ว — เสียบผ่าน `setHapticsImpl()` |
| `SafeArea` | `react-native-safe-area-context` | ติดตั้งแล้ว — เสียบผ่าน `setSafeAreaHook()` |
| `WebView` | `react-native-webview` | ติดตั้งแล้ว |
| `CupertinoPageRoute` | `expo-router` | ติดตั้งแล้ว |
| `Clipboard.setData` | `expo-clipboard` | **ยังไม่มี** |
| `showCupertinoModalPopup` (bottom sheet) | `@gorhom/bottom-sheet` | **ยังไม่มี** — มี Reanimated + Gesture Handler พร้อมแล้ว |
| `showGeneralDialog` (popup กลางจอ) | `<Modal>` ของ RN + Reanimated | ใช้ของที่มีได้เลย |
| `CupertinoAlertDialog` | `Alert.alert()` | ของ native ไม่ต้องลง |
| `CupertinoActionSheet` | `@expo/react-native-action-sheet` | **ยังไม่มี** |
| `geolocator` / `geocoding` | `expo-location` | **ยังไม่มี** |
| `image_picker` | `expo-image-picker` | ติดตั้งแล้ว |
| Live Activity (ActivityKit) | ต้องเขียน native module เอง | ยังไม่มีทางลัด |

---

## 3. รายการ component ที่ต้องย้าย

จากโค้ด Flutter มี widget class ที่เป็น public ทั้งหมด **134 ตัว**

| กลุ่ม | จำนวน | ลำดับความสำคัญ |
|---|---|---|
| `core/widgets` (ใช้ร่วมทุกฟีเจอร์) | 9 | **1 — ทำก่อน** เพราะทุกอย่างพึ่งมัน |
| `features/health` | 35 | 3 |
| `features/me` | 28 | 4 |
| `features/home` | 22 | 2 — เป็นหน้าแรกที่ผู้ใช้เห็น |
| `features/medicine` | 15 | 3 |
| `features/appointment` | 11 | 4 |
| `features/family` | 8 | 5 |
| `features/nutrition` | 4 | 5 |
| `features/shell` + `auth` | 2 | 1 — โครงหลักของแอป |

ชุดแกน 8 ตัวใน `src/components/` ครอบคลุมกลุ่มที่ 1 ไปแล้วเกือบหมด เหลือ `LiquidGlassButton`,
`PopoverMenu`, `LargeTitleHeader`, `AppOptionSheet` ที่ต้องรอการตัดสินใจเรื่อง bottom sheet และ navigation

---

## 4. กลยุทธ์แท็บเล็ต แยกตามชนิดหน้าจอ

โปรเจ็กต์ Flutter ตอนนี้ใช้ `ResponsiveFrame` บีบเนื้อหาเหลือ 520px แล้วใส่ขอบเทา —
เป็นการกันไม่ให้พัง ไม่ใช่การรองรับแท็บเล็ตจริง

| ชนิดหน้า | ตัวอย่าง | compact | medium ขึ้นไป |
|---|---|---|---|
| ฟอร์ม / ขั้นตอน | ล็อกอิน, กรอกโค้ด, เพิ่มยา | เต็มจอ | คุมกว้าง `container.form` (520) จัดกึ่งกลาง — แบบที่ทำอยู่ ถูกแล้ว |
| ฟีด / รายการ | หน้าหลัก, สุขภาพ | คอลัมน์เดียว | คุมกว้าง `container.content` (720) หรือแตกเป็น 2 คอลัมน์ |
| Master-detail | ครอบครัว, รายการยา, นัดหมาย | กดเข้าไปหน้าใหม่ | แสดงสองฝั่งพร้อมกัน ไม่ต้องเปลี่ยนหน้า |
| การ์ดกริด | สรุปสุขภาพ | 2 คอลัมน์ | 3-4 คอลัมน์ ใช้ `useColumnWidth()` |
| Modal / sheet | ทุกหน้าที่เป็น sheet | เต็มความกว้าง | คุมกว้าง 640 จัดกึ่งกลาง ไม่ให้ยืดเต็มจอ |

---

## 5. บันทึกการตัดสินใจ

สิ่งที่เลือกแทนคุณระหว่างสร้างระบบ พร้อมเหตุผลและวิธีเปลี่ยนกลับ

| # | เรื่อง | ตัดสินใจ | เหตุผล | เปลี่ยนกลับที่ |
|---|---|---|---|---|
| 1 | สีแบรนด์บนตัวหนังสือ | `#157F5E` แทน `#1D8B6B` | `#1D8B6B` บนพื้นขาวได้ 4.24:1 ตก AA (ต้อง 4.5) | `color.semantic.*.text.brand` |
| 2 | พื้นปุ่มหลัก | `#157F5E` | ขาวบนสีนี้ 4.97:1 ผ่าน AA | `color.semantic.*.action.primaryBg` |
| 3 | ลำดับชั้นตัวหนังสือ | `#6D756E` เลื่อนจาก secondary → tertiary | ให้ทั้ง 3 ชั้นผ่าน AA | `color.semantic.*.text` |
| 4 | Neutral | ผสมเขียวจางๆ (H128) | กลมกลืนกับแบรนด์ ต่างจากเทากลางแทบไม่เห็น | `color.neutral.*` |
| 5 | line-height เนื้อหา | 1.29 → 1.5 | ภาษาไทยมีสระบน-ล่างและวรรณยุกต์ 1.29 ทำให้บรรทัดชนกัน | `typography.body.*` |
| 6 | letter-spacing ไทย | ตัดค่าบวกออกทั้งหมด | ถ่างช่องไฟทำให้สระหลุดจากพยัญชนะ | `typography.*.letterSpacing` |
| 7 | ระยะที่หลุดกริด | ปัดเข้า 4pt (~180 จุด) | คุณเลือกใช้กริดสากล | `layout.$extensions.migrationMap` |
| 8 | radius กล่องในการ์ด | 16 → 8 | กฎ concentric: 24 − 16 = 8 | `radius.role.cardInner` |
| 9 | radius bottom sheet | 38 → 40 | เข้ากริด 4pt | `radius.5xl` |
| 10 | เงาโหมดมืด | ไม่ใช้เงา ใช้ความสว่างพื้นผิว | เงาไม่ทำงานบนพื้นมืด (Material 3) | `elevation.dark.*` |
| 11 | ขนาดตัวอักษรเศษ | 12.5 / 13.5 → 12 / 14 | ขนาดทศนิยมทำให้ตัวอักษรเบลอ | `font.size.*` |

---

## 6. ลำดับงานที่แนะนำ

1. ตัดสินใจเรื่องฟอนต์ (ข้อ 1) — กระทบทุกหน้าจอ ยิ่งช้ายิ่งแก้ยาก
2. เสียบ `setHapticsImpl` / `setSafeAreaHook` แล้วครอบ `ThemeProvider` + `ToastProvider` ที่ `app/_layout.tsx`
3. เปลี่ยนชื่อ `useTheme` ของเดิมเป็น `useLegacyPalette` เพื่อไม่ให้ชนกัน
4. ย้าย `features/shell` (tab bar) — เป็นโครงที่ทุกหน้าอยู่ข้างใน
5. ย้าย `features/home` ทีละการ์ด โดยใช้ component ชุดแกน
6. ค่อยไล่ health → medicine → me → ที่เหลือ
7. เมื่อไม่มีใครเรียก `AppColors` แล้ว ลบ `src/core/theme/colors.ts` ทิ้ง
