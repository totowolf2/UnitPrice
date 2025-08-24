class AppConstants {
  // Database
  static const String databaseName = 'unitprice.isar';
  
  // Session Management
  static const int maxComparisonSessions = 3;
  
  // Image Storage
  static const String imageFolder = 'product_images';
  static const int maxImageWidth = 1024;
  static const int maxImageHeight = 1024;
  static const int imageQuality = 80;
  static const int compressedImageSize = 512;
  static const int compressQuality = 85;
  
  // Categories
  static const String defaultCategoryName = 'อื่นๆ';
  
  // Price precision
  static const int pricePrecision = 2; // For THB display
  static const int ppuPrecision = 3; // For price per unit calculations
}

class AppStrings {
  // Thai language strings
  static const String appName = 'UnitPrice';
  static const String products = 'สินค้า';
  static const String addProduct = 'เพิ่มสินค้า';
  static const String editProduct = 'แก้ไขสินค้า';
  static const String productName = 'ชื่อสินค้า';
  static const String price = 'ราคา';
  static const String category = 'หมวดหมู่';
  static const String packCount = 'จำนวนแพ็ค';
  static const String unitAmount = 'ปริมาณต่อหน่วย';
  static const String unit = 'หน่วย';
  static const String image = 'รูปภาพ';
  static const String save = 'บันทึก';
  static const String cancel = 'ยกเลิก';
  static const String delete = 'ลบ';
  static const String search = 'ค้นหา';
  static const String filter = 'กรอง';
  static const String compare = 'เปรียบเทียบ';
  static const String history = 'ประวัติ';
  static const String settings = 'การตั้งค่า';
  static const String noProducts = 'ไม่มีสินค้า';
  static const String cheapest = 'ถูกที่สุด';
  static const String pricePerUnit = 'ราคาต่อหน่วย';
  static const String takePhoto = 'ถ่ายภาพ';
  static const String chooseFromGallery = 'เลือกจากแกลเลอรี่';
  static const String error = 'เกิดข้อผิดพลาด';
  static const String required = 'จำเป็น';
  static const String invalidNumber = 'ตัวเลขไม่ถูกต้อง';
}