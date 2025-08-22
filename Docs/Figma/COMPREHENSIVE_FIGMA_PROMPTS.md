# Baty Food - Comprehensive Figma Design Prompts 🎨

## 🎯 Overview

This document contains detailed prompts for generating complete Figma designs for the Baty Food application. Each prompt is designed to be used with Figma AI tools to create comprehensive, production-ready designs.

**Figma Design Tool:** [Baty Food Application](https://www.figma.com/make/9VpNwReXziKngp9aDajZWK/Baty-Food-Application?node-id=0-1&p=f&t=7NgHyDgGquVdqYxr-0)

## 🎨 Design System Foundation

### Brand Identity

- **Primary Color:** #FF6B35 (Warm Orange)
- **Secondary Color:** #2E8B57 (Natural Green)
- **Accent Color:** #FFD700 (Golden)
- **Background:** #F8F9FA (Light Gray)
- **Text:** #343A40 (Dark Gray)
- **Typography:** Cairo Font Family (Bold 700, Regular 400, Light 300)

### Design Principles

- **Mobile-First:** Responsive design starting from mobile
- **Accessibility:** High contrast, readable fonts, clear touch targets
- **Consistency:** Unified design language across all screens
- **User-Centric:** Intuitive navigation and clear call-to-actions
- **shadcn/ui Integration:** Design components that align with shadcn/ui patterns

### Input Field Guidelines

- **Background:** Always white (#FFFFFF) for input fields
- **Text Color:** Black (#000000) for input text
- **Border:** Light gray (#E5E7EB) for normal state
- **Focus State:** Orange border (#FF6B35) with subtle shadow
- **Error State:** Red border (#EF4444) with error message below
- **Placeholder:** Medium gray (#6B7280) text

---

## 📱 Mobile Application Designs

### 1. Splash Screen & Onboarding

**Prompt:**

```
Create a mobile splash screen for "Baty Food" - a home-cooked food delivery app. Design includes:
- App logo (chef hat with fork and knife icon)
- App name "Baty Food" in Cairo Bold
- Tagline "Home-cooked meals delivered to your door"
- Loading animation (pulsing chef hat icon)
- Background gradient from orange (#FF6B35) to green (#2E8B57)
- Screen size: 375x812px (iPhone X)
- Include subtle food illustrations in background
- Modern, clean design with warm, inviting colors
- Design should be compatible with shadcn/ui component patterns
```

### 2. Authentication Screens

**Login Screen Prompt:**

```
Design a mobile login screen for Baty Food app with:
- App logo at top center
- "Welcome Back" heading in Cairo Bold
- Email input field with envelope icon (white background, black text, light gray border)
- Password input field with lock icon and show/hide toggle (white background, black text)
- "Forgot Password?" link
- Primary login button (orange background #FF6B35)
- "Or continue with" divider
- Social login buttons (Google, Facebook)
- "Don't have an account? Sign up" link at bottom
- Clean, modern design with proper spacing
- Screen size: 375x812px
- All input fields must have white backgrounds with black text
- Design should align with shadcn/ui input component patterns
```

**Sign Up Screen Prompt:**

```
Create a mobile signup screen for Baty Food with:
- App logo and "Create Account" heading
- Full name input field (white background, black text)
- Email input field (white background, black text)
- Phone number input field (white background, black text)
- Password input field with strength indicator (white background, black text)
- Confirm password field (white background, black text)
- User type selection (Customer/Cook) with radio buttons
- Terms and conditions checkbox
- Primary "Create Account" button (orange background)
- "Already have an account? Sign in" link
- Clean form layout with proper validation states
- Screen size: 375x812px
- All input fields must have white backgrounds with black text
- Design should align with shadcn/ui form component patterns
```

### 3. Customer App - Home Screen

**Prompt:**

```
Design a customer home screen for Baty Food mobile app featuring:
- Header with profile avatar, search icon, and cart icon
- "What would you like to eat today?" heading
- Search bar with location icon and "Search for dishes..." (white background, black text)
- Food categories horizontal scroll (Egyptian, Italian, Asian, Desserts, etc.)
- "Featured Chefs" section with chef cards showing:
  * Chef profile picture
  * Chef name and rating
  * Speciality cuisine
  * "View Menu" button
- "Popular Dishes" section with recipe cards showing:
  * Food image
  * Dish name and chef name
  * Price and rating
  * "Add to Cart" button
- Bottom navigation with Home, Search, Orders, Profile icons
- Warm, inviting design with food imagery
- Screen size: 375x812px
- Design should align with shadcn/ui card and button component patterns
```

### 4. Recipe Detail Screen

**Prompt:**

```
Create a detailed recipe screen for Baty Food mobile app with:
- Hero image of the dish (full width)
- Back arrow and heart/favorite icon overlay
- Dish name in large Cairo Bold font
- Chef information with profile picture, name, and rating
- Price prominently displayed
- Description text with ingredients and cooking style
- "Ingredients" section with bullet points
- "Reviews" section showing star ratings and comments
- Quantity selector (+ and - buttons)
- "Add to Cart" primary button (orange background)
- "Order Now" secondary button
- Related dishes carousel at bottom
- Clean, appetizing design with high-quality food photography
- Screen size: 375x812px
- Design should align with shadcn/ui card and button component patterns
```

### 5. Cart Screen

**Prompt:**

```
Design a shopping cart screen for Baty Food mobile app featuring:
- Header with "Your Cart" title and back arrow
- Cart items list with:
  * Food image thumbnail
  * Dish name and chef name
  * Price per item
  * Quantity controls (+ and -)
  * Remove item button
- Subtotal, delivery fee, and total calculations
- Delivery address section with edit option
- Delivery time selection
- Special instructions text area (white background, black text)
- "Proceed to Checkout" primary button (orange background)
- "Continue Shopping" secondary button
- Empty cart state with illustration
- Clean, organized layout with clear pricing
- Screen size: 375x812px
- All input fields must have white backgrounds with black text
- Design should align with shadcn/ui card and form component patterns
```

### 6. Checkout Screen

**Prompt:**

```
Create a comprehensive checkout screen for Baty Food mobile app with:
- Header with "Checkout" title and back arrow
- Order summary section with items and total
- Delivery address confirmation with edit option
- Delivery time selection with time slots
- Payment method selection:
  * Credit/Debit card option
  * Digital wallets (Apple Pay, Google Pay)
  * Cash on delivery option
- Card input form with validation (white background, black text):
  * Card number field
  * Expiry date field
  * CVV field
  * Cardholder name field
- Billing address section (white background, black text)
- Special instructions field (white background, black text)
- Terms and conditions checkbox
- "Place Order" primary button (orange background)
- Security badges and trust indicators
- Clean, secure payment interface
- Screen size: 375x812px
- All input fields must have white backgrounds with black text
- Design should align with shadcn/ui form and button component patterns
```

### 7. Browse Recipes Screen

**Prompt:**

```
Design a comprehensive recipe browse screen for Baty Food mobile app with:
- Header with search bar and filter icon
- Search bar with "Search recipes..." placeholder (white background, black text)
- Filter options section:
  * Cuisine type filter (multi-select)
  * Price range slider
  * Rating filter
  * Dietary restrictions (vegetarian, vegan, gluten-free)
  * Chef rating filter
- Sort options (Relevance, Price, Rating, Popularity)
- Recipe grid showing:
  * High-quality food images
  * Recipe name and chef name
  * Price and rating
  * Quick "Add to Cart" button
  * "View Details" link
- Pagination or infinite scroll
- "Clear Filters" button
- Loading states with skeleton cards
- Empty state with illustration
- Clean, intuitive filter interface
- Screen size: 375x812px
- All input fields must have white backgrounds with black text
- Design should align with shadcn/ui card, button, and form component patterns
```

### 8. Featured Cooks Screen

**Prompt:**

```
Create a featured cooks screen for Baty Food mobile app featuring:
- Header with "Featured Chefs" title and search icon
- Search bar with "Search chefs..." placeholder (white background, black text)
- Filter options:
  * Cuisine speciality
  * Rating filter
  * Distance radius
  * Availability status
- Chef cards showing:
  * Chef profile picture
  * Chef name and rating
  * Speciality cuisine
  * Years of experience
  * Number of dishes available
  * Response time
  * "View Profile" button
- Grid layout with proper spacing
- "Follow Chef" functionality
- Chef verification badges
- Online/offline status indicators
- Clean, professional chef showcase
- Screen size: 375x812px
- All input fields must have white backgrounds with black text
- Design should align with shadcn/ui card and button component patterns
```

### 9. Cook Profile Screen

**Prompt:**

```
Design a detailed cook profile screen for Baty Food mobile app with:
- Hero section with chef profile picture and cover image
- Chef name, rating, and verification badge
- "Follow" and "Message" buttons
- Chef bio and speciality information
- "About" section with:
  * Years of experience
  * Certifications
  * Kitchen photos
  * Operating hours
- Menu section with categorized dishes
- Reviews and ratings from customers
- Contact information and response time
- "View Full Menu" button
- "Start Order" primary button (orange background)
- Chef's kitchen photos gallery
- Availability calendar
- Clean, professional profile layout
- Screen size: 375x812px
- Design should align with shadcn/ui card, button, and avatar component patterns
```

### 10. Order Tracking Screen

**Prompt:**

```
Create an order tracking screen for Baty Food mobile app with:
- Order number and status header
- Progress timeline showing:
  * Order confirmed (checkmark)
  * Chef preparing (cooking icon)
  * Out for delivery (delivery icon)
  * Delivered (house icon)
- Estimated delivery time
- Chef information with contact button
- Order details list with items and quantities
- Delivery address
- Payment method used
- "Contact Support" button
- "Rate Your Order" button
- Real-time status updates
- Clean timeline design with icons
- Screen size: 375x812px
- Design should align with shadcn/ui progress and card component patterns
```

### 11. Customer Profile Screen

**Prompt:**

```
Design a customer profile screen for Baty Food mobile app featuring:
- Profile header with avatar, name, and edit button
- "My Account" section with:
  * Personal information
  * Addresses (home, work, etc.)
  * Payment methods
  * Preferences (dietary restrictions, allergies)
- "My Orders" section with order history
- "Favorites" section with saved dishes
- "Settings" section with:
  * Notifications
  * Language
  * Currency
  * Privacy settings
- "Support" section with help center and contact
- "Logout" button
- Clean, organized menu-style layout
- Screen size: 375x812px
- All input fields must have white backgrounds with black text
- Design should align with shadcn/ui card and form component patterns
```

### 12. Cook App - Dashboard

**Prompt:**

```
Create a cook dashboard for Baty Food mobile app with:
- Header with cook profile picture and name
- "Today's Overview" section with:
  * Orders received (number)
  * Orders completed (number)
  * Earnings today (amount)
  * Rating (stars)
- "New Orders" section with order cards showing:
  * Customer name and order time
  * Order items and quantities
  * Total amount
  * Accept/Decline buttons
- "Active Orders" section with cooking progress
- "Today's Menu" quick access
- "Earnings" chart (weekly/monthly)
- Bottom navigation with Dashboard, Orders, Menu, Profile
- Professional, clean design for cooks
- Screen size: 375x812px
- Design should align with shadcn/ui card, button, and progress component patterns
```

### 13. Recipe Management Screen

**Prompt:**

```
Design a recipe management screen for cooks in Baty Food app with:
- Header with "My Recipes" title and "Add New" button
- Recipe cards showing:
  * Food image
  * Recipe name and category
  * Price and availability status
  * Edit and delete buttons
- "Add New Recipe" form with:
  * Recipe name input (white background, black text)
  * Category selection
  * Description text area (white background, black text)
  * Ingredients list with add/remove
  * Price input (white background, black text)
  * Cooking time
  * Image upload
  * Availability toggle
- Search and filter options
- Bulk actions (enable/disable multiple)
- Clean, organized layout for easy management
- Screen size: 375x812px
- All input fields must have white backgrounds with black text
- Design should align with shadcn/ui form, card, and button component patterns
```

### 14. Order Management Screen

**Prompt:**

```
Create an order management screen for cooks in Baty Food app featuring:
- Header with "Orders" title and filter options
- Order status tabs (New, Preparing, Ready, Completed)
- Order cards showing:
  * Order number and time
  * Customer name and delivery address
  * Order items with quantities
  * Special instructions
  * Total amount
  * Status update buttons
- "Accept Order" and "Start Cooking" actions
- "Mark as Ready" and "Complete Order" buttons
- Order history with ratings and feedback
- Real-time notifications
- Professional, efficient layout
- Screen size: 375x812px
- Design should align with shadcn/ui card, button, and tabs component patterns
```

---

## 💻 Web Application Designs

### 15. Web Landing Page

**Prompt:**

```
Design a modern landing page for Baty Food website with:
- Navigation bar with logo, menu items, and login/signup buttons
- Hero section with:
  * Compelling headline "Home-cooked meals delivered to your door"
  * Subheading explaining the service
  * Search bar with location and cuisine filters (white background, black text)
  * CTA button "Find Your Perfect Meal"
  * Hero image showing delicious home-cooked food
- "How It Works" section with 3 steps
- "Featured Chefs" section with chef profiles
- "Popular Cuisines" section with food categories
- Customer testimonials carousel
- "Download App" section with QR codes
- Footer with links and social media
- Responsive design for desktop (1440px width)
- Modern, clean design with food photography
- All input fields must have white backgrounds with black text
- Design should align with shadcn/ui component patterns
```

### 16. Web Customer Dashboard

**Prompt:**

```
Create a web customer dashboard for Baty Food with:
- Sidebar navigation with user profile and menu items
- Main content area with:
  * Welcome message and quick stats
  * Recent orders with status
  * Favorite dishes carousel
  * Recommended chefs
  * Quick order buttons
- Search functionality with advanced filters (white background, black text)
- Order history table with details
- Profile settings panel
- Address management
- Payment methods section
- Responsive design for desktop and tablet
- Clean, modern interface with intuitive navigation
- Screen size: 1440x900px
- All input fields must have white backgrounds with black text
- Design should align with shadcn/ui sidebar, card, and table component patterns
```

### 17. Web Cook Dashboard

**Prompt:**

```
Design a comprehensive web cook dashboard for Baty Food featuring:
- Sidebar with cook profile and navigation menu
- Main dashboard with:
  * Revenue charts and statistics
  * Order management table
  * Menu management interface
  * Customer reviews and ratings
  * Earnings breakdown
- Recipe management with drag-and-drop interface
- Order processing workflow
- Analytics and reporting section
- Settings and preferences
- Professional, data-rich interface
- Responsive design for desktop
- Screen size: 1440x900px
- All input fields must have white backgrounds with black text
- Design should align with shadcn/ui sidebar, table, and chart component patterns
```

### 18. Web Recipe Browse Page

**Prompt:**

```
Create a recipe browse page for Baty Food website with:
- Header with search bar and filter options
- Sidebar filters for:
  * Cuisine type
  * Price range
  * Rating
  * Dietary restrictions
  * Chef rating
- Main content grid showing recipe cards with:
  * High-quality food images
  * Recipe name and chef
  * Price and rating
  * Quick add to cart button
  * View details link
- Pagination or infinite scroll
- Sort options (price, rating, popularity)
- Responsive grid layout
- Clean, appetizing design
- Screen size: 1440x900px
- All input fields must have white backgrounds with black text
- Design should align with shadcn/ui card, button, and form component patterns
```

---

## 🎨 Component Library

### 19. Design System Components

**Prompt:**

```
Create a comprehensive design system for Baty Food including:
- Button components (Primary, Secondary, Ghost, Danger) - align with shadcn/ui
- Input fields (Text, Email, Password, Search) - white background, black text
- Cards (Recipe, Chef, Order, Review) - align with shadcn/ui card patterns
- Navigation components (Header, Sidebar, Bottom Nav) - align with shadcn/ui
- Form components (Checkbox, Radio, Select, Toggle) - align with shadcn/ui
- Feedback components (Alert, Toast, Loading, Empty State) - align with shadcn/ui
- Data display (Tables, Lists, Charts) - align with shadcn/ui
- Icons and illustrations
- Color palette with all variations
- Typography scale
- Spacing system
- Shadow and elevation system
- Responsive breakpoints
- Accessibility guidelines
- Component documentation
- All input fields must have white backgrounds with black text
```

---

## 📱 Additional Mobile Screens

### 20. Search & Filter Screen

**Prompt:**

```
Design a search and filter screen for Baty Food mobile app with:
- Search bar with voice input option (white background, black text)
- Recent searches list
- Popular searches tags
- Filter options:
  * Cuisine type (multi-select)
  * Price range slider
  * Rating filter
  * Distance radius
  * Dietary restrictions
  * Chef rating
- Sort options (Relevance, Price, Rating, Distance)
- Search results with recipe cards
- "Clear Filters" button
- Clean, intuitive filter interface
- Screen size: 375x812px
- All input fields must have white backgrounds with black text
- Design should align with shadcn/ui form and card component patterns
```

### 21. Chef Profile Screen

**Prompt:**

```
Create a chef profile screen for Baty Food mobile app featuring:
- Chef header with profile picture, name, and rating
- Chef bio and speciality information
- "About" section with experience and certifications
- Menu section with categorized dishes
- Reviews and ratings from customers
- Contact information and response time
- "Follow Chef" button
- "Message Chef" option
- Chef's kitchen photos
- Operating hours and availability
- Clean, professional profile layout
- Screen size: 375x812px
- Design should align with shadcn/ui card, button, and avatar component patterns
```

### 22. Payment & Checkout Screen

**Prompt:**

```
Design a payment and checkout screen for Baty Food mobile app with:
- Order summary with items and total
- Delivery address confirmation
- Delivery time selection
- Payment method selection:
  * Credit/Debit card
  * Digital wallets
  * Cash on delivery
- Card input form with validation (white background, black text)
- Billing address section (white background, black text)
- Special instructions field (white background, black text)
- Terms and conditions checkbox
- "Place Order" primary button (orange background)
- Security badges and trust indicators
- Clean, secure payment interface
- Screen size: 375x812px
- All input fields must have white backgrounds with black text
- Design should align with shadcn/ui form and button component patterns
```

### 23. Notifications Screen

**Prompt:**

```
Create a notifications screen for Baty Food mobile app featuring:
- Header with "Notifications" title and settings icon
- Notification categories (All, Orders, Promotions, System)
- Notification cards showing:
  * Notification icon and type
  * Title and message
  * Timestamp
  * Action buttons if applicable
- Mark all as read option
- Notification settings
- Empty state with illustration
- Pull-to-refresh functionality
- Clean, organized notification list
- Screen size: 375x812px
- Design should align with shadcn/ui card and button component patterns
```

### 24. Settings Screen

**Prompt:**

```
Design a comprehensive settings screen for Baty Food mobile app with:
- Profile settings section
- Account preferences
- Notification settings with toggles
- Privacy and security options
- Language and region settings
- Currency preferences
- Dietary preferences and allergies (white background, black text)
- Payment methods management
- Address book
- App preferences (theme, font size)
- Help and support section
- About app and legal information
- Logout button
- Clean, organized settings menu
- Screen size: 375x812px
- All input fields must have white backgrounds with black text
- Design should align with shadcn/ui form and card component patterns
```

---

## 🎯 Implementation Guidelines

### Design Delivery

1. **Figma File Structure:**

   - Organize screens by user type (Customer, Cook, Web)
   - Create component library with reusable elements
   - Use consistent naming conventions
   - Include responsive variants

2. **Asset Requirements:**

   - High-quality food photography
   - Chef profile images
   - App icons and illustrations
   - Loading animations
   - Empty state illustrations

3. **Design Specifications:**

   - Include all color codes and typography
   - Specify spacing and sizing
   - Document interaction states
   - Provide accessibility guidelines
   - **IMPORTANT:** All input fields must have white backgrounds with black text

4. **Developer Handoff:**
   - Export all assets in multiple formats
   - Include CSS variables and design tokens
   - Document component behavior
   - Provide responsive breakpoints
   - Include shadcn/ui component mapping

### Quality Assurance

- Test designs on multiple screen sizes
- Ensure accessibility compliance
- Validate color contrast ratios
- Review user flow and navigation
- Test with real content and data
- Verify all input fields have white backgrounds with black text

---

## 🚀 Next Steps

1. **Phase 1:** Create core screens (Splash, Auth, Home, Recipe Detail)
2. **Phase 2:** Build customer app screens (Cart, Checkout, Browse, Cook Profiles)
3. **Phase 3:** Develop cook app screens (Dashboard, Management)
4. **Phase 4:** Design web application screens
5. **Phase 5:** Create component library and design system
6. **Phase 6:** Review, refine, and prepare for development

---

**🎨 Ready to create amazing designs for Baty Food! 🍽️**

**Figma Design Tool:** [Baty Food Application](https://www.figma.com/make/9VpNwReXziKngp9aDajZWK/Baty-Food-Application?node-id=0-1&p=f&t=7NgHyDgGquVdqYxr-0)
