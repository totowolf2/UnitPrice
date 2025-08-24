# 📱 UnitPrice – Mobile App Plan

---

## 🎯 เป้าหมาย

แอพมือถือออฟไลน์ สำหรับ **เปรียบเทียบราคาสินค้าต่อหน่วย**
เริ่มจากหมวดที่ใช้บ่อย (ml/L) แต่รองรับทุกหน่วย เช่น g/kg, ml/L, piece

---

## 🛠️ ฟีเจอร์หลัก

* บันทึกสินค้า

  * ชื่อสินค้า
  * ราคา (THB, รองรับ multi-currency ในอนาคต)
  * หมวดหมู่ (แก้ไขได้, default = “อื่นๆ”)
  * รูปภาพ (เลือก/ถ่าย, ไม่มี → placeholder)
  * จำนวนต่อแพ็ค
  * ปริมาณต่อชิ้น
  * หน่วยต่อชิ้น (เลือกจาก drop-down)

* คำนวณราคาต่อหน่วย (PPU)

* เรียงลำดับถูกสุด → แพงสุด

* ค้นหา/ฟิลเตอร์สินค้า (ชื่อ, หมวดหมู่, ราคา)

* บันทึกการเปรียบเทียบ (Session) → เก็บ **3 ล่าสุด** (แบบหมุน)

---

## 📊 หน่วยที่รองรับ

* **น้ำหนัก**: g, kg
* **ปริมาตร**: ml, L
* **ชิ้น**: piece

### การแปลงอัตโนมัติ

* 1 kg = 1000 g
* 1 L = 1000 ml
* piece = 1:1

### สูตร PPU

```
PPU = price / (packCount × unitAmount_in_baseUnit)
```

### กฎการเปรียบเทียบ

* เทียบได้เฉพาะสินค้าที่เป็น “ชนิดหน่วยเดียวกัน”

  * น้ำหนัก ↔ น้ำหนัก
  * ปริมาตร ↔ ปริมาตร
  * ชิ้น ↔ ชิ้น

---

## 🖥️ UX / UI

* Material 3 + โทนสดใส (พื้นหลังฟ้า, accent เขียว/ส้ม)
* **หน้าหลัก (Home)**

  * ลิสต์สินค้า + ราคาต่อหน่วย
  * Highlight สินค้าถูกสุด
  * ช่องค้นหา + chip filter หมวดหมู่
* **หน้าฟอร์มเพิ่ม/แก้สินค้า**

  * อินพุตครบ (ชื่อ, ราคา, pack, unitAmount, หน่วย, หมวดหมู่)
  * Preview ราคาต่อหน่วย real-time
* **หน้าประวัติ**

  * แสดง 3 เซสชันล่าสุด → เข้าไปดู detail
* **จัดการหมวดหมู่**

  * Bottom sheet (เพิ่ม/แก้/ลบ)
* Animation: Hero, AnimatedList, AnimatedSwitcher
* Empty state: ชัดเจน + ปุ่ม “เพิ่มสินค้า”

---

## 🗂️ โครงสร้างข้อมูล

**Product**

* id (uuid)
* name (string, indexed)
* categoryId (fk)
* price (double, 3 decimals)
* packCount (int)
* unitAmount (double)
* unitType (enum: weight, volume, piece)
* unit (enum: g, kg, ml, L, piece)
* imagePath (nullable)
* createdAt, updatedAt

**Category**

* id
* name (unique)
* color?
* default = “อื่นๆ”

**CompareSession**

* id, createdAt
* items: snapshot (productId, priceSnapshot, unitAmountSnapshot, packCountSnapshot, ppuSnapshot)

---

## 💾 เทคโนโลยี / ไลบรารี

* **Flutter** (Android first)
* State management: **Riverpod**
* Local DB: **Isar**
* รูปภาพ: `image_picker` + `flutter_image_compress`
* UI: Material 3, dynamic color (Android 12+)

---

## 🔒 ข้อกำหนดเพิ่มเติม

* ไม่มี FaceID/รหัสผ่าน
* ไม่มี export/import
* ไม่มี cloud backup
* เก็บประวัติสูงสุด 3 เซสชัน

---

## 🎨 โลโก้แอพ

* ตัวละครการ์ตูน (ผมแดง) ถือสินค้าสองชนิด + มีเครื่องหมาย `?` เหนือหัว
* แสดงอารมณ์ **งงว่าจะเลือกอันไหนดี**
* พื้นหลังฟ้า, flat-style
* ใช้ **icon เดี่ยว ๆ** (ไม่มีข้อความ)

---

## 📦 Asset

* Export icon Android หลายขนาด (mdpi, hdpi, xhdpi, xxhdpi, xxxhdpi)
* ไฟล์ต้นฉบับ PNG 512×512 (transparent) เผื่อใช้ใน splash screen

---

## ✅ Roadmap / Sprint

1. Setup project + theme + DB schema
2. Product CRUD + image handling + หน่วยเลือกได้ + conversion
3. Compare logic + sort/filter/search + highlight ถูกสุด
4. Session/History (3 ล่าสุด)
5. Polish UI/UX (animation, empty state)
6. Testing (unit, widget, golden)
7. Asset & deployment (icon, splash, store setup)

---

## 🧪 Test Focus

* **Unit**: conversion, PPU formula, limit history=3
* **Widget**: form validation, list sorting
* **Golden**: การ์ดสินค้า (theme light/dark)
* **Persistence**: CRUD + session snapshot

---