#!/bin/bash -x

# You should probably modify the contents of these files to suit.
source ./__k8s.sh
source ./__hosts.sh

# These ones, not so much.
source ./versions.sh
source ./urls.sh

set -e

# Install Derrer
helm upgrade -i derrer \
-n $CMS_WEBHOOKS_NAMESPACE \
--create-namespace \
--set serviceAccountName=$ABTUTOR_SERVICE_ACCOUNT \
$DERRER_HELM_URL \
--version $DERRER_HELM_VERSION \
--wait

ESCAPED_ABTUTOR_HOST=`echo $ABTUTOR_HOST | sed "s/\./\\\\\./g"`

# Install Auth-Injector
helm upgrade -i \
auth-injector \
--create-namespace \
-n $CMS_WEBHOOKS_NAMESPACE \
--set serviceAccount.name=$ABTUTOR_K8S_SERVICE_ACCOUNT \
--set auth.oidc.ingress.hosts."$ESCAPED_ABTUTOR_HOST"=not-used \
--set auth.oidc.service.image.tag=$AUTH_INJECTOR_OIDC_SERVICE_TAG \
--set auth.proxy.image.tag=$AUTH_INJECTOR_AUTH_PROXY_TAG \
--set registry.cmsPublicRegistry=$CMS_PUBLIC_REGISTRY \
--version $AUTH_INJECTOR_HELM_VERSION \
$AUTH_INJECTOR_HELM_URL \
--wait


