#!/bin/bash
set -e

cd ../terraform

echo "[ROLLBACK] Restoring previous working version..."

terraform workspace select previous || terraform workspace new previous

terraform apply -auto-approve

echo "[DONE] Rollback completed!"
