#!/usr/bin/env bash
# ============================================================
# ani-plus — ani-cli fork with batch download + persistent config
# Based on ani-cli by pystardust (v5.1.5)
# ============================================================

version_number="1.0.0"

# ============ UI ============

menu() {
    case "$menu_program" in
        fzf) fzf --reverse --cycle --prompt "$1" $2 $3 ;;
        rofi) rofi -sort -dmenu -i -p "$1" $2 $3 ;;
        dmenu) dmenu -l 20 -p "$1" $3 ;;
        *) "$menu_program" $3 "$1" ;;
    esac
}

nth() {
    _stdin=$(cat -)
    [ -z "$_stdin" ] && return 1
    _line_count="$(printf "%s\n" "$_stdin" | wc -l | tr -d "[:space:]")"
    [ "$_line_count" -eq 1 ] && printf "%s" "$_stdin" | cut -f 2,3 && return 0
    _prompt="$1"
    [ $# -ne 1 ] && _multi_flag="$2"
    _line=$(printf "%s" "$_stdin" | cut -f 1,3 | tr '\t' ' ' | menu "$_prompt" "$_multi_flag" "$menu_extra_flags" | cut -d " " -f 1)
    _line_start=$(printf "%s" "$_line" | head -n 1)
    _line_end=$(printf "%s" "$_line" | tail -n 1)
    [ -n "$_line" ] || return 1
    if [ "$_line_start" = "$_line_end" ]; then
        printf "%s" "$_stdin" | grep -E '^'"${_line}"'($|[[:space:]])' | cut -f 2,3 || return 1
    else
        printf "%s" "$_stdin" | sed -n '/^'"${_line_start}"'$/,/^'"${_line_end}$"'/p' || return 1
    fi
}

die() { printf "\33[2K\r\033[1;31m%s\033[0m\n" "$*" >&2; exit 1; }
info() { printf "\33[2K\r\033[1;34m%s\033[0m\n" "$*"; }

help_info() {
    printf "
    Usage:
    %s [options] [query]
    %s [query] [options]

    Playback:
      -c, --continue        Continue watching from history
      -q, --quality <q>     Video quality (best|1080p|720p|480p|360p|240p)
      -v, --vlc             Use VLC instead of mpv
      -s, --syncplay        Use Syncplay
      -S, --select-nth <n>  Select nth entry from search list
      -e, --episode <range> Episode or range (e.g. 5, 1-12)
      --dub                 Play dubbed version
      --skip                Skip intro (requires ani-skip)
      --no-detach           Don't detach the player
      --exit-after-play     Exit after player closes
      -N, --nextep-countdown
                            Show next episode countdown

    Download:
      -d, --download-dir <path>
                            PERMANENTLY set download directory
                            (saved to ~/.config/ani-plus/config)
      --show-download-dir   Show current config
      --reset-config        Reset saved config to defaults
      --dl, --download      Single-episode download mode

    Misc:
      -D, --delete          Delete history
      -l, --logview         Show logs
      -V, --version         Show version
      -h, --help            Show this help
      -U, --update          Self-update script
      --rofi                Use rofi for menus
      --dmenu               Use dmenu for menus
    \n" "${0##*/}" "${0##*/}"
    exit 0
}

version_info() { printf "%s\n" "$version_number"; exit 0; }

update_script() {
    info "[branch:$branch] Checking for Update.."
    update="$($curl_exe --fail-with-body -sL -A "$agent" "https://raw.githubusercontent.com/pystardust/ani-cli/$branch/ani-cli")" || die "[branch:$branch] Connection error: $update"
    new_version="$(printf "%s" "$update" | sed -nE 's|^version_number="([^"]+)"$|\1|p')"
    [ -z "$new_version" ] && die "[branch:$branch] Invalid response."
    printf "%s" "$update" | grep -q "^version_number" || die "[branch:$branch] Invalid response."
    update="$(printf "%s\n" "$update" | diff -u "$0" -)"
    if [ -z "$update" ]; then
        info "[branch:$branch] Script is up to date :) ($version_number)"
    else
        if printf "%s\n" "$update" | patch "$0" -; then
            info "[branch:$branch] Updated: $version_number -> $new_version"
        else
            die "[branch:$branch] Failed to update. Read the above line!"
        fi
    fi
    exit 0
}

# ============ BOOKKEEPING ============

dep_ch() { command -v "$1" >/dev/null || die "Program $1 not found. Please install it."; }

dep_ch_failover() {
    [ -z "$1" ] && return 1
    prog=$(printf "%s" "$1" | cut -d "," -f 1)
    rest=$(printf "%s" "$1" | cut -s -d "," -f 2-)
    command -v "$prog" >/dev/null 2>&1 && printf "%s" "$prog" && return 0
    [ -e "$prog" ] && printf "%s" "$prog" && return 0
    dep_ch_failover "$rest"
}

cleanup() {
    [ "$player_function" = "android_mpv" ] && : >"/storage/emulated/0/mpv/mpv.config.mp4" 2>/dev/null
    tput sgr0
    rm -f "${histfile}.new"
}

# ============ SCRAPING ============

hianime_curl() {
    _curl_status=0
    _response="$($curl_exe -sL -A "$agent" --max-time 10 $cipher_flag -w ' %{http_code}' "$@")" || _curl_status=$?
    _http_code=${_response##* }
    _response=${_response% *}
    if [ "$_curl_status" -ne 0 ]; then
        case "$_http_code" in
            [1-5][0-9][0-9]) _detail="HTTP $_http_code" ;;
            *) _detail="no HTTP response" ;;
        esac
        die "Connection error: could not fetch $1 ($_detail; curl exit $_curl_status)"
    fi
    case "$_http_code" in
        2??) ;;
        *) printf "%s" "$_response" | grep -qi "Just a moment" ||
            die "Request failed: HTTP $_http_code from $1" ;;
    esac
    printf "%s" "$_response"
}

b64_decode() {
    printf "%s\n" "$1" | base64 -d 2>/dev/null || printf "%s\n" "$1" | base64 -D 2>/dev/null || printf "%s\n" "$1" | openssl base64 -d -A 2>/dev/null
}

deobfuscate_blob() (
    _bytes="$(b64_decode "$1" | od -v -An -tu1)"
    set -- 111 116 97 107 117 45 101 109 98 101 100 45 118 49
    _output=""
    for _byte in $_bytes; do
        _char=$((_byte ^ $1))
        _output="${_output}\\0$((_char / 64))$(((_char / 8) % 8))$((_char % 8))"
        set -- "$@" "$1"
        shift
    done
    printf "%b" "$_output"
)

hianime_search() {
    _page="$(hianime_curl "$(printf "$search_api" "$1")")" || return 1
    if printf "%s" "$_page" | grep -qi "<title>Just a moment"; then
        [ "$curl_exe" = "curl" ] && die "Blocked by cloudflare. Try installing curl-impersonate"
        die "Blocked by cloudflare."
    fi
    printf "%s" "$_page" | sed '/id="main-sidebar"/,$d' | tr '\n' ' ' | sed 's|<div class="film-detail">|\n<div class="film-detail">|g' |
        sed -nE 's|.*<h3 class="film-name">[[:space:]]*<a href="[^"]*/([^"/]*)"[[:space:]]*title="([^"]*)".*|\1\t\2|p' |
        sed -e "s|&#039;|'|g" -e 's|&quot;|"|g' -e "s|&amp;|\&|g"
}

hianime_episodes() {
    _page="$(hianime_curl "$(printf "$episodes_api" "${1##*-}")")" || return 1
    printf "%s" "$_page" | sed 's|\\||g; s|ep-item|\nep-item|g' |
        sed -nE "s|.*data-number=\"([^\"]*)\".*data-id=\"([0-9]+)\".*/watch/${1}[?]ep=.*|\\2\\t\\1|p"
}

hianime_m3u8() {
    _ep_id=$(printf "%s" "$episode_maps" | sed -nE "s|^([0-9]+)\t${1}$|\1|p")
    _servers="$(hianime_curl "$(printf "$servers_api" "$_ep_id")" | sed 's|\\"|"|g; s|server-item|\nserver-item|g')"
    _hash="$(printf "%s\n" "$_servers" | sed -nE 's|.*data-type="'"$2"'".*data-server-name="ZokoAnime".*data-hash="([^"]*)".*|\1|p' | head -n 1)"
    _embed="$(b64_decode "$_hash")"
    [ -z "$_embed" ] && return 1
    refr="$(printf "%s" "$_embed" | sed -E 's|^(https?://[^/]*).*|\1/|')"
    mal_id="$(printf "%s" "$_embed" | sed -nE 's|.*/mal/([0-9]+)/.*|\1|p')"
    _blob="$(hianime_curl "$_embed" | sed -nE 's|.*window\.__P="([^"]*)".*|\1|p')"
    [ -z "$_blob" ] && return 1
    _json="$(deobfuscate_blob "$_blob")"
    _m3u8_master="$(printf "%s" "$_json" | sed -nE 's|.*"src":"([^"]*\.m3u8[^"]*)".*|\1|p')"
    [ -z "$_m3u8_master" ] && return 1
    sub_link="$(printf "%s" "$_json" | sed 's|.*"subtitles":\[||; s|}\].*||; s|},{|}\n{|g' | grep -m 1 '"default":true' | sed -nE 's|.*"src":"([^"]*)".*|\1|p')"
    links="$(hianime_curl "$_m3u8_master" -e "$refr" | sed 's|^#EXT-X-STREAM.*x||g; s|,.*|p|g; /^#/d; $!N; s|\n| >|;/EXT-X-I-FRAME/d' | sed "\|>https*://|!s|>|>${_m3u8_master%/*}/|" | sort -g -r -s)"
    [ -n "$links" ]
}

select_quality() {
    case "$1" in
        best) _result=$(printf "%s" "$links" | head -n 1) ;;
        worst) _result=$(printf "%s" "$links" | grep -E '^[0-9]{3,4}' | tail -n 1) ;;
        *) _result=$(printf "%s" "$links" | grep -m 1 "$1") ;;
    esac
    [ -z "$_result" ] && printf "\33[2K\r\033[1;33m%s\033[0m\n" "$1 not found, defaulting to best" >&2 && _result=$(printf "%s" "$links" | head -n 1)
    video_link=$(printf "%s" "$_result" | cut -d ">" -f 2)
}

get_video_link() {
    hianime_m3u8 "$ep_no" "$mode" || die "No sources found for $mode!"
    info "hianime.at links fetched"
    select_quality "$quality"
    if printf "%s" "$ep_list" | grep -q "^$ep_no$"; then
        [ -z "$video_link" ] && die "Episode is released, but no valid sources!"
    else
        [ -z "$video_link" ] && die "Episode not released!"
    fi
}

time_until_next_ep() {
    animeschedule="https://animeschedule.net"
    _query="$(printf "%s" "$*" | tr ' ' '+')"
    $curl_exe -s -G "$animeschedule/api/v3/anime" --data "q=${_query}" | sed 's|},{"id"|\n|g' | while read -r _entry; do
        _route=$(printf "%s" "$_entry" | sed -nE 's|.*"route":"([^"]*)",.*|\1|p')
        _eng_title=$(printf '%s' "$_entry" | sed -nE 's|.*"english":"([^"]*)".*|\1|p')
        [ -z "$_eng_title" ] && _eng_title=$(printf '%s' "$_entry" | sed -nE 's|.*,"title":"([^"]*)".*|\1|p')
        [ -z "$_eng_title" ] && _eng_title="N/A"
        _jpn_title=$(printf '%s' "$_entry" | sed -nE 's|.*"romaji":"([^"]*)".*|\1|p')
        [ -z "$_jpn_title" ] && _jpn_title="N/A"
        _status=$(printf '%s' "$_entry" | sed -nE 's|.*"status":"([^"]*)".*|\1|p')
        [ -z "$_status" ] && _status="Unknown"
        case "$_status" in
            Ongoing) _color="33" ;;
            Finished) _color="32" ;;
            *) _color="36" ;;
        esac
        printf "Eng: %s\n" "$_eng_title"
        printf "Jpn: %s\n" "$_jpn_title"
        printf "Status: \033[1;%sm%s\033[0m\n" "$_color" "$_status"
        if [ "$_status" != "Finished" ]; then
            _page="$($curl_exe -s "$animeschedule/anime/$_route")"
            _sub_ep=$(printf "%s" "$_page" | sed -nE 's|.*release-time-type-subs"[^>]*><span class="release-time-episode-number">Episode ([0-9]+)</span>.*|\1|p' | head -n 1)
            _dub_ep=$(printf "%s" "$_page" | sed -nE 's|.*release-time-type-dub"[^>]*><span class="release-time-episode-number">Episode ([0-9]+)</span>.*|\1|p' | head -n 1)
            _sub_countdown=$(printf "%s" "$_page" | sed -nE 's|.*class="countdown-time" datetime="([^"]*)".*|\1|p' | head -n 1)
            _dub_countdown=$(printf "%s" "$_page" | sed -nE 's|.*class="countdown-time countdown-time-dub" datetime="([^"]*)".*|\1|p' | head -n 1)
            [ -n "$_sub_ep" ] && [ -n "$_sub_countdown" ] && printf "Next Sub: Episode %s in \033[1;%sm%s\033[0m\n" "$_sub_ep" "$_color" "$_sub_countdown" || printf "Next Sub: N/A\n"
            [ -n "$_dub_ep" ] && [ -n "$_dub_countdown" ] && printf "Next Dub: Episode %s in \033[1;%sm%s\033[0m\n" "$_dub_ep" "$_color" "$_dub_countdown" || printf "Next Dub: N/A\n"
        fi
        printf "\n"
    done
    exit 0
}

# ============ HISTORY ============

backup_old_hist() {
    backupfile="${histfile}.v4"
    : >"${histfile}.new"
    while IFS="	" read -r ep_no anime_id anime_title; do
        case "$anime_id" in
            *-*) printf "%s\t%s\t%s\n" "$ep_no" "$anime_id" "$anime_title" >>"${histfile}.new" ;;
            *) printf "%s\t%s\t%s\n" "$ep_no" "$anime_id" "$anime_title" >>"$backupfile" ;;
        esac
    done <"$histfile"
    mv "${histfile}.new" "$histfile"
}

process_hist_entry() {
    ep_list=$(hianime_episodes "$anime_id" | cut -f 2)
    ep_no=$(printf "%s" "$ep_list" | sed -n "/^${ep_no}$/{n;p;}") 2>/dev/null
    [ -n "$ep_no" ] && printf "%s\t%s - episode %s\n" "$anime_id" "$anime_title" "$ep_no"
}

update_history() {
    if grep -q "	${anime_id}	" "$histfile"; then
        safe_title=$(printf "%s" "$anime_title" | sed 's|[&\|]|\\&|g')
        sed -E "s|^[^	]+	${anime_id}	[^	]+$|${ep_no}	${anime_id}	${safe_title}|" "$histfile" >"${histfile}.new"
    else
        cp "$histfile" "${histfile}.new"
        printf "%s\t%s\t%s\n" "$ep_no" "$anime_id" "$anime_title" >>"${histfile}.new"
    fi
    mv "${histfile}.new" "$histfile"
}

# ============ PLAYING ============

download() {
    _name="$(printf "%s" "$2" | tr '<>:"/\\|?*' '_')"
    [ -n "$sub_link" ] && $curl_exe -sL -A "$agent" -e "$refr" --max-time 10 $cipher_flag "$sub_link" -o "$download_dir/$_name.vtt"
    command -v "yt-dlp" >/dev/null && yt-dlp --referer "$refr" "$1" --no-skip-unavailable-fragments --fragment-retries infinite -N 16 -o "$download_dir/$_name.mp4" $3 && return 0
    ffmpeg -extension_picky 0 -referer "$refr" -loglevel error -stats -i "$1" -c copy "$download_dir/$_name.mp4" $3
}

android_mpv() {
    _conf_dir="/storage/emulated/0/mpv"
    if [ -w "${_conf_dir%/mpv}" ]; then
        [ -d "$_conf_dir" ] || mkdir "$_conf_dir"
        printf "referrer=%s\n%s\n" "$refr" "${sub_link:+sub-file=$sub_link}" >"$_conf_dir/mpv.config.mp4"
    fi
    nohup am start --user 0 -a android.intent.action.VIEW -d "$video_link" -n is.xyz.mpv/.MPVActivity -e "title" "${anime_title} Episode ${ep_no}" $player_extra_flags >/dev/null 2>&1 &
}

play_episode() {
    [ "$log_episode" = 1 ] && [ "$player_function" != "debug" ] && [ "$player_function" != "download" ] && command -v logger >/dev/null && logger -t ani-plus "${anime_title} ${ep_no}"
    [ -z "$video_link" ] && get_video_link
    [ "$skip_intro" = 1 ] && skip_flag="$(ani-skip -i "$mal_id" -e "$ep_no")"
    wait
    case "$player_function" in
        debug) printf "All links:\n%s\nSelected link:\n%s\nSubtitles:\n%s\n" "$links" "$video_link" "$sub_link" ;;
        android_mpv) android_mpv ;;
        android_vlc) nohup am start --user 0 -a android.intent.action.VIEW -d "$video_link" -n org.videolan.vlc/org.videolan.vlc.gui.video.VideoPlayerActivity -e "title" "${anime_title} Episode ${ep_no}" $player_extra_flags >/dev/null 2>&1 & ;;
        *flatpak*mpv*) flatpak run io.mpv.Mpv --referrer="$refr" ${sub_link:+--sub-file="$sub_link"} $skip_flag $player_extra_flags --force-media-title="${anime_title} Episode ${ep_no}" "$video_link" >/dev/null 2>&1 & ;;
        *mpv*)
            if [ "$no_detach" = 0 ]; then
                nohup $player_function --referrer="$refr" ${sub_link:+--sub-file="$sub_link"} $skip_flag $player_extra_flags --force-media-title="${anime_title} Episode ${ep_no}" "$video_link" >/dev/null 2>&1 &
            else
                $player_function --referrer="$refr" ${sub_link:+--sub-file="$sub_link"} $skip_flag $player_extra_flags --force-media-title="${anime_title} Episode ${ep_no}" "$video_link"
                mpv_exitcode=$?
                [ "$exit_after_play" = 1 ] && [ -z "$_range" ] && exit "$mpv_exitcode"
            fi
            ;;
        *iina*)
            _sub_iina="$(printf "%s" "$sub_link" | sed 's|:|\\:|g')"
            if pgrep -f "IINA" >/dev/null 2>&1; then
                nohup $player_function --mpv-referrer="$refr" ${_sub_iina:+--mpv-sub-files="$_sub_iina"} $player_extra_flags --no-stdin --mpv-force-media-title="${anime_title} Episode ${ep_no}" "$video_link" >/dev/null 2>&1 &
            else
                nohup $player_function --mpv-referrer="$refr" ${_sub_iina:+--mpv-sub-files="$_sub_iina"} $player_extra_flags --no-stdin --keep-running --mpv-force-media-title="${anime_title} Episode ${ep_no}" "$video_link" >/dev/null 2>&1 &
            fi
            ;;
        *vlc*) nohup $player_function --http-referrer="$refr" $player_extra_flags --play-and-exit --meta-title="${anime_title} Episode ${ep_no}" "$video_link" ${sub_link:+:input-slave="$sub_link"} >/dev/null 2>&1 & ;;
        *yncpla*) nohup $player_function $player_extra_flags "$video_link" -- $skip_flag --referrer="$refr" ${sub_link:+--sub-file="$sub_link"} --force-media-title="${anime_title} Episode ${ep_no}" >/dev/null 2>&1 & ;;
        download) "$player_function" "$video_link" "${anime_title} Episode ${ep_no}" $player_extra_flags ;;
        catt) nohup catt cast $player_extra_flags "$video_link" >/dev/null 2>&1 & ;;
        iSH)
            printf "\033]8;;vlc://%s\a~~~~~~~~~~~~~~~~~~~~\n~ Tap to open VLC ~\n~~~~~~~~~~~~~~~~~~~~\033]8;;\a\n" "$video_link"
            sleep 5
            ;;
        *) nohup $player_function $player_extra_flags "$video_link" >/dev/null 2>&1 & ;;
    esac
    replay="$video_link"
    unset video_link
    update_history
    [ "$menu_program" != "fzf" ] && wait
}

