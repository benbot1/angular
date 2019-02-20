#!/usr/bin/env bash

set -eux -o pipefail
readonly pwd=$(pwd)

function testBazel() {
  # Set up
  bazel version
  ng version
  rm -rf demo
  # Create project
  ng new demo --collection=@angular/bazel --defaults --skip-git --skip-install --style=scss
  cd demo
  cp ../package.json.replace ./package.json
  sed -i "s#file:../angular#${pwd}/../..#" ./package.json
  yarn
  yarn webdriver-manager update --gecko=false --standalone=false $CI_CHROMEDRIVER_VERSION_ARG
  ng generate component widget --style=css
  ng build
  ng test
  ng e2e
}

function testNonBazel() {
  # Replace angular.json that uses Bazel builder with the default generated by CLI
  mv ./angular.json.bak ./angular.json
  mv ./tsconfig.json.bak ./tsconfig.json
  rm -rf dist src/main.dev.ts src/main.prod.ts
  sed -i 's/"es5BrowserSupport": true//' angular.json
  ng build --progress=false
  ng test --progress=false --watch=false
  ng e2e --configuration=production --webdriver-update=false
}

testBazel
testNonBazel
