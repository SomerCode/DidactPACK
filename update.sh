#!/bin/bash

# Function to check for updates recursively in the given directory
check_for_updates() {
  local directory="$1"
  local repo_name="$2"

  echo "Checking for updates in $directory/$repo_name..."

  # Save the current working directory
  current_dir=$(pwd)

  # Change to the repository directory
  cd "$directory"

  # Clone the latest version of the repository
  git clone "https://github.com/$github_username/$repo_name.git" "$directory/$repo_name.tmp" 2>/dev/null

  # Check if the cloning was successful
  if [ $? -eq 0 ]; then
    # Compare the content of the current version with the latest version
    if ! diff -qr "$directory/$repo_name" "$directory/$repo_name.tmp" &>/dev/null; then
      echo "Updating $repo_name to the latest version..."

      # Replace the old version with the new one
      rm -rf "$directory/$repo_name"
      mv "$directory/$repo_name.tmp" "$directory/$repo_name"

      echo "Update completed."
    else
      echo "No updates available for $repo_name."
      rm -rf "$directory/$repo_name.tmp"
    fi
  else
    echo "Failed to check for updates in $repo_name."
  fi

  # Restore the original working directory
  cd "$current_dir"
}

# Set the initial directory
local_path="$(dirname "$(realpath "$0")")"
github_username="SomerCode"

# Check the name of the desktop directory
desktop_name=$(xdg-user-dir DESKTOP 2>/dev/null)
desktop_name=${desktop_name:-"$HOME/Desktop"}

# Check if Didactinstaller directory exists
if [ ! -d "$local_path/Didactinstaller" ]; then
  # Directory does not exist, perform initial installation
  echo "Installing Didactinstaller..."
  git clone "https://github.com/$github_username/Didactinstaller.git" "$local_path/Didactinstaller" 2>/dev/null
else
  # Directory exists, perform update
  check_for_updates "$local_path" "Didactinstaller"
fi

# Check if the update or installation was successful
if [ -d "$local_path/Didactinstaller" ]; then
  # Run the Python script
  echo "Running Didactinstaller Python script..."
  python3 "$local_path/Didactinstaller/app.py"

  # Create a desktop shortcut
  desktop_file="$desktop_name/Didactinstaller.desktop"
  echo "[Desktop Entry]" > "$desktop_file"
  echo "Version=1.0" >> "$desktop_file"
  echo "Name=Didactinstaller" >> "$desktop_file"
  echo "Comment=Your description here" >> "$desktop_file"
  echo "Exec=gnome-terminal --command 'bash -c \"cd $local_path/Didactinstaller && ./update.sh\"'" >> "$desktop_file"
  echo "Path=$local_path/Didactinstaller" >> "$desktop_file"
  echo "Icon=$local_path/Didactinstaller/your_icon.png" >> "$desktop_file"
  echo "Terminal=false" >> "$desktop_file"
  echo "Type=Application" >> "$desktop_file"
  echo "Categories=Utility;" >> "$desktop_file"

  chmod +x "$desktop_file"

  echo "Desktop shortcut created at: $desktop_file"
else
  echo "No updates or failed to install/update Didactinstaller. Exiting."
fi
