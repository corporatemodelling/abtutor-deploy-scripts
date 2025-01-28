#!/bin/bash -x

# You should probably modify the contents of these files to suit.
source ./__hosts.sh
source ./__k8s.sh
source ./__cockroach.sh
source ./__keycloak.sh
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
--set keycloak.auth.existingSecret="$KEYCLOAK_ADMIN_PASSWORD_SECRET_NAME" \
--set keycloak.auth.passwordSecretKey="$KEYCLOAK_ADMIN_PASSWORD_SECRET_KEY" \
--set keycloak.postgresql.auth.password="$KEYCLOAK_POSTGRES_PASSWORD" \
--set keycloak.postgresql.auth.postgresPassword="$KEYCLOAK_POSTGRES_ADMIN_PASSWORD" \
--set keycloak.postgresql.auth.existingSecret="$KEYCLOAK_POSTGRES_PASSWORD_SECRET_NAME" \
--set keycloak.postgresql.auth.secretKeys.userPasswordKey="$KEYCLOAK_POSTGRES_PASSWORD_SECRET_KEY" \
--set client.oidc.secret="$KEYCLOAK_OIDC_CLIENT_SECRET" \
--set client.oidc.existingSecret.name="$KEYCLOAK_OIDC_CLIENT_SECRET_NAME" \
--set client.oidc.existingSecret.namespace="$KEYCLOAK_OIDC_CLIENT_SECRET_NAMESPACE" \
--set client.oidc.existingSecret.key="$KEYCLOAK_OIDC_CLIENT_SECRET_KEY" \
--set client.admin.secret="$KEYCLOAK_ADMIN_CLIENT_SECRET" \
--set client.admin.existingSecret.name="$KEYCLOAK_ADMIN_CLIENT_SECRET_NAME" \
--set client.admin.existingSecret.namespace="$KEYCLOAK_ADMIN_CLIENT_SECRET_NAMESPACE" \
--set client.admin.existingSecret.key="$KEYCLOAK_ADMIN_CLIENT_SECRET_KEY" \
--set reCAPTCHA.enabled=$RECAPTCHA_ENABLED \
--set reCAPTCHA.siteKey="$RECAPTCHA_SITE_KEY" \
--set reCAPTCHA.secret="$RECAPTCHA_SITE_SECRET" \
--set reCAPTCHA.existingSecret.name="$RECAPTCHA_SITE_SECRET_NAME" \
--set reCAPTCHA.existingSecret.namespace="$RECAPTCHA_SITE_SECRET_NAMESPACE" \
--set reCAPTCHA.existingSecret.key="$RECAPTCHA_SITE_SECRET_KEY" \
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
--set email.existingSecret.name="$EMAIL_SMTP_PASSWORD_SECRET_NAME" \
--set email.existingSecret.namespace="$EMAIL_SMTP_PASSWORD_SECRET_NAMESPACE" \
--set email.existingSecret.key="$EMAIL_SMTP_PASSWORD_SECRET_KEY" \
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
--set api.signup.keycloak.existingSecret.name=$KEYCLOAK_ADMIN_CLIENT_SECRET_NAME \
--set api.signup.keycloak.existingSecret.namespace=$KEYCLOAK_ADMIN_CLIENT_SECRET_NAMESPACE \
--set api.signup.keycloak.existingSecret.key=$KEYCLOAK_ADMIN_CLIENT_SECRET_KEY \
--set api.xero.clientId=$XERO_CLIENT_ID \
--set api.xero.clientSecret=$XERO_CLIENT_SECRET \
--set api.xero.existingSecret.name=$XERO_CLIENT_SECRET_NAME \
--set api.xero.existingSecret.namespace=$XERO_CLIENT_SECRET_NAMESPACE \
--set api.xero.existingSecret.key=$XERO_CLIENT_SECRET_KEY \
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
--set api.adduser.image.tag=$API_ADDUSER_TAG \
--set api.batchinvoice.image.tag=$API_BATCHINVOICE_TAG \
--set api.payment.image.tag=$API_PAYMENT_TAG \
--set api.renewalinitiator.image.tag=$API_RENEWALINITIATOR_TAG \
--set api.renewalorder.image.tag=$API_RENEWALORDER_TAG \
--set api.renewalsendreminder.image.tag=$API_RENEWALSENDREMINDER_TAG \
--set api.renewalconverttoinvoice.image.tag=$API_RENEWALCONVERTTOINVOICE_TAG \
--set api.renewalaccount.image.tag=$API_RENEWALACCOUNT_TAG \
--set api.renewalxerocheck.image.tag=$API_RENEWALXEROCHECK_TAG \
--set api.renewallicence.image.tag=$API_RENEWALLICENCE_TAG \
--set api.renewalsendinvoice.image.tag=$API_RENEWALSENDINVOICE_TAG \
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

