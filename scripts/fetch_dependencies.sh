#!/usr/bin/env bash -e

# usage: ./scripts/fetch_dependencies.sh --integration=[integration]
#
# Available options: "cocoapods", "carthage"

# parse arguments
INTEGRATION=""

while [[ $# -gt 0 ]]
do
  case $1 in
    -i|--integration)
    INTEGRATION="$2"
    echo "> Following integration option was provided to the script: $INTEGRATION"
    shift # past argument
    continue;;
    *)
    break;;
  esac
done

# CocoaPods
if [[ "$INTEGRATION" = "cocoapods" ]]; then
  echo "> Starting to grab SDKs using CocoaPods integration."
  echo "> Running: bundle exec pod update"
  bundle exec pod update
  exit;
fi

# Carthage
if [[ "$INTEGRATION" = "carthage" ]]; then
  echo "> Starting to grab SDKs using Carthage integration."

  echo "> Running: carthage update --use-binaries"
  carthage update --use-binaries
  exit;
fi

# All integration types
if [[ -z "$INTEGRATION" ]]; then
  echo "> Integration option was not specified (eg: carthage, cocoapods or manual). Script will grab SDKs using all supported dependency managers."

  echo "> Integration: cocoapods"
  echo "> Running: bundle exec pod update"
  bundle exec pod update

  echo "> Running: carthage update --use-xcframeworks"
  carthage update --use-xcframeworks
fi
