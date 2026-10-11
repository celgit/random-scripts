#!/bin/bash
# Sets up a server with fish, tmux and fastfetch, plus their configs from this repo.
# Run after git clone/pull: ./Server-setup/initiate.sh
# Safe to re-run: every step checks the current state and only does what is missing.
# Works on Fedora (dnf) and Ubuntu/Debian (apt). Existing config files are
# replaced with links into this repo.

set -o pipefail

DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

have() { command -v "$1" >/dev/null 2>&1; }

# pkg <package>: installs with whichever package manager is available.
apt_updated=0
pkg() {
  if have dnf; then
    sudo dnf install -y "$1"
  elif have apt-get; then
    if [ "$apt_updated" = 0 ]; then
      sudo apt-get update -qq
      apt_updated=1
    fi
    sudo apt-get install -y "$1"
  else
    echo "NOTE:        no known package manager, install $1 yourself"
    return 1
  fi
}

# fastfetch_from_release: older Ubuntu/Debian releases and RHEL-likes do not
# package fastfetch, so fall back to the package the project publishes itself.
fastfetch_from_release() {
  local arch ext variant tmp rc=1
  case "$(uname -m)" in
    x86_64) arch=amd64 ;;
    aarch64|arm64) arch=aarch64 ;;
    armv7l) arch=armv7l ;;
    *) return 1 ;;
  esac
  if have apt-get; then ext=deb
  elif have dnf; then ext=rpm
  else return 1
  fi

  tmp="$(mktemp -d)" || return 1
  chmod 755 "$tmp"
  # The polyfilled build is for systems with an older glibc.
  for variant in "" "-polyfilled"; do
    curl -fsSL -o "$tmp/fastfetch.$ext" \
      "https://github.com/fastfetch-cli/fastfetch/releases/latest/download/fastfetch-linux-$arch$variant.$ext" || continue
    if [ "$ext" = deb ]; then
      sudo apt-get install -y "$tmp/fastfetch.deb"
    else
      sudo dnf install -y "$tmp/fastfetch.rpm"
    fi
    rc=$?
    [ "$rc" = 0 ] && break
  done
  rm -rf "$tmp"
  return "$rc"
}

# link <source> <target>: skips if the target dir is missing (tool not installed).
# A real file at the target is replaced, since the repo is the source of truth.
link() {
  local src="$1" dst="$2"
  if [ ! -d "$(dirname "$dst")" ]; then
    echo "skipping:    $dst (directory does not exist)"
  elif [ -e "$dst" ] && [ ! -L "$dst" ]; then
    ln -sfn "$src" "$dst" && echo "replaced:    $dst (was a real file)"
  else
    ln -sfn "$src" "$dst" && echo "linked:      $dst"
  fi
}

echo "== Tools"
for tool in curl tmux fish; do
  if have "$tool"; then
    echo "found:       $tool"
  else
    echo "installing:  $tool"
    pkg "$tool" || echo "NOTE:        could not install $tool, skipping it"
  fi
done

if have fastfetch; then
  echo "found:       fastfetch"
else
  echo "installing:  fastfetch"
  if ! pkg fastfetch; then
    echo "retrying:    fastfetch from the project's own release package"
    fastfetch_from_release || echo "NOTE:        could not install fastfetch, skipping it"
  fi
fi

echo "== fish"
if have fish; then
  fish_path="$(command -v fish)"
  mkdir -p "$HOME/.config/fish/functions"

  if ! grep -qx "$fish_path" /etc/shells; then
    echo "$fish_path" | sudo tee -a /etc/shells > /dev/null && echo "added:       $fish_path to /etc/shells"
  fi

  # Changed through sudo so it also works for accounts without a password.
  if [ "$(getent passwd "$USER" | cut -d: -f7)" = "$fish_path" ]; then
    echo "found:       fish is already the login shell"
  elif have chsh; then
    sudo chsh -s "$fish_path" "$USER" && echo "changed:     login shell to fish (takes effect at next login)"
  else
    sudo usermod -s "$fish_path" "$USER" && echo "changed:     login shell to fish (takes effect at next login)"
  fi
else
  echo "skipping:    fish is missing"
fi

echo "== Links"
if have fastfetch; then
  mkdir -p "$HOME/.config/fastfetch"
fi

link "$DIR/tmux.conf"                       "$HOME/.tmux.conf"
link "$DIR/fish/config.fish"                "$HOME/.config/fish/config.fish"
link "$DIR/fish/functions/fish_prompt.fish" "$HOME/.config/fish/functions/fish_prompt.fish"
link "$DIR/fish/functions/gac.fish"         "$HOME/.config/fish/functions/gac.fish"
link "$DIR/fastfetch/config.jsonc"          "$HOME/.config/fastfetch/config.jsonc"
