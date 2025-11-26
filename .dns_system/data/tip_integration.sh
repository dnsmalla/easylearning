#!/usr/bin/env bash
# DNS System - Tip Integration for Error Prevention
# Integrates systematic tip management into existing code generation workflow

# Get script directory
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SYSTEM_DIR="$(dirname "$SCRIPT_DIR")/system"
TIP_MANAGER_SCRIPT="$SCRIPT_DIR/tip_management_system.py"

# Initialize tip manager if needed
init_tip_manager() {
    if [[ ! -f "$TIP_MANAGER_SCRIPT" ]]; then
        echo "❌ Tip management system not found: $TIP_MANAGER_SCRIPT"
        return 1
    fi
    
    echo "🔧 Initializing tip management system..."
    python "$TIP_MANAGER_SCRIPT" > /dev/null 2>&1
    return $?
}

# Extract tips from existing DNS system files
extract_existing_tips() {
    local corrections_dir="$SYSTEM_DIR/workspace/corrections"
    local feedback_file="$SYSTEM_DIR/docs/FEEDBACK.md"
    
    echo "📚 Extracting tips from DNS system files..."
    
    if [[ ! -d "$corrections_dir" ]]; then
        echo "⚠️  Corrections directory not found: $corrections_dir"
        return 1
    fi
    
    # Run tip extraction
    python -c "
import sys
sys.path.insert(0, '$SCRIPT_DIR')
from tip_management_system import TipManager
import logging

logging.basicConfig(level=logging.INFO)
tip_manager = TipManager('$SCRIPT_DIR')

# Extract from corrections
extracted = tip_manager.extract_tips_from_correction_files('$corrections_dir')
print(f'✅ Extracted {extracted} tips from correction files')

# Show statistics
stats = tip_manager.get_statistics()
print(f'📊 Total tips in database: {stats[\"total_tips\"]}')
print(f'📈 Average success rate: {stats[\"avg_success_rate\"]:.1%}')
"
    
    return $?
}

