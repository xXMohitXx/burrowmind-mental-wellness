# BurrowMind AI-Assisted Mental Wellness App

A local-first, privacy-focused mental wellness companion built with Flutter and Python.

## Overview

BurrowMind is designed for reflection, self-awareness, and emotional regulation. It is **NOT** a medical app, therapy replacement, or crisis intervention tool.

## Tech Stack

### Mobile (Flutter)
- **State Management**: Riverpod
- **Navigation**: GoRouter
- **Local Database**: SQLite (sqflite)
- **Secure Storage**: flutter_secure_storage
- **HTTP Client**: Dio

### Backend (Python)
- **Framework**: FastAPI
- **AI**: GROQ API (Llama 3)
- **Auth**: JWT with python-jose

## Project Structure

```
burrowmind_serious/
├── mobile/           # Flutter app
│   ├── lib/
│   │   ├── core/     # Theme, constants, utils, router
│   │   ├── data/     # Local DB, remote API, DAOs
│   │   ├── domain/   # Entities, repositories, use cases
│   │   └── features/ # Feature modules
│   └── pubspec.yaml
├── backend/          # Python FastAPI
│   ├── app/
│   │   ├── api/      # Route handlers
│   │   ├── core/     # Config, security
│   │   └── ai/       # GROQ client, prompts, safety
│   └── requirements.txt
└── docs/             # Documentation
```

## Getting Started

### Prerequisites
- Flutter SDK 3.5+
- Python 3.10+
- GROQ API Key (free tier available)

### Mobile Setup
```bash
cd mobile
flutter pub get
flutter run
```

### Backend Setup
```bash
cd backend
python -m venv venv
source venv/bin/activate  # or `venv\Scripts\activate` on Windows
pip install -r requirements.txt
cp .env.example .env  # Add your GROQ API key
uvicorn app.main:app --reload
```

## Features

- 🌙 **Dark Theme** - Calming earthy tones
- 📊 **Mental Wellness Score** - Daily composite indicator
- 📝 **Mood Tracking** - Log daily moods with factors
- 😴 **Sleep Tracking** - Quality and duration
- 🧘 **Mindful Hours** - Track meditation and activities
- 📓 **Journal** - Rich text with mood linking
- 🤖 **AI Companion** - Reflection-focused conversations
- 🔒 **Privacy First** - Local data storage

## AI Safety

The AI companion follows strict safety guidelines:
- Never diagnoses or prescribes
- Provides crisis resources when needed
- Encourages professional help for serious concerns
- Does not create emotional dependency

## License

MIT License