play() {
    _start=$(printf "%s" "$ep_no" | grep -Eo '^(-1|[0-9]+(\.[0-9]+)?)')
    _end=$(printf "%s" "$ep_no" | grep -Eo '(-1|[0-9]+(\.[0-9]+)?)$')
    [ "$_start" = "-1" ] && ep_no=$(printf "%s" "$ep_list" | tail -n 1) && unset _start
    [ -z "$_end" ] || [ "$_end" = "$_start" ] && unset _start _end
    [ "$_start" = "0" ] && _start=$(printf "%s" "$ep_list" | head -n 1)
    [ "$_end" = "-1" ] && _end=$(printf "%s" "$ep_list" | tail -n 1)
    _line_count=$(printf "%s\n" "$ep_no" | wc -l | tr -d "[:space:]")
    if [ "$_line_count" != 1 ] || [ -n "$_start" ]; then
        [ -z "$_start" ] && _start=$(printf "%s\n" "$ep_no" | head -n 1)
        [ -z "$_end" ] && _end=$(printf "%s\n" "$ep_no" | tail -n 1)
        _range=$(printf "%s\n" "$ep_list" | sed -nE "/^${_start}\$/,/^${_end}\$/p")
        [ -z "$_range" ] && die "Invalid range!"
        for i in $_range; do
            tput clear
            ep_no=$i
            info "Playing episode $ep_no..."
            [ "$i" = "$_end" ] && unset _range
            play_episode
        done
    else
        printf "%s" "$ep_list" | grep -q "^$ep_no$" || die "Invalid episode!"
        play_episode
    fi
    [ "$player_function" != "debug" ] && [ "$player_function" != "download" ] && tput rc && tput ed
}

# ============ BATCH DOWNLOAD ============

dl_resume_from() {
    _folder="$1"
    _last=0
    if [ -d "$_folder" ]; then
        _last=$(find "$_folder" -type f \( -name "*.mp4" -o -name "*.mkv" -o -name "*.webm" \) 2>/dev/null |
            grep -oE '[0-9]+[^0-9]*\.[a-zA-Z0-9]+$' | grep -oE '[0-9]+' | sort -n | tail -n 1)
    fi
    [ -z "$_last" ] && _last=0
    printf "%s" "$_last"
}

dl_quality_menu() {
    printf "best\n1080p\n720p\n480p\n360p\n240p" | nth "Quality: " "" "$menu_extra_flags"
}

dl_save_config() {
    mkdir -p "$config_dir"
    {
        printf 'download_dir="%s"\n' "$download_dir"
        [ -n "$quality" ] && printf 'quality="%s"\n' "$quality"
    } > "$config_file"
}

dl_batch_anime() {
    _animedir=$(printf "%s" "$anime_title" | sed 's/[^A-Za-z0-9 _.-]//g')
    _target="$download_dir/$_animedir"

    _last_ep=$(dl_resume_from "$_target")
    _next_ep=$((_last_ep + 1))

    printf "\n"
    printf "Anime:   %s\n" "$anime_title"
    printf "Folder:  %s\n" "$_target"
    printf "Episodes available: %s\n" "$(printf "%s\n" "$ep_list" | wc -l)"
    if [ "$_last_ep" -gt 0 ]; then
        printf "Local progress: up to episode %s\n" "$_last_ep"
    fi
    printf "\n"

    if [ "$_last_ep" -gt 0 ]; then
        printf "Enter range (e.g. %s-24), or 'all' to resume from %s: " "$_next_ep" "$_next_ep"
    else
        printf "Enter range (e.g. 1-17), or 'all': "
    fi
    read -r _range

    if [ "${_range,,}" = "all" ]; then
        _range="$_next_ep-9999"
    else
        if [[ "$_range" =~ ^([0-9]+)-([0-9]+)$ ]]; then
            _start_req="${BASH_REMATCH[1]}"
            _end_req="${BASH_REMATCH[2]}"
            if [ "$_start_req" -le "$_last_ep" ] && [ "$_end_req" -ge "$_next_ep" ]; then
                printf "Adjusting range %s to %s-%s to skip existing files.\n" "$_range" "$_next_ep" "$_end_req"
                _range="$_next_ep-$_end_req"
            fi
        fi
    fi

    printf "\n"
    _qual=$(dl_quality_menu)
    [ -z "$_qual" ] && _qual="best"

    _ep_start="${_range%%-*}"
    _ep_end="${_range##*-}"
    [ "$_ep_end" -gt 10000 ] 2>/dev/null && _ep_end=$(printf "%s\n" "$ep_list" | tail -n 1)

    mkdir -p "$_target"

    _old_dir="$download_dir"
    download_dir="$_target"
    _old_quality="$quality"
    quality="$_qual"

    printf "\n"
    printf "%s\n" "$ep_list" | while IFS= read -r _ep; do
        _n=$(printf "%s" "$_ep" | grep -oE '^[0-9]+')
        [ -z "$_n" ] && continue
        [ "$_n" -lt "$_ep_start" ] 2>/dev/null && continue
        [ "$_n" -gt "$_ep_end" ] 2>/dev/null && continue

        ep_no="$_ep"
        info "Downloading $anime_title Episode $_ep..."
        get_video_link
        download "$video_link" "${anime_title} Episode ${ep_no}" ""
    done

    download_dir="$_old_dir"
    quality="$_old_quality"

    printf "\n"
    info "Download complete: $anime_title"
}

