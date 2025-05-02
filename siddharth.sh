#!/bin/bash

# siddharth.sh - A tool to recursively scan a website using gobuster with colorized output and clean results
# inspired by gobuster


RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
YELLOW='\033[1;33m'
NC='\033[0m' 

if ! command -v gobuster &> /dev/null; then
    echo -e "${RED}Error: gobuster is not installed. Please install it first.${NC}"
    exit 1
fi

if ! command -v curl &> /dev/null; then
    echo -e "${RED}Error: curl is not installed. Please install it first.${NC}"
    exit 1
fi

if [ $# -lt 2 ]; then
    echo -e "${RED}Usage: $0 <target_url> <wordlist> [gobuster_options]${NC}"
    echo -e "${RED}Example: $0 https://example.com /usr/share/wordlists/dirb/common.txt -t 50${NC}"
    exit 1
fi

TARGET_URL="$1"
WORDLIST="$2"
shift 2
GOBUSTER_OPTIONS="$@"

TARGET_URL=$(echo "$TARGET_URL" | sed 's/\/$//')

TEMP_FILE=$(mktemp)
QUEUE_FILE=$(mktemp)
SCANNED_FILE=$(mktemp)
ALL_RESULTS_FILE=$(mktemp)

echo "$TARGET_URL" > "$QUEUE_FILE"

run_gobuster() {
    local url="$1"
    echo -e "${CYAN}[*] Scanning: $url${NC}"
    
    gobuster dir \
        -u "$url" \
        -w "$WORDLIST" \
        -s "200,301,302,303,400,401,403" \
        -b "" \
        -q \
        $GOBUSTER_OPTIONS | \
    sed 's/\x1B\[[0-9;]*[JKmsu]//g' | \
    sed 's/\r//g' | \
    grep -E 'Status: [0-9]{3}' | \
    awk '{print $1 "\tStatus: " $3}' | \
    sed "s|^$url/||" | \
    sed 's/\/$//' > "$TEMP_FILE"
    
    if [ -s "$TEMP_FILE" ]; then
        echo "Results for $url:" >> "$ALL_RESULTS_FILE"
        cat "$TEMP_FILE" >> "$ALL_RESULTS_FILE"
        echo "" >> "$ALL_RESULTS_FILE"
    fi
}

fetch_headers() {
    local url="$1"
    local path="$2"
    local full_url="$url/$path"
    echo -e "${CYAN}[*] Fetching headers for: $full_url${NC}"
    curl -I "$full_url" 2>/dev/null | head -n 10 | while read -r line; do
        echo -e "${YELLOW}$line${NC}"
    done
    echo ""
}

while [ -s "$QUEUE_FILE" ]; do
    CURRENT_URL=$(tail -n 1 "$QUEUE_FILE")
    
    if grep -Fx "$CURRENT_URL" "$SCANNED_FILE" > /dev/null; then
        sed -i '$d' "$QUEUE_FILE"
        continue
    fi

    run_gobuster "$CURRENT_URL"

    if [ -s "$TEMP_FILE" ]; then
        echo -e "${GREEN}[*] Discovered paths for $CURRENT_URL:${NC}"
        echo -e "${GREEN}Path\t\tStatus${NC}"
        echo -e "${GREEN}----\t\t------${NC}"
        while IFS=$'\t' read -r path status; do
            printf "${GREEN}%-20s\t%s${NC}\n" "$path" "$status"
            fetch_headers "$CURRENT_URL" "$path" >> "$ALL_RESULTS_FILE"
        done < "$TEMP_FILE"
        echo ""
    fi

    echo "$CURRENT_URL" >> "$SCANNED_FILE"

    while IFS=$'\t' read -r path status; do
        [ -z "$path" ] && continue
        
        FULL_URL="$CURRENT_URL/$path"
        
        if ! grep -Fx "$FULL_URL" "$SCANNED_FILE" > /dev/null && \
           ! grep -Fx "$FULL_URL" "$QUEUE_FILE" > /dev/null; then
            echo "$FULL_URL" >> "$QUEUE_FILE"
        fi
    done < "$TEMP_FILE"

    if [ -s "$QUEUE_FILE" ]; then
        echo -e "${YELLOW}[*] Current queue:${NC}"
        while IFS= read -r queue_item; do
            echo -e "${YELLOW}  $queue_item${NC}"
        done < "$QUEUE_FILE"
        echo ""
    fi

    > "$TEMP_FILE"

    sed -i '$d' "$QUEUE_FILE"
done

if [ -s "$ALL_RESULTS_FILE" ]; then
    echo -e "${CYAN}[*] Final Summary of All Findings:${NC}"
    current_url=""
    while IFS= read -r line; do
        if [[ "$line" == "Results for"* ]]; then
            current_url="${line#Results for }"
            current_url="${current_url%:}"
            echo -e "${GREEN}Results for ${current_url}:${NC}"
            echo -e "${GREEN}Path\t\tStatus${NC}"
            echo -e "${GREEN}----\t\t------${NC}"
        elif [[ "$line" == $'\t'* ]]; then
            IFS=$'\t' read -r path status <<< "$line"
            printf "${GREEN}%-20s\t%s${NC}\n" "$path" "$status"
        elif [ -n "$line" ]; then
            echo -e "${YELLOW}$line${NC}"
        else
            echo ""
        fi
    done < "$ALL_RESULTS_FILE"
else
    echo -e "${RED}[*] No paths discovered during the scan.${NC}"
fi

rm "$TEMP_FILE" "$QUEUE_FILE" "$SCANNED_FILE" "$ALL_RESULTS_FILE"

echo -e "${CYAN}[*] Scanning complete.${NC}"
