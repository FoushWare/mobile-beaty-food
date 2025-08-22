# 🧪 **Flutter Auth Integration Testing Guide**

## 🚀 **Quick Start**

1. **Start Backend**: Make sure your NestJS backend is running on `http://localhost:3000`
2. **Run Flutter App**: Execute `flutter run` in the `Beaty_flutter` directory
3. **Test Authentication Flow**: Follow the steps below

## 🔐 **Authentication Flow Testing**

### **Step 1: Phone Verification**

- Navigate to phone verification screen
- Enter any phone number (e.g., `+201234567890`)
- Click "إرسال رمز التحقق" (Send OTP)
- **Expected**: Fixed OTP `1234` should be displayed in development info

### **Step 2: OTP Verification**

- Enter the fixed OTP: `1234`
- Click "تحقق من الرمز" (Verify OTP)
- **Expected**: Success message and navigation to profile completion

### **Step 3: Basic Profile Completion**

- Enter your name and email
- Select user type (Customer or Chef)
- Click "إكمال الملف الشخصي" (Complete Basic Profile)
- **Expected**: Profile saved and navigation to next step

### **Step 4: Profile Completion (Customer)**

- If you selected Customer, complete address and preferences
- **Expected**: Full profile completion

### **Step 5: Chef Verification (Chef)**

- If you selected Chef, complete chef-specific information
- **Expected**: Chef verification completion

## 📱 **Test Scenarios**

### **✅ Happy Path**

1. Phone → OTP → Basic Profile → Complete Profile → Success
2. Phone → OTP → Basic Profile → Chef Verification → Success

### **❌ Error Scenarios**

1. **Invalid Phone**: Enter less than 10 digits
2. **Invalid OTP**: Enter wrong OTP (not `1234`)
3. **Network Error**: Turn off backend and test error handling
4. **Validation Errors**: Submit forms without required fields

### **🔄 Edge Cases**

1. **Resend OTP**: Test resend functionality
2. **Back Navigation**: Navigate back and forth between screens
3. **State Persistence**: Test if auth state persists after app restart

## 🧪 **API Testing with Backend**

### **Backend Status Check**

```bash
# Check if backend is running
curl http://localhost:3000/api/health

# Expected: {"status":"ok","timestamp":"..."}
```

### **Test OTP Endpoint**

```bash
# Send OTP
curl -X POST http://localhost:3000/api/auth/send-otp \
  -H "Content-Type: application/json" \
  -d '{"phone":"+201234567890"}'

# Expected: {"success":true,"message":"OTP sent successfully",...}
```

### **Test OTP Verification**

```bash
# Verify OTP
curl -X POST http://localhost:3000/api/auth/verify-otp \
  -H "Content-Type: application/json" \
  -d '{"phone":"+201234567890","otp":"1234"}'

# Expected: {"success":true,"message":"OTP verified successfully",...}
```

## 📊 **Expected Results**

### **Authentication States**

- **Initial**: Loading spinner
- **Unauthenticated**: Welcome screen with login buttons
- **Authenticated**: User dashboard with profile info
- **Error**: Error message with retry button

### **Profile Levels**

- **Mobile Verified**: Orange badge
- **Basic Profile**: Blue badge
- **Complete Profile**: Green badge
- **Chef Verified**: Purple badge

### **Data Display**

- Sample recipes should load from seed data
- User information should display correctly
- Profile completion status should update

## 🐛 **Troubleshooting**

### **Common Issues**

#### **1. Backend Connection Error**

```
Error: Network error
```

**Solution**: Ensure backend is running on `http://localhost:3000`

#### **2. OTP Verification Fails**

```
Error: Invalid OTP
```

**Solution**: Use fixed OTP `1234` for development

#### **3. Navigation Issues**

```
Error: Route not found
```

**Solution**: Check if all screens are properly registered in router

#### **4. State Management Issues**

```
Error: Provider not found
```

**Solution**: Ensure AuthProvider is properly wrapped in MultiProvider

### **Debug Commands**

#### **Flutter Debug**

```bash
# Check Flutter version
flutter --version

# Clean and rebuild
flutter clean
flutter pub get
flutter run

# Check for errors
flutter analyze
```

#### **Backend Debug**

```bash
# Check backend logs
cd Beaty-food-BE
npm run start:dev

# Check database
npm run db:studio
```

## 📱 **Mobile Testing**

### **iOS Simulator**

```bash
flutter run -d ios
```

### **Android Emulator**

```bash
flutter run -d android
```

### **Physical Device**

```bash
flutter devices
flutter run -d <device-id>
```

## 🔍 **Logging & Debugging**

### **Enable Debug Logs**

```dart
// In auth_service.dart
print('🚨 DEVELOPMENT MODE: Fixed OTP for $phone: $_fixedOtp');
print('📱 In production, this would be sent via SMS service');
```

### **Check Network Requests**

- Use Flutter Inspector to monitor network calls
- Check backend logs for incoming requests
- Verify request/response payloads

### **State Debugging**

```dart
// In auth_provider.dart
print('Auth State: ${_state}');
print('Auth Data: ${_authData}');
print('Profile Data: ${_profileData}');
```

## ✅ **Success Criteria**

### **Authentication Flow**

- [ ] Phone verification works
- [ ] OTP verification works with fixed code `1234`
- [ ] Basic profile completion works
- [ ] Profile completion works for customers
- [ ] Chef verification works for chefs
- [ ] Login/logout functionality works

### **State Management**

- [ ] Auth state persists across app restarts
- [ ] Profile data loads correctly
- [ ] Error states are handled gracefully
- [ ] Loading states are displayed

### **UI/UX**

- [ ] All screens render correctly
- [ ] Navigation works smoothly
- [ ] Error messages are user-friendly
- [ ] Loading indicators are visible

### **Data Integration**

- [ ] Backend APIs are called correctly
- [ ] Response data is parsed correctly
- [ ] Seed data displays properly
- [ ] User data is stored locally

## 🎯 **Next Steps After Testing**

1. **Complete Profile Screens**: Implement remaining profile completion screens
2. **Recipe Management**: Add recipe browsing and ordering
3. **User Dashboard**: Enhance authenticated user experience
4. **Error Handling**: Improve error messages and recovery
5. **Offline Support**: Add offline functionality and caching

---

**Ready to test your Flutter authentication integration! 🚀**


