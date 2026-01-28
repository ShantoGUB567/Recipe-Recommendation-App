# Weekly Meal Planner - Firebase Integration Quick Guide

## How It Works

### User Flow

1. **User Opens Weekly Meal Planner Screen**
   - App checks Firebase for existing meal plan for today's date
   - If plan exists AND current date is within range → Show plan
   - If plan expired OR doesn't exist → Show empty state

2. **User Clicks "Generate"**
   - EasyLoading shows: "Generating meal plan..."
   - Gemini AI generates 7-day plan
   - Plan automatically saved to Firebase
   - EasyLoading shows success: "Meal plan generated successfully!"

3. **User Comes Back Later**
   - Plan loads automatically from Firebase (no wait!)
   - Works same day or within 7-day range

4. **After 7 Days**
   - Plan expired (outside date range)
   - Shows empty state
   - User must generate new plan for current week

---

## Firebase Database Path

```
weekly_meal_plans/
└── {USER_ID}/
    └── {YYYY-MM-DD}/          ← Date plan was generated
        ├── generatedDate: ISO timestamp
        ├── startDate: ISO timestamp
        ├── endDate: ISO timestamp
        └── meals: [...]
```

**Example for User ID "abc123" generated on 2026-01-28:**
```
weekly_meal_plans/abc123/2026-01-28/
```

---

## Key Implementation Details

### Smart Date Validation

```dart
// In loadMealPlanFromFirebase()
final startDate = DateTime.parse(data['startDate']);  // 2026-01-28
final endDate = DateTime.parse(data['endDate']);      // 2026-02-03

if (now.isAfter(startDate) && now.isBefore(endDate.add(Duration(days: 1)))) {
  // Plan is valid - show it
} else {
  // Plan expired - return null
}
```

### Automatic Firebase Save

```dart
// In generateWeeklyMealPlan()
final mealPlans = _parseMealPlan(text);
await saveMealPlanToFirebase(mealPlans);  // ← Auto save!
return mealPlans;
```

---

## Testing Scenarios

### Scenario 1: First Time User
```
Today: 2026-01-28
Action: Click Generate
Result: 7-day plan (01-28 to 02-03) saved to Firebase
UI: Plan shows with all meals
```

### Scenario 2: Return Visit Same Week
```
Today: 2026-01-30
Action: Open Weekly Meal Planner
Result: Firebase loads plan from 2026-01-28
UI: Plan shows immediately (no loading!)
```

### Scenario 3: Plan Expired
```
Today: 2026-02-04
Action: Open Weekly Meal Planner
Result: Firebase loads plan from 2026-01-28
Check: 2026-02-04 is AFTER 2026-02-03 (expired)
UI: Empty state - "No meal plan generated"
Action: User must click Generate for new week
```

### Scenario 4: Regenerate Same Day
```
Today: 2026-01-28
Action: Generate plan
Result: 2026-01-28 plan saved to Firebase
Action: Click Generate again
Result: Old plan overwritten with new plan
UI: Updated meal plan shows
```

---

## EasyLoading Usage

### In Weekly Meal Planner

**Show Loading:**
```dart
EasyLoading.show(status: 'Generating meal plan...');
```

**Show Success:**
```dart
EasyLoading.showSuccess('Meal plan generated successfully!', 
  duration: Duration(seconds: 2));
```

**Show Error:**
```dart
EasyLoading.showError('Failed to generate meal plan');
```

### In Auth Screens

**Error:**
```dart
EasyLoading.showError('Email & password required');
```

**Success:**
```dart
EasyLoading.showSuccess('Login successful!', duration: Duration(seconds: 1));
```

---

## Common Issues & Solutions

### Issue: Plan not loading after app restart
- **Check:** User logged in?
- **Check:** Plan date is within current date range?
- **Check:** Firebase rules allow read/write?

### Issue: Old plan still showing on expired date
- **Expected behavior:** Plan only shows if date is in range
- **Solution:** User must regenerate for new week

### Issue: Different plan shows on different dates
- **Expected behavior:** Plan is tied to generation date (2026-01-28)
- **Shows until:** End of week (2026-02-03)

### Issue: Plan lost after logout/login
- **Expected behavior:** Data is user-specific (by Firebase UID)
- **Check:** Logged in as same user?

---

## Debug Mode

**View Firebase Saves in Logs:**
```
✅ Meal plan saved to Firebase     ← Success
❌ Error saving meal plan to Firebase: ... ← Failed
```

**View Firebase Loads in Logs:**
```
✅ Loaded meal plan from Firebase  ← Loaded from DB
⚠️ Meal plan is expired (outside date range) ← Expired
⚠️ No meal plan found in Firebase for today ← Not found
```

---

## Migration from Old System

- **Old:** Plans only in memory (lost on app restart)
- **New:** Plans in Firebase (persistent across sessions)
- **No data loss:** Existing logic still works
- **No breaking changes:** UI and UX identical

---

## Performance Notes

- Firebase loads in ~1-2 seconds (varies by connection)
- If user has slow internet, show appropriate messaging
- Meal plan generation takes ~10-15 seconds (AI call)
- Local parsing is instant

---

## Security Notes

- Data stored under `weekly_meal_plans/{userId}/`
- Each user can only access their own plans
- Firebase security rules should restrict access
- Recommended rule:
```
"weekly_meal_plans": {
  "$uid": {
    ".read": "$uid === auth.uid",
    ".write": "$uid === auth.uid"
  }
}
```

---

**Last Updated:** January 28, 2026  
**Status:** Ready for Production  
**All EasyLoading Notifications:** Implemented ✅
**Firebase Integration:** Complete ✅
