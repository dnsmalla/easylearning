#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════
# Logger Functions
# ═══════════════════════════════════════════════════════════════════════════

# Print a boxed title
print_box() {
    local title="$1"
    local width=60
    local padding=$(( (width - ${#title} - 2) / 2 ))
    
    echo -e "${COLOR_CYAN}╔$(printf '═%.0s' $(seq 1 $width))╗${COLOR_NC}"
    printf "${COLOR_CYAN}║%*s%s%*s║${COLOR_NC}\n" $padding "" "$title" $((width - padding - ${#title})) ""
    echo -e "${COLOR_CYAN}╚$(printf '═%.0s' $(seq 1 $width))╝${COLOR_NC}"
}

# Print a section header
print_section() {
    local title="$1"
    echo ""
    echo -e "${COLOR_CYAN}═══════════════════════════════════════════════════════════${COLOR_NC}"
    echo -e "${COLOR_CYAN}  $title${COLOR_NC}"
    echo -e "${COLOR_CYAN}═══════════════════════════════════════════════════════════${COLOR_NC}"
    echo ""
}

# Log messages
log_info() { echo -e "${COLOR_BLUE}ℹ️  $*${COLOR_NC}"; }
log_success() { echo -e "${COLOR_GREEN}✅ $*${COLOR_NC}"; }
log_warning() { echo -e "${COLOR_YELLOW}⚠️  $*${COLOR_NC}"; }
log_error() { echo -e "${COLOR_RED}❌ $*${COLOR_NC}" >&2; }

# Log step in a workflow
log_step() {
    local current=$1
    local total=$2
    local message=$3
    echo -e "${COLOR_BLUE}[$current/$total] $message${COLOR_NC}"
}

# Log task status
log_task() {
    local task="$1"
    printf "  • %-40s " "$task"
}

log_task_done() {
    echo -e "${COLOR_GREEN}✓${COLOR_NC}"
}

log_task_failed() {
    echo -e "${COLOR_RED}✗${COLOR_NC}"
}

log_task_skip() {
    echo -e "${COLOR_YELLOW}○${COLOR_NC}"
}

# Print summary
log_summary() {
    local passed=$1
    local failed=$2
    local total=$((passed + failed))
    
    echo ""
    echo -e "${COLOR_CYAN}Summary:${COLOR_NC}"
    echo -e "  Total: $total"
    echo -e "  ${COLOR_GREEN}Passed: $passed${COLOR_NC}"
    echo -e "  ${COLOR_RED}Failed: $failed${COLOR_NC}"
}

