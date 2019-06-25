#!/bin/bash
set -e

# Upload the working directory to be built.
BRANCH=$(git symbolic-ref --short HEAD)-$USER;
SHA=$(git rev-parse --short HEAD)-$USER;
gcloud --project cockroach-dev-inf builds submit --substitutions=BRANCH_NAME=$BRANCH,SHORT_SHA=$SHA

# Patch the running configuration.
kubectl set image cronjob/repo-digest repo-digest=gcr.io/cockroach-dev-inf/cockroachlabs/repo-digest:$SHA

echo "Configuration pushed. Start a one-off job by running:"
echo "kubectl create job --from=cronjob/repo-digest repo-digest-$USER"
echo "kubectl delete job repo-digest-$USER"