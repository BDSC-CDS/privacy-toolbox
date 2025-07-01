#!/bin/bash

set -e

APP_VERSION="v0.1.6"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "######################################"
echo "Delete existing chart if already pulled:"
if [ -d "$SCRIPT_DIR/helm/privacy-toolbox-chart" ]; then
  echo "Removing existing chart directory: $SCRIPT_DIR/helm/privacy-toolbox-chart"
  rm -rf "$SCRIPT_DIR/helm/privacy-toolbox-chart"
else
  echo "No existing chart directory found."
fi

echo "######################################"
echo "Helm pull GHCR registry:"
helm pull oci://ghcr.io/bdsc-cds/charts/privacy-toolbox-chart --version $APP_VERSION --untar -d $SCRIPT_DIR/helm
echo "\n"

echo "######################################"
echo "Checking values.yaml file:"
VALUES_FILE="$SCRIPT_DIR/values.yaml"
if [ ! -f "$VALUES_FILE" ]; then
  echo "Values file not found: $VALUES_FILE"
  exit 1
fi
echo "\n"

echo "#######################################"
echo "Checking logo.png file:"
LOGO_FILE="$SCRIPT_DIR/logo.png"
if [ -f "$LOGO_FILE" ]; then
  echo "Logo file found: ./logo.png"
  BASE_64_LOGO_PATH=$(mktemp)
  cat $LOGO_FILE | base64 > $BASE_64_LOGO_PATH
else
  echo "No logo file found, proceeding without it."
fi
echo "\n"

echo "######################################"
echo "Update Helm dependencies for all subcharts:"
find . -name Chart.yaml -execdir helm dependency update \; # Required for sub-sub-subcharts to work properly.
echo "\n"

echo "######################################"
echo "Helm upgrade or install:"
helm upgrade --install privacy-toolbox $SCRIPT_DIR/helm/privacy-toolbox-chart \
  --version $APP_VERSION \
  --namespace "demo" \
  --create-namespace \
  -f $VALUES_FILE \
  --set-file frontend.config.logopngb64=$BASE_64_LOGO_PATH \
  --set backend.arx.postgresql.secrets.postgresPassword= # <Redacted> To be set during first deployment.