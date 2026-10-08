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
<a href="https://github.com/h3ray3s"><img src="https://img.shields.io/badge/active%20dev-h3ray3s-lightblue"></a>
</p>

A CLI to browse and watch anime — **inspired by [ani-cli](https://github.com/pystardust/ani-cli)** — with **batch download**, **resume detection**, **persistent config**, and more.

> ⚠️ This project is still in active development. New servers and features will be added in upcoming updates.

## Why ani-plus?

| Feature | Ani-plus |
|---------|----------|
| Batch download | ✅ full batch loop |
| Auto-organizes anime files into folders by series name | ✅ |
| Resume downloads from last episode | ✅ detects existing files |
| Persistent download dir | ✅ `-d /path` saves to config |
| Interactive menu after anime select | ✅ Watch / Download / Quit |
| Quality preference remembered | ✅ saved in config |
| All ani-cli flags | ✅ preserved |

## Table of Contents

- [Why ani-plus?](#why-ani-plus)
- [Showcase](#showcase)
- [Installation](#installation)
- [Usage](#usage)
- [Batch Download](#batch-download)
- [Persistent Config](#persistent-config)
- [Dependencies](#dependencies)
- [Ani-Skip](#ani-skip)
- [Fixing errors](#fixing-errors)
- [FAQ](#faq)
- [Uninstall](#uninstall)
- [Disclaimer](#disclaimer)

## Showcase
$ ani-plus

Search anime: cyberpunk

▸ Cyberpunk: Edgerunners
Cyberpunk 2077
Cyberpunk: 2077 (Subbed)

Selected: Cyberpunk: Edgerunners
Episodes: 10 available
Save dir: /home/hera/anime

What would you like to do?

Watch now

Batch download

Quit
Choice [1]: 2

Folder: /home/hera/anime/Cyberpunk Edgerunners
Local progress: up to episode 3
Enter range (e.g. 4-24), or 'all' to resume from 4: 4-10

Downloading Cyberpunk: Edgerunners Episode 4...
Downloading Cyberpunk: Edgerunners Episode 5...
Download complete: Cyberpunk: Edgerunners
Add another anime? (y/n): n

text

## Installation

### Arch Linux (AUR)

```bash
yay -S ani-plus
# or
paru -S ani-plus
Manual:

bash
git clone https://aur.archlinux.org/ani-plus.git
cd ani-plus
makepkg -si
Android (Termux)
bash
pkg update
pkg install curl fzf mpv yt-dlp ffmpeg
curl -L https://raw.githubusercontent.com/h3ray3s/ani-plus/main/ani-plus.sh -o $PREFIX/bin/ani-plus
chmod +x $PREFIX/bin/ani-plus
MPV referrer setup:

bash
termux-setup-storage
# In MPV app: Settings → Advanced → mpv.conf
# Add: include="/storage/emulated/0/mpv/mpv.config.mp4"
Steam Deck
bash
flatpak install -y io.mpv.Mpv
git clone --depth 1 https://github.com/junegunn/fzf.git ~/.fzf
~/.fzf/install
mkdir -p ~/.local/bin
curl -L https://github.com/yt-dlp/yt-dlp/releases/latest/download/yt-dlp -o ~/.local/bin/yt-dlp
chmod +x ~/.local/bin/yt-dlp
echo 'export PATH=$HOME/.local/bin:$PATH' >> ~/.bashrc
source ~/.bashrc
curl -L https://raw.githubusercontent.com/h3ray3s/ani-plus/main/ani-plus.sh -o ~/.local/bin/ani-plus
chmod +x ~/.local/bin/ani-plus
FreeBSD
bash
sudo pkg install mpv fzf yt-dlp ffmpeg curl
curl -L https://raw.githubusercontent.com/h3ray3s/ani-plus/main/ani-plus.sh -o /usr/local/bin/ani-plus
sudo chmod +x /usr/local/bin/ani-plus
From Source
bash
git clone https://github.com/h3ray3s/ani-plus.git
cd ani-plus
sudo cp ani-plus.sh /usr/local/bin/ani-plus
sudo chmod +x /usr/local/bin/ani-plus
Usage
bash
ani-plus                              # interactive
ani-plus -q 720p "one piece"          # quality
ani-plus -e 4 "cyberpunk edgerunners" # episode
ani-plus -e 5-8 "blue lock"           # range
ani-plus -v "peak piece"              # VLC
ani-plus -s "spy x family"            # Syncplay
ani-plus --skip "jujutsu kaisen"      # skip intro
ani-plus -c                           # continue
ani-plus -N "one piece"               # next episode countdown
ani-plus -U                           # update
All flags
Flag	Description
-c, --continue	Continue from history
-q, --quality <q>	Video quality (best, 1080p, 720p, 480p, 360p, 240p)
-v, --vlc	Use VLC
-s, --syncplay	Syncplay
-S, --select-nth <n>	Select nth search result
-e, --episode <range>	Episode or range
--dub	Dubbed version
--skip	Skip intro (ani-skip)
--no-detach	Don't detach player
--exit-after-play	Return player exit code
-N, --nextep-countdown	Show next episode countdown
-d, --download-dir <path>	Set persistent download directory
--show-download-dir	Show config
--reset-config	Reset config
--dl, --download	Single-episode download
-D, --delete	Delete history
-l, --logview	Show logs
-V, --version	Version
-h, --help	Help
-U, --update	Update script
--rofi / --dmenu	Use rofi/dmenu for menus
Batch Download
The killer feature of ani-plus.

Search for anime

Select from the list

Choose 2) Batch download

Enter episode range (1-12, all, etc.)

Pick quality

Downloads go to <download_dir>/<anime title>/Episode N.mp4

After each batch, asks "Add another anime?"

Resume detection
ani-plus scans the target folder for existing .mp4 / .mkv / .webm files and detects the highest episode number. If you already have episodes 1–5, entering all will resume from episode 6.

text
Local progress: up to episode 5
Enter range (e.g. 6-24), or 'all' to resume from 6: all
Folder structure
text
<download_dir>/
├── Cyberpunk Edgerunners/
│   ├── Cyberpunk Edgerunners Episode 01.mp4
│   ├── Cyberpunk Edgerunners Episode 01.vtt
│   ├── Cyberpunk Edgerunners Episode 02.mp4
│   └── ...
└── Blue Lock/
    └── ...
Persistent Config
Set your download dir once — it sticks.

bash
ani-plus -d /run/media/hera/Percival/anime
Output:

text
Download directory permanently set to: /run/media/hera/Percival/anime
Config saved at: /home/hera/.config/ani-plus/config
Check current config
bash
ani-plus --show-download-dir
Reset config
bash
ani-plus --reset-config
Config file location
OS	Path
Linux / macOS	~/.config/ani-plus/config
Windows	%APPDATA%\ani-plus\config
Android (Termux)	~/.config/ani-plus/config
Dependencies
Required
Tool	Purpose
grep	Text parsing
sed	Text parsing
curl	HTTP requests
mpv	Video player
fzf	Interactive menu
yt-dlp or ffmpeg	Download engine
Optional
Tool	Purpose
ani-skip	Auto-skip intros
rofi / dmenu	Alternative menus
vlc	Alternative player
syncplay	Watch with friends
patch	Self-update support
Install all deps (Arch)
bash
sudo pacman -S curl sed grep fzf mpv yt-dlp ffmpeg
Install all deps (Debian/Ubuntu)
bash
sudo apt install curl sed grep fzf mpv yt-dlp ffmpeg
Install all deps (macOS)
bash
brew install curl fzf mpv yt-dlp ffmpeg
brew install --cask iina
Ani-Skip
ani-skip automatically skips anime openings.

bash
yay -S ani-skip
ani-plus --skip "one piece"
Fixing errors
Blocked by Cloudflare
bash
yay -S curl-impersonate-bin
# Manual:
curl -LO "https://github.com/lwthiker/curl-impersonate/releases/download/v0.6.1/curl-impersonate-v0.6.1.x86_64-linux-gnu.tar.gz"
sudo tar xf curl-impersonate-v0.6.1.x86_64-linux-gnu.tar.gz -C /usr/local/bin
ani-plus auto-detects and uses curl-impersonate if present.

"No sources found"
Try --dub flag (sub servers may be down)

Update with ani-plus -U

Check hianime status

Update failing
bash
sudo pacman -S patch   # Arch
sudo apt install patch # Debian
Then run ani-plus -U.

FAQ
Q: Can I use this instead of ani-cli?
A: Yes — it's a superset. Every ani-cli flag works. ani-cli is installed as a symlink so scripts calling ani-cli still work.

Q: Where does it download to by default?
A: Current working directory. Set a permanent dir with ani-plus -d /path.

Q: Can I download at a specific quality?
A: Yes. Pick from best, 1080p, 720p, 480p, 360p, 240p.

Q: Does it work on Windows?
A: Via WSL. Native Windows support is coming.

Q: Where's the history stored?
A: ~/.local/state/ani-plus/ani-hsts (respects $XDG_STATE_HOME).

Q: How do I report a bug?
A: Open an issue.

Uninstall
Arch
bash
sudo pacman -R ani-plus
From source
bash
sudo rm /usr/local/bin/ani-plus
rm -rf ~/.config/ani-plus
rm -rf ~/.local/state/ani-plus
Contributing
Fork the repo

Create a branch (git checkout -b feature/amazing)

Commit (git commit -m "Add amazing feature")

Push (git push origin feature/amazing)

Open a Pull Request

AI policy: Pull requests containing AI-generated code must disclose this in the PR description. Low-effort AI-generated contributions will be rejected.

Disclaimer
ani-plus does not host any content. It scrapes publicly available stream URLs from hianime.at and passes them to mpv/yt-dlp.

Do not use this for piracy

Respect content licenses in your country

The maintainer is not responsible for how you use this tool

If you enjoy an anime, buy the Blu-ray or subscribe to a legitimate streaming service.

License
GPL-3.0

Credits
pystardust/ani-cli — the original

hianime.at — the source

All 138 ani-cli contributors

Made by Hera — a fork built out of frustration with -e 1 -e 2 -e 3...
