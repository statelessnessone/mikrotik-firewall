#!/bin/bash
# MikroTik RouterOS Script Validation Tool
# Validates RouterOS script syntax and checks for destructive operations

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "${SCRIPT_DIR}/.." && pwd)"
LOGS_DIR="${PROJECT_ROOT}/logs"

# Create logs directory if it doesn't exist
mkdir -p "${LOGS_DIR}"

# Log file with timestamp
LOG_FILE="${LOGS_DIR}/validate_mikrotik_$(date '+%Y%m%d_%H%M%S').log"

# Function to log both to console and file
log_both() {
    local message="$1"
    echo "$message"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $message" >> "$LOG_FILE"
}

validate_mikrotik_script() {
    local script_file="$1"
    local errors=0
    local warnings=0
    
    # Context window sizes for destructive operation validation
    declare -r COMMENTED_CONTEXT_BEFORE=10
    declare -r COMMENTED_CONTEXT_AFTER=5
    declare -r ACTIVE_CONTEXT_BEFORE=5
    declare -r ACTIVE_CONTEXT_AFTER=2
    
    if [[ ! -f "$script_file" ]]; then
        log_both "Error: File $script_file not found"
        return 1
    fi
    
    log_both "Validating MikroTik script: $script_file"
    log_both "=========================================="
    
    # Check for destructive operations
    log_both "Checking for destructive operations..."
    # Use only regex patterns for destructive operations
    local destructive_patterns=(
        'remove[[:space:]]+\[find\]'
        'reset-configuration'
        'system[[:space:]]+reset'
        '/?system[[:space:]]+backup'
        '(/ip[[:space:]]+firewall[[:space:]]+)?filter[[:space:]]+remove'
        '(/ip[[:space:]]+firewall[[:space:]]+)?nat[[:space:]]+remove'
        '(/ip[[:space:]]+firewall[[:space:]]+)?address-list[[:space:]]+remove'
    )
    
    for pattern in "${destructive_patterns[@]}"; do
        if grep -Eq "$pattern" "$script_file"; then
            # Check for both active and commented destructive operations
            local destructive_lines=$(grep -En "$pattern" "$script_file")
            while IFS= read -r line; do
                local line_num=$(echo "$line" | cut -d: -f1)
                local line_content=$(echo "$line" | cut -d: -f2-)
                
                # Check if it's a commented line
                if [[ "$line_content" =~ ^[[:space:]]*# ]]; then
                    # Check for warnings in surrounding lines for commented operations
                    local context_start=$((line_num - COMMENTED_CONTEXT_BEFORE))
                    local context_end=$((line_num + COMMENTED_CONTEXT_AFTER))
                    [[ $context_start -lt 1 ]] && context_start=1
                    
                    if sed -n "${context_start},${context_end}p" "$script_file" | grep -qi "WARNING\|BACKUP\|CAUTION\|CRITICAL\|DESTRUCTIVE\|RISK"; then
                        echo "✓ Commented destructive operation '$pattern' at line $line_num has proper warnings"
                    else
                        echo "⚠ Commented destructive operation '$pattern' at line $line_num lacks adequate warnings"
                        ((warnings++))
                    fi
                else
                    # Active destructive operation - check for warnings
                    local context_start=$((line_num - ACTIVE_CONTEXT_BEFORE))
                    local context_end=$((line_num + ACTIVE_CONTEXT_AFTER))
                    [[ $context_start -lt 1 ]] && context_start=1
                    
                    if sed -n "${context_start},${context_end}p" "$script_file" | grep -qi "WARNING\|BACKUP\|CAUTION\|CRITICAL\|DESTRUCTIVE\|RISK"; then
                        echo "✓ Active destructive operation '$pattern' at line $line_num has proper warnings"
                    else
                        echo "⚠ Active destructive operation '$pattern' at line $line_num lacks adequate warnings"
                        ((warnings++))
                    fi
                fi
            done <<< "$destructive_lines"
        fi
    done
    
    # Validate script syntax
    log_both ""
    log_both "Validating script syntax..."
    local line_num=0
    local in_continuation=false
    
    while IFS= read -r line; do
        ((line_num++))
        
        # Skip comments and empty lines
        [[ "$line" =~ ^[[:space:]]*# ]] && continue
        [[ "$line" =~ ^[[:space:]]*$ ]] && continue
        
        # Handle line continuations
        if [[ "$line" =~ \\[[:space:]]*$ ]]; then
            in_continuation=true
        fi
        
        # Check for valid RouterOS commands
        if [[ "$line" =~ ^[[:space:]]*/ ]]; then
            echo "✓ Line $line_num: RouterOS command: $line"
            in_continuation=false
        elif [[ "$line" =~ ^[[:space:]]*(add|set|print|enable|disable|do|local|if|foreach|while|export|import|put|delay) ]]; then
            echo "✓ Line $line_num: Parameter/Script command: $line"
            in_continuation=false
        elif [[ "$line" =~ ^[[:space:]]*: ]]; then
            echo "✓ Line $line_num: Script command: $line"
            in_continuation=false
        elif [[ "$line" =~ ^[[:space:]]*\} ]]; then
            echo "✓ Line $line_num: Script block end: $line"
            in_continuation=false
        elif [[ "$in_continuation" == true ]]; then
            echo "✓ Line $line_num: Continuation line: $line"
            if [[ ! "$line" =~ \\[[:space:]]*$ ]]; then
                in_continuation=false
            fi
        else
            echo "⚠ Line $line_num: Unknown line format: $line"
            ((errors++))
        fi
    done < "$script_file"
    
    log_both ""
    log_both "=========================================="
    log_both "Validation complete."
    log_both "Errors: $errors"
    log_both "Warnings: $warnings"
    
    if [[ $errors -gt 0 ]]; then
        log_both "❌ Validation failed with $errors errors"
        return 1
    elif [[ $warnings -gt 0 ]]; then
        log_both "⚠️  Validation passed with $warnings warnings"
        return 0
    else
        log_both "✅ Validation passed successfully"
        return 0
    fi
}

# Main execution
if [[ $# -eq 0 ]]; then
    echo "Usage: $0 <script-file>"
    echo "Example: $0 00-main-config.rsc"
    exit 1
fi

validate_mikrotik_script "$1"