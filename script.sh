#!/usr/bin/bash
TARGET="$1"

# Parameter validation
if [ $# -ne 1 ]; then
  echo "To use the script you should run $0 <domain name>"
  exit 1
fi

wget --timeout=10 "https://crt.sh/?q=$TARGET"

# Timeout mechanism
if [ $? -eq 124 ]; then
  echo "Operation terminated due to timeout."
  exit 1
fi