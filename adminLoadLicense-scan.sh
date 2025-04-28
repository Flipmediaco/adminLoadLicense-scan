#!/bin/bash

echo "🛡️  Magento adminLoadLicense Scanner"
echo

# Prompt for Magento root directory
read -rp "Enter the full path to the Magento document root: " MAGENTO_ROOT

# Validate the directory
if [[ ! -d "$MAGENTO_ROOT" ]]; then
    echo "❌ Error: Directory '$MAGENTO_ROOT' does not exist. Exiting."
    exit 1
fi

# Move into the Magento root
cd "$MAGENTO_ROOT" || {
    echo "❌ Error: Failed to enter directory '$MAGENTO_ROOT'. Exiting."
    exit 1
}

echo
echo "📂 Working inside: $(pwd)"
echo

# Live filesystem scan
echo "🔎 Scanning live filesystem (all PHP files in app/code and vendor)..."
find app/code vendor/ -type f -iname "*.php" \
  | xargs --no-run-if-empty grep -i -n "adminLoadLicense("

# Check if we're inside a Git repository
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then

  echo
  # Prompt for Git history scan
  read -rp "⚙️  Do you want to scan Git history for adminLoadLicense()? (may be long) (Y/n): " SCAN_GIT
  SCAN_GIT=${SCAN_GIT:-Y}

  if [[ "$SCAN_GIT" =~ ^[Yy]$ ]]; then
      echo
      # Check if this is a shallow clone
      if git rev-parse --is-shallow-repository | grep -q true; then
        echo "⚠️  Warning: This repository is a shallow clone. Git history scan may be incomplete."
        echo "⚠️  You may want to run 'git fetch --unshallow' to retrieve full history."
        echo
        read -rp "⚙️  Continue Git history scan anyway? (Y/n): " CONTINUE_SHALLOW
        CONTINUE_SHALLOW=${CONTINUE_SHALLOW:-Y}
        if [[ ! "$CONTINUE_SHALLOW" =~ ^[Yy]$ ]]; then
          echo "ℹ️  Skipping Git history scan due to shallow clone."
          echo
          echo "✅ Scan Complete."
          exit 0
        fi
      fi

      # Prompt for scan depth
      echo
      echo "Select Git history scan mode:"
      echo "1) Deep Scan all app/code/*.php files"
      echo "2) Limited Scan: only licence/license*.php files"
      read -rp "Enter choice [1-2]: " SCAN_MODE
      SCAN_MODE=${SCAN_MODE:-1}

      echo
      if [[ "$SCAN_MODE" == "1" ]]; then
        echo "🔎 Performing DEEP Git history scan (all PHP files under app/code)..."
        FILE_FILTER='^app/code/.*\.php$'
      else
        echo "🔎 Performing LIMITED Git history scan (only licence/license PHP files under app/code)..."
        FILE_FILTER='^app/code/.*[Ll]icence.*\.php$\|^app/code/.*[Ll]icense.*\.php$'
      fi

      git rev-list --all | while read -r commit; do
        git ls-tree -r --name-only "$commit" \
          | grep -E "$FILE_FILTER" \
          | while read -r file; do
            # Progress feedback
            echo "Checking $commit:$file" >&2
            if git show "${commit}:${file}" 2>/dev/null | grep -qi "adminLoadLicense("; then
              echo "$commit:$file"
            fi
          done
      done
  else
      echo "ℹ️  Skipping Git history scan."
  fi

else
  echo
  echo "ℹ️  No Git repository detected — skipping Git history scan."
fi

echo
echo "✅ Scan Complete."