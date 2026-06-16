# 📸 ShutterSpace
> **Premium Unified Freelance Marketplace & Booking Platform for Photographers** — Built natively for iOS with Swift, UIKit, and Firebase integrations.

[![Swift Version](https://img.shields.io/badge/Swift-5.10-orange.svg?style=flat-square&logo=swift)](https://developer.apple.com/swift/)
[![Platform](https://img.shields.io/badge/Platform-iOS-blue.svg?style=flat-square)](https://developer.apple.com/ios/)
[![Backend](https://img.shields.io/badge/Backend-Firebase%20%28Auth%2C%20Firestore%29-yellow.svg?style=flat-square&logo=firebase)](https://firebase.google.com/)
[![CDN](https://img.shields.io/badge/Hosting-Cloudinary-blueviolet.svg?style=flat-square&logo=cloudinary)](https://cloudinary.com/)
[![Payment Gateway](https://img.shields.io/badge/Payments-Midtrans%20Sandbox-green.svg?style=flat-square)](https://midtrans.com/)

---

## 🌟 Overview
Freelance photographers make up a massive segment of the visual arts workforce, yet their administrative workflow is heavily fragmented—often relying on social media for discovery, chat apps for scheduling, and manual bank transfers for payments.

**ShutterSpace** unifies this entire workflow into a single, cohesive iOS mobile application. Clients can easily browse artist portfolios, check real-time availability, select customized service packages, and perform secure transactions natively.

---

## ⚡ Key Features

### 🔍 Photographer Discovery & Filters
- Browse freelance photographers categorized by specialties (e.g., product, event, portrait).
- Information-symmetry solutions allowing quick pricing comparisons and portfolio reviews.

### 🖼️ High-Performance Portfolios
- High-resolution portfolio galleries powered by **Cloudinary CDN** hosting to ensure lightning-fast image delivery.
- Interactive showcase displays allowing photographers to customize their catalog order.

### 📅 Availability & Package Management
- Native booking calendars where photographers can set their weekly availability slots.
- Custom service packages with transparent pricing, eliminating administrative negotiating overhead.

### 💳 Integrated Payments
- Direct secure checkouts utilizing **Midtrans Payment Gateway** integration.
- Instant booking confirmation upon payment receipt.

### 💬 Real-Time Chat System
- Native client-to-photographer messenger channel powered by Firestore.
- Offline caching for viewing conversations in low-connectivity areas.

### 🛡️ Admin Monitoring Panel
- Dedicated moderation interface for system administrators.
- Allows account status changes and reviewing in-app reports.

---

## 🛠️ Codebase Structure

```
ShutterSpace/
├── ShutterSpace/                    # iOS Core Application Code
│   ├── Views/                       # UIKit Layouts & Storyboard flows
│   ├── ViewModels/                  # State management controllers
│   ├── Models/                      # Core data schemas
│   ├── Services/                    # API wrappers (Cloudinary, Midtrans, Firebase)
│   └── Assets.xcassets              # Visual tokens and icons
├── ShutterSpace.xcodeproj           # Xcode project configuration
├── ShutterSpaceTests/               # XCTest Unit testing suites
└── ShutterSpaceUITests/             # UI workflow automated tests
```

---

## 🚀 Getting Started

1. Open the project folder in **Xcode 15+** by double-clicking `ShutterSpace.xcodeproj`.
2. Configure your API credentials inside `Secrets.xcconfig` (Midtrans Merchant IDs, Cloudinary configs, and Firebase configurations).
3. Ensure target is set to your preferred iOS Simulator (iOS 17+).
4. Run `Cmd + R` to compile and launch.

---

*Developed by Team ShutterSpace (Elifele Fredrik, Dave Tristian, Kenneth Jonathan, Stevanus Ivan).*
