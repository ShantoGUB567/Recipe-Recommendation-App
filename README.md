# 🍳 Yummate – AI Powered Recipe Generator App

Yummate is an AI-powered mobile application that generates recipes based on available ingredients. 
It helps users cook smarter, reduce food waste, and plan meals efficiently.

---

## 🚀 Features
- Generate recipes from available ingredients
- Image-based ingredient recognition
- AI-powered personalized recipe suggestions
- Smart meal planning
- Community interaction
- Offline access to saved recipes

---

## 🧠 Technologies Used
- Flutter (Mobile App Development)
- Firebase Authentication
- Gemini AI (Recipe Generation)
- Image Recognition AI
- REST APIs

---

## 📱 App Screenshots
|---------|----------|----------|
| ![Splash Screen](AppScreenshots/SplashScreen.jpeg) | ![Siginup Screen](AppScreenshots/Signup.jpeg) | ![Login Screen](AppScreenshots/Login.jpeg) |
|---------|----------|----------|
| ![Home Screen](AppScreenshots/Home.jpeg) | ![Input Image Screen](AppScreenshots/InputImage.jpeg) | ![Genereted Recipe.jpeg Screen](AppScreenshots/GeneretedRecipe.jpeg) |
|---------|----------|----------|
| ![Recipe Details Screen](AppScreenshots/RecipeDetails.jpeg) | ![App Drawer](AppScreenshots/Drawer.jpeg) | ![Community Screen](AppScreenshots/Community.jpeg) | 
|---------|----------|----------|
| ![Weekly Meal Planner Screen](AppScreenshots/WeeklyMealPlanner.jpeg) | ![Save Recipe Screen](AppScreenshots/SaveRecipe.jpeg) | ![Edit Profile Screen](AppScreenshots/EditProfile.jpeg)|
|---------|----------|----------|

<!-- ![Personalization Profile](AppScreenshots/Personalization.jpeg) -->

---

## 🛠️ Installation & Setup 
Follow the steps below to run the Yummate app locally on your machine.

### ✅ Prerequisites
Make sure you have the following installed:
- Flutter SDK (latest stable version)
- Dart SDK
- Android Studio or VS Code
- Android Emulator or Physical Device
- Git (optional but recommended)

1. Check Flutter installation:
    ```bash
    flutter --version
2. Clone the repository  
   ```bash
   https://github.com/ShantoGUB567/Recipe-Recommendation-App.git
3. Navigate into the project directory:
    ```bash
    cd yummate
4. Install Dependencies 
- Fetch all required Flutter packages:
    ```bash
    flutter pub get
5. Firebase Setup
- Create a Firebase project from the Firebase Console
- Enable Email & Password Authentication
- Download google-services.json
- Place it inside:
    ```bash
    android/app/
6. AI Configuration
- Set up Gemini AI API key
- Store the API key securely (e.g., environment variables or config file)
- Ensure backend services can access the AI endpoint
7. Run the Application
- Make sure an emulator or physical device is connected, then run:
    ```bash
    flutter run
8. Build APK (Optional)
- To generate a release APK:
    ```bash
    flutter build apk
- The APK will be available inside:
    'build/app/outputs/flutter-apk/'
9. Troubleshooting
    - If you face issues, try:
    ```bash
    flutter clean
    flutter pub get
    flutter run
