# Vybe Cabs — Rider App

A ride-hailing application built with **Flutter**, **Riverpod**, **Firebase Authentication**, **Google Maps SDK**, and dynamic local persistence, following the strict Vybe Design System.

---

## 📱 Features & Highlights

### 1. Design System & Theme Engine
- Strictly implemented following the `colors.md` token architecture (`AppColors`).
- Zero hardcoded hex colors across screens and reusable widgets.
- Clean typography hierarchy using the custom **Inter** font family (`Inter-Regular`, `Inter-Medium`, `Inter-SemiBold`, `Inter-Bold`, `Inter-ExtraBold`).
- High quality UI matching the reference design:
  - **Welcome & Splash**: Branded taxi illustrations, animated logo, clear value proposition.
  - **OTP Verification**: 4-digit individual digit boxes, countdown timer, auto-detect spinner, and manual fallback banner.
  - **Profile Setup**: Required first name, optional last name.
  - **Home Dashboard**: Dynamic time-based greeting, multi-category tabs (`Ride`, `Work`, `Care`), 3D card layout (`Quick Ride`, `Airport Pickup`, `Scheduled Ride`), Switch Account sheet, and Profile Menu sheet.

### 2. Multi-Stop Route Selection & Real Google Map SDK
- Centered on the user's location (`2066, Nripen Ghosh Sarani Rd, Kolkata`).
- Interactive Google Map with live markers for Pickup (Azure), Stops (Yellow), and Destination (Orange).
- Supports **multiple intermediate stops** with dynamic fare recalculation (base fare + ₹25 per additional stop).
- Instant search filtering across popular landmarks.

### 3. Vehicle Tiers: Car, Bike, and Tirri
- **Vybe Go (Car)**: Compact AC sedans / hatchbacks with 4 seats.
- **Vybe Moto (Bike)**: Fast bike taxi with verified riders & safety helmet.
- **Vybe Tirri (E-Rickshaw)**: Iconic Kolkata Toto / zero-emission E-Rickshaw for quick local transit.
- **Vybe Prime Sedan**: Spacious luxury sedans with chauffeurs.

### 4. End-to-End Live Ride Simulation
- **Finding Driver**: Radar ripple pulse animation (`VybeAnimatedPulse`) with *"Waiting for drivers to accept your request"*.
- **Driver Accepted**: Matched driver details (photo, vehicle name, license plate, 4.9+ star rating).
- **Secure Start PIN**: 4-digit PIN displayed on screen for the rider to share with the driver before departure.
- **Driver En-Route Movement**: Smooth animated vehicle marker movement along realistic street waypoints with camera bearing alignment.
- **Driver Arrived**: Status banner transition notifying rider that driver is at pickup point.
- **Ride In Progress**: Marker moves along route waypoints to destination.
- **Flexible In-Transit Payment**: Rider can choose to pay before trip completion or upon arrival.
- **Payment Options**: Supports **UPI** (Google Pay, PhonePe, Paytm), **Credit/Debit Cards**, and **Cash Payment**.
- **Payment & Completion Animation**: Scale/bounce tick animation and rating card with 1–5 stars.

### 5. Dynamic Local Storage Persistence
- Built on `SharedPreferences` via `LocalStorageService`.
- No backend server required: dynamically stores user profiles, authentication sessions, and past ride receipts.
- Includes 6 realistic seeded trips, and newly completed rides immediately prepended and persisted reactively in **Your Trips**.

---

## 🏛️ Project Architecture

Organized using Riverpod's Feature-First layered architecture:

```
lib/
├── core/
│   ├── theme/
│   │   ├── app_colors.dart        # Semantic color tokens from colors.md
│   │   ├── app_typography.dart    # Inter font styles & text hierarchy
│   │   └── app_theme.dart         # Material 3 ThemeData
│   ├── constants/
│   │   └── app_constants.dart     # Coordinates, storage keys, waypoints
│   ├── services/
│   │   ├── local_storage_service.dart # SharedPreferences dynamic storage
│   │   └── location_service.dart      # Device GPS & location permissions
│   └── widgets/
│       ├── vybe_button.dart       # Reusable button with tap micro-interactions
│       ├── vybe_text_field.dart   # Design system input field
│       ├── vybe_card.dart         # Consistent surface cards & shadows
│       ├── vybe_badge.dart        # Status & feature badges
│       ├── vybe_bottom_sheet.dart # Modal bottom sheet container
│       └── vybe_animated_pulse.dart # Radar driver search ripple animation
└── features/
    ├── auth/
    │   ├── domain/user_model.dart
    │   ├── data/auth_repository.dart
    │   └── presentation/
    │       ├── controllers/auth_controller.dart
    │       └── screens/ (splash, get_started, phone_input, otp_verification, enter_name)
    ├── home/
    │   └── presentation/
    │       ├── screens/home_screen.dart
    │       └── widgets/ (switch_account_sheet, profile_menu_sheet)
    ├── booking/
    │   ├── domain/ (location_item, vehicle_tier)
    │   ├── data/booking_dummy_data.dart
    │   └── presentation/
    │       ├── controllers/booking_controller.dart
    │       └── screens/ (location_selector_screen, vehicle_selection_sheet)
    ├── tracking/
    │   ├── domain/ (driver_model, ride_state)
    │   └── presentation/
    │       ├── controllers/tracking_controller.dart
    │       ├── screens/live_tracking_screen.dart
    │       └── widgets/ (finding_driver_card, driver_info_card, payment_bottom_sheet, trip_completed_dialog)
    └── history/
        └── presentation/
            ├── controllers/history_controller.dart
            └── screens/ride_history_screen.dart
```

---

## 🧪 Testing & Verification

Comprehensive unit tests verifying the state machine, local storage, booking controller, and tracking simulation are included in `test/booking_and_tracking_test.dart`:

```bash
flutter test
```

To run the app:

```bash
flutter run
```

To build a release or debug APK:

```bash
flutter build apk --debug
```
Output artifact: `build/app/outputs/flutter-apk/app-debug.apk`
