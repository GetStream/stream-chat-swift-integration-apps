#!/usr/bin/env bash

# usage: ./scripts/fetch_dependencies.sh [integration]
#
# Available options: "cocoapods", "cocoapods-xc", "spm", "spm-xc", "carthage", "carthage-xc"

INTEGRATION="$1"
XC_FOLDER=XCIntegration

function updatePods {
  pod update
}

function updateXCPods {
  cd $XC_FOLDER
  pod update
  cd ..
}

function updateCarthage {
  rm -rf Carthage/Build
  rm -rf Carthage/Checkouts
  carthage update --use-xcframeworks --no-use-binaries --platform iOS
}

function updateXCCarthage {
  cd $XC_FOLDER
  carthage update --use-xcframeworks
  cd ..
}

# CocoaPods
if [[ "$INTEGRATION" = "cocoapods" ]]; then
  echo "> Grabbing SDKs using CocoaPods integration."
  echo "> Running: pod update"
  updatePods
  exit;
fi

# CocoaPods XCFrameworks
if [[ "$INTEGRATION" = "cocoapods-xc" ]]; then
  echo "> Starting to grab SDKs using CocoaPods integration."
  echo "> Running: pod update"
  updateXCPods
  exit;
fi

# Carthage
if [[ "$INTEGRATION" = "carthage" ]]; then
  echo "> Grabbing SDKs using Carthage integration."
  echo "> Running: carthage update --use-xcframeworks --no-use-binaries --platform iOS"
  updateCarthage
  exit;
fi

# Carthage XCFrameworks
if [[ "$INTEGRATION" = "carthage-xc" ]]; then
  echo "> Starting to grab SDKs using Carthage integration."
  echo "> carthage update --use-xcframeworks"
  updateXCCarthage
  exit;
fi

# All integration types - can be leveraged for local - non CI purposes
if [[ -z "$INTEGRATION" ]]; then
  echo "> Integration option was not specified (eg: cocoapods or spm). Script will grab SDKs using all supported dependency managers."

  echo "> Integration: cocoapods"
  echo "> Running: pod update"
  updatePods

  echo "> Integration: cocoapods (XCFramework)"
  echo "> Running: pod update in Pods-XC"
  updateXCPods

  echo "> Integration: Carthage"
  echo "> Running: carthage update --use-xcframeworks --no-use-binaries --platform iOS"
  updateCarthage

  echo "> Integration: Carthage (XCFramework)"
  echo "> Running: carthage update --use-xcframeworks"
  updateXCCarthage
fi
