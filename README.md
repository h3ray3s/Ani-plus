# Ani-plus
<p align=center>
<br>
<a href="http://makeapullrequest.com"><img src="https://img.shields.io/badge/PRs-welcome-brightgreen.svg"></a>
<a href="#Linux"><img src="https://img.shields.io/badge/os-linux-brightgreen">
<a href="#MacOS"><img src="https://img.shields.io/badge/os-mac-brightgreen">
<a href="#Windows"><img src="https://img.shields.io/badge/os-windows-yellowgreen">
<a href="#Android"><img src="https://img.shields.io/badge/os-android-yellow">
<a href="#Steam-deck"><img src="https://img.shields.io/badge/os-steamdeck-yellow">
<a href="#iOS"><img src="https://img.shields.io/badge/os-ios-red">
<br>
[![AUR version](https://img.shields.io/aur/version/ani-plus?style=flat-square)](https://aur.archlinux.org/packages/ani-plus)
[![GitHub release](https://img.shields.io/github/v/release/h3ray3s/ani-plus?style=flat-square)](https://github.com/h3ray3s/ani-plus/releases)
[![License](https://img.shields.io/github/license/h3ray3s/ani-plus?style=flat-square)](https://github.com)

A CLI to browse and watch anime — **Inspired from [ani-cli](https://github.com/pystardust/ani-cli)** with **batch download**, **resume detection**, **persistent config** and much more.
<a href="https://github.com/port19x"><img src="https://img.shields.io/badge/lead-port19x-lightblue"></a>
<a href="https://github.com/CoolnsX"><img src="https://img.shields.io/badge/maintainer-CoolnsX-blue"></a>
<a href="https://github.com/justchokingaround"><img src="https://img.shields.io/badge/maintainer-justchokingaround-blue"></a>
<a href="https://github.com/Derisis13"><img src="https://img.shields.io/badge/maintainer-Derisis13-blue"></a>
<a href="https://github.com/71zenith"><img src="https://img.shields.io/badge/maintainer-71zenith-blue"></a>
<a href="https://github.com/vorlie"><img src="https://img.shields.io/badge/maintainer-vorlie-blue"></a>

</p>
---

## Why ani-plus?

| Feature | ani-plus |
|---------|---------|----------|
| Batch download | ⚠️ via `-d -e` (one at a time) | ✅ full batch loop |
| Automatically organizes anime files into existing folders or creates new ones based on the series name|
| Resume from last episode | ❌ | ✅ detects existing files |
| Persistent download dir | ❌ (env var only) | ✅ `-d /path` saves to config |
| Interactive menu after anime select | ❌ | ✅ Watch / Download / Quit |
| Quality preference remembered | ❌ | ✅ saved in config |
| All ani-cli flags | — | ✅ preserved |

---
|This project is still in development and new servers will be added in the next update|

## Table of Contents

- [Why ani-plus?](#why-ani-plus)
- [Showcase](#showcase)
- [Installation](#installation)
  - [Arch Linux (AUR)](#arch-linux-aur)
  - [Debian / Ubuntu](#debian--ubuntu)
  - [Fedora](#fedora)
  - [OpenSUSE](#opensuse)
  - [macOS](#macos)
  - [Android (Termux)](#android-termux)
  - [Steam Deck](#steam-deck)
  - [FreeBSD](#freebsd)
  - [From Source](#from-source)
- [Usage](#usage)
- [Batch Download](#batch-download)
- [Persistent Config](#persistent-config)
- [Dependencies](#dependencies)
- [Ani-Skip](#ani-skip)
- [Fixing errors](#fixing-errors)
- [FAQ](#faq)
- [Uninstall](#uninstall)
- [Disclaimer](#disclaimer)

---

## Showcase

```
$ ani-plus

Search anime: cyberpunk

  ▸ Cyberpunk: Edgerunners
    Cyberpunk 2077
    Cyberpunk: 2077 (Subbed)
    ...

Selected: Cyberpunk: Edgerunners
Episodes: 10 available
Save dir: /home/hera/anime

What would you like to do?
  1) Watch now
  2) Batch download
  3) Quit
Choice [1]: 2

Folder:  /home/hera/anime/Cyberpunk Edgerunners
Local progress: up to episode 3
Enter range (e.g. 4-24), or 'all' to resume from 4: 4-10

Choose quality:
  ▸ 1080p
    720p
    ...

Downloading Cyberpunk: Edgerunners Episode 4...
Downloading Cyberpunk: Edgerunners Episode 5...
...
Download complete: Cyberpunk: Edgerunners
Add another anime? (y/n): n
```

---

## Installation

### Arch Linux (AUR)

```bash
# Using yay
yay -S ani-plus

# Using paru
paru -S ani-plus
```

**Manual install from AUR:**
```bash
git clone https://aur.archlinux.org/ani-plus.git
cd ani-plus
makepkg -si
```

### Debian / Ubuntu

```bash
# Coming soon — pending Debian packaging
# For now, install from source (see below)
```

### Fedora

```bash
# Coming soon — pending COPR setup
sudo dnf copr enable h3ray3s/ani-plus
sudo dnf install ani-plus
```

### OpenSUSE

```bash
# Coming soon
zypper addrepo https://download.opensuse.org/repositories/home:/h3ray3s/ani-plus.repo
zypper install ani-plus
```

### macOS

```bash
# Homebrew tap (coming soon)
brew tap h3ray3s/ani-plus
brew install ani-plus
```

### Android (Termux)

```bash
pkg update
pkg install curl fzf mpv yt-dlp ffmpeg
curl -L https://raw.githubusercontent.com/h3ray3s/ani-plus/main/ani-plus.sh \
  -o $PREFIX/bin/ani-plus
chmod +x $PREFIX/bin/ani-plus
```

**Setup MPV referrer for Android:**
```bash
termux-setup-storage
# In MPV app: Settings → Advanced → mpv.conf
# Add: include="/storage/emulated/0/mpv/mpv.config.mp4"
```

### Steam Deck

**Full install script (paste into Konsole in Desktop Mode):**

```bash
# Dependencies
flatpak install -y io.mpv.Mpv
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install

# yt-dlp for downloads
mkdir -p ~/.local/bin
curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp \
  -o ~/.local/bin/yt-dlp
chmod +x ~/.local/bin/yt-dlp

# PATH
echo 'export PATH=$HOME/.local/bin:$PATH' >> ~/.bashrc
source ~/.bashrc

# ani-plus
curl -L https://raw.githubusercontent.com/h3ray3s/ani-plus/main/ani-plus.sh \
  -o ~/.local/bin/ani-plus
chmod +x ~/.local/bin/ani-plus
```

### FreeBSD

```bash
sudo pkg install mpv fzf yt-dlp ffmpeg curl
curl -L https://raw.githubusercontent.com/h3ray3s/ani-plus/main/ani-plus.sh \
  -o /usr/local/bin/ani-plus
sudo chmod +x /usr/local/bin/ani-plus
```

### From Source

Works on any Unix-like OS.

```bash
git clone https://github.com/h3ray3s/ani-plus.git
cd ani-plus
sudo cp ani-plus.sh /usr/local/bin/ani-plus
sudo chmod +x /usr/local/bin/ani-plus
```

---

## Usage

### Watch mode (default)

```bash
ani-plus
# → search → select anime → select episode → plays in mpv
```

### Command-line flags

```bash
# Watch with quality
ani-plus -q 720p "JBA No more balls"

# Play specific episode
ani-plus -e 4 "cyberpunk edgerunners"

# Play range
ani-plus -e 5-8 "blue lock"

# Use VLC instead of mpv
ani-plus -v "Peak piece"

# Syncplay (watch with friends)
ani-plus -s "spy x family"

# Skip intro (requires ani-skip)
ani-plus --skip "jujutsu kaisen"

# Continue from history
ani-plus -c

# Next episode countdown
ani-plus -N "one piece"

# Update
ani-plus -U
```

### All flags

| Flag | Description |
|------|-------------|
| `-c, --continue` | Continue from history |
| `-q, --quality <q>` | Video quality (`best`, `1080p`, `720p`, `480p`, `360p`, `240p`) |
| `-v, --vlc` | Use VLC |
| `-s, --syncplay` | Syncplay |
| `-S, --select-nth <n>` | Select nth search result |
| `-e, --episode <range>` | Episode or range |
| `--dub` | Dubbed version |
| `--skip` | Skip intro (ani-skip) |
| `--no-detach` | Don't detach player |
| `--exit-after-play` | Return player exit code |
| `-N, --nextep-countdown` | Show next episode countdown |
| `-d, --download-dir <path>` | **Set persistent download directory** |
| `--show-download-dir` | **Show config** |
| `--reset-config` | **Reset config** |
| `--dl, --download` | Single-episode download |
| `-D, --delete` | Delete history |
| `-l, --logview` | Show logs |
| `-V, --version` | Version |
| `-h, --help` | Help |
| `-U, --update` | Update script |
| `--rofi` / `--dmenu` | Use rofi/dmenu for menus |

---

## Batch Download

The **killer feature** of ani-plus.

### How it works

1. Search for anime
2. Select from the list
3. Choose **2) Batch download**
4. Enter episode range (`1-12`, `all`, etc.)
5. Pick quality
6. Downloads go to `<download_dir>/<anime title>/Episode N.mp4`
7. After each batch, asks "Add another anime?"

### Resume detection

ani-plus **scans the target folder** for existing `.mp4` / `.mkv` / `.webm` files and detects the highest episode number. If you already have episodes 1–5, entering `all` will resume from episode 6.

```
Local progress: up to episode 5
Enter range (e.g. 6-24), or 'all' to resume from 6: all
```

### Folder structure

```
<download_dir>/
├── Cyberpunk Edgerunners/
│   ├── Cyberpunk Edgerunners Episode 01.mp4
│   ├── Cyberpunk Edgerunners Episode 01.vtt   ← subtitles
│   ├── Cyberpunk Edgerunners Episode 02.mp4
│   └── ...
├── Blue Lock/
│   └── ...
```

---

## Persistent Config

Set your download dir once — it sticks.

```bash
# Set download directory permanently
ani-plus -d /run/media/hera/Percival/anime

# Output:
# Download directory permanently set to: /run/media/hera/Percival/anime
# Config saved at: /home/hera/.config/ani-plus/config
```

From then on, **every** batch download goes to that folder. No more `cd` before running.

### Check current config

```bash
ani-plus --show-download-dir

# Download directory: /run/media/hera/Percival/anime
# Quality:            best
# Config file:        /home/hera/.config/ani-plus/config
#
# --- file contents ---
# download_dir="/run/media/hera/Percival/anime"
# quality="1080p"
```

### Reset config

```bash
ani-plus --reset-config
```

### Config file location

| OS | Path |
|----|------|
| Linux / macOS | `~/.config/ani-plus/config` |
| Windows | `%APPDATA%\ani-plus\config` |
| Android (Termux) | `~/.config/ani-plus/config` |

### Quality preference is also saved

When you pick a quality during batch download (e.g. `1080p`), it's saved and pre-selected next time.

---

## Dependencies

### Required

| Tool | Purpose |
|------|---------|
| `grep` | Text parsing |
| `sed` | Text parsing |
| `curl` | HTTP requests |
| `mpv` | Video player |
| `fzf` | Interactive menu |
| `yt-dlp` or `ffmpeg` | Download engine |

### Optional

| Tool | Purpose |
|------|---------|
| `ani-skip` | Auto-skip intros |
| `rofi` / `dmenu` | Alternative menus |
| `vlc` | Alternative player |
| `syncplay` | Watch with friends |
| `patch` | Self-update support |

### Install all deps (Arch)

```bash
sudo pacman -S curl sed grep fzf mpv yt-dlp ffmpeg
```

### Install all deps (Debian/Ubuntu)

```bash
sudo apt install curl sed grep fzf mpv yt-dlp ffmpeg
```

### Install all deps (macOS)

```bash
brew install curl fzf mpv yt-dlp ffmpeg
brew install --cask iina
```

---

## Ani-Skip

[ani-skip](https://github.com/synacktraa/ani-skip) automatically skips anime openings.

```bash
# Install (Arch)
yay -S ani-skip

# Use with ani-plus
ani-plus --skip "one piece"
```

## Fixing errors

### Blocked by cloudflare

Install `curl-impersonate`:

```bash
# Arch
yay -S curl-impersonate-bin

# Manual install
curl -LO "https://github.com/lwthiker/curl-impersonate/releases/download/v0.6.1/curl-impersonate-v0.6.1.x86_64-linux-gnu.tar.gz"
sudo tar xf curl-impersonate-v0.6.1.x86_64-linux-gnu.tar.gz -C /usr/local/bin
```

ani-plus auto-detects and uses `curl-impersonate` if present.

### "No sources found"

- Try `--dub` flag (sub servers may be down)
- Update with `ani-plus -U`
- Check [hianime status](https://hianime.at)

### Update failing

Install `patch`:

```bash
# Arch
sudo pacman -S patch

# Debian
sudo apt install patch
```

Then run `ani-plus -U`.

---

## FAQ

**Q: Can I use this instead of ani-cli?**  
A: Yes — it's a superset. Every ani-cli flag works. Additionally, `ani-cli` is installed as a symlink so scripts calling `ani-cli` still work.

**Q: Where does it download to by default?**  
A: Current working directory. Set a permanent dir with `ani-plus -d /path`.

**Q: Can I download at a specific quality?**  
A: Yes. When prompted, pick from `best`, `1080p`, `720p`, `480p`, `360p`, `240p`.

**Q: Does it work on Windows?**  
A: Via WSL. Native Windows support is coming.

**Q: Where's the history stored?**  
A: `~/.local/state/ani-plus/ani-hsts` (respects `$XDG_STATE_HOME`).

**Q: How do I report a bug?**  
A: [Open an issue](https://github.com/h3ray3s/ani-plus/issues).

---

## Uninstall

### Arch

```bash
sudo pacman -R ani-plus
```

### From source

```bash
sudo rm /usr/local/bin/ani-plus
rm -rf ~/.config/ani-plus
rm -rf ~/.local/state/ani-plus
```

### Cleanup saved config

```bash
rm -rf ~/.config/ani-plus
rm -rf ~/.local/state/ani-plus
```

---

## Contributing

1. Fork the repo
2. Create a branch (`git checkout -b feature/amazing`)
3. Commit (`git commit -m "Add amazing feature"`)
4. Push (`git push origin feature/amazing`)
5. Open a Pull Request

**AI policy:** Pull requests containing AI-generated code must disclose this in the PR description. Low-effort AI-generated contributions will be rejected.

---

## Disclaimer

ani-plus does **not** host any content. It scrapes publicly available stream URLs from hianime.at and passes them to mpv/yt-dlp.

- Do not use this for piracy
- Respect content licenses in your country
- The maintainer is not responsible for how you use this tool

If you enjoy an anime, **buy the Blu-ray** or subscribe to a legitimate streaming service.

---

## License

GPL-3.0 

## Credits

- [pystardust/ani-cli](https://github.com/pystardust/ani-cli) — the original
- [hianime.at](https://hianime.at) — the source
- All 138 ani-cli contributors

---

**Made by [Hera](https://github.com/h3ray3s)** — a fork built out of frustration with `-e 1 -e 2 -e 3...`
