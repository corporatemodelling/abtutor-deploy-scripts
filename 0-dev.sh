#!/bin/bash -x

# You should probably modify the contents of these files to suit.
source ./__hosts.sh
source ./__k8s.sh

# These ones, not so much.
source ./urls.sh

set -e

# Add Helm repo (where Mailhog is found)
helm repo add codecentric https://codecentric.github.io/helm-charts

# Install Mailhog
helm upgrade -i \
mailhog \
-n $ABTUTOR_K8S_NAMESPACE \
--create-namespace \
--set ingress.enabled=true \
--set ingress.ingressClassName=nginx \
--set ingress.annotations."nginx\.org/mergeable-ingress-type"=minion \
--set ingress.hosts[0].host=$ABTUTOR_HOST \
--set ingress.hosts[0].paths[0].path=/mailhog \
--set ingress.hosts[0].paths[0].pathType=Prefix \
--set extraEnv[0].name=MH_UI_WEB_PATH \
--set extraEnv[0].value=mailhog \
codecentric/mailhog

# Create SSL/TLS cert
helm upgrade -i \
abtutor-ssl-cert-dev \
--set domain=$ABTUTOR_HOST \
oci://cr.corporatemodelling.com/corporatemodelling/development/kubernetes/dev-tls-cert

# Install Redis
helm upgrade -i \
redis \
-n $ABTUTOR_K8S_NAMESPACE \
--create-namespace \
--set auth.enabled="false" \
$REDIS_HELM_URL \
--wait
