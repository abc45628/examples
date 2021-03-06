#!/bin/bash


################################################################################
# Overview
################################################################################
#
# Delete Kafka cluster and environment if start.sh exited prematurely
#
################################################################################

# Source library
source ../../utils/helper.sh

ccloud::validate_version_ccloud_cli 1.7.0 || exit 1
ccloud::validate_logged_in_ccloud_cli || exit 1
check_timeout || exit 1
check_mvn || exit 1
check_expect || exit 1
check_jq || exit 1

ENVIRONMENT_NAME="demo-script-env"
ENVIRONMENT=$(ccloud environment list | grep $ENVIRONMENT_NAME | tr -d '\*' | awk '{print $1;}')
#echo "ENVIRONMENT: $ENVIRONMENT"
CLUSTER_NAME="demo-kafka-cluster"
CLUSTER=$(ccloud kafka cluster list | grep $CLUSTER_NAME | tr -d '\*' | awk '{print $1;}')
#echo "CLUSTER: $CLUSTER"
CLIENT_CONFIG="/tmp/client.config"

##################################################
# Cleanup
# - Delete the Kafka topics, Kafka cluster, environment, and the log files
##################################################

echo -e "\n# Cleanup: delete topics, kafka cluster, environment"
for t in $TOPIC1 $TOPIC2 $TOPIC3 connect-configs connect-offsets connect-status; do
  if ccloud kafka topic describe $t &>/dev/null; then
    echo "ccloud kafka topic delete $t"
    ccloud kafka topic delete $t
  fi
done

if [[ ! -z "$CLUSTER" ]]; then
  echo "ccloud kafka cluster delete $CLUSTER"
  ccloud kafka cluster delete $CLUSTER 1>/dev/null
fi

if [[ ! -z "$ENVIRONMENT" ]]; then
  echo "ccloud environment delete $ENVIRONMENT"
  ccloud environment delete $ENVIRONMENT 1>/dev/null
fi

rm -f "$CLIENT_CONFIG"
