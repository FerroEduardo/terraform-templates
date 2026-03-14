#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<EOF
Usage: $0 <parallel> <total>

Example:
  $0 50 500

This script reads the ALB DNS from Terraform output named 'alb_dns' in the
current directory and sends HTTP requests to trigger load.
EOF
}

if [ "$#" -ne 2 ]; then
  usage
  exit 1
fi

parallel="$1"
total="$2"

if ! command -v terraform >/dev/null 2>&1; then
  echo "terraform not found in PATH" >&2
  exit 2
fi

host=$(terraform output -raw lb-url 2>/dev/null || true)
if [ -z "$host" ]; then
  echo "Could not read 'lb-url' from Terraform outputs in current directory" >&2
  echo "Run this from the directory with your Terraform config and outputs." >&2
  exit 3
fi

# Strip leading http:// or https:// if present, to avoid double prefix
host="${host#http://}"
host="${host#https://}"

echo "Sending $total requests to http://$host/ with $parallel parallelism"

re='^[0-9]+$'
if ! [[ $parallel =~ $re ]] || ! [[ $total =~ $re ]]; then
  echo "parallel and total must be positive integers" >&2
  exit 4
fi

seq 1 "$total" | xargs -P "$parallel" -I{} curl -sS -o /dev/null "http://$host/"

echo "Done"
