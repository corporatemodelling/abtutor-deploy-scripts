#!/bin/bash -x

# You should probably modify the contents of these files to suit.
source ./__hosts.sh
source ./__k8s.sh
source ./__cockroach.sh
source ./__secrets.sh
source ./__email.sh
source ./__xero.sh

# These ones, not so much.
source ./versions.sh
source ./urls.sh

set -e

# Install Keycloak
helm upgrade -i \
$KEYCLOAK_RELEASE_NAME \
-n $ABTUTOR_K8S_NAMESPACE \
--create-namespace \
--set serviceAccountName=$ABTUTOR_K8S_SERVICE_ACCOUNT \
--set registry.cmsPublicRegistry=$CMS_PUBLIC_REGISTRY \
--set keycloak.hostname=$ABTUTOR_HOST \
--set keycloak.httpRelativePath=$KEYCLOAK_INGRESS_RELATIVE_PATH \
--set keycloak.serviceAccount.name=$ABTUTOR_K8S_SERVICE_ACCOUNT \
--set keycloak.auth.adminPassword="$KEYCLOAK_ADMIN_PASSWORD" \
--set keycloak.postgresql.auth.password="$KEYCLOAK_POSTGRES_PASSWORD" \
--set keycloak.postgresql.auth.postgresPassword="$KEYCLOAK_POSTGRES_ADMIN_PASSWORD" \
--set client.oidc.secret=$KEYCLOAK_OIDC_CLIENT_SECRET \
--set client.admin.secret=$KEYCLOAK_ADMIN_CLIENT_SECRET \
--set userWebservice.image.tag=$KEYCLOAK_USER_WEBSERVICE_TAG \
--set userWebservice.database.host=$COCKROACHDB_HOST \
--set userWebservice.database.user=$COCKROACHDB_ADMIN_USER \
--set userWebservice.database.sslSecret=$COCKROACHDB_ADMIN_USER_SSL_SECRET \
--set userWebservice.database.name=$COCKROACHDB_DATABASE_NAME \
--set email.host=$EMAIL_SMTP_HOST \
--set email.port=$EMAIL_SMTP_PORT \
--set email.auth="$EMAIL_SMTP_AUTH" \
--set email.user="$EMAIL_SMTP_USER" \
--set email.password="$EMAIL_SMTP_PASSWORD" \
--set email.from.address=$EMAIL_KEYCLOAK_FROM_ADDRESS \
--set email.from.display="$EMAIL_KEYCLOAK_DISPLAY_NAME" \
--set keycloak.cmsInitContainer.registry=$CMS_PUBLIC_REGISTRY \
--set keycloak.cmsInitContainer.tag=$KEYCLOAK_INIT_CONTAINER_TAG \
--version $KEYCLOAK_HELM_VERSION \
$KEYCLOAK_HELM_URL \
--wait

# Enable Auth-Injector
kubectl label namespace $ABTUTOR_K8S_NAMESPACE corporatemodelling.com/auth-injector=enabled --overwrite

# Install WebWFTL and all supporting services
helm upgrade -i \
abtutor-webwftl \
-n $ABTUTOR_K8S_NAMESPACE \
--create-namespace \
--set registry.cmsPublicRegistry=$CMS_PUBLIC_REGISTRY \
--set database.host=$COCKROACHDB_HOST \
--set database.credentials.username=$COCKROACHDB_ADMIN_USER \
--set database.credentials.sslCerts=$COCKROACHDB_ADMIN_USER_SSL_SECRET \
--set ingress.host=$ABTUTOR_HOST \
--set serviceAccountName=$ABTUTOR_K8S_SERVICE_ACCOUNT \
--set api.signup.keycloak.adminClientId=admin-cli \
--set api.signup.keycloak.adminClientSecret=$KEYCLOAK_ADMIN_CLIENT_SECRET \
--set api.xero.clientId=$XERO_CLIENT_ID \
--set api.xero.clientSecret=$XERO_CLIENT_SECRET \
--set auth.oidc.clientId=abtutor-openid-connect \
--set auth.oidc.configurationUrl="http://${KEYCLOAK_RELEASE_NAME}.${ABTUTOR_K8S_NAMESPACE}.svc.cluster.local${KEYCLOAK_INGRESS_RELATIVE_PATH}realms/ABtutor/.well-known/openid-configuration" \
--set auth.oidc.clientSecretProviderBaseUri="http://${KEYCLOAK_RELEASE_NAME}-client-secret-provider.${ABTUTOR_K8S_NAMESPACE}.svc.cluster.local" \
--set auth.oidc.clientSecretId="ABtutor_{{clientId}}" \
--set redis.host=$REDIS_HOST \
--set redis.port=$REDIS_PORT \
--set redis.defaultDatabase=$REDIS_DEFAULT_DATABASE \
--set webwftl.image.tag=$WEBWFTL_TAG \
--set easyquery.image.tag=$EASYQUERY_TAG \
--set webforms.image.tag=$WEBFORMS_TAG \
--set ux.image.tag=$UX_TAG \
--set api.order.image.tag=$API_ORDER_TAG \
--set api.license.image.tag=$API_LICENSE_TAG \
--set api.businessAccount.image.tag=$API_BUSINESS_ACCOUNT_TAG \
--set api.product.image.tag=$API_PRODUCT_TAG \
--set api.accounts.image.tag=$API_ACCOUNTS_TAG \
--set api.xero.image.tag=$API_XERO_TAG \
--set api.signup.image.tag=$API_SIGNUP_TAG \
--set contentcreation.api.image.tag=$CONTENT_CREATION_API_TAG \
--set contentcreation.jsonmerge.image.tag=$CONTENT_CREATION_JSON_MERGE_TAG \
--set emails.templateservice.image.tag=$EMAIL_TEMPLATE_SERVICE_TAG \
--set emails.emailcomposer.image.tag=$EMAIL_COMPOSER_TAG \
$ABTUTOR_WEBWFTL_HELM_URL \
--version $ABTUTOR_WEBWFTL_HELM_VERSION \
--wait

# Install master ingress
helm upgrade -i \
abtutor-master-ingress \
-n $ABTUTOR_K8S_NAMESPACE \
--create-namespace \
--set host=$ABTUTOR_HOST \
--set tlsSecret=$ABTUTOR_K8S_TLS_SECRET_NAME \
$MASTER_INGRESS_HELM_URL \
--version $MASTER_INGRESS_HELM_VERSION \
--wait

# Prevent access to the client secret provider from anywhere
# other than the OpenID Connect service.
cat <<EOF | kubectl apply -f -
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: client-secret-provider-lockdown
  namespace: $ABTUTOR_K8S_NAMESPACE
spec:
  podSelector:
    matchLabels:
      app.kubernetes.io/name: keycloak-client-secret-provider
  ingress:
    - from:
        - namespaceSelector:
            matchLabels:
              name: $CMS_WEBHOOKS_NAMESPACE
        - podSelector:
            matchLabels:
              app.kubernetes.io/name: auth-injector-oidc-service
EOF

