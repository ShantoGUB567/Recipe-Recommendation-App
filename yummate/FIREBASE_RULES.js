// Firebase Realtime Database Security Rules
// Copy this to your Firebase Console > Database > Rules

{
  "rules": {
    "users": {
      "$uid": {
        // Allow users to read/write only their own data
        ".read": "auth.uid === $uid",
        ".write": "auth.uid === $uid",
        
        "saved_recipes": {
          "$recipeId": {
            // Allow full access to own saved recipes
            ".read": true,
            ".write": true,
            ".validate": "newData.hasChildren(['id', 'userId', 'recipe', 'savedAt'])"
          }
        },
        
        "recipe_history": {
          "$historyId": {
            // Allow full access to own history
            ".read": true,
            ".write": true,
            ".validate": "newData.hasChildren(['id', 'userId', 'query', 'type', 'recipes', 'createdAt'])"
          }
        }
      }
    }
  }
}

// Explanation:
// 1. Users can only access their own user node (matching auth.uid)
// 2. Within their node, they can read/write saved_recipes collection
// 3. Within their node, they can read/write recipe_history collection
// 4. Data validation ensures required fields are present
// 5. This prevents users from accessing other users' data

// Alternative: More Permissive (Development Only)
// ⚠️ DO NOT use in production - security risk!
{
  "rules": {
    "users": {
      "$uid": {
        ".read": "auth != null",
        ".write": "auth.uid === $uid",
        
        "saved_recipes": {
          ".indexOn": ["userId", "savedAt"]
        },
        
        "recipe_history": {
          ".indexOn": ["userId", "createdAt", "type"]
        }
      }
    }
  }
}

// Alternative: Strict (Production)
// Most restrictive - recommended for sensitive apps
{
  "rules": {
    "users": {
      "$uid": {
        ".read": "auth.uid === $uid",
        ".write": "auth.uid === $uid",
        ".validate": "auth.uid === $uid",
        
        "saved_recipes": {
          "$recipeId": {
            ".read": "auth.uid === $uid",
            ".write": "auth.uid === $uid",
            ".validate": "newData.child('userId').val() === auth.uid && 
                        newData.hasChildren(['id', 'userId', 'recipe', 'savedAt'])"
          }
        },
        
        "recipe_history": {
          "$historyId": {
            ".read": "auth.uid === $uid",
            ".write": "auth.uid === $uid",
            ".validate": "newData.child('userId').val() === auth.uid && 
                        newData.hasChildren(['id', 'userId', 'query', 'type', 'recipes', 'createdAt'])"
          }
        }
      }
    }
  }
}

// Steps to Apply Rules:
// 1. Go to Firebase Console
// 2. Select your project
// 3. Navigate to Realtime Database
// 4. Click "Rules" tab
// 5. Paste the rules above
// 6. Click "Publish"
// 7. Confirm the changes

// Testing Rules:
// Use Firebase Console Simulator to test:
// 1. Authentication: Simulate user login
// 2. Location: /users/{uid}/saved_recipes
// 3. Operation: Read, Write, Delete
// 4. Verify: Rules allow/deny as expected
