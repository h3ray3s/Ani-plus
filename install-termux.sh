#!/data/data/com.termux/files/usr/bin/bash
set -e

echo "==> Installing dependencies..."
pkg update -y
pkg install -y curl fzf mpv yt-dlp ffmpeg sed grep

echo "==> Downloading ani-plus..."
curl -L https://raw.githubusercontent.com/h3ray3s/Ani-plus/main/ani-plus.sh \
  -o $PREFIX/bin/ani-plus
chmod +x $PREFIX/bin/ani-plus

echo ""
echo "✓ ani-plus installed. Run: ani-plus"
echo ""
echo "For MPV playback, add this to MPV's mpv.conf:"
echo "  include=\"/storage/emulated/0/mpv/mpv.config.mp4\""
