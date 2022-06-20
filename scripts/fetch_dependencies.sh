#!/usr/bin/env bash -e

# usage: ./scripts/fetch_dependencies.sh --integration [integration] --version [version]
#
# Available options: "cocoapods", "cocoapods-xc", "spm", "spm-xc", "carthage", "carthage-xc"

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

XC_FOLDER=XCIntegration

function updatePods {
  pod update
}

function updateXCPods {
  cd $XC_FOLDER
  pod update
  cd ..
}

function updateSPM {
  if [[ -z "$VERSION_NUMBER" ]]; then
     echo "VERSION argument was not passed (eg. -v 4.6.0). Skipping..."
     exit;
  fi
  
  # Updates version of StreamChatUI package in related StreamChatIntegration-SPM xcode project
  sed -i '' -e "s|version =.*|version = '$VERSION_NUMBER';|g" StreamChatIntegration-SPM.xcodeproj/project.pbxproj
  bundle exec fastlane build_oss_integration_app scheme:StreamChatIntegration-SPM

  # Updates version of StreamChatUI package in related StreamChatIntegration-SPM xcode project
  sed -i '' -e "s|version =.*|version = '$VERSION_NUMBER';|g" StreamChatIntegration-MultiBundle.xcodeproj/project.pbxproj
  bundle exec fastlane build_oss_integration_app scheme:StreamChatIntegration-MultiBundle
}

function updateXCSPM {
  if [[ -z "$VERSION_NUMBER" ]]; then
     echo "VERSION argument was not passed (eg. -v 4.6.0). Skipping..."
     exit;
  fi
  
  cd $XC_FOLDER
  
  # Updates version of StreamChatUI package in related StreamChatIntegration--XC-SPM xcode project
  sed -i '' -e "s|version =.*|version = '$VERSION_NUMBER';|g" StreamChatIntegration-XC-SPM.xcodeproj/project.pbxproj
  bundle exec fastlane build_xc_integration_app scheme:StreamChatIntegration-XC-SPM
  
  cd ..
}

function updateCarthage {
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

# SPM
if [[ "$INTEGRATION" = "spm" ]]; then
  echo "> Grabbing SDKs using SwiftPM integration. Version: $VERSION_NUMBER"
  echo "> Running: bundle exec fastlane build_integration_app scheme:StreamChatIntegration-SPM"
  updateSPM
  exit;
fi

# SPM XCFrameworks
if [[ "$INTEGRATION" = "spm-xc" ]]; then
  echo "> Starting to grab SDKs using SwiftPM integration. Version: $VERSION_NUMBER"
  echo "> Running: bundle exec fastlane build_integration_app scheme:StreamChatIntegration-XC-SPM"
  updateXCSPM
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

  echo "> Integration: SwiftPM"
  echo "> Running: bundle exec fastlane build_oss_integration_app scheme:StreamChatIntegration-SPM"
  updateSPM

  echo "> Integration: SwiftPM (XCFramework)"
  echo "> Running: bundle exec fastlane build_xc_integration_app scheme:StreamChatIntegration-XC-SPM"
  updateXCSPM

  echo "> Integration: Carthage"
  echo "> Running: carthage update --use-xcframeworks --no-use-binaries --platform iOS"
  updateCarthage

  echo "> Integration: Carthage (XCFramework)"
  echo "> Running: carthage update --use-xcframeworks"
  updateXCCarthage
fi
