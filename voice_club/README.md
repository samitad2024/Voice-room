# VoiceClub - Audio Chat App MVP

A production-level MVP of a Clubhouse-like audio chat application built with Flutter, featuring Clean Architecture, BLoC state management, and a polished UI/UX.

## 🎯 Features

### Core Functionality
- **User Authentication** - Login/logout with mock Firebase
- **Room Browsing** - Explore active, trending, and scheduled audio rooms
- **Room Details** - View speakers, listeners, and room information
- **Room Controls** - Mute/unmute, raise hand, leave room
- **Search** - Search for rooms by title, description, or tags
- **Real-time Updates** - Pull-to-refresh for latest rooms

### UI/UX Highlights
- Modern, polished interface with custom color scheme
- Smooth animations and transitions
- Professional card-based layouts
- Bottom navigation for easy access
- Floating action button for quick room creation
- Beautiful splash screen with animations
- Status indicators (LIVE badges, participant counts)
- Verified user badges

## 🏗️ Architecture

This project follows **Clean Architecture** principles with clear separation of concerns:

```
lib/
├── core/
│   ├── constants/          # App-wide constants (colors, strings)
│   ├── theme/             # App theme configuration
│   ├── utils/             # Utility functions
│   ├── error/             # Error handling
│   └── di/                # Dependency injection
├── data/
│   ├── models/            # Data models
│   ├── repositories/      # Repository implementations
│   └── datasources/       # Mock Firebase service
├── domain/
│   ├── entities/          # Business entities
│   ├── repositories/      # Repository interfaces
│   └── usecases/          # Business logic use cases
└── presentation/
    ├── auth/              # Authentication screens & BLoC
    ├── home/              # Home/explore screens & BLoC
    └── room/              # Room details screens & BLoC
```

## 🛠️ Tech Stack

- **Flutter** - UI framework
- **BLoC** (flutter_bloc 8.1.6) - State management
- **Get It** (8.3.0) - Dependency injection
- **Dartz** (0.10.1) - Functional programming
- **Equatable** (2.0.5) - Value equality
- **Google Fonts** (6.3.3) - Typography

## 🚀 Getting Started

### Installation

1. **Install dependencies**
   ```bash
   flutter pub get
   ```

2. **Run the app**
   ```bash
   flutter run
   ```

### Demo Accounts

Login with any username: `john_doe`, `sarah_smith`, `mike_wilson`, `emily_brown`, or `david_jones`

**Password**: Any password works (mock authentication)

Or click **"Continue as Guest"** to quick start.

## 🎨 Design System

### Colors
- **Primary**: `#5B51D8` (Purple)
- **Success**: `#34C759` (Green) - LIVE indicators
- **Error**: `#FF3B30` (Red)
- **Background**: `#F5F3F0` (Warm gray)

### Typography
- **Font Family**: Inter (Google Fonts)
- **Weights**: Regular, Medium, SemiBold, Bold

## 📱 Features Overview

### Home/Explore
- Trending, active, and upcoming rooms
- Real-time search functionality
- Pull-to-refresh
- Create new room dialog

### Room Details
- Room info with category and status
- Speakers and listeners lists
- Control panel (mute, raise hand, leave)
- Share and options menu

## 📦 Architecture Highlights

### Clean Architecture Layers
1. **Presentation** - UI & BLoC state management
2. **Domain** - Business logic & use cases
3. **Data** - Repositories & mock Firebase

### State Management
Uses **BLoC pattern**:
- **AuthBloc** - Authentication
- **HomeBloc** - Room lists & search
- **RoomBloc** - Room interactions

## 🔧 Mock Data

Includes realistic mock data:
- 5 user profiles with avatars
- 6 rooms (4 active, 2 scheduled)
- Categories: Technology, Business, Music, Lifestyle
- Simulated API delays

## 🎯 Future Enhancements

- Real Firebase integration
- WebRTC audio streaming
- User profiles & following
- Push notifications
- Dark mode
- Multi-language support

---

**Note**: This is an MVP with mock data. For production, integrate real Firebase and audio streaming services.


- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
