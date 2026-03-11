# Detects the project type for a given directory.
# Usage: _wto_detect_project_type <directory>
# Prints one of: android, ios, other
#
# To add a new project type, add an `if` block before `print "other"`.

_wto_detect_project_type() {
  local dir="$1"

  # Android: Gradle wrapper or build scripts at root
  # Covers: pure Android apps, Kotlin Multiplatform (KMP)
  if [[ -f "$dir/gradlew" \
     || -f "$dir/build.gradle" \
     || -f "$dir/build.gradle.kts" \
     || -f "$dir/settings.gradle" \
     || -f "$dir/settings.gradle.kts" ]]; then
    print "android"
    return
  fi

  # iOS: Xcode workspace/project or CocoaPods manifest at root
  # xed prefers .xcworkspace over .xcodeproj automatically
  if [[ -n "$(find "$dir" -maxdepth 1 \( -name "*.xcworkspace" -o -name "*.xcodeproj" \) 2>/dev/null | head -1)" \
     || -f "$dir/Podfile" ]]; then
    print "ios"
    return
  fi

  # Default: open in Cursor / VS Code
  print "other"
}
