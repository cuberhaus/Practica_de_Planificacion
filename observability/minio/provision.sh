#!/bin/sh
# Idempotent MinIO bucket provisioner.
#
# Normally executed by the `minio-init` service in docker-compose.obs.yml on
# first bring-up. This standalone copy exists so it can be run by hand
# against a different S3 endpoint, e.g. a fresh Hetzner Object Storage
# project, without rebuilding the container.
#
# Usage:
#   S3_ENDPOINT=https://nbg1.your-objectstorage.com \
#   S3_ACCESS_KEY=xxx \
#   S3_SECRET_KEY=yyy \
#   ./provision.sh
#
# Requires the `mc` (minio client) binary on PATH.

set -eu

: "${S3_ENDPOINT:?S3_ENDPOINT must be set, e.g. http://minio:9000}"
: "${S3_ACCESS_KEY:?S3_ACCESS_KEY must be set}"
: "${S3_SECRET_KEY:?S3_SECRET_KEY must be set}"

# Normalise the endpoint — `mc alias set` wants a scheme.
case "$S3_ENDPOINT" in
  http://*|https://*) S3_URL="$S3_ENDPOINT" ;;
  *) S3_URL="http://$S3_ENDPOINT" ;;
esac

mc alias set local "$S3_URL" "$S3_ACCESS_KEY" "$S3_SECRET_KEY"

for bucket in obs-tempo obs-loki obs-mimir obs-pyroscope; do
  mc mb --ignore-existing "local/$bucket"
  printf 'bucket %s ready\n' "$bucket"
done

printf 'all observability buckets provisioned\n'