# ============ MAIN ============

base_api="https://hianime.at"
search_api="${base_api}/search?keyword=%s"
episodes_api="${base_api}/api/theme/episode/list/%s"
servers_api="${base_api}/api/theme/episode/servers?episodeId=%s"
ciphers='ECDHE-ECDSA-AES128-GCM-SHA256:ECDHE-RSA-AES128-GCM-SHA256:ECDHE-ECDSA-AES256-GCM-SHA384:ECDHE-RSA-AES256-GCM-SHA384:ECDHE-ECDSA-CHACHA20-POLY1305:ECDHE-RSA-CHACHA20-POLY1305'
tls13_ciphers='TLS_AES_128_GCM_SHA256:TLS_AES_256_GCM_SHA384:TLS_CHACHA20_POLY1305_SHA256'
agent="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/124.0.0.0 Safari/537.36"

# Config dir + load saved settings
config_dir="${XDG_CONFIG_HOME:-$HOME/.config}/ani-plus"
config_file="$config_dir/config"
if [ -f "$config_file" ]; then
    . "$config_file"
fi

mode="${ANI_CLI_MODE:-sub}"
download_dir="${download_dir:-${ANI_CLI_DOWNLOAD_DIR:-.}}"
log_episode="${ANI_CLI_LOG:-1}"
quality="${quality:-${ANI_CLI_QUALITY:-best}}"
exact_match="${ANI_CLI_EXACT:-0}"

curl_exe=$(dep_ch_failover "curl_firefox135,curl_chrome136,curl_chrome116,curl_ff117,curl") || die "Program curl not found"

case "$(uname -a | cut -d " " -f 1,3-)" in
    *Darwin*)
        cipher_flag="--ciphers $ciphers --tls13-ciphers $tls13_ciphers"
        player_function="${ANI_CLI_PLAYER:-$(dep_ch_failover "iina,/Applications/IINA.app/Contents/MacOS/iina-cli,mpv,vlc")}" || die 'No player found.'
        ;;
    *ndroid*) player_function="${ANI_CLI_PLAYER:-android_mpv}" ;;
    *MINGW* | *WSL2*) player_function="${ANI_CLI_PLAYER:-mpv.exe}" ;;
    *ish*)
        player_function="${ANI_CLI_PLAYER:-iSH}"
        curl_exe=$(dep_ch_failover "curl_safari260_ios,$curl_exe")
        ;;
    *) player_function="${ANI_CLI_PLAYER:-$(dep_ch_failover "mpv,$HOME/.local/share/flatpak/app/io.mpv.Mpv/,/var/lib/flatpak/app/io.mpv.Mpv/,vlc")}" || die 'No player found.' ;;
esac

player_extra_flags="${ANI_CLI_PLAYER_FLAGS:-""}"
no_detach="${ANI_CLI_NO_DETACH:-0}"
exit_after_play="${ANI_CLI_EXIT_AFTER_PLAY:-0}"
skip_intro="${ANI_CLI_SKIP_INTRO:-0}"
menu_program="${ANI_CLI_MENU:-fzf}"
menu_extra_flags="${ANI_CLI_MENU_FLAGS:-""}"

if [ ! -t 0 ]; then
    command -v dmenu >/dev/null && menu_program=dmenu
    command -v rofi >/dev/null && menu_program=rofi
fi

hist_dir="${ANI_CLI_HIST_DIR:-${XDG_STATE_HOME:-$HOME/.local/state}/ani-plus}"
[ ! -d "$hist_dir" ] && mkdir -p "$hist_dir"
histfile="$hist_dir/ani-hsts"
[ ! -f "$histfile" ] && : >"$histfile"

