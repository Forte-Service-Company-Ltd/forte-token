#!/bin/bash

# Script to retrieve values from .env file and load policy trackers
# NOTE: This is only viable for FOR Token Policy in its state as of 12/10/25
# Check if .env file exists
if [[ ! -f ".env" ]]; then
    echo "Error: .env file not found!"
    exit 1
fi

# Function to get value from .env file
get_env_value() {
    local key="$1"
    # Handle both formats: KEY=value and KEY=value (with potential quotes)
    local value=$(grep "^${key}=" .env | cut -d '=' -f2- | sed 's/^"\(.*\)"$/\1/' | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
    echo "$value"
}

# Retrieve values from .env
POLICY_ID=$(get_env_value "POLICY_ID")
TRACKER_INDEX=$(get_env_value "TRACKER_INDEX")
KEY_TYPE=$(get_env_value "KEY_TYPE")
VALUE_TYPE=$(get_env_value "VALUE_TYPE")
KEYS=$(get_env_value "KEYS")
VALUES=$(get_env_value "VALUES")

# Display the values
echo "Retrieved values from .env:"
echo "=========================="
echo "POLICY_ID: $POLICY_ID"
echo "TRACKER_INDEX: $TRACKER_INDEX" 
echo "KEY_TYPE: $KEY_TYPE"
echo "VALUE_TYPE: $VALUE_TYPE"
echo "KEYS: $KEYS"
echo "VALUES: $VALUES"
echo

# Convert KEYS to array
IFS=',' read -ra KEYS_ARRAY <<< "$KEYS"
echo "KEYS array (${#KEYS_ARRAY[@]} elements):"
for i in "${!KEYS_ARRAY[@]}"; do
    echo "  [$i]: ${KEYS_ARRAY[$i]}"
done
echo

# Get checksummed addresses
echo "Checksummed KEYS:"
CHECKSUMMED_KEYS_ARRAY=()
for i in "${!KEYS_ARRAY[@]}"; do
    checksummed=$(cast to-check-sum-address "${KEYS_ARRAY[$i]}")
    CHECKSUMMED_KEYS_ARRAY+=("$checksummed")
    echo "  [$i]: ${KEYS_ARRAY[$i]} -> $checksummed"
done
echo

# ABI-encode each checksummed KEYS value
echo "ABI-encoded KEYS:"
ENCODED_KEYS_ARRAY=()
for i in "${!CHECKSUMMED_KEYS_ARRAY[@]}"; do
    encoded=$(cast abi-encode "f(address)" "${CHECKSUMMED_KEYS_ARRAY[$i]}")
    ENCODED_KEYS_ARRAY+=("$encoded")
    echo "  [$i]: ${CHECKSUMMED_KEYS_ARRAY[$i]} -> $encoded"
done
echo

# Convert VALUES to array
IFS=',' read -ra VALUES_ARRAY <<< "$VALUES"
echo "VALUES array (${#VALUES_ARRAY[@]} elements):"
for i in "${!VALUES_ARRAY[@]}"; do
    echo "  [$i]: ${VALUES_ARRAY[$i]}"
done
echo

# ABI-encode each VALUES value
echo "ABI-encoded VALUES:"
ENCODED_VALUES_ARRAY=()
for i in "${!VALUES_ARRAY[@]}"; do
    encoded=$(cast abi-encode "f(string)" "${VALUES_ARRAY[$i]}")
    ENCODED_VALUES_ARRAY+=("$encoded")
    echo "  [$i]: ${VALUES_ARRAY[$i]} -> $encoded"
done
echo

# Create filtered TRACKER 2 arrays excluding "STK" values
echo "Filtering arrays (excluding STK values):"
KEYSX_ARRAY=()
VALUESX_ARRAY=()
for i in "${!VALUES_ARRAY[@]}"; do
    if [[ "${VALUES_ARRAY[$i]}" != "STK" ]]; then
        KEYSX_ARRAY+=("${CHECKSUMMED_KEYS_ARRAY[$i]}")
        VALUESX_ARRAY+=("${VALUES_ARRAY[$i]}")
        echo "  Including [$i]: Key=${CHECKSUMMED_KEYS_ARRAY[$i]}, Value=${VALUES_ARRAY[$i]}"
    else
        echo "  Excluding [$i]: Key=${CHECKSUMMED_KEYS_ARRAY[$i]}, Value=${VALUES_ARRAY[$i]} (STK)"
    fi
done
echo "KEYSX_ARRAY (${#KEYSX_ARRAY[@]} elements):"
for i in "${!KEYSX_ARRAY[@]}"; do
    echo "  [$i]: ${KEYSX_ARRAY[$i]}"
done
echo "VALUESX_ARRAY (${#VALUESX_ARRAY[@]} elements):"
for i in "${!VALUESX_ARRAY[@]}"; do
    echo "  [$i]: ${VALUESX_ARRAY[$i]}"
done
echo

# ABI-encode each KEYSX_ARRAY value
echo "ABI-encoded KEYSX:"
ENCODED_KEYSX_ARRAY=()
for i in "${!KEYSX_ARRAY[@]}"; do
    encoded=$(cast abi-encode "f(address)" "${KEYSX_ARRAY[$i]}")
    ENCODED_KEYSX_ARRAY+=("$encoded")
    echo "  [$i]: ${KEYSX_ARRAY[$i]} -> $encoded"
done
echo

# ABI-encode each VALUESX_ARRAY value
echo "ABI-encoded VALUESX:"
ENCODED_VALUESX_ARRAY=()
for i in "${!VALUESX_ARRAY[@]}"; do
    encoded=$(cast abi-encode "f(bool)" true)
    ENCODED_VALUESX_ARRAY+=("$encoded")
    echo "  [$i]: ${VALUESX_ARRAY[$i]} -> $encoded"
done
echo

# Generate cast calldata command
echo "Generating cast calldata command for TRACKER1:"
echo "================================="

# Build the encoded keys array string for the command
ENCODED_KEYS_STRING=""
for i in "${!ENCODED_KEYS_ARRAY[@]}"; do
    if [ $i -eq 0 ]; then
        ENCODED_KEYS_STRING="${ENCODED_KEYS_ARRAY[$i]}"
    else
        ENCODED_KEYS_STRING="${ENCODED_KEYS_STRING},${ENCODED_KEYS_ARRAY[$i]}"
    fi
done

# Build the encoded values array string for the command
ENCODED_VALUES_STRING=""
for i in "${!ENCODED_VALUES_ARRAY[@]}"; do
    if [ $i -eq 0 ]; then
        ENCODED_VALUES_STRING="${ENCODED_VALUES_ARRAY[$i]}"
    else
        ENCODED_VALUES_STRING="${ENCODED_VALUES_STRING},${ENCODED_VALUES_ARRAY[$i]}"
    fi
done

# Execute the cast calldata command to get the official calldata string
echo "Command to execute for TRACKER 1:"
echo "cast calldata \"updateTracker(uint256,uint256,(bool,uint8,bool,uint8,bytes,uint256),bytes[],bytes[])\" $POLICY_ID $TRACKER_INDEX \"(true,$VALUE_TYPE,true,$KEY_TYPE,0x1234567890abcdef,$TRACKER_INDEX)\" \"[$ENCODED_KEYS_STRING]\" \"[$ENCODED_VALUES_STRING]\""
echo
echo "CALLDATA:"
cast calldata "updateTracker(uint256,uint256,(bool,uint8,bool,uint8,bytes,uint256),bytes[],bytes[])" \
    "$POLICY_ID" \
    "$TRACKER_INDEX" \
    "(true,$VALUE_TYPE,true,$KEY_TYPE,0x1234567890abcdef,$TRACKER_INDEX)" \
    "[$ENCODED_KEYS_STRING]" \
    "[$ENCODED_VALUES_STRING]"

# Generate filtered cast calldata command for TRACKER2 only if KEYSX(all addresses but STK) is not empty
if [ ${#KEYSX_ARRAY[@]} -gt 0 ]; then
    echo
    echo
    echo "Generating command for TRACKER 2(excluding STK values):"
    echo "================================================================="

    # Build the encoded KEYSX array string for the command
    ENCODED_KEYSX_STRING=""
    for i in "${!ENCODED_KEYSX_ARRAY[@]}"; do
        if [ $i -eq 0 ]; then
            ENCODED_KEYSX_STRING="${ENCODED_KEYSX_ARRAY[$i]}"
        else
            ENCODED_KEYSX_STRING="${ENCODED_KEYSX_STRING},${ENCODED_KEYSX_ARRAY[$i]}"
        fi
    done

    # Build the encoded VALUESX array string for the command
    ENCODED_VALUESX_STRING=""
    for i in "${!ENCODED_VALUESX_ARRAY[@]}"; do
        if [ $i -eq 0 ]; then
            ENCODED_VALUESX_STRING="${ENCODED_VALUESX_ARRAY[$i]}"
        else
            ENCODED_VALUESX_STRING="${ENCODED_VALUESX_STRING},${ENCODED_VALUESX_ARRAY[$i]}"
        fi
    done

    # Execute the filtered cast calldata command for TRACKER2
    echo "Command to execute for TRACKER 2:"
    echo "cast calldata \"updateTracker(uint256,uint256,(bool,uint8,bool,uint8,bytes,uint256),bytes[],bytes[])\" $POLICY_ID $TRACKER_INDEX \"(true,$VALUE_TYPE,true,$KEY_TYPE,0x1234567890abcdef,$TRACKER_INDEX)\" \"[$ENCODED_KEYSX_STRING]\" \"[$ENCODED_VALUESX_STRING]\""
    echo
    echo "CALLDATA:"
    cast calldata "updateTracker(uint256,uint256,(bool,uint8,bool,uint8,bytes,uint256),bytes[],bytes[])" \
        "$POLICY_ID" \
        "2" \
        "(true,$VALUE_TYPE,true,$KEY_TYPE,0x1234567890abcdef,$TRACKER_INDEX)" \
        "[$ENCODED_KEYSX_STRING]" \
        "[$ENCODED_VALUESX_STRING]"
fi