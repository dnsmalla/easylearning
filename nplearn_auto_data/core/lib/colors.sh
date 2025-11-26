#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════
# Color Definitions
# ═══════════════════════════════════════════════════════════════════════════

# ANSI Color Codes
export COLOR_RED='\033[0;31m'
export COLOR_GREEN='\033[0;32m'
export COLOR_YELLOW='\033[0;33m'
export COLOR_BLUE='\033[0;34m'
export COLOR_PURPLE='\033[0;35m'
export COLOR_CYAN='\033[0;36m'
export COLOR_WHITE='\033[0;37m'
export COLOR_NC='\033[0m' # No Color

# Bold variants
export COLOR_BOLD_RED='\033[1;31m'
export COLOR_BOLD_GREEN='\033[1;32m'
export COLOR_BOLD_YELLOW='\033[1;33m'
export COLOR_BOLD_BLUE='\033[1;34m'
export COLOR_BOLD_PURPLE='\033[1;35m'
export COLOR_BOLD_CYAN='\033[1;36m'
export COLOR_BOLD_WHITE='\033[1;37m'

# Legacy aliases
export RED="$COLOR_RED"
export GREEN="$COLOR_GREEN"
export YELLOW="$COLOR_YELLOW"
export BLUE="$COLOR_BLUE"
export CYAN="$COLOR_CYAN"
export NC="$COLOR_NC"

# Color helper functions
color_red() { echo -e "${COLOR_RED}$*${COLOR_NC}"; }
color_green() { echo -e "${COLOR_GREEN}$*${COLOR_NC}"; }
color_yellow() { echo -e "${COLOR_YELLOW}$*${COLOR_NC}"; }
color_blue() { echo -e "${COLOR_BLUE}$*${COLOR_NC}"; }
color_cyan() { echo -e "${COLOR_CYAN}$*${COLOR_NC}"; }
color_error() { echo -e "${COLOR_RED}$*${COLOR_NC}" >&2; }

