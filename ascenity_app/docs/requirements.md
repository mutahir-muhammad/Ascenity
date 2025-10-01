UI/UX Design Specification: Ascenity
Version: 1.2 (Enhanced Interactivity)

Design Philosophy: Minimalist, content-forward, and emotionally resonant. This design specification follows a "Spotify-like" structure, emphasizing a dark, immersive experience with vibrant accents. The light theme will use "Snow" as its base for a clean, airy feel.

Core Colors (Recap):

Dark Background: Deep Navy (#07073A)

Light Background: Snow (#FFFAFA) or Light Gray (#F4F0ED)

Accents: Soft Blue (#40D5FF), Aquamarine (#57FFBB), Blueberry (#497EFF)

Part 0: Onboarding & Authentication
Screen: onboarding_screen.dart
The user's first impression. It must be captivating and clearly state the app's purpose.

Layout: Scaffold -> Container (with Gradient) -> Column

Background: A full-screen LinearGradient from Soft Blue (top left) to Aquamarine (bottom right).

Widgets & Animations:

Lottie.asset('assets/animations/breathing.json'): A large, centered Lottie animation playing on a continuous loop to create a calming, dynamic backdrop.

Text Widget (Tagline): Displays "Know your mind,\nknow your emotions." in Poppins font, size 26, FontWeight.w600. This text should fade and slide into view after a short delay, once the Lottie animation is visible.

AnimatedButton.dart (Get Started): A custom animated button widget.

Interaction: It has a subtle, continuous "breathing" animation (slowly scaling between 1.0 and 1.02) to attract attention. On press, it executes a more pronounced scale-down animation (ScaleTransition).

Part 1: Core App Structure & Shell
Screen: main_shell.dart
This is the persistent root of the app after onboarding. It manages the main pages and the navigation bar.

Root Widget: Scaffold

Body: A PageView with BouncingScrollPhysics to hold the main screens (Dashboard, Journal, Progress). This allows for smooth, physics-based swiping between screens. A PageController will sync the page view with the nav bar.

Bottom Navigation: A custom BottomNavigationBar widget (CustomNavBar.dart).

UI: No background color (transparent to the main Scaffold's navy). It has a subtle top border line.

Interaction & Animation: The selected icon is filled. A small, glowing Aquamarine dot appears below it with a "pop" animation (AnimatedContainer changing size, or ScaleTransition). The icon itself scales up slightly. Unselected icons fade to a lower opacity. The switch between states is animated smoothly.

Part 2: Screen-by-Screen Component Breakdown
Screen 1: dashboard_screen.dart (The Home Tab)
A dynamic, personalized space using CustomScrollView and Slivers.

Layout: Scaffold -> CustomScrollView -> Slivers[]

Widgets & Animations:

SliverAppBar (GreetingHeader.dart):

Description: A large, welcoming header that collapses on scroll. The transition between expanded and collapsed states is a smooth fade and slide, managed by FlexibleSpaceBar. The user's CircleAvatar smoothly shrinks and moves into the collapsed AppBar position.

SliverToBoxAdapter (MoodSelectorCarousel.dart):

Interaction: Scrolling should provide haptic feedback (HapticFeedback.lightImpact()) as each mood card snaps to the center. When a mood is selected, the main screen's background can have a temporary, soft gradient overlay of that mood's accent color which then gently fades out.

SliverToBoxAdapter (ProgressRingsSection.dart):

Animation: The progress rings should animate their progress value when the screen first loads, filling up from zero to the current value.

SliverGrid (QuickActionsGrid.dart):

Animation: The cards in the grid should stagger-animate into view when the dashboard loads, fading and sliding in one after the other for a cascading effect.

Screen 2: journaling_page.dart (The Journal Tab)
A feed of past entries.

Layout: Scaffold -> CustomScrollView

Widgets & Animations:

SliverList (JournalEntryList.dart):

Animation: Each JournalEntryCard will stagger-animate into view as the user scrolls down the list. Use a package like flutter_staggered_animations to have them fade and slide in from the bottom.

Screen 3: journal_detail_page.dart (For new or existing entries)
An immersive writing experience.

Layout: Scaffold

Widgets & Animations:

AppBar: Contains a "Save" button.

Interaction: When tapped, the "Save" icon should transform into a CircularProgressIndicator. Upon successful save, it morphs into a checkmark icon before the page navigates back. This can be achieved with an AnimatedSwitcher.

GuidedQuestionCard.dart:

Interaction: Users can swipe this card horizontally to dismiss it or cycle through other questions, adding an interactive discovery element.

Screen 4: progress_page.dart (The Progress Tab)
A visually rich dashboard for trends and achievements.

Layout: Scaffold -> ListView

Widgets & Animations:

MoodTrendChart.dart:

Animation: The line chart should animate on screen load, with the line path drawing itself from left to right.

StreakHighlightCard.dart:

Animation: This card can have a subtle, continuous shimmer effect (shimmer package) to make it look premium and important. The Lottie flame animation provides constant, gentle motion.

BadgesGrid.dart:

Animation: When a new badge is unlocked, a dialog appears showing the full-size badge. Upon closing the dialog, the badge animates from the center of the screen and settles into its place in the grid. A Lottie confetti animation can play over the entire screen at the moment of unlock.

Screen 5: ai_insights_page.dart (Modal Bottom Sheet)
A summary of AI analysis.

Layout: Shown inside a showModalBottomSheet call.

Widgets & Animations:

Animation: The modal sheet itself animates in smoothly from the bottom. Once visible, each card inside (SentimentCard, WordCloud, etc.) should fade and slide in sequentially with a slight delay for a clean, cascading effect.

Part 3: Reusable Custom Widgets Specification
MoodCard.dart:

Interaction & Animation: The glowing border should appear smoothly using an AnimatedContainer that changes its BoxDecoration. The scaling effect (AnimatedScale) and opacity change (AnimatedOpacity) should happen simultaneously, creating a single, fluid response to the tap.

ProgressRingCard.dart:

Animation: The progress value is animated via a TweenAnimationBuilder, allowing the ring to fill up visually over a short duration when it first appears.

QuickActionCard.dart:

Interaction: In addition to the InkWell ripple, the card itself can slightly scale down on press (ScaleTransition) for more tactile feedback.

JournalEntryCard.dart:

Interaction: The Hero animation will be the primary interaction. The tag should be unique to the entry ID.

Badge.dart:

Animation: The transition between the grayscale (locked) and full-color (unlocked) states should be handled by an AnimatedSwitcher with a FadeTransition for a smooth cross-fade effect.

Part 4: Global Animations & Transitions
Page Transitions: Use FadeTransition or a custom SharedAxisTransition from the animations package for navigating between the main shell screens to create a modern, fluid feel.

List Animations: When new items are added to a list (e.g., a new journal entry), they should animate in using a FadeIn and SlideIn effect.

Hero Animations: Use prominently for navigating from a list item to its detail page (e.g., JournalEntryCard -> JournalDetailPage). This creates a seamless and visually impressive connection.

Micro-interactions: Implement small, delightful details.

Haptic Feedback: Use HapticFeedback.lightImpact() on key interactions like selecting a mood or snapping a carousel.

Overscroll Glow: Ensure the app uses the platform-appropriate overscroll effect (glowing on Android, bouncing on iOS).