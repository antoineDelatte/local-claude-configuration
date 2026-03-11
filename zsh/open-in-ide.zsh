# Opens the appropriate IDE for a given project type and directory.
# Usage: _wto_open_ide <project-type> <directory>
# project-type: android | ios | other
#
# To add a new IDE, add a case branch or extend the fallback chain.

_wto_open_ide() {
  local project_type="$1"
  local dir="$2"

  case "$project_type" in
    android)
      # JetBrains Toolbox installs `studio` CLI at
      # ~/Library/Application Support/JetBrains/Toolbox/scripts/studio
      if command -v studio &>/dev/null; then
        studio "$dir"
      else
        open -a "Android Studio" "$dir"
      fi
      ;;

    ios)
      # xed is Apple's official CLI at /usr/bin/xed.
      # It automatically selects .xcworkspace over .xcodeproj.
      xed "$dir"
      ;;

    *)
      # Cursor: CLI is not on PATH by default; check the known bundle location.
      local cursor_bin="/Applications/Cursor.app/Contents/Resources/app/bin/cursor"
      if command -v cursor &>/dev/null; then
        cursor "$dir"
      elif [[ -x "$cursor_bin" ]]; then
        "$cursor_bin" "$dir"
      elif command -v code &>/dev/null; then
        code "$dir"
      else
        print "No editor found. Install Cursor or VS Code, or open '$dir' manually." >&2
        return 1
      fi
      ;;
  esac
}
