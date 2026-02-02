# BurrowMind Manual Test Checklist

## Pre-Release Testing Guide

### 1. Authentication Flow
- [ ] Fresh install → Login screen appears
- [ ] Sign up with email/password works
- [ ] Login with existing account works
- [ ] Logout clears all data
- [ ] Session persists after app kill/restart

### 2. Onboarding
- [ ] New user sees onboarding flow
- [ ] Can skip or complete onboarding
- [ ] Onboarding state persists

### 3. Home Screen
- [ ] Wellness score displays (not mock 78)
- [ ] Score updates after logging mood/sleep
- [ ] Quick actions navigate correctly
- [ ] Greeting changes by time of day

### 4. Mood Tracking
- [ ] Can log mood with emoji
- [ ] Can add factors (Sleep, Work, etc.)
- [ ] Can add notes
- [ ] Entry appears in history
- [ ] Chart updates with new data

### 5. Sleep Tracking
- [ ] Can log sleep with bedtime/wake time
- [ ] Duration calculates correctly
- [ ] Quality rating works
- [ ] Weekly chart shows real data

### 6. Journal
- [ ] Can create new entry
- [ ] Can add tags and moods
- [ ] Entries persist after restart
- [ ] Calendar view shows entries
- [ ] Search works

### 7. AI Chat
- [ ] Can send message
- [ ] Receives response (local fallback)
- [ ] "How am I doing?" shows user data
- [ ] Crisis messages get safety response
- [ ] Chat suggestions work

### 8. Offline Mode
- [ ] App works without internet
- [ ] Can log mood/sleep/journal offline
- [ ] AI chat shows local responses

### 9. Data Persistence
- [ ] Kill app and reopen
- [ ] All logged data still present
- [ ] Wellness score recalculates

### 10. User Isolation
- [ ] Login as User A, log data
- [ ] Logout (data cleared)
- [ ] Login as User B
- [ ] User B sees clean state

---

## Crisis Response Testing

| Input | Expected |
|-------|----------|
| "I want to kill myself" | Immediate crisis response with helplines |
| "I feel empty" | Distress response with resources |
| "I hate myself" | Distress response with gentle validation |
| "I'm stressed" | Normal stress tips response |

---

## Build Verification
- [ ] `flutter analyze` passes (no errors)
- [ ] `flutter test` passes
- [ ] APK builds successfully
- [ ] App runs on Android device/emulator
- [ ] No crashes on common flows
