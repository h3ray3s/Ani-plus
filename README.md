# Ani-plus

<p align="center">
<br>
<a href="http://makeapullrequest.com"><img src="https://img.shields.io/badge/PRs-welcome-brightgreen.svg"></a>
<a href="#linux"><img src="https://img.shields.io/badge/os-linux-brightgreen"></a>
<a href="#macos"><img src="https://img.shields.io/badge/os-mac-brightgreen"></a>
<a href="#windows"><img src="https://img.shields.io/badge/os-windows-yellowgreen"></a>
<a href="#android"><img src="https://img.shields.io/badge/os-android-yellow"></a>
<a href="#steam-deck"><img src="https://img.shields.io/badge/os-steamdeck-yellow"></a>
<a href="#ios"><img src="https://img.shields.io/badge/os-ios-red"></a>
<br>
<a href="https://github.com/h3ray3s/Ani-plus/releases"><img src="https://img.shields.io/github/v/release/h3ray3s/Ani-plus?style=flat-square"></a>
<a href="https://github.com/h3ray3s/Ani-plus/blob/main/LICENSE"><img src="https://img.shields.io/github/license/h3ray3s/Ani-plus?style=flat-square"></a>
<a href="https://github.com/h3ray3s/Ani-plus/stargazers"><img src="https://img.shields.io/github/stars/h3ray3s/Ani-plus?style=flat-square"></a>
<a href="https://github.com/h3ray3s"><img src="https://img.shields.io/badge/active%20dev-h3ray3s-lightred"></a>
</p>

