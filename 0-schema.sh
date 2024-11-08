#!/bin/bash -x

# You should probably modify the contents of these files to suit.
source ./__hosts.sh
source ./__k8s.sh
source ./__cockroach.sh
source ./__email.sh

# These ones, not so much.
source ./versions.sh
source ./urls.sh

set -e

# Install database schema
helm upgrade -i \
"${COCKROACHDB_RELEASE_NAME}-migration" \
-n $ABTUTOR_K8S_NAMESPACE \
--create-namespace \
--set serviceAccountName=$ABTUTOR_K8S_SERVICE_ACCOUNT \
--set database.name=$COCKROACHDB_DATABASE_NAME \
--set database.service=$COCKROACHDB_HOST \
--set database.credentials.user=$COCKROACHDB_ADMIN_USER \
--set database.credentials.sslSecret=$COCKROACHDB_ADMIN_USER_SSL_SECRET \
--set migration.placeholders.adminEmail="$ADMINISTRATOR_EMAIL_ADDRESS" \
--set migration.image.tag=$COCKROACHDB_MIGRATION_TAG \
--version $COCKROACHDB_SCHEMA_MIGRATION_HELM_VERSION \
$COCKROACHDB_SCHEMA_MIGRATION_HELM_URL \
--wait

