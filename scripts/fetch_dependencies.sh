#!/usr/bin/env bash -e

# usage: ./scripts/fetch_dependencies.sh --integration=[integration] --version=[version]
#
# Available options: "cocoapods", "spm"

# parse arguments
INTEGRATION=""
VERSION_NUMBER=""

while [[ $# -gt 0 ]]
do
  case $1 in
    -i|--integration)
    INTEGRATION="$2"
    echo "> Following integration option was provided to the script: $INTEGRATION"
    shift 2;; # past argument
    -v|--version)
    VERSION_NUMBER="$2"
    echo "> Following version number was provided to the script: $VERSION_NUMBER"
    shift # past argument
    continue;;
    *)
    break;;
  esac
done

function updatePods {
  pod update --repo-update
}

function updateSPM {
  # Updates version of StreamChatUI package in related StreamChatIntegration-SPMxcode project
  sed -i '' -e "s|version =.*|version = '$VERSION_NUMBER';|g" StreamChatIntegration-SPM.xcodeproj/project.pbxproj
  bundle exec fastlane build_integration_app scheme:StreamChatIntegration-SPM
}

# CocoaPods
if [[ "$INTEGRATION" = "cocoapods" ]]; then
  echo "> Starting to grab SDKs using CocoaPods integration."
  echo "> Running: pod update --repo-update"
    updatePods
  exit;
fi

# SPM
if [[ "$INTEGRATION" = "spm" ]]; then
  echo "> Starting to grab SDKs using SwiftPM integration. Version: $VERSION_NUMBER"
  echo "> Running: bundle exec fastlane build_integration_app scheme:StreamChatIntegration-SPM"
    updateSPM
  exit;
fi

# Carthage
if [[ "$INTEGRATION" = "carthage" ]]; then
  echo "> Starting to grab SDKs using Carthage integration."

  echo "> ./scripts/carthage.sh build --use-xcframeworks --platform iOS"
  ./scripts/carthage.sh build --use-xcframeworks --platform iOS
  exit;
fi

# All integration types - can be leveraged for local - non CI purposes
if [[ -z "$INTEGRATION" ]]; then
  echo "> Integration option was not specified (eg: cocoapods or spm). Script will grab SDKs using all supported dependency managers."

  echo "> Integration: cocoapods"
  echo "> Running: pod update --repo-update"
  updatePods

  echo "> Integration: SwiftPM"
  echo "> Running: bundle exec fastlane build_integration_app scheme:StreamChatIntegration-SPM"
  updateSPM
   
fi
