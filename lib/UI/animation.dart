import 'package:flutter/material.dart';

class AnimatedSnackbar extends StatefulWidget {
  const AnimatedSnackbar({super.key});

  @override
  _AnimatedSnackbarState createState() => _AnimatedSnackbarState();
}

class _AnimatedSnackbarState extends State<AnimatedSnackbar>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOut,
      ),
    );

    _animationController.forward();

    // Auto-dismiss Snackbar after animation completes
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        Future.delayed(const Duration(seconds: 2), () {
          _animationController.reverse();
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _showSnackbar() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: FadeTransition(
          opacity: _animation,
          child: const Text('Animated Snackbar'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Animated Snackbar Demo'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _showSnackbar,
          child: const Text('Show Snackbar'),
        ),
      ),
    );
  }
}
