# Name of the K8S namespace that we are installing into.
# It will be created if it does not exist.
# !
ABTUTOR_K8S_NAMESPACE=abtutor
# Name of the K8S namespace that we are installing webhooks into.
# It will be created if it does not exist.
# !
CMS_WEBHOOKS_NAMESPACE=cms-webhooks
# Name of K8S service account to use. Use "default" if need be.
# !
ABTUTOR_K8S_SERVICE_ACCOUNT=default
# K8S secret that contains SSL/TLS certificates specifically for your host.
# At a minimum, secret should contain "tls.crt" and "tls.key"
# !
ABTUTOR_K8S_TLS_SECRET_NAME=abtutor-ssl-cert-dev-tls


# Name for the Keycloak Helm release
KEYCLOAK_RELEASE_NAME=abtutor-keycloak
# Name for the CockroachDB Helm release
COCKROACHDB_RELEASE_NAME=cockroachdb-cluster


# Ingress prefix for Keycloak.
# Ensure this starts AND ends with a "/"
KEYCLOAK_INGRESS_RELATIVE_PATH=/abtkeycloak/
