#!/bin/bash
# MikroTik RouterOS Script Validation Tool
# Validates RouterOS script syntax and checks for destructive operations

validate_mikrotik_script() {
    local script_file="$1"
    local errors=0
    local warnings=0
    
    if [[ ! -f "$script_file" ]]; then
        echo "Error: File $script_file not found"
        return 1
    fi
    
    echo "Validating MikroTik script: $script_file"
    echo "=========================================="
    
    # Check for destructive operations
    echo "Checking for destructive operations..."
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
                    # Check for warnings in surrounding lines (5 before, 2 after)
                    local context_start=$((line_num - 10))
                    local context_end=$((line_num + 5))
                    [[ $context_start -lt 1 ]] && context_start=1
                    
                    if sed -n "${context_start},${context_end}p" "$script_file" | grep -qi "WARNING\|BACKUP\|CAUTION\|CRITICAL\|DESTRUCTIVE\|RISK"; then
                        echo "✓ Commented destructive operation '$pattern' at line $line_num has proper warnings"
                    else
                        echo "⚠ Commented destructive operation '$pattern' at line $line_num lacks adequate warnings"
                        ((warnings++))
                    fi
                else
                    # Active destructive operation - check for warnings
                    local context_start=$((line_num - 5))
                    local context_end=$((line_num + 2))
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
    echo ""
    echo "Validating script syntax..."
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
    
    echo ""
    echo "=========================================="
    echo "Validation complete."
    echo "Errors: $errors"
    echo "Warnings: $warnings"
    
    if [[ $errors -gt 0 ]]; then
        echo "❌ Validation failed with $errors errors"
        return 1
    elif [[ $warnings -gt 0 ]]; then
        echo "⚠️  Validation passed with $warnings warnings"
        return 0
    else
        echo "✅ Validation passed successfully"
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