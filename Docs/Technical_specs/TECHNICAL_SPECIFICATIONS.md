# Baty Food - المواصفات التقنية التفصيلية 🛠️

## 📋 جدول المحتويات

1. [البنية التقنية](#البنية-التقنية)
2. [Backend Specifications](#backend-specifications)
3. [Frontend Specifications](#frontend-specifications)
4. [Mobile App Specifications](#mobile-app-specifications)
5. [قاعدة البيانات](#قاعدة-البيانات)
6. [API Endpoints](#api-endpoints)
7. [الأمان](#الأمان)
8. [الأداء](#الأداء)
9. [الاختبار](#الاختبار)
10. [النشر](#النشر)

---

## 🏗️ البنية التقنية

### الهيكل العام

```
┌─────────────────────────────────────────────────────────────┐
│                    Client Applications                      │
├─────────────────┬─────────────────┬─────────────────────────┤
│   Flutter App   │   React Web     │   Admin Dashboard       │
│   (Mobile)      │   (Frontend)    │   (Management)          │
└─────────┬───────┴─────────┬───────┴─────────────┬───────────┘
          │                 │                     │
          └─────────────────┼─────────────────────┘
                            │
                ┌───────────▼───────────┐
                │    Node.js API        │
                │    (Backend)          │
                └───────────┬───────────┘
                            │
                ┌───────────▼───────────┐
                │   MongoDB Atlas       │
                │   (Database)          │
                └───────────────────────┘
```

### التقنيات المستخدمة

| المكون   | التقنية             | البديل           | السبب                          |
| -------- | ------------------- | ---------------- | ------------------------------ |
| Backend  | Node.js + Express   | Python + Django  | سرعة التطوير، مجتمع كبير       |
| Database | MongoDB Atlas       | PostgreSQL       | مرونة في البيانات، طبقة مجانية |
| Frontend | React + Material-UI | Vue.js + Vuetify | واجهات جميلة، مكونات جاهزة     |
| Mobile   | Flutter             | React Native     | أداء أفضل، واجهة موحدة         |
| Storage  | Cloudinary          | AWS S3           | تخزين مجاني للصور              |
| Hosting  | Render + Netlify    | Heroku + Vercel  | خدمات مجانية                   |

---

## 🔧 Backend Specifications

### المتطلبات التقنية

- **Node.js:** v18 أو أحدث
- **Express:** v4.18 أو أحدث
- **MongoDB:** v6 أو أحدث
- **JWT:** للمصادقة
- **Multer:** لرفع الملفات
- **Nodemailer:** للإشعارات

### هيكل المشروع

```
backend/
├── src/
│   ├── controllers/
│   │   ├── authController.js
│   │   ├── userController.js
│   │   ├── recipeController.js
│   │   ├── orderController.js
│   │   └── paymentController.js
│   ├── models/
│   │   ├── User.js
│   │   ├── Recipe.js
│   │   ├── Order.js
│   │   └── Payment.js
│   ├── routes/
│   │   ├── auth.js
│   │   ├── users.js
│   │   ├── recipes.js
│   │   ├── orders.js
│   │   └── payments.js
│   ├── middleware/
│   │   ├── auth.js
│   │   ├── upload.js
│   │   ├── validation.js
│   │   └── errorHandler.js
│   ├── utils/
│   │   ├── database.js
│   │   ├── email.js
│   │   ├── payment.js
│   │   └── helpers.js
│   └── config/
│       ├── database.js
│       ├── email.js
│       └── payment.js
├── uploads/
├── tests/
├── package.json
├── server.js
└── .env
```

### الميزات الأساسية

1. **نظام المصادقة**

   - تسجيل الدخول/الخروج
   - تجديد التوكن
   - استعادة كلمة المرور
   - التحقق من البريد الإلكتروني

2. **إدارة المستخدمين**

   - إنشاء/تعديل/حذف الحسابات
   - رفع الصور الشخصية
   - إدارة الملف الشخصي
   - نظام التقييمات

3. **إدارة الوصفات**

   - إنشاء/تعديل/حذف الوصفات
   - رفع صور الوصفات
   - البحث والفلترة
   - نظام التقييمات

4. **إدارة الطلبات**

   - إنشاء/تتبع/إلغاء الطلبات
   - تحديث حالة الطلب
   - إشعارات في الوقت الفعلي
   - نظام التقييمات

5. **نظام المدفوعات**
   - الدفع نقداً عند الاستلام
   - دفع إلكتروني (لاحقاً)
   - إدارة العمولات
   - تقارير المبيعات

---

## 🎨 Frontend Specifications

### المتطلبات التقنية

- **React:** v18 أو أحدث
- **Material-UI:** v5 أو أحدث
- **Redux Toolkit:** لإدارة الحالة
- **React Router:** للتنقل
- **Axios:** لطلبات HTTP
- **React Query:** لإدارة البيانات

### هيكل المشروع

```
frontend/
├── public/
│   ├── index.html
│   ├── favicon.ico
│   └── manifest.json
├── src/
│   ├── components/
│   │   ├── common/
│   │   │   ├── Header.jsx
│   │   │   ├── Footer.jsx
│   │   │   ├── Loading.jsx
│   │   │   └── ErrorBoundary.jsx
│   │   ├── auth/
│   │   │   ├── Login.jsx
│   │   │   ├── Register.jsx
│   │   │   └── ForgotPassword.jsx
│   │   ├── cook/
│   │   │   ├── Dashboard.jsx
│   │   │   ├── RecipeForm.jsx
│   │   │   ├── OrderList.jsx
│   │   │   └── Analytics.jsx
│   │   ├── customer/
│   │   │   ├── RecipeList.jsx
│   │   │   ├── RecipeDetail.jsx
│   │   │   ├── Cart.jsx
│   │   │   └── OrderHistory.jsx
│   │   └── admin/
│   │       ├── Dashboard.jsx
│   │       ├── UserManagement.jsx
│   │       └── Reports.jsx
│   ├── pages/
│   │   ├── Home.jsx
│   │   ├── CookDashboard.jsx
│   │   ├── CustomerDashboard.jsx
│   │   └── AdminDashboard.jsx
│   ├── store/
│   │   ├── index.js
│   │   ├── authSlice.js
│   │   ├── recipeSlice.js
│   │   └── orderSlice.js
│   ├── services/
│   │   ├── api.js
│   │   ├── authService.js
│   │   ├── recipeService.js
│   │   └── orderService.js
│   ├── utils/
│   │   ├── constants.js
│   │   ├── helpers.js
│   │   └── validation.js
│   ├── styles/
│   │   ├── theme.js
│   │   └── global.css
│   ├── App.jsx
│   └── index.js
├── package.json
└── README.md
```

### الميزات الأساسية

1. **واجهة الطهاة**

   - لوحة تحكم شاملة
   - إدارة الوصفات
   - متابعة الطلبات
   - التحليلات والإحصائيات

2. **واجهة العملاء**

   - تصفح الوصفات
   - البحث والفلترة
   - سلة المشتريات
   - متابعة الطلبات

3. **واجهة الإدارة**
   - إدارة المستخدمين
   - مراقبة النظام
   - التقارير والإحصائيات
   - إدارة المحتوى

---

## 📱 Mobile App Specifications

### المتطلبات التقنية

- **Flutter:** v3.10 أو أحدث
- **Dart:** v3.0 أو أحدث
- **Firebase:** للمصادقة والإشعارات
- **Provider/Bloc:** لإدارة الحالة
- **HTTP:** لطلبات API
- **Shared Preferences:** لتخزين البيانات المحلية

### هيكل المشروع

```
mobile/
├── android/
├── ios/
├── lib/
│   ├── main.dart
│   ├── app.dart
│   ├── config/
│   │   ├── routes.dart
│   │   ├── theme.dart
│   │   └── constants.dart
│   ├── models/
│   │   ├── user.dart
│   │   ├── recipe.dart
│   │   ├── order.dart
│   │   └── payment.dart
│   ├── services/
│   │   ├── api_service.dart
│   │   ├── auth_service.dart
│   │   ├── storage_service.dart
│   │   └── notification_service.dart
│   ├── providers/
│   │   ├── auth_provider.dart
│   │   ├── recipe_provider.dart
│   │   ├── order_provider.dart
│   │   └── cart_provider.dart
│   ├── screens/
│   │   ├── auth/
│   │   │   ├── login_screen.dart
│   │   │   ├── register_screen.dart
│   │   │   └── forgot_password_screen.dart
│   │   ├── customer/
│   │   │   ├── home_screen.dart
│   │   │   ├── recipe_list_screen.dart
│   │   │   ├── recipe_detail_screen.dart
│   │   │   ├── cart_screen.dart
│   │   │   └── order_history_screen.dart
│   │   └── cook/
│   │       ├── dashboard_screen.dart
│   │       ├── recipe_management_screen.dart
│   │       ├── order_management_screen.dart
│   │       └── analytics_screen.dart
│   ├── widgets/
│   │   ├── common/
│   │   │   ├── custom_app_bar.dart
│   │   │   ├── loading_widget.dart
│   │   │   └── error_widget.dart
│   │   ├── recipe/
│   │   │   ├── recipe_card.dart
│   │   │   └── recipe_list_item.dart
│   │   └── order/
│   │       ├── order_card.dart
│   │       └── order_status_widget.dart
│   └── utils/
│       ├── helpers.dart
│       ├── validators.dart
│       └── extensions.dart
├── assets/
│   ├── images/
│   ├── icons/
│   └── fonts/
├── pubspec.yaml
└── README.md
```

### الميزات الأساسية

1. **تطبيق العملاء**

   - تصفح الوصفات
   - البحث والفلترة
   - إضافة للسلة
   - إتمام الطلب
   - متابعة الطلب
   - التقييم والمراجعة

2. **تطبيق الطهاة**
   - لوحة تحكم
   - إدارة الوصفات
   - متابعة الطلبات
   - تحديث حالة الطلب
   - التحليلات

---

## 🗄️ قاعدة البيانات

### مخطط قاعدة البيانات

#### Users Collection

```javascript
{
  _id: ObjectId,
  name: String,
  email: String,
  phone: String,
  password: String (hashed),
  address: {
    street: String,
    district: String,
    city: String,
    coordinates: {
      lat: Number,
      lng: Number
    }
  },
  userType: "cook" | "customer",
  profileImage: String,
  bio: String,
  cuisineSpecialties: [String],
  rating: Number,
  totalReviews: Number,
  reviews: [{
    reviewer: ObjectId,
    rating: Number,
    comment: String,
    createdAt: Date
  }],
  isVerified: Boolean,
  isActive: Boolean,
  lastActive: Date,
  preferences: {
    dietaryRestrictions: [String],
    favoriteCuisines: [String],
    spiceLevel: String
  },
  createdAt: Date,
  updatedAt: Date
}
```

#### Recipes Collection

```javascript
{
  _id: ObjectId,
  cookId: ObjectId,
  title: String,
  description: String,
  ingredients: [{
    name: String,
    quantity: String,
    unit: String
  }],
  instructions: [{
    step: Number,
    description: String
  }],
  price: Number,
  currency: String,
  images: [{
    url: String,
    caption: String,
    isPrimary: Boolean
  }],
  cuisineType: String,
  category: String,
  preparationTime: Number,
  cookingTime: Number,
  servings: Number,
  difficulty: String,
  spiceLevel: String,
  dietaryInfo: {
    isVegetarian: Boolean,
    isVegan: Boolean,
    isGlutenFree: Boolean,
    isDairyFree: Boolean,
    isNutFree: Boolean,
    isHalal: Boolean,
    isKosher: Boolean
  },
  nutritionInfo: {
    calories: Number,
    protein: Number,
    carbohydrates: Number,
    fat: Number,
    fiber: Number,
    sugar: Number,
    sodium: Number
  },
  tags: [String],
  isAvailable: Boolean,
  isFeatured: Boolean,
  orderCount: Number,
  rating: Number,
  totalReviews: Number,
  reviews: [{
    reviewer: ObjectId,
    rating: Number,
    comment: String,
    createdAt: Date
  }],
  allergens: [String],
  specialNotes: String,
  createdAt: Date,
  updatedAt: Date
}
```

#### Orders Collection

```javascript
{
  _id: ObjectId,
  customerId: ObjectId,
  cookId: ObjectId,
  recipeId: ObjectId,
  quantity: Number,
  unitPrice: Number,
  totalPrice: Number,
  status: "pending" | "confirmed" | "preparing" | "ready" | "delivering" | "delivered" | "cancelled",
  deliveryAddress: {
    street: String,
    district: String,
    city: String,
    coordinates: {
      lat: Number,
      lng: Number
    }
  },
  deliveryInstructions: String,
  paymentMethod: "cash" | "card" | "wallet",
  paymentStatus: "pending" | "paid" | "failed",
  commission: Number,
  estimatedDeliveryTime: Date,
  actualDeliveryTime: Date,
  customerRating: {
    rating: Number,
    comment: String,
    createdAt: Date
  },
  cookRating: {
    rating: Number,
    comment: String,
    createdAt: Date
  },
  createdAt: Date,
  updatedAt: Date
}
```

#### Payments Collection

```javascript
{
  _id: ObjectId,
  orderId: ObjectId,
  customerId: ObjectId,
  cookId: ObjectId,
  amount: Number,
  commission: Number,
  paymentMethod: String,
  paymentStatus: String,
  transactionId: String,
  paymentDate: Date,
  createdAt: Date
}
```

### الفهارس (Indexes)

```javascript
// Users Collection
db.users.createIndex({ email: 1 }, { unique: true });
db.users.createIndex({ phone: 1 });
db.users.createIndex({ userType: 1 });
db.users.createIndex({ "address.coordinates": "2dsphere" });
db.users.createIndex({ rating: -1 });

// Recipes Collection
db.recipes.createIndex({ cookId: 1 });
db.recipes.createIndex({ cuisineType: 1 });
db.recipes.createIndex({ category: 1 });
db.recipes.createIndex({ price: 1 });
db.recipes.createIndex({ rating: -1 });
db.recipes.createIndex({ isAvailable: 1 });
db.recipes.createIndex({ isFeatured: 1 });
db.recipes.createIndex({ orderCount: -1 });

// Orders Collection
db.orders.createIndex({ customerId: 1 });
db.orders.createIndex({ cookId: 1 });
db.orders.createIndex({ status: 1 });
db.orders.createIndex({ createdAt: -1 });
db.orders.createIndex({ paymentStatus: 1 });

// Text Search Indexes
db.recipes.createIndex({
  title: "text",
  description: "text",
  "ingredients.name": "text",
  tags: "text",
});
```

---

## 🔌 API Endpoints

### Authentication

```
POST   /api/auth/register
POST   /api/auth/login
POST   /api/auth/logout
POST   /api/auth/refresh-token
POST   /api/auth/forgot-password
POST   /api/auth/reset-password
POST   /api/auth/verify-email
```

### Users

```
GET    /api/users/profile
PUT    /api/users/profile
PUT    /api/users/password
POST   /api/users/upload-avatar
GET    /api/users/:id
GET    /api/users/cooks
GET    /api/users/cooks/:id
POST   /api/users/:id/review
```

### Recipes

```
GET    /api/recipes
POST   /api/recipes
GET    /api/recipes/:id
PUT    /api/recipes/:id
DELETE /api/recipes/:id
POST   /api/recipes/:id/images
DELETE /api/recipes/:id/images/:imageId
GET    /api/recipes/search
GET    /api/recipes/featured
GET    /api/recipes/popular
```

### Orders

```
GET    /api/orders
POST   /api/orders
GET    /api/orders/:id
PUT    /api/orders/:id/status
POST   /api/orders/:id/rate
GET    /api/orders/customer/:customerId
GET    /api/orders/cook/:cookId
```

### Payments

```
POST   /api/payments/create
GET    /api/payments/:id
PUT    /api/payments/:id/status
GET    /api/payments/orders/:orderId
```

### Admin

```
GET    /api/admin/dashboard
GET    /api/admin/users
PUT    /api/admin/users/:id/status
GET    /api/admin/orders
GET    /api/admin/reports
```

---

## 🔒 الأمان

### المصادقة والتفويض

- **JWT Tokens:** للمصادقة
- **Refresh Tokens:** لتجديد الجلسات
- **Role-based Access Control:** للصلاحيات
- **Password Hashing:** باستخدام bcrypt

### حماية البيانات

- **Input Validation:** التحقق من المدخلات
- **SQL Injection Protection:** حماية من حقن SQL
- **XSS Protection:** حماية من XSS
- **CSRF Protection:** حماية من CSRF
- **Rate Limiting:** تحديد معدل الطلبات

### تشفير البيانات

- **HTTPS:** تشفير البيانات في النقل
- **Environment Variables:** حماية المتغيرات الحساسة
- **Data Encryption:** تشفير البيانات الحساسة

---

## ⚡ الأداء

### تحسين قاعدة البيانات

- **Indexing:** فهارس مناسبة
- **Query Optimization:** تحسين الاستعلامات
- **Connection Pooling:** تجميع الاتصالات
- **Caching:** التخزين المؤقت

### تحسين التطبيق

- **Code Splitting:** تقسيم الكود
- **Lazy Loading:** التحميل الكسول
- **Image Optimization:** تحسين الصور
- **CDN:** شبكة توصيل المحتوى

### المراقبة

- **Performance Monitoring:** مراقبة الأداء
- **Error Tracking:** تتبع الأخطاء
- **Logging:** تسجيل الأحداث
- **Analytics:** التحليلات

---

## 🧪 الاختبار

### أنواع الاختبارات

1. **Unit Tests:** اختبار الوحدات
2. **Integration Tests:** اختبار التكامل
3. **API Tests:** اختبار API
4. **UI Tests:** اختبار الواجهات
5. **Performance Tests:** اختبار الأداء

### أدوات الاختبار

- **Jest:** اختبار JavaScript
- **Supertest:** اختبار API
- **Cypress:** اختبار الواجهات
- **Flutter Test:** اختبار Flutter

### تغطية الاختبارات

- **Backend:** 80%+
- **Frontend:** 70%+
- **Mobile:** 75%+

---

## 🚀 النشر

### البيئات

1. **Development:** للتطوير
2. **Staging:** للاختبار
3. **Production:** للإنتاج

### منصات النشر

- **Backend:** Render.com
- **Frontend:** Netlify.com
- **Database:** MongoDB Atlas
- **Mobile:** Google Play Store, Apple App Store

### CI/CD Pipeline

1. **Code Push:** دفع الكود
2. **Automated Testing:** اختبار تلقائي
3. **Build:** بناء التطبيق
4. **Deploy:** نشر التطبيق

---

## 📊 المراقبة والتحليلات

### أدوات المراقبة

- **Application Performance Monitoring:** New Relic
- **Error Tracking:** Sentry
- **Logging:** Winston
- **Analytics:** Google Analytics

### المقاييس المهمة

- **Response Time:** وقت الاستجابة
- **Error Rate:** معدل الأخطاء
- **User Engagement:** تفاعل المستخدمين
- **Conversion Rate:** معدل التحويل

---

## 🔄 التحديثات والصيانة

### جدول التحديثات

- **Security Updates:** تحديثات أمنية فورية
- **Feature Updates:** تحديثات الميزات شهرياً
- **Performance Updates:** تحديثات الأداء ربع سنوياً
- **Major Updates:** تحديثات رئيسية سنوياً

### الصيانة

- **Backup:** نسخ احتياطية يومية
- **Monitoring:** مراقبة مستمرة
- **Support:** دعم فني
- **Documentation:** تحديث التوثيق

---

**🎯 هذه المواصفات التقنية ستساعد الفريق في تطوير منتج عالي الجودة ومتسق!**
