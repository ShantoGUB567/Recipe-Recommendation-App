import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:yummate/screens/auth/login_screen.dart';
import 'package:get/get.dart';
import 'package:yummate/screens/auth/signup_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  late VideoPlayerController _videoController;
  bool _isVideoInitialized = false;
  bool _showButton = false;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
    _startButtonTimer();
  }

  void _startButtonTimer() {
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showButton = true;
        });
      }
    });
  }

  Future<void> _initializeVideo() async {
    _videoController =
        VideoPlayerController.asset('assets/videos/background.mp4')
          ..initialize().then((_) {
            setState(() {
              _isVideoInitialized = true;
            });
            _videoController.setLooping(true);
            _videoController.play();
          });
  }

  @override
  void dispose() {
    _videoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Video Background
          if (_isVideoInitialized)
            SizedBox(
              width: double.infinity,
              height: MediaQuery.of(context).size.height,
              child: FittedBox(
                fit: BoxFit.fitHeight,
                alignment: Alignment.center,
                child: SizedBox(
                  width: _videoController.value.size.width,
                  height: _videoController.value.size.height,
                  child: VideoPlayer(_videoController),
                ),
              ),
            )
          else
            Container(color: Colors.black),

          // Dark overlay for better visibility
          Container(color: Colors.black.withOpacity(0.4)),

          // Content
          SafeArea(
            child: Stack(
              children: [
                // Logo and App Name - Centered with fixed position
                Center(
                  child: Transform.translate(
                    offset: const Offset(0, -100),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Logo
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: Image.asset(
                            'assets/images/logo.png',
                            width: MediaQuery.of(context).size.width * 0.7,
                            height:
                                MediaQuery.of(context).size.width *
                                0.7 *
                                (975 / 2025),
                            fit: BoxFit.contain,
                          ),
                        ),

                        const SizedBox(height: 30),

                        // Slogan
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 32.0),
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              'Turn Ingredients into Magic',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                                letterSpacing: 0.5,
                                height: 1.3,
                                shadows: [
                                  Shadow(
                                    color: Colors.black.withOpacity(0.5),
                                    blurRadius: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Get Started Button - Positioned at bottom
                if (_showButton)
                  Positioned(
                    bottom: 60,
                    left: 0,
                    right: 0,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Center(
                          child:
                              ElevatedButton(
                                    onPressed: () {
                                      // Navigate to login screen
                                      Get.to(() => LoginScreen());
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange.shade700,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 60,
                                        vertical: 18,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      ),
                                      elevation: 8,
                                    ),
                                    child: const Text(
                                      'Get Started',
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  )
                                  .animate()
                                  .fadeIn(duration: 400.ms)
                                  .slideY(
                                    begin: 1,
                                    end: 0,
                                    duration: 600.ms,
                                    curve: Curves.easeOut,
                                  ),
                        ),
                        const SizedBox(height: 16),
                        Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Text(
                                  'Already have an account? ',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    // Navigate to signup screen
                                    Get.to(() => SignupScreen());
                                  },
                                  child: const Text(
                                    'Sign In.',
                                    style: TextStyle(
                                      color: Colors.orange,
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            )
                            .animate()
                            .fadeIn(duration: 400.ms, delay: 200.ms)
                            .slideY(
                              begin: 1,
                              end: 0,
                              duration: 600.ms,
                              curve: Curves.easeOut,
                            ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
