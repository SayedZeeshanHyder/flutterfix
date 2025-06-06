FlutterFix CLI Tool
====================

Description:
-------------
FlutterFix is a small command-line tool to help automate common Flutter project tasks like:
- Building APKs
- Cleaning builds
- Getting packages
- Running doctor checks

It acts as a simplified replacement for typing repetitive `flutter` commands.
Just use `flutterfix` instead of `flutter` for faster workflows.

Setup Instructions:
--------------------
1. Extract this zip file to any folder (e.g., C:\Tools\flutterfix)
2. Open Environment Variables on your system
3. Edit the "Path" variable under User or System variables
4. Add the path to the "bin" folder, e.g.:
   C:\Tools\flutterfix\bin
5. Click OK and restart your terminal or VS Code

How to Use:
------------
In any terminal, run:

  flutterfix [command]

Think of it as a debug replacement of flutter:
  `flutterfix build apk` = `flutter build apk`
  `flutterfix pub get`   = `flutter pub get`
  `flutterfix clean` = `flutter clean`

Available Commands:
--------------------
- flutterfix build apk     → Builds the APK
- flutterfix clean     → Cleans the Flutter project
- flutterfix pub get       → Runs flutter pub get
- flutterfix doctor    → Runs flutter doctor
- flutterfix help      → Shows help/instructions

Example:
---------
  cd MyFlutterApp
  flutterfix build apk

Notes:
-------
- Works on Windows
- Internal logic is hidden for simplicity and security
- No need to touch or view the script inside

Use `flutterfix` like you'd use `flutter`, but faster and simpler.
