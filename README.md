# Nukkad 🏘️
> **Buy, Sell, Lend & Help — Right Around You.**

[![Flutter](https://img.shields.io/badge/Flutter-3.44.6-02569B?style=for-the-badge&logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.12.2-0175C2?style=for-the-badge&logo=dart)](https://dart.dev)
[![State Management](https://img.shields.io/badge/Riverpod-2.6.1-059669?style=for-the-badge)](https://riverpod.dev)
[![Persistence](https://img.shields.io/badge/Hive-Offline--First-FF6F00?style=for-the-badge)](https://pub.dev/packages/hive)
[![Tests](https://img.shields.io/badge/Unit%20Tests-100%25%20Passing-success?style=for-the-badge)](#-test-suite--verification)

**Nukkad** is a local-first neighborhood marketplace built with Flutter. It allows residents of a single locality to create, discover, save, contact, and manage hyper-local listings completely offline—without complex cloud infrastructure, tracking, or invasive registration.

---

## ✨ Features Suite

- 🛍️ **4 Hyper-Local Categories**: Explore **Sell**, **Buy**, **Lend**, and **Help** items within your locality.
- 🏷️ **Price & Offer Strikethrough Engine**: Prominent current price display alongside original price strikethroughs (e.g. `₹4,800` vs `~~₹6,500~~`) and red neighborhood discount offer badges.
- 🤖 **AI Insights & Trust Analysis Panel**: Real-time listing quality score (0–100), concise product intelligence traits (e.g., `✅ Clear title`, `✅ Locality specified`, `⚠️ No photo provided`), and actionable AI recommendations.
- 💬 **Branded Local Contact Triggers**: Tailored, brand-styled triggers for **WhatsApp** (`Color(0xFF25D366)`), **Phone Calls**, and **In-Person Meetups**.
- 📌 **Offline Bookmark & State Management**: Bookmark favorite listings locally and manage listing statuses (*Active*, *Contacted*, *Closed*) with instant Hive persistence.
- 🎨 **Emerald Light Mode Design System**: Material 3 interface featuring Emerald Green (`#059669`), Slate surfaces, high-resolution product visuals, and dual CORS network/graphic banner fallbacks.

---

## 🏛️ Clean Architecture & AI Isolation

The codebase is structured according to **Clean Architecture** principles, enforcing a strict unidirectional dependency graph:

```
lib/
├── core/
│   ├── constants/        # App-wide categories, localities, contact methods
│   ├── router/           # GoRouter route declarations
│   └── theme/            # Emerald Light Mode Material 3 design system
├── features/
│   ├── ai/               # Isolated Local AI feature slice
│   │   ├── domain/       # LocalAiService interface & AiListingInsights models
│   │   ├── data/         # FallbackLocalAiService deterministic rule engine
│   │   └── presentation/ # AiFeedbackCard & AiInsightsCard widgets
│   ├── home/             # Main Feed & Splash screens
│   ├── listing/          # Listing domain model, Hive datasource, repository, CRUD screens
│   ├── saved/            # Saved/Bookmarked items view
│   └── settings/         # Privacy baseline & theme configuration
└── shared/               # Reusable widgets (ListingCard, search bars)
```

### 🔒 Architectural Isolation of Local AI
The **Local AI Service** is completely decoupled behind an abstract contract (`LocalAiService`). The application relies on `FallbackLocalAiService`—a deterministic, offline rule-based engine that evaluates listing quality, trust scores, and buyer recommendations locally without internet access, external API keys, or cloud tracking.

---

## 📚 Architectural Documentation Index

All architectural decisions and lab requirement documentation are maintained in the repository:

- 📄 [`docs/product-slice.md`](docs/product-slice.md) — Comprehensive product scope and bounded context breakdown.
- 📈 [`docs/success-metrics.md`](docs/success-metrics.md) — Target UX metrics and offline reliability benchmarks.
- ♿ [`docs/accessibility-check.md`](docs/accessibility-check.md) — WCAG 2.1 touch-target and screen-reader audit.
- 🔒 [`docs/security-baseline.md`](docs/security-baseline.md) — Locality privacy baseline (exact addresses are never collected).
- 🤖 [`docs/local-ai-note.md`](docs/local-ai-note.md) — Technical note on Local AI abstraction and offline fallbacks.
- 📑 [`docs/adr/0001-local-first-marketplace-slice.md`](docs/adr/0001-local-first-marketplace-slice.md) — Architecture Decision Record (ADR 0001).

---

## 🚀 Getting Started

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (v3.44.6 or later)
- Google Chrome or Edge browser

### Running the App Locally

1. **Clone the repository**:
   ```bash
   git clone https://github.com/amaanshaikh711/Nukkad.git
   cd Nukkad
   ```

2. **Install Flutter dependencies**:
   ```bash
   flutter pub get
   ```

3. **Run on Chrome**:
   ```bash
   flutter run -d chrome --web-port=8080
   ```
   Open `http://localhost:8080` in your web browser.

---

## 🧪 Test Suite & Verification

Run the full automated test suite covering AI rule evaluations, repository CRUD operations, and trust score logic:

```bash
flutter test
```

### Test Coverage Summary:
- `fallback_local_ai_service_test.dart`: Validates draft review scores, short draft warnings, and buyer AI insights generation.
- `listing_repository_test.dart`: Validates Hive seeding, local CRUD persistence, save status toggles, and item status transitions.

---

## 📄 License

This project is created for the Mobile Architecture Lab (MAL) Lab 1 assignment. Licensed under the MIT License.
