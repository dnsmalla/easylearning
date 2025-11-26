#!/bin/bash
# ═══════════════════════════════════════════════════════════════════════════
# Data Validator
# ═══════════════════════════════════════════════════════════════════════════

# Validate JSON file
validate_json_file() {
    local file="$1"
    local name=$(basename "$file")
    
    log_task "Validating $name"
    
    if [ ! -f "$file" ]; then
        log_task_failed
        log_error "File not found: $file"
        return 1
    fi
    
    # Check JSON syntax
    if python3 -c "import json; json.load(open('$file'))" 2>/dev/null; then
        log_task_done
        return 0
    else
        log_task_failed
        log_error "Invalid JSON in $name"
        return 1
    fi
}

# Validate all data files
validate_all_data() {
    print_section "Validating Data Files"
    
    local passed=0
    local failed=0
    
    # Validate all JSON files in Resources
    for file in "$APP_RESOURCES_PATH"/*.json; do
        if [ -f "$file" ]; then
            if validate_json_file "$file"; then
                passed=$((passed + 1))
            else
                failed=$((failed + 1))
            fi
        fi
    done
    
    echo ""
    log_summary $passed $failed
    
    if [ $failed -eq 0 ]; then
        log_success "All data files valid"
        return 0
    else
        log_error "Some data files have errors"
        return 1
    fi
}

# Validate manifest structure
validate_manifest() {
    local manifest="$APP_RESOURCES_PATH/manifest.json"
    
    log_task "Validating manifest structure"
    
    if ! python3 -c "
import json
with open('$manifest') as f:
    data = json.load(f)
    assert 'version' in data, 'Missing version'
    assert 'releaseDate' in data, 'Missing releaseDate'
    assert 'files' in data, 'Missing files'
    assert 'changelog' in data, 'Missing changelog'
" 2>/dev/null; then
        log_task_failed
        return 1
    fi
    
    log_task_done
    return 0
}

# Validate vocabulary structure
validate_vocabulary() {
    local vocab_file="$APP_RESOURCES_PATH/vocabulary.json"
    
    log_task "Validating vocabulary structure"
    
    if ! python3 -c "
import json
with open('$vocab_file') as f:
    data = json.load(f)
    assert 'category' in data, 'Missing category'
    assert 'levels' in data, 'Missing levels'
    for level, items in data['levels'].items():
        if items:
            item = items[0]
            assert 'id' in item, 'Missing id'
            assert 'nepali' in item, 'Missing nepali'
            assert 'english' in item, 'Missing english'
" 2>/dev/null; then
        log_task_failed
        return 1
    fi
    
    log_task_done
    return 0
}