source="${ANI_CLI_DEFAULT_SOURCE:-search}"
branch="${ANI_CLI_BRANCH:-master}"

# ============ ARG PARSER ============
while [ $# -gt 0 ]; do
    case "$1" in
        -v | --vlc)
            case "$(uname -a | cut -d " " -f 1,3-)" in
                *ndroid*) player_function="android_vlc" ;;
                MINGW* | *WSL2*) player_function="vlc.exe" ;;
                *ish*) player_function="iSH" ;;
                *) player_function="vlc" ;;
            esac
            ;;
        -s | --syncplay)
            case "$(uname -s)" in
                Darwin*) player_function="/Applications/Syncplay.app/Contents/MacOS/syncplay" ;;
                MINGW* | *Msys)
                    export PATH="$PATH":"/c/Program Files (x86)/Syncplay/"
                    player_function="syncplay.exe"
                    ;;
                *) player_function="syncplay" ;;
            esac
            ;;
        -q | --quality) [ $# -lt 2 ] && die "missing argument!"; quality="$2"; shift ;;
        -S | --select-nth) [ $# -lt 2 ] && die "missing argument!"; index="$2"; shift ;;
        -c | --continue) source=history ;;
        -d | --download-dir)
            [ $# -lt 2 ] && die "missing argument for -d!"
            download_dir="$2"
            mkdir -p "$download_dir"
            dl_save_config
            info "Download directory permanently set to: $download_dir"
            info "Config saved at: $config_file"
            exit 0
            ;;
        --show-download-dir)
            printf "Download directory: %s\n" "$download_dir"
            printf "Quality:            %s\n" "$quality"
            printf "Config file:        %s\n" "$config_file"
            [ -f "$config_file" ] && { printf "\n--- file contents ---\n"; cat "$config_file"; }
            exit 0
            ;;
        --reset-config)
            rm -f "$config_file"
            info "Config reset. Defaults will be used next run."
            exit 0
            ;;
        --dl | --download) player_function=download ;;
        -D | --delete) : >"$histfile"; exit 0 ;;
        -l | --logview)
            case "$(uname -s)" in
                Darwin*) log show --predicate 'process == "logger"' ;;
                Linux*) journalctl -t ani-plus ;;
                *) die "Logger not implemented for your platform" ;;
            esac
            exit 0
            ;;
        -V | --version) version_info ;;
        -h | --help) help_info ;;
        -e | --episode | -r | --range) [ $# -lt 2 ] && die "missing argument!"; ep_no="$2"; shift ;;
        --dub) mode="dub" ;;
        --no-detach) no_detach=1 ;;
        --exit-after-play) exit_after_play=1 && no_detach=1 ;;
        --rofi) menu_program=rofi ;;
        --dmenu) menu_program=dmenu ;;
        --skip) skip_intro=1 ;;
        -N | --nextep-countdown) source=nextep ;;
        -U | --update)
            dep_ch "patch"
            branch="${2:-$branch}"
            update_script
            ;;
        *) query="$(printf "%s" "$query $1" | sed 's|^ ||;s| |+|g')" ;;
    esac
    shift
done

[ "$menu_program" = "fzf" ] && menu_multi_flag="-m"
[ "$menu_program" = "rofi" ] && menu_multi_flag="-multi-select"

info "Checking dependencies..."
dep_ch "sed"; dep_ch "grep"
[ "$skip_intro" = 1 ] && dep_ch "ani-skip"
dep_ch "$menu_program"

case "$player_function" in
    debug) ;;
    download) dep_ch_failover "yt-dlp,ffmpeg" >/dev/null || die 'Neither yt-dlp nor ffmpeg found' ;;
    android*) printf "\33[2K\rChecking of players on Android is disabled.\n" ;;
    *iSH*) printf "\33[2K\rChecking of players on iOS is disabled\n" ;;
    *flatpak*mpv*) dep_ch "flatpak" ;;
    *) dep_ch "$player_function" ;;
esac

trap 'cleanup; exit 1' INT HUP TERM