# Generate prevention prompt for a specific project
generate_prevention_prompt() {
    local project_type="$1"
    local language="$2"
    local output_file="$3"
    
    if [[ -z "$project_type" || -z "$language" ]]; then
        echo "Usage: generate_prevention_prompt <project_type> <language> [output_file]"
        return 1
    fi
    
    echo "🛡️ Generating prevention prompt for $project_type ($language)..."
    
    local prompt_content
    prompt_content=$(python -c "
import sys
sys.path.insert(0, '$SCRIPT_DIR')
from tip_management_system import TipManager
import logging

logging.basicConfig(level=logging.WARNING)  # Suppress info logs
tip_manager = TipManager('$SCRIPT_DIR')
prompt = tip_manager.generate_prevention_prompt('$project_type', '$language')
print(prompt)
")
    
    if [[ -n "$output_file" ]]; then
        echo "$prompt_content" > "$output_file"
        echo "✅ Prevention prompt saved to: $output_file"
    else
        echo "$prompt_content"
    fi
    
    return 0
}

# Update tip usage after code generation
update_tip_usage() {
    local tip_id="$1"
    local success="$2"  # true or false
    
    if [[ -z "$tip_id" || -z "$success" ]]; then
        echo "Usage: update_tip_usage <tip_id> <true|false>"
        return 1
    fi
    
    python -c "
import sys
sys.path.insert(0, '$SCRIPT_DIR')
from tip_management_system import TipManager
import logging

logging.basicConfig(level=logging.WARNING)
tip_manager = TipManager('$SCRIPT_DIR')
success_bool = True if '$success'.lower() == 'true' else False
tip_manager.update_tip_usage('$tip_id', success_bool)
print(f'Updated tip usage: $tip_id (success: $success)')
"
    
    return $?
}

# Add a new tip from recent error
add_tip_from_error() {
    local error_type="$1"
    local project_type="$2"
    local language="$3"
    local error_pattern="$4"
    local solution="$5"
    local prevention_code="$6"
    
    if [[ -z "$error_type" || -z "$project_type" || -z "$language" || -z "$solution" ]]; then
        echo "Usage: add_tip_from_error <error_type> <project_type> <language> <error_pattern> <solution> [prevention_code]"
        echo "Error types: syntax_error, import_missing, logic_error, template_placeholder, best_practice"
        return 1
    fi
    
    echo "💡 Adding new tip from error..."
    
    python -c "
import sys
sys.path.insert(0, '$SCRIPT_DIR')
from tip_management_system import TipManager, CodeTip, TipCategory, TipPriority
from datetime import datetime
import logging

logging.basicConfig(level=logging.INFO)

# Map string to enum
category_map = {
    'syntax_error': TipCategory.SYNTAX_ERROR,
    'import_missing': TipCategory.IMPORT_MISSING,
    'logic_error': TipCategory.LOGIC_ERROR,
    'template_placeholder': TipCategory.TEMPLATE_PLACEHOLDER,
    'best_practice': TipCategory.BEST_PRACTICE
}

tip_manager = TipManager('$SCRIPT_DIR')

# Generate tip ID
tip_id = f'${error_type}_${project_type}_${language}_{datetime.now().strftime(\"%Y%m%d_%H%M%S\")}'

# Create tip
tip = CodeTip(
    tip_id=tip_id,
    category=category_map.get('$error_type', TipCategory.BEST_PRACTICE),
    priority=TipPriority.HIGH,
    project_type='$project_type',
    language='$language',
    error_pattern='$error_pattern',
    solution='$solution',
    prevention_code='$prevention_code',
    success_rate=0.8,  # Default starting rate
    usage_count=0,
    created_date=datetime.now(),
    tags=['$error_type', '$project_type']
)

if tip_manager.add_tip(tip):
    print(f'✅ Added tip: {tip_id}')
else:
    print(f'❌ Failed to add tip: {tip_id}')
"
    
    return $?
}

# Enhanced code generation with tip injection
generate_code_with_tips() {
    local project_title="$1"
    local project_type="$2"
    local language="$3"
    local output_file="$4"
    
    if [[ -z "$project_title" || -z "$project_type" || -z "$language" ]]; then
        echo "Usage: generate_code_with_tips <title> <project_type> <language> [output_file]"
        return 1
    fi
    
    echo "🚀 Generating code with prevention tips for: $project_title"
    
    # Generate prevention prompt
    local temp_prompt_file="/tmp/prevention_prompt_$$.md"
    generate_prevention_prompt "$project_type" "$language" "$temp_prompt_file"
    
    # Create enhanced generation instructions
    local enhanced_prompt="/tmp/enhanced_prompt_$$.md"
    cat > "$enhanced_prompt" <<EOF
# 🤖 Enhanced Code Generation Request

## Project Details
- **Title**: $project_title
- **Type**: $project_type  
- **Language**: $language

$(cat "$temp_prompt_file")

## 🎯 Generation Requirements
1. **Apply all prevention tips above** - These are based on real error patterns
2. **Follow language-specific standards** - Use appropriate coding conventions
3. **Include comprehensive error handling** - Prevent runtime issues
4. **Add proper imports and dependencies** - Include all necessary imports
5. **Implement actual business logic** - No placeholder methods
6. **Use meaningful variable names** - Clear and descriptive naming
7. **Add logging and monitoring** - Include appropriate logging
8. **Include type hints/annotations** - For better code quality

## 📋 Output Requirements
- Provide complete, working code
- Include all necessary imports
- Follow the prevention tips exactly
- Add comments explaining key decisions
- Ensure code is production-ready

## 🔍 Quality Checks
Before submitting, verify:
- [ ] All imports are present
- [ ] No syntax errors
- [ ] No placeholder values
- [ ] Error handling implemented
- [ ] Prevention tips applied
- [ ] Code follows language standards

Generate the complete $language code for: **$project_title**
EOF

    echo "📝 Enhanced prompt created with $(wc -l < "$temp_prompt_file") lines of prevention tips"
    echo "💡 Use this prompt with your AI assistant:"
    echo "📁 Prompt file: $enhanced_prompt"
    
    if [[ -n "$output_file" ]]; then
        cp "$enhanced_prompt" "$output_file"
        echo "✅ Enhanced prompt saved to: $output_file"
    else
        echo ""
        echo "=== ENHANCED PROMPT ==="
        cat "$enhanced_prompt"
        echo "======================="
    fi
    
    # Cleanup
    rm -f "$temp_prompt_file" "$enhanced_prompt"
    
    return 0
}

# Show tip statistics
show_tip_stats() {
    echo "📊 Tip Database Statistics"
    echo "=========================="
    
    python -c "
import sys
sys.path.insert(0, '$SCRIPT_DIR')
from tip_management_system import TipManager
import logging

logging.basicConfig(level=logging.WARNING)
tip_manager = TipManager('$SCRIPT_DIR')
stats = tip_manager.get_statistics()

print(f'Total Tips: {stats[\"total_tips\"]}')
print(f'Average Success Rate: {stats[\"avg_success_rate\"]:.1%}')
print()

print('📈 By Category:')
for category, count in stats['by_category'].items():
    print(f'  {category}: {count}')

print()
print('🌐 By Language:')
for language, count in stats['by_language'].items():
    print(f'  {language}: {count}')

print()
print('📋 By Project Type:')
for proj_type, count in stats['by_project_type'].items():
    print(f'  {proj_type}: {count}')

if stats['most_used']:
    print()
    print('🏆 Most Used Tip:')
    print(f'  ID: {stats[\"most_used\"][\"tip_id\"]}')
    print(f'  Usage: {stats[\"most_used\"][\"usage_count\"]} times')
    print(f'  Solution: {stats[\"most_used\"][\"solution\"]}')

print()
print(f'🆕 Recently Added: {stats[\"recently_added\"]} tips (last 7 days)')
"
}

# Export tips to Excel/CSV for manual editing
export_tips() {
    local format="$1"  # csv or excel
    local output_file="$2"
    
    if [[ -z "$format" ]]; then
        format="csv"
    fi
    
    if [[ -z "$output_file" ]]; then
        output_file="$SCRIPT_DIR/coding_tips_export.${format}"
    fi
    
    echo "📤 Exporting tips to $format format..."
    
    if [[ "$format" == "excel" ]]; then
        python -c "
import sys
sys.path.insert(0, '$SCRIPT_DIR')
from tip_management_system import TipManager
import pandas as pd
import logging

logging.basicConfig(level=logging.WARNING)
tip_manager = TipManager('$SCRIPT_DIR')

# Convert tips to DataFrame
tips_data = []
for tip in tip_manager.tips.values():
    tips_data.append(tip_manager._tip_to_dict(tip))

if tips_data:
    df = pd.DataFrame(tips_data)
    df.to_excel('$output_file', index=False)
    print(f'✅ Exported {len(tips_data)} tips to: $output_file')
else:
    print('❌ No tips to export')
"
    else
        # CSV export is handled automatically by the tip manager
        if [[ -f "$SCRIPT_DIR/coding_tips.csv" ]]; then
            cp "$SCRIPT_DIR/coding_tips.csv" "$output_file"
            echo "✅ Exported tips to: $output_file"
        else
            echo "❌ No tips database found"
        fi
    fi
}

# Main command dispatcher
main() {
    case "${1:-help}" in
        init)
            init_tip_manager
            ;;
        extract)
            extract_existing_tips
            ;;
        prompt)
            generate_prevention_prompt "$2" "$3" "$4"
            ;;
        update)
            update_tip_usage "$2" "$3"
            ;;
        add)
            add_tip_from_error "$2" "$3" "$4" "$5" "$6" "$7"
            ;;
        generate)
            generate_code_with_tips "$2" "$3" "$4" "$5"
            ;;
        stats)
            show_tip_stats
            ;;
        export)
            export_tips "$2" "$3"
            ;;
        *)
            echo "DNS Tip Management System"
            echo "========================"
            echo ""
            echo "Usage: $0 {init|extract|prompt|update|add|generate|stats|export}"
            echo ""
            echo "🏗️  Setup Commands:"
            echo "  init                           - Initialize tip management system"
            echo "  extract                        - Extract tips from existing correction files"
            echo ""
            echo "💡 Tip Management:"
            echo "  prompt <type> <lang> [file]    - Generate prevention prompt"
            echo "  add <error_type> <proj> <lang> <pattern> <solution> [code] - Add new tip"
            echo "  update <tip_id> <true|false>   - Update tip usage statistics"
            echo ""
            echo "🚀 Enhanced Generation:"
            echo "  generate <title> <type> <lang> [file] - Generate code with prevention tips"
            echo ""
            echo "📊 Analytics:"
            echo "  stats                          - Show tip database statistics"
            echo "  export [csv|excel] [file]      - Export tips for manual editing"
            echo ""
            echo "🎯 Examples:"
            echo "  $0 init"
            echo "  $0 extract"
            echo "  $0 prompt ecommerce python"
            echo "  $0 generate 'Shopping Cart' ecommerce python"
            echo "  $0 add syntax_error mobile swift 'Missing semicolon' 'Always end statements with semicolon'"
            echo "  $0 stats"
            echo ""
            echo "📁 Data Location: $SCRIPT_DIR"
            echo "📊 CSV File: $SCRIPT_DIR/coding_tips.csv"
            ;;
    esac
}

# Execute main function
main "$@"
