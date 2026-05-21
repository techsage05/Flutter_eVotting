import 'package:flutter/material.dart';

// This is a simple placeholder class that holds and shows different pages (fragments)
// inside the elections page without using traditional full screen routes (MaterialPageRoute).
// It acts as a container for whichever view we want to display.
class FragmentPlaceholder extends StatelessWidget {
  final Widget child;

  const FragmentPlaceholder({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Just a simple container that displays the active view (fragment) passed to it.
    return child;
  }
}