# ============ MAIN LOOP ============
_first_iter=1
while true; do
    if [ "$_first_iter" != 1 ]; then
        unset query index ep_no result anime_title anime_id episode_maps ep_list
        source="search"
    fi
    _first_iter=0

    case "$source" in
        history)
            backup_old_hist
            anime_list=$(while read -r ep_no anime_id anime_title; do process_hist_entry & done <"$histfile")
            wait
            [ -z "$anime_list" ] && die "No unwatched series in history!"
            [ -z "${index##*[!0-9]*}" ] && anime_id=$(printf "%s" "$anime_list" | nl -w 2 | sed 's/^[[:space:]]//' | nth "Select anime: " | cut -f 1)
            [ -z "${index##*[!0-9]*}" ] || anime_id=$(printf "%s" "$anime_list" | sed -n "${index}p" | cut -f 1)
            [ -z "$anime_id" ] && exit 1
            anime_title=$(printf "%s" "$anime_list" | grep "^$anime_id	" | cut -f 2 | sed 's| - episode.*||')
            episode_maps="$(hianime_episodes "$anime_id")" || exit 1
            ep_list="$(printf "%s" "$episode_maps" | cut -f 2)"
            ep_no=$(printf "%s" "$anime_list" | grep "^$anime_id	" | sed -nE 's/.*- episode (.+)$/\1/p')
            ;;
        *)
            if [ "$menu_program" = "fzf" ]; then
                while [ -z "$query" ]; do
                    printf "\33[2K\r\033[1;36mSearch anime: \033[0m" && read -r query
                done
            else
                [ -z "$query" ] && query=$(: | menu "Search anime: " "" "$menu_extra_flags")
                [ -z "$query" ] && exit 1
            fi

            [ "$source" = "nextep" ] && time_until_next_ep "$query"

            user_query="$(printf "%s" "$query" | tr '+' ' ')"
            query=$(printf "%s" "$query" | sed 's| |+|g')

            anime_list=$(hianime_search "$query") || exit 1
            [ -z "$anime_list" ] && die "No results found!"

            if [ "$exact_match" = 1 ]; then
                _query_norm="$(printf "%s" "$user_query" | tr '[:upper:]' '[:lower:]' | tr -s '[:space:]' ' ' | sed 's/^ *//;s/ *$//')"
                anime_list="$(printf "%s\n" "$anime_list" | while IFS="$(printf '\t')" read -r _id _title; do
                    _title_norm="$(printf "%s" "$_title" | tr '[:upper:]' '[:lower:]' | tr -s '[:space:]' ' ' | sed 's/^ *//;s/ *$//')"
                    [ "$_title_norm" = "$_query_norm" ] && printf "%s\t%s\n" "$_id" "$_title"
                done)"
                [ -z "$anime_list" ] && die "No exact match found for '$user_query'!"
            fi

            [ "$index" -eq "$index" ] 2>/dev/null && result=$(printf "%s" "$anime_list" | sed -n "${index}p")
            [ -z "$index" ] && result=$(printf "%s" "$anime_list" | nl -w 2 | sed 's/^[[:space:]]//' | nth "Select anime: ")
            [ -z "$result" ] && die "Invalid anime selection"
            anime_title="$(printf "%s" "$result" | cut -f 2)"
            anime_id="$(printf "%s" "$result" | cut -f 1)"
            episode_maps="$(hianime_episodes "$anime_id")" || exit 1
            ep_list="$(printf '%s' "$episode_maps" | cut -f 2)"
            ;;
    esac

    # MODE PROMPT
    printf "\n"
    printf "Selected: %s\n" "$anime_title"
    printf "Episodes: %s available\n" "$(printf "%s\n" "$ep_list" | wc -l)"
    printf "Save dir: %s\n" "$download_dir"
    printf "\n"
    printf "What would you like to do?\n"
    printf "  1) Watch now\n"
    printf "  2) Batch download\n"
    printf "  3) Quit\n"
    printf "Choice [1]: "
    read -r _mode_choice

    case "$_mode_choice" in
        2|d|download)
            dl_batch_anime
            printf "\n"
            printf "Add another anime? (y/n): "
            read -r _ans
            case "$_ans" in
                y|Y|yes) continue ;;
                *) cleanup; exit 0 ;;
            esac
            ;;
        3|q|quit) cleanup; exit 0 ;;
        *) break ;;
    esac
done

# WATCH FLOW
[ -z "$ep_no" ] && ep_no=$(printf "%s" "$ep_list" | nth "Select episode: " "$menu_multi_flag")
[ -z "$ep_no" ] && die "Invalid episode selection"

tput cuu1 && tput el
tput sc

play
[ "$player_function" = "download" ] || [ "$player_function" = "debug" ] && exit 0

while cmd=$(printf "next\nreplay\nprevious\nselect\nchange_quality\nquit" | nth "Playing episode $ep_no of $anime_title... "); do
    case "$cmd" in
        next) ep_no=$(printf "%s" "$ep_list" | sed -n "/^${ep_no}$/{n;p;}") 2>/dev/null ;;
        replay) video_link="$replay" ;;
        previous) ep_no=$(printf "%s" "$ep_list" | sed -n "/^${ep_no}$/{g;1!p;};h") 2>/dev/null ;;
        select) ep_no=$(printf "%s" "$ep_list" | nth "Select episode: " "$menu_multi_flag") ;;
        change_quality)
            new_quality="$(printf "%s" "$links" | menu "Select Quality: " "" "$menu_extra_flags" | cut -d ">" -f 1)"
            [ -z "$new_quality" ] && die "No quality selected"
            select_quality "$new_quality"
            ;;
        *) cleanup; exit 0 ;;
    esac
    [ -z "$ep_no" ] && die "Out of range"
    play
done
