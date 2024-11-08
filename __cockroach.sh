source ./__k8s.sh

# Name of CockroachDB database (to use or create)
COCKROACHDB_DATABASE_NAME=abtutor
# Name of CockroachDB schema (to use or create)
COCKROACHDB_SCHEMA_NAME=abtutor
# Name of database admin user (to use or create)
COCKROACHDB_ADMIN_USER=abtadmin
# Size of CockroachDB cluster (if creating).
# You can use 1 for testing (though, if you do, you may need to create your own PersistentVolumes)
# Production should use at least 3.
# 2 is not a valid value.
COCKROACHDB_CLUSTER_SIZE=3

# IF YOU ARE SUPPLYING YOUR OWN DATABASE, set these to the names
# of your CockroachDB service, and the Secret that contains the
# SSL auth certificates for the user identified by COCKROACHDB_ADMIN_USER.
# Otherwise, they are calculated from the above values.
COCKROACHDB_HOST="${COCKROACHDB_RELEASE_NAME}-public"
COCKROACHDB_ADMIN_USER_SSL_SECRET="${COCKROACHDB_RELEASE_NAME}-client-${COCKROACHDB_ADMIN_USER}"
