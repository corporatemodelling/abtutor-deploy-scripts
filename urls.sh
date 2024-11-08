source ./versions.sh

# Helm/image registries
DOCKERHUB_REGISTRY=registry-1.docker.io
CMS_PUBLIC_REGISTRY=ghcr.io/corporatemodelling
CMS_PRIVATE_REGISTRY=cr.corporatemodelling.com

# Pre-release versions will come from the private registry.
getAppropriateRegistry () {
	if [[ "$1" =~ ^[0-9]+.[0-9]+.[0-9]+$ ]]; then
		echo $CMS_PUBLIC_REGISTRY
	else
		echo $CMS_PRIVATE_REGISTRY
	fi
}

# URLs for images and charts

# These ones always come from Docker Hub

REDIS_HELM_URL=oci://$DOCKERHUB_REGISTRY/bitnamicharts/redis
DERRER_HELM_URL=oci://$DOCKERHUB_REGISTRY/peeveen/derrer

# These ones might come from our public or private registry, depending on the version

COCKROACHDB_CLUSTER_HELM_REGISTRY=`getAppropriateRegistry $COCKROACHDB_CLUSTER_HELM_VERSION`
COCKROACHDB_CLUSTER_HELM_URL=oci://$COCKROACHDB_CLUSTER_HELM_REGISTRY/corporatemodelling/common/kubernetes/cockroachdb/cockroachdb-cluster

COCKROACHDB_SCHEMA_MIGRATION_HELM_REGISTRY=`getAppropriateRegistry $COCKROACHDB_SCHEMA_MIGRATION_HELM_VERSION`
COCKROACHDB_SCHEMA_MIGRATION_HELM_URL=oci://$COCKROACHDB_SCHEMA_MIGRATION_HELM_REGISTRY/corporatemodelling/abtutor-projects/database/migration

MASTER_INGRESS_HELM_REGISTRY=`getAppropriateRegistry $MASTER_INGRESS_HELM_VERSION`
MASTER_INGRESS_HELM_URL=oci://$MASTER_INGRESS_HELM_REGISTRY/corporatemodelling/common/kubernetes/master-ingress

KEYCLOAK_HELM_REGISTRY=`getAppropriateRegistry $KEYCLOAK_HELM_VERSION`
KEYCLOAK_HELM_URL=oci://$KEYCLOAK_HELM_REGISTRY/corporatemodelling/abtutor-projects/keycloak/keycloak

ABTUTOR_WEBWFTL_HELM_REGISTRY=`getAppropriateRegistry $ABTUTOR_WEBWFTL_HELM_VERSION`
ABTUTOR_WEBWFTL_HELM_URL=oci://$ABTUTOR_WEBWFTL_HELM_REGISTRY/corporatemodelling/abtutor-projects/abtutor-webwftl

AUTH_INJECTOR_HELM_REGISTRY=`getAppropriateRegistry $AUTH_INJECTOR_HELM_VERSION`
AUTH_INJECTOR_HELM_URL=oci://$AUTH_INJECTOR_HELM_REGISTRY/corporatemodelling/common/kubernetes/auth/auth-injector

