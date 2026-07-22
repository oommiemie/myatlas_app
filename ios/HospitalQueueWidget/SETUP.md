# Widget Extension setup (one-time, in Xcode)

The Swift source is ready in this folder. To wire it up as an actual iOS target:

## 1. Add the Widget Extension target

1. เปิด `ios/Runner.xcworkspace` ใน Xcode
2. File → New → Target…
3. เลือก **Widget Extension** → Next
4. Product Name: **`HospitalQueueWidget`** (exactly this name)
5. Bundle Identifier จะเป็น: `com.oommie.myatlasapp.HospitalQueueWidget`
6. **ติ๊ก "Include Live Activity"**
7. Language: Swift, Team: **FFFGJANVWN** (Oommie), Embed in Application: Runner
8. Click Finish — Xcode ถามให้ activate scheme, กด **Activate**

## 2. Replace the auto-generated files

Xcode สร้าง template ให้ 3 ไฟล์ (HospitalQueueWidgetBundle.swift, HospitalQueueWidgetLiveActivity.swift, HospitalQueueWidget.swift) — **ลบทิ้งทั้งหมด** แล้วเพิ่มไฟล์ที่มีอยู่แล้วในโฟลเดอร์นี้แทน:

- `HospitalQueueAttributes.swift`
- `HospitalQueueLiveActivity.swift`
- `HospitalQueueWidgetBundle.swift`
- `Info.plist`

วิธี: Right-click ที่กลุ่ม `HospitalQueueWidget` ใน Xcode → **Add Files to "Runner"…** → เลือกทั้ง 4 ไฟล์ → Target Membership ให้ติ๊ก **HospitalQueueWidget เท่านั้น** (ยกเว้น `HospitalQueueAttributes.swift` — ติ๊กทั้ง **HospitalQueueWidget** และ **Runner**)

## 3. Deployment target

Widget Extension ต้อง iOS 16.1+ (Runner ตอนนี้ 16.1 แล้ว)

## 4. Signing

- Runner + Widget: Team = **FFFGJANVWN** (personal, ใช้ slot ที่ 2)
- Automatic signing OK สำหรับ personal team

## 5. Build & test

```bash
flutter clean && flutter build ios --debug
flutter run -d 5D2599F9-...  # iPhone 17 Pro Max sim (มี Dynamic Island)
```

แตะการ์ด "คิวรับบริการโรงพยาบาล" ที่หน้าหลัก → เข้าหน้า detail → Live Activity จะเริ่มอัตโนมัติ:
- **Lock Screen**: banner สีน้ำเงินเข้ม
- **Dynamic Island**: cross-icon compact / expanded ตอนกดค้าง
