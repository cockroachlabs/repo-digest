#!/bin/bash
# Adapted from cron_github_digest.sh on the old shared host.

set -exo pipefail

export MAILTO="cockroachdb-github@googlegroups.com,eng@cockroachlabs.com"
REPOS="cockroachdb/cockroach,cockroachdb/cockroach-prod,cockroachdb/docs,cockroachdb/rpc-bench,cockroachdb/examples-go,cockroachlabs/managed-service"

run_timestamp=$(date  +"%Y-%m-%d-%H:%M:%S")

LOGS_BASE="/data/logs/digest/"
LOGS="${LOGS_BASE}/${run_timestamp}"
LATEST_FILE="${LOGS_BASE}/latest"
mkdir -p ${LOGS}

if [ -f ${LATEST_FILE} ]; then
  since=$(egrep "^nextsince:" ${LATEST_FILE} | awk '{print $2}')
else
  since=""
fi
sinceflag=""
if [ -n "${since}" ]; then
  sinceflag="-s ${since}"
fi

repo-digest \
  -t $(cat /secrets/github-issue-token) \
  --repos=${REPOS} \
  -o ${LOGS} \
  -p /cockroachdb.template ${sinceflag} \
  > ${LOGS}/stdout \
  2> ${LOGS}/stderr

digest_file=$(egrep -w "^digest:" ${LOGS}/stdout | awk '{print $2}')
since_value=$(egrep -w "^nextsince:" ${LOGS}/stdout | awk '{print $2}')
if [ -z "${since_value}" ]; then
  exit 1
fi
cp ${LOGS}/stdout ${LATEST_FILE}
pretty_since=$(egrep "^prettysince:" ${LATEST_FILE} | cut -d':' -f2-)

cat << EOF > /tmp/mail
To: $MAILTO
From: Marvin<robot+digest@cockroachlabs.com>
MIME-Version: 1.0
Content-Type: text/html; charset=utf-8
Subject: cockroachdb digest since ${pretty_since}

EOF
sed 's/\.svg/.png/g' ${digest_file} >> /tmp/mail

ssmtp -t < /tmp/mail

