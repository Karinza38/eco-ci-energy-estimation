#!/bin/bash
set -euo pipefail

# Parse named parameters
while [[ $# -gt 0 ]]; do
    key="$1"

    case $key in
        -f|--file)
        FILE="$2"
        shift # past argument
        shift # past value
        ;;
        -l|--label)
        LABEL="$2"
        shift # past argument
        shift # past value
        ;;
        -c|--cpu)
        CPU="$2"
        shift # past argument
        shift # past value
        ;;
        -e|--energy)
        ENERGY="$2"
        shift # past argument
        shift # past value
        ;;
        -p|--power)
        POWER="$2"
        shift # past argument
        shift # past value
        ;;
        *)  # unknown option
        echo "Unknown option: $1"
        exit 1
        ;;
    esac
done

# Check if the JSON file exists, and create it if not
if [ ! -f "$FILE" ]; then
    echo "{}" > "$FILE"
fi

# Define the data point to add to the JSON file
read -r -d '' NEW_STEP << EOM
{
    "label": "$LABEL",
    "cpu_avg_percent": $CPU,
    "energy_joules": $ENERGY,
    "power_avg_watts": $POWER
}
EOM

# Add the data point to the JSON file
if [ -s "$FILE" ]; then
    jq --argjson newstep "$NEW_STEP" '. + $newstep' "$FILE" > tmp.$$.json && mv tmp.$$.json "$FILE"
else
    echo "$NEW_STEP" > "$FILE"
fi

# Remove all line breaks
tr -d '\n' < "$FILE" > temp && mv temp "$FILE"
