#!/bin/bash -x

# You should probably modify the contents of these files to suit.
source ./__hosts.sh
source ./__k8s.sh
source ./__cockroach.sh
source ./__secrets.sh
source ./__email.sh

# These ones, not so much.
source ./versions.sh
source ./urls.sh

set -e

# Install the CockroachDB custom resource definitions and operator webhooks
kubectl apply -f https://raw.githubusercontent.com/cockroachdb/cockroach-operator/master/install/crds.yaml
kubectl apply -f https://raw.githubusercontent.com/cockroachdb/cockroach-operator/master/install/operator.yaml

# Install CockroachDB
helm upgrade -i \
$COCKROACHDB_RELEASE_NAME \
-n $ABTUTOR_K8S_NAMESPACE \
--create-namespace \
--set "additionalUsers[0].name=$COCKROACHDB_ADMIN_USER" \
--set "cockroachVersion=$COCKROACHDB_VERSION" \
--set "init.sql[0].commands=CREATE DATABASE IF NOT EXISTS $COCKROACHDB_DATABASE_NAME; \
USE $COCKROACHDB_DATABASE_NAME; \
CREATE SCHEMA IF NOT EXISTS $COCKROACHDB_SCHEMA_NAME; \
GRANT ALL ON DATABASE $COCKROACHDB_DATABASE_NAME TO $COCKROACHDB_ADMIN_USER; \
GRANT ALL ON SCHEMA $COCKROACHDB_SCHEMA_NAME TO $COCKROACHDB_ADMIN_USER; \
GRANT ALL ON ALL TABLES IN SCHEMA $COCKROACHDB_SCHEMA_NAME TO $COCKROACHDB_ADMIN_USER; \
ALTER DEFAULT PRIVILEGES IN SCHEMA $COCKROACHDB_SCHEMA_NAME GRANT ALL PRIVILEGES ON TABLES TO $COCKROACHDB_ADMIN_USER;" \
--set clusterSize=$COCKROACHDB_CLUSTER_SIZE \
--version $COCKROACHDB_CLUSTER_HELM_VERSION \
$COCKROACHDB_CLUSTER_HELM_URL \
--wait

