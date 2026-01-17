# Yummate Recipe Management System - Architecture

## System Flow Diagram

```
┌─────────────────────────────────────────────────────────────────────┐
│                         YUMMATE APP ARCHITECTURE                     │
└─────────────────────────────────────────────────────────────────────┘

┌──────────────────┐
│   HOME SCREEN    │
│  - Generate      │  ─────────┐
│  - Search        │           │
└──────────────────┘           │
                               │
                               ▼
                    ┌──────────────────────┐
                    │  GEMINI SERVICE      │
                    │  (Generate recipes)  │
                    └──────────────────────┘
                               │
                  ┌────────────┴────────────┐
                  ▼                         ▼
        ┌────────────────────┐    ┌────────────────────┐
        │ SEARCH FLOW        │    │ GENERATE FLOW      │
        │ type: "search"     │    │ type: "generate"   │
        └────────────────────┘    └────────────────────┘
                  │                         │
                  └────────────┬────────────┘
                               ▼
                  ┌──────────────────────────────┐
                  │  GENERATE RECIPE SCREEN      │
                  │  (Shows 3 recipes)           │
                  │  - Save to Firebase History  │
                  └──────────────────────────────┘
                               │
                ┌──────────────┼──────────────┐
                ▼              ▼              ▼
        ┌───────────────┐ ┌──────────────────────┐ ┌──────────────────┐
        │ RECIPE 1      │ │ RECIPE 2             │ │ RECIPE 3         │
        └───────────────┘ └──────────────────────┘ └──────────────────┘
                │              │                        │
                └──────────────┴────────────────────────┘
                               │
                    ┌──────────▼──────────┐
                    │ RECIPE DETAILS      │
                    │ SCREEN              │
                    │ - Save/Unsave Btn   │
                    │ - Toggle State      │
                    └─────────────────────┘
                               │
                ┌──────────────┼──────────────┐
                ▼              ▼              ▼
        ┌─────────────┐  ┌──────────────┐  ┌──────────────┐
        │ FIREBASE    │  │ SHARED PREF  │  │ LOCAL STATE  │
        │ Save Recipe │  │ (Checked)    │  │ (Temp)       │
        └─────────────┘  └──────────────┘  └──────────────┘
```

---

## Firebase Data Structure

```
FIREBASE REALTIME DATABASE
├── users/
│   └── {userId}/
│       ├── saved_recipes/
│       │   └── {recipeId}/
│       │       ├── id: "uuid"
│       │       ├── userId: "user123"
│       │       ├── recipe: {...}
│       │       └── savedAt: "2024-01-18T10:30:00.000Z"
│       │
│       └── recipe_history/
│           └── {historyId}/
│               ├── id: "uuid"
│               ├── userId: "user123"
│               ├── query: "Ingredients: tomato, onion"
│               ├── type: "generate" | "search"
│               ├── recipes: [recipe1, recipe2, recipe3]
│               └── createdAt: "2024-01-18T10:30:00.000Z"
```

---

## Component Interaction Map

```
┌─────────────────────────────────────────────────────────────────────┐
│                     USER ACTIONS & FLOWS                             │
└─────────────────────────────────────────────────────────────────────┘

1. SEARCH RECIPE
   ├─ User enters recipe name
   ├─ GeminiService generates 3 recipes
   ├─ RecipeService saves to recipe_history with type="search"
   ├─ GenerateRecipeScreen displays 3 recipes
   └─ RecipeHistoryScreen updates in real-time

2. GENERATE RECIPE
   ├─ User selects ingredients
   ├─ GeminiService generates 3 recipes
   ├─ RecipeService saves to recipe_history with type="generate"
   ├─ GenerateRecipeScreen displays 3 recipes
   └─ RecipeHistoryScreen updates in real-time

3. SAVE RECIPE
   ├─ User opens RecipeDetailsScreen
   ├─ User clicks bookmark icon
   ├─ RecipeService.saveRecipe() is called
   ├─ Recipe saved to saved_recipes collection with unique ID
   ├─ Bookmark icon toggles (filled)
   └─ SavedRecipesScreen updates in real-time

4. VIEW SAVED RECIPES
   ├─ User navigates to SavedRecipesScreen
   ├─ RecipeService.streamSavedRecipes() loads data
   ├─ Real-time stream updates UI
   ├─ User can remove recipes (PopupMenu)
   └─ Removal updates Firebase immediately

5. VIEW RECIPE HISTORY
   ├─ User navigates to RecipeHistoryScreen
   ├─ RecipeService.streamRecipeHistory() loads data
   ├─ Real-time stream updates UI
   ├─ User can delete entries (long-press)
   └─ User can clear all history
```

---

## Service Layer Architecture

```
┌────────────────────────────────────────────────────────────────┐
│                    SERVICE LAYER                               │
└────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ RecipeService (lib/services/recipe_service.dart)            │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  SAVED RECIPES:                                              │
│  • saveRecipe()              - Save to Firebase             │
│  • removeSavedRecipe()       - Remove from Firebase         │
│  • getSavedRecipes()         - Fetch user's saved          │
│  • isRecipeSaved()           - Check if saved              │
│  • streamSavedRecipes()      - Real-time stream            │
│                                                              │
│  RECIPE HISTORY:                                             │
│  • saveRecipeHistory()       - Save search/generate        │
│  • getRecipeHistory()        - Fetch all history           │
│  • getRecipeHistoryByType()  - Filter by type             │
│  • deleteRecipeHistory()     - Delete entry               │
│  • clearAllRecipeHistory()   - Delete all                 │
│  • streamRecipeHistory()     - Real-time stream           │
│                                                              │
│  DATABASE:                                                   │
│  • FirebaseDatabase.instance.ref()                          │
│                                                              │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ GeminiService (lib/services/gemini_service.dart)            │
├─────────────────────────────────────────────────────────────┤
│  • generateRecipe()          - Generate 3 recipes          │
│  • searchRecipe()            - Search variations           │
│  • identifyIngredientsFromImage() - Vision recognition    │
│                                                              │
└─────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────┐
│ SessionService (lib/services/session_service.dart)         │
├─────────────────────────────────────────────────────────────┤
│  • saveFavoriteRecipe()      - Local storage              │
│  • getCheckedIngredients()   - Ingredient checkboxes      │
│  • saveRecentRecipe()        - Recent recipes             │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

---

## Real-Time Update Flow

```
┌──────────────────────────────────────────────────────────┐
│          REAL-TIME DATA SYNCHRONIZATION                  │
└──────────────────────────────────────────────────────────┘

Firebase Realtime Database
  │
  ├─ OnValue Stream
  │  │
  │  ├─ recipe_history/
  │  │   └─ Changes → streamRecipeHistory()
  │  │       │
  │  │       ▼
  │  │   RecipeHistoryScreen
  │  │       ├─ Sorts by timestamp (descending)
  │  │       ├─ Updates UI
  │  │       └─ Refreshes list
  │  │
  │  └─ saved_recipes/
  │      └─ Changes → streamSavedRecipes()
  │          │
  │          ▼
  │      SavedRecipesScreen
  │          ├─ Refreshes saved list
  │          ├─ Updates counters
  │          └─ Shows/hides empty state
  │
  └─ Automatic when:
     • Recipe is saved
     • Recipe is removed
     • History entry is added
     • History entry is deleted
     • All history is cleared
```

---

## State Management Flow

```
┌─────────────────────────────────────────────────────────────┐
│                  STATE MANAGEMENT                           │
└─────────────────────────────────────────────────────────────┘

RecipeDetailsScreen:
  ├─ isSaved: bool                 → Bookmark button state
  ├─ _isLoadingSaveStatus: bool    → Loading indicator
  ├─ checkedIngredients: Set<int>  → Ingredient checkboxes
  └─ Actions:
     ├─ _checkSaveStatus()         → Load from Firebase
     ├─ _toggleSaveRecipe()        → Save/Remove from Firebase
     └─ _saveCheckedIngredients()  → Update local state

RecipeHistoryScreen:
  ├─ _historyStream: Stream        → Real-time from Firebase
  ├─ _userId: String               → Current user ID
  └─ Actions:
     ├─ _initializeStream()        → Initialize stream
     ├─ _clearAllHistory()         → Delete all entries
     └─ _deleteHistoryEntry()      → Delete one entry

SavedRecipesScreen:
  ├─ _savedRecipesStream: Stream   → Real-time from Firebase
  ├─ _userId: String               → Current user ID
  └─ Actions:
     ├─ _initializeStream()        → Initialize stream
     └─ _removeSavedRecipe()       → Remove recipe
```

---

## Error Handling Strategy

```
┌─────────────────────────────────────────────────────────────┐
│              ERROR HANDLING & USER FEEDBACK                 │
└─────────────────────────────────────────────────────────────┘

Firebase Operations:
  │
  ├─ Success
  │  └─ ScaffoldMessenger.showSnackBar() ✓
  │     • "Recipe saved successfully"
  │     • "Recipe removed from saved"
  │     • "History entry deleted"
  │
  └─ Error
     ├─ Try-catch block
     ├─ Print to console
     └─ ScaffoldMessenger.showSnackBar() ✗
        • "Error: [error message]"
        • "Please login to save recipes"

Authentication Checks:
  │
  ├─ User logged in
  │  └─ Proceed with Firebase operation
  │
  └─ User not logged in
     ├─ Show login prompt
     └─ Disable Firebase features

Streams:
  │
  ├─ ConnectionState.waiting
  │  └─ Show CircularProgressIndicator()
  │
  ├─ ConnectionState.active
  │  └─ Display data
  │
  └─ No data
     └─ Show empty state with icon
```

---

**Architecture is production-ready and scalable! 🚀**
