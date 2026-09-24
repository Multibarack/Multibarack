#!/usr/bin/env bash
set -euo pipefail

CLUSTER_NAME="platform-lab"

kind delete cluster --name "$CLUSTER_NAME"
