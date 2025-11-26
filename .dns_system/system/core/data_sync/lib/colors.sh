#!/bin/bash

# ═══════════════════════════════════════════════════════════════════════════
# COLORS LIBRARY
# ═══════════════════════════════════════════════════════════════════════════
# Provides color definitions and formatting functions for terminal output
# ═══════════════════════════════════════════════════════════════════════════

# Color definitions
export COLOR_RED='\033[0;31m'
export COLOR_GREEN='\033[0;32m'
export COLOR_YELLOW='\033[1;33m'
export COLOR_BLUE='\033[0;34m'
export COLOR_CYAN='\033[0;36m'
export COLOR_MAGENTA='\033[0;35m'
export COLOR_WHITE='\033[1;37m'
export COLOR_GRAY='\033[0;90m'
export COLOR_NC='\033[0m'  # No Color

# Style definitions
export STYLE_BOLD='\033[1m'
export STYLE_DIM='\033[2m'
export STYLE_UNDERLINE='\033[4m'
export STYLE_RESET='\033[0m'

# ───────────────────────────────────────────────────────────────────────────
# Formatted output functions
# ───────────────────────────────────────────────────────────────────────────

color_print() {
    local color="$1"
    shift
    echo -e "${color}$@${COLOR_NC}"
}

color_error() {
    color_print "$COLOR_RED" "$@"
}

color_success() {
    color_print "$COLOR_GREEN" "$@"
}

color_warning() {
    color_print "$COLOR_YELLOW" "$@"
}

color_info() {
    color_print "$COLOR_BLUE" "$@"
}

color_highlight() {
    color_print "$COLOR_CYAN" "$@"
}

# ───────────────────────────────────────────────────────────────────────────
# Box drawing functions
# ───────────────────────────────────────────────────────────────────────────

print_box() {
    local title="$1"
    local width=64
    
    echo "╔$(printf '═%.0s' $(seq 1 $((width-2))))╗"
    printf "║ %-$((width-4))s ║\n" "$title"
    echo "╚$(printf '═%.0s' $(seq 1 $((width-2))))╝"
}

print_separator() {
    local width="${1:-64}"
    echo "$(color_print $COLOR_CYAN "$(printf '═%.0s' $(seq 1 $width))")"
}

print_section() {
    local title="$1"
    echo ""
    print_separator
    color_highlight "  $title"
    print_separator
    echo ""
}

# ───────────────────────────────────────────────────────────────────────────
# Status indicators
# ───────────────────────────────────────────────────────────────────────────

print_check() {
    echo -e "${COLOR_GREEN}✓${COLOR_NC} $@"
}

print_cross() {
    echo -e "${COLOR_RED}✗${COLOR_NC} $@"
}

print_arrow() {
    echo -e "${COLOR_BLUE}→${COLOR_NC} $@"
}

print_bullet() {
    echo -e "${COLOR_CYAN}•${COLOR_NC} $@"
}

# Export functions
export -f color_print color_error color_success color_warning color_info color_highlight
export -f print_box print_separator print_section
export -f print_check print_cross print_arrow print_bullet

