#!/usr/bin/env bash

# deasy - Dead Easy YouTube Downloader
# Makes yt-dlp actually easy to use

deasy() {
  # Colors
  local RED='\033[0;31m'
  local GREEN='\033[0;32m'
  local YELLOW='\033[1;33m'
  local BLUE='\033[0;34m'
  local MAGENTA='\033[0;35m'
  local CYAN='\033[0;36m'
  local BOLD='\033[1m'
  local RESET='\033[0m'
  
  # Show help if no arguments
  if [[ $# -eq 0 ]]; then
    echo -e "${BOLD}${CYAN}deasy${RESET} ${BLUE}v1.0${RESET} - Dead Easy YouTube Downloader"
    echo -e "${BLUE}═══════════════════════════════════════════${RESET}"
    echo -e "${BOLD}Usage:${RESET} deasy [what] [quality] [format] <url>"
    echo
    echo -e "${BOLD}What to download:${RESET}"
    echo -e "  ${GREEN}video${RESET}     Download video ${YELLOW}(default)${RESET}"
    echo -e "  ${GREEN}audio${RESET}     Download audio only"
    echo -e "  ${GREEN}playlist${RESET}  Download entire playlist"
    echo
    echo -e "${BOLD}Quality (optional):${RESET}"
    echo -e "  ${CYAN}best${RESET}      Highest quality ${YELLOW}(default)${RESET}"
    echo -e "  ${CYAN}1080${RESET}      1080p"
    echo -e "  ${CYAN}720${RESET}       720p"
    echo -e "  ${CYAN}480${RESET}       480p"
    echo
    echo -e "${BOLD}Video Formats (optional):${RESET}"
    echo -e "  ${CYAN}mp4${RESET}       MP4 format ${YELLOW}(default)${RESET}"
    echo -e "  ${CYAN}mkv${RESET}       MKV format"
    echo -e "  ${CYAN}webm${RESET}      WebM format"
    echo -e "  ${CYAN}avi${RESET}       AVI format"
    echo
    echo -e "${BOLD}Audio Formats (optional):${RESET}"
    echo -e "  ${CYAN}mp3${RESET}       MP3 format ${YELLOW}(default)${RESET}"
    echo -e "  ${CYAN}m4a${RESET}       M4A/AAC format"
    echo -e "  ${CYAN}flac${RESET}      FLAC lossless"
    echo -e "  ${CYAN}opus${RESET}      Opus format"
    echo -e "  ${CYAN}wav${RESET}       WAV format"
    echo
    echo -e "${BOLD}Super Easy Examples:${RESET}"
    echo -e "  ${MAGENTA}deasy https://youtube.com/watch?v=...${RESET}"
    echo -e "    → Downloads best quality video"
    echo
    echo -e "  ${MAGENTA}deasy audio https://youtube.com/watch?v=...${RESET}"
    echo -e "    → Downloads audio as MP3"
    echo
    echo -e "  ${MAGENTA}deasy playlist https://youtube.com/playlist?list=...${RESET}"
    echo -e "    → Downloads entire playlist"
    echo
    echo -e "  ${MAGENTA}deasy 720 https://youtube.com/watch?v=...${RESET}"
    echo -e "    → Downloads 720p video as MP4"
    echo
    echo -e "  ${MAGENTA}deasy video 720 mkv https://youtube.com/watch?v=...${RESET}"
    echo -e "    → Downloads 720p video as MKV"
    echo
    echo -e "  ${MAGENTA}deasy playlist audio flac https://youtube.com/playlist?list=...${RESET}"
    echo -e "    → Downloads playlist as FLAC files"
    echo
    echo -e "${BOLD}That's it! No complicated flags.${RESET}"
    echo -e "${BLUE}═══════════════════════════════════════════${RESET}"
    return 1
  fi
  
  # Check if yt-dlp is installed
  if ! command -v yt-dlp &> /dev/null; then
    echo -e "${RED}✗ Error:${RESET} yt-dlp is not installed"
    echo -e "  Install with: ${CYAN}pip install yt-dlp${RESET}"
    return 1
  fi
  
  # Smart parsing - figure out what user wants
  local what="video"
  local quality="best"
  local video_format="mp4"
  local audio_format="mp3"
  local url=""
  
  # Parse arguments intelligently
  for arg in "$@"; do
    case "${arg,,}" in
      audio|music|song)
        what="audio"
        ;;
      playlist|list|pl)
        what="playlist"
        ;;
      video|vid)
        what="video"
        ;;
      best|highest|max)
        quality="best"
        ;;
      1080|1080p|hd)
        quality="1080"
        ;;
      720|720p)
        quality="720"
        ;;
      480|480p)
        quality="480"
        ;;
      360|360p)
        quality="360"
        ;;
      # Video formats
      mp4)
        video_format="mp4"
        ;;
      mkv)
        video_format="mkv"
        ;;
      webm)
        video_format="webm"
        ;;
      avi)
        video_format="avi"
        ;;
      # Audio formats
      mp3)
        audio_format="mp3"
        ;;
      m4a|aac)
        audio_format="m4a"
        ;;
      flac)
        audio_format="flac"
        ;;
      opus)
        audio_format="opus"
        ;;
      wav)
        audio_format="wav"
        ;;
      http://*|https://*)
        url="$arg"
        ;;
    esac
  done
  
  # Check if URL was provided
  if [[ -z "$url" ]]; then
    echo -e "${RED}✗ No URL found!${RESET}"
    echo -e "  ${YELLOW}Example:${RESET} deasy audio https://youtube.com/watch?v=..."
    return 1
  fi
  
  # Smart detection: if URL contains "playlist" and user didn't specify, ask
  if [[ "$url" == *"playlist"* ]] && [[ "$what" != "playlist" ]]; then
    echo -e "${YELLOW}🤔 Looks like a playlist URL!${RESET}"
    echo -e "   Download as playlist? [Y/n]: "
    read -r response
    if [[ ! "$response" =~ ^[Nn] ]]; then
      what="playlist"
    fi
  fi
  
  # Show what we're doing
  echo -e "${BOLD}${MAGENTA}▶ Starting download...${RESET}"
  echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
  
  case "$what" in
    audio)
      echo -e "  📻 ${GREEN}Audio Download${RESET} → ${audio_format^^}"
      echo -e "  🔗 ${url}"
      echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
      
      if [[ "$what" == "playlist" ]]; then
        yt-dlp \
          -x \
          --audio-format "$audio_format" \
          --audio-quality 0 \
          --yes-playlist \
          "$url"
      else
        yt-dlp \
          -x \
          --audio-format "$audio_format" \
          --audio-quality 0 \
          --no-playlist \
          "$url"
      fi
      ;;
      
    playlist)
      # Check if they want audio playlist
      local is_audio=0
      for arg in "$@"; do
        [[ "${arg,,}" =~ ^(audio|mp3|music)$ ]] && is_audio=1
      done
      
      if [[ $is_audio -eq 1 ]]; then
        echo -e "  🎵 ${GREEN}Playlist Audio Download${RESET} → ${audio_format^^}"
        echo -e "  🔗 ${url}"
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
        
        yt-dlp \
          -x \
          --audio-format "$audio_format" \
          --audio-quality 0 \
          --yes-playlist \
          -o "%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s" \
          "$url"
      else
        echo -e "  📺 ${GREEN}Playlist Video Download${RESET} → ${quality} (${video_format^^})"
        echo -e "  🔗 ${url}"
        echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
        
        local format_str
        case "$quality" in
          1080)
            format_str="bestvideo[height<=1080]+bestaudio/best[height<=1080]"
            ;;
          720)
            format_str="bestvideo[height<=720]+bestaudio/best[height<=720]"
            ;;
          480)
            format_str="bestvideo[height<=480]+bestaudio/best[height<=480]"
            ;;
          360)
            format_str="bestvideo[height<=360]+bestaudio/best[height<=360]"
            ;;
          *)
            format_str="bestvideo+bestaudio/best"
            ;;
        esac
        
        yt-dlp \
          -f "$format_str" \
          --merge-output-format "$video_format" \
          --yes-playlist \
          -o "%(playlist)s/%(playlist_index)s - %(title)s.%(ext)s" \
          "$url"
      fi
      ;;
      
    video)
      echo -e "  🎬 ${GREEN}Video Download${RESET} → ${quality} (${video_format^^})"
      echo -e "  🔗 ${url}"
      echo -e "${BLUE}━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━${RESET}"
      
      local format_str
      case "$quality" in
        1080)
          format_str="bestvideo[height<=1080]+bestaudio/best[height<=1080]"
          ;;
        720)
          format_str="bestvideo[height<=720]+bestaudio/best[height<=720]"
          ;;
        480)
          format_str="bestvideo[height<=480]+bestaudio/best[height<=480]"
          ;;
        360)
          format_str="bestvideo[height<=360]+bestaudio/best[height<=360]"
          ;;
        *)
          format_str="bestvideo+bestaudio/best"
          ;;
      esac
      
      yt-dlp \
        -f "$format_str" \
        --merge-output-format "$video_format" \
        --no-playlist \
        "$url"
      ;;
  esac
  
  local exit_code=$?
  
  # Show result
  if [[ $exit_code -eq 0 ]]; then
    echo -e "${GREEN}✓ Done! Enjoy your download! 🎉${RESET}"
  else
    echo -e "${RED}✗ Something went wrong (exit code: $exit_code)${RESET}"
  fi
  
  return $exit_code
}

# Make function available
deasy "$@"