A CLI to browse and watch anime — inspired by [ani-cli](https://github.com/pystardust/ani-cli) — with batch download, resume detection, persistent config, and more.

> ⚠️ This project is still in active development. New servers and features will be added in upcoming updates.

---

## Why ani-plus?

| Feature | Ani-plus |
|---------|:--------:|
| Batch download | ✅ full batch loop |
| Auto-organises files into folders by series name | ✅ |
| Resume downloads from last episode | ✅ detects existing files |
| Persistent download dir | ✅ `-d /path` saves to config |
| Interactive menu after anime select | ✅ Watch / Download / Quit |
| Quality preference remembered | ✅ saved in config |
| All ani-cli flags | ✅ preserved |

---

## Table of Contents

- [Why ani-plus?](#why-ani-plus)
- [Showcase](#showcase)
- [Installation](#installation)
  - [Most Linux distros](#For-most-linux-Distro)
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
- [Persistent Config](#persistent-config)
- [Dependencies](#dependencies)
- [Ani-Skip](#ani-skip)
- [Fixing errors](#fixing-errors)
- [FAQ](#faq)
- [Uninstall](#uninstall)
- [Contributing](#contributing)
- [Disclaimer](#disclaimer)
- [License](#license)
- [Credits](#credits)

---

## Showcase

```console
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


### Please use install script as AUR is facing technical issues 

### For most linux Distro
```bash

curl -fsSL https://github.com/h3ray3s/Ani-plus/releases/latest/download/ani-plus-1.0.0-install.sh | sudo bash
```


### Arch Linux (AUR)

```bash
# Using yay
yay -S ani-plus

# Using paru
paru -S ani-plus
```

Manual install from AUR:

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

Setup MPV referrer for Android:

```bash
termux-setup-storage
# In MPV app: Settings → Advanced → mpv.conf
# Add: include="/storage/emulated/0/mpv/mpv.config.mp4"
```

### Steam Deck

Full install script (paste into Konsole in Desktop Mode):

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

# Ani-plus Usage Guide

A visual walkthrough of every screen you'll see.

---

## Table of Contents

- [Starting Ani-plus](#starting-ani-plus)
- [Search Flow](#search-flow)
- [The Mode Menu](#the-mode-menu)
- [Watch Flow](#watch-flow)
- [Batch Download Flow](#batch-download-flow)
- [Resume Detection](#resume-detection)
- [Quality Selection](#quality-selection)
- [Post-Play Menu](#post-play-menu)
- [Command-Line Flags](#command-line-flags)
- [Config Menu](#config-menu)
- [Common Routes](#common-routes)

---

## Starting Ani-plus

**PLEASE SET DOWNLOAD DIR BY ``ani-plus -d /path``**

Just type `ani-plus` in your terminal.

```console
$ ani-plus
```

You'll immediately be dropped into the search prompt.

```console
Search anime: █
```

---

## Search Flow

Type any anime name. Hit Enter.

```console
Search anime: JBA No more balls
```

Ani-plus queries hianime.at and shows you a menu of matching results.

```console
┌──────────────────────────────────────────┐
│  Select anime:                           │
│                                          │
│  ▸ JBA No more balls                     │
│    JBA No more balls (Dub)               │
│    JoJo's Bizarre Adventure              │
│    JoJo's Bizarre Adventure: Stone Ocean │
│    JoJo's Bizarre Adventure (Subbed)     │
│    ...                                   │
└──────────────────────────────────────────┘
```

Use **arrow keys** to navigate, **Enter** to select.

---

## The Mode Menu

Once you pick an anime, Ani-plus fetches the episode list and shows you
what to do next.

```console
Selected: JBA No more balls
Episodes: 12 available
Save dir: /home/hera/anime

What would you like to do?
  1) Watch now
  2) Batch download
  3) Quit
Choice [1]: █
```

Three routes:

| Choice | What happens |
|--------|-------------|
| `1` or Enter | Watch an episode now |
| `2` | Batch download a range |
| `3` | Exit cleanly |

---

## Watch Flow

Choose `1`. Then pick an episode.

```console
┌──────────────────────────────────────────┐
│  Select episode:                         │
│                                          │
│  ▸ 1                                     │
│    2                                     │
│    3                                     │
│    4                                     │
│    ...                                   │
└──────────────────────────────────────────┘
```

Select one, and Ani-plus:

1. Fetches the stream URLs
2. Picks the best quality
3. Launches mpv (or your configured player)

```console
hianime.at links fetched
Playing episode 1...
```

**Multi-select for ranges:** hold `Tab` to select multiple episodes, or
enter a range directly with `-e "1-5"`.

---

## Batch Download Flow

Choose `2`. Ani-plus scans the target folder first.

```console
Anime:   JBA No more balls
Folder:  /home/hera/anime/JBA No more balls
Episodes available: 12

Enter range (e.g. 1-12), or 'all': █
```

Two ways to specify:

| Input | Meaning |
|-------|---------|
| `1-12` | Download episodes 1 through 12 |
| `all` | Download every episode |
| `5` | Download just episode 5 |

After you type the range, Ani-plus asks for quality.

---

## Resume Detection

If you already have episodes in the target folder, Ani-plus tells you.

```console
Anime:   JBA No more balls
Folder:  /home/hera/anime/JBA No more balls
Episodes available: 12
Local progress: up to episode 3

Enter range (e.g. 4-24), or 'all' to resume from 4: █
```

Type `all` and it starts at episode 4. Type `5-8` and it downloads just
those. No duplicate downloads.

**How it works:** Ani-plus scans the folder for `.mp4`, `.mkv`, and `.webm`
files, extracts the highest episode number it finds, and picks up from
there.

---

## Quality Selection

After picking a range, Ani-plus asks for video quality.

```console
┌──────────────────────────────────────────┐
│  Quality:                                │
│                                          │
│  ▸ best                                  │
│    1080p                                 │
│    720p                                 │
│    480p                                 │
│    360p                                 │
│    240p                                 │
└──────────────────────────────────────────┘
```

Pick one. Your choice is **saved to config** and pre-selected next time.

Then the download begins:

```console
Downloading JBA No more balls Episode 4...
Downloading JBA No more balls Episode 5...
Downloading JBA No more balls Episode 6...
...
Download complete: JBA No more balls
```

---

## Post-Play Menu

While an episode is playing, Ani-plus waits. When the player closes:

```console
┌──────────────────────────────────────────┐
│  Playing episode 1 of JBA No more balls... │
│                                          │
│  ▸ next                                  │
│    replay                                │
│    previous                              │
│    select                                │
│    change_quality                        │
│    quit                                  │
└──────────────────────────────────────────┘
```

| Option | Action |
|--------|--------|
| `next` | Play the next episode |
| `replay` | Replay the current episode |
| `previous` | Go back one episode |
| `select` | Jump to a specific episode |
| `change_quality` | Switch quality mid-session |
| `quit` | Exit cleanly |

---

## Command-Line Flags

Skip the interactive menus with flags.

### Direct watch

```console
$ ani-plus -q 720p "JBA No more balls"
```

Searches, plays the first result, at 720p.

### Specific episode

```console
$ ani-plus -e 4 "JBA No more balls"
```

Searches, plays episode 4.

### Episode range

```console
$ ani-plus -e 5-8 "JBA No more balls"
```

Searches, plays episodes 5 through 8 sequentially.

### VLC instead of mpv

```console
$ ani-plus -v "JBA No more balls"
```

### Continue from history

```console
$ ani-plus -c
```

Resumes the last anime you were watching.

### Next-episode countdown

```console
$ ani-plus -N "JBA No more balls"
```

Shows when the next sub/dub episode releases.

### Update the script

```console
$ ani-plus -U
```

Fetches the latest `ani-plus.sh` from the repo.

---

## Config Menu

Ani-plus stores its settings in `~/.config/ani-plus/config`.

### Set download directory (once)

```console
$ ani-plus -d /run/media/hera/Percival/anime

Download directory permanently set to: /run/media/hera/Percival/anime
Config saved at: /home/hera/.config/ani-plus/config
```

From then on, every batch download goes there. No `cd` required.

### View current config

```console
$ ani-plus --show-download-dir

Download directory: /run/media/hera/Percival/anime
Quality:            best
Config file:        /home/hera/.config/ani-plus/config

--- file contents ---
download_dir="/run/media/hera/Percival/anime"
quality="1080p"
```

### Reset config

```console
$ ani-plus --reset-config

Config reset. Defaults will be used next run.
```

---

## Common Routes

| Scenario | Command |
|----------|---------|
| Browse and pick interactively | `ani-plus` |
| Play an anime by name | `ani-plus "JBA No more balls"` |
| Play at 720p | `ani-plus -q 720p "JBA No more balls"` |
| Play episode 4 | `ani-plus -e 4 "JBA No more balls"` |
| Play episodes 5 through 8 | `ani-plus -e 5-8 "JBA No more balls"` |
| Continue from last session | `ani-plus -c` |
| Check next episode air date | `ani-plus -N "JBA No more balls"` |
| Download one episode | `ani-plus --dl -e 4 "JBA No more balls"` |
| Change download dir permanently | `ani-plus -d /path/to/anime` |
| Show current settings | `ani-plus --show-download-dir` |
| Reset everything | `ani-plus --reset-config` |
| Update script | `ani-plus -U` |
| Help | `ani-plus -h` |
| Version | `ani-plus -V` |

---

## Folder Layout After Batch Download

```
/your/download_dir/
├── JBA No more balls/
│   ├── JBA No more balls Episode 01.mp4
│   ├── JBA No more balls Episode 01.vtt   ← subtitles
│   ├── JBA No more balls Episode 02.mp4
│   ├── JBA No more balls Episode 02.vtt
│   └── ...
├── JoJo's Bizarre Adventure/
│   ├── JoJo's Bizarre Adventure Episode 01.mp4
│   └── ...
└── One Piece/
    ├── One Piece Episode 1080.mp4
    └── ...
```

Subtitle files are downloaded alongside each episode automatically.

---

## Troubleshooting The Flow

| Symptom | Cause | Fix |
|---------|-------|-----|
| Menu doesn't appear | `fzf` not installed | `sudo pacman -S fzf` |
| No search results | Cloudflare block on hianime | Install `curl-impersonate` |
| Video doesn't play | mpv missing referrer | Check the README FAQ |
| Download hangs | yt-dlp out of date | `yt-dlp -U` |
| Config not loading | Bad path in config | `ani-plus --reset-config` |

---

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
| `-d, --download-dir <path>` | Set persistent download directory |
| `--show-download-dir` | Show config |
| `--reset-config` | Reset config |
| `--dl, --download` | Single-episode download |
| `-D, --delete` | Delete history |
| `-l, --logview` | Show logs |
| `-V, --version` | Version |
| `-h, --help` | Help |
| `-U, --update` | Update script |
| `--rofi` / `--dmenu` | Use rofi/dmenu for menus |

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

From then on, every batch download goes to that folder. No more `cd` before running.

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

---

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
A: [Open an issue](https://github.com/h3ray3s/Ani-plus/issues).

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

ani-plus does **not** host any content. It scrapes publicly available stream URLs from `hianime.at` and passes them to `mpv` / `yt-dlp`.

- Do not use this for piracy
- Respect content licenses in your country
- The maintainer is not responsible for how you use this tool

If you enjoy an anime, **buy the Blu-ray** or subscribe to a legitimate streaming service.

---

## License

GPL-3.0

---

## Credits

- [pystardust/ani-cli](https://github.com/pystardust/ani-cli) — the original
- [hianime.at](https://hianime.at) — the source
- All 138 ani-cli contributors

**Made by [Hera](https://github.com/h3ray3s)** — a fork built out of frustration with `-e 1 -e 2 -e 3...`
