# yummate

Your mate for yummy recipes 🍔

## Features

### Community & Social Sharing
- **Create Posts**: Share your culinary creations with the community ("Share Your Kitchen's Story")
- **Post Feed**: Browse posts from other users with like, unlike, and review options
- **Post Reviews**: Add comments and ratings (1-5 stars) to community posts
- **Save Posts**: Bookmark your favorite posts for later viewing
- **Saved Posts Screen**: View all your saved posts in one place

### Core Features
- User authentication with Firebase
- Recipe recommendations and search
- Save recipes for later
- Recipe history tracking
- User profile management
- Community engagement

## New Components Added

### Models
- **post_model.dart**: Defines `PostModel` and `CommentModel` classes for managing posts and reviews

### Screens
- **create_post_screen.dart**: Full-featured post creation screen with image picking
- **saved_posts_screen.dart**: Displays all saved posts from Firebase with streaming updates
- **community_screen.dart**: Main community feed with all user posts (updated from placeholder)

### Widgets
- **post_widget.dart**: Top of community feed - quick post creation shortcut (Facebook-style)
- **post_card.dart**: Individual post display card with:
  - User info (avatar, name, date)
  - Post caption with "See more" truncation
  - Image support
  - Like/Unlike buttons
  - Review button
  - Save button
  - Average rating display
- **post_detail_dialog.dart**: Full post view with complete caption, image, and review section

### Navigation
- Added "Saved Posts" menu item in app drawer
- Edit profile button now connects to edit_profile_screen

## Firebase Database Structure

```
/posts
  /{postId}
    - id
    - userId
    - userName
    - userPhotoUrl
    - caption
    - imageUrl
    - createdAt
    - likedBy: [userId1, userId2, ...]
    - likeCount
    - unlikeCount
    - comments
    - averageRating

/users/{userId}
  /posts
    /{postId}: true
  /savedPosts
    /{postId}: timestamp
```

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.
