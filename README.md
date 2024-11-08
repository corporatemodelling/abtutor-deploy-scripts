# ABtutor Installation Scripts

Follow these steps in order to install the ABtutor solution.

## Fork this repo

First of all, make a fork of this repo, and keep your own **private** copy with your own customized files.

## Installing a pre-release

If you are installing a pre-release version (i.e. if any of the versions mentioned in `versions.sh` are `latest`, or are suffixed with `-alpha.*` or `-rc.*`), you will need to perform a couple of additional steps.

### Service account pull secrets

Customize your Kubernetes service account with `imagePullSecrets` that allow you to pull from the Corporate Modelling Services internal registry, located at `cr.corporatemodelling.com`.

1. If you do not already have one, contact CMS to obtain a deploy token.
2. Update the `imagePullSecrets` of your service account to use this token when accessing the `cr.corporatemodelling.com` registry (see commands below).

> If you don't have a specialized service account, use `default`.

```bash
# Create a new secret in Kubernetes, containing your deploy token
kubectl create secret docker-registry cms-deploy-secret --docker-server=cr.corporatemodelling.com --docker-username=username --docker-password=your_deploy_token

# If your service account currently does not contain any pull secrets ...
kubectl patch serviceaccount your_service_account --type "json" -p '[{"op": "add", "path": "/imagePullSecrets","value": [{"name": "cms-deploy-secret"}]}]'

# Otherwise ...
kubectl patch serviceaccount your_service_account --type "json" -p '[{"op": "add", "path": "/imagePullSecrets/-","value": {"name": "cms-deploy-secret"}}]'
```

### Helm registry login

You should also login to the Corporate Modelling internal registry via Helm:

```bash
# When prompted, enter the username and password (deploy token) that was provided to you.
helm registry login cr.corporatemodelling.com
```

## Variable scripts

Now customize the `__*.sh` files. These contain variables that are used by the installation scripts. Look for the `# !` markers, which indicate the variables that you most likely _should_ modify. Other values _can_ be modified, if you wish.

## Dev/test components

If installing a development or test environment, install `0-dev.sh` before anything else. This installs a Redis, a mock SMTP server, and a TLS/SSL certificate configured for your hostname.

> For a production environment, it is _up to you to provide these_.

> The installed SSL certificate is signed by an internal CMS certificate. Outside of CMS, it will be reported as "insecure".

## Mutating Webhooks

Install the `0-webhooks.sh` script before the main scripts.

Mutating webhooks affect a Kubernetes cluster globally, not just within the namespace that they are installed into. So, if these have already been installed (into _any_ namespace, even for a different product deployment), there is no need to install them again.

> The namespace that the webhooks are installed into is defined in `__k8s.sh`.

> Installing them again into the _same_ namespace will do no harm, but if you _have_ already installed them, but want to install them into a _different_ namespace, you **must** uninstall the previous instance first. Multiple webhooks performing the same mutations will most likely cause chaos.

## Database

If your cluster already has a CockroachDB database that you want to use, you should make additional modifications to `__cockroach.sh` to ensure that the follow-up scripts receive the correct values for `COCKROACHDB_ADMIN_USER_SSL_SECRET` and `COCKROACH_HOST`.

Otherwise, run `0-database.sh` to install an empty CockroachDB database cluster.

## Database schema

The database will need to be initialized with the schema.

However, if you intend to restore a backup of a database to work with, the backup will already contain the schema.

Otherwise, run `0-schema.sh` to install the database schema.

## Installing the ABtutor solution

Run `1-install.sh` to install the Keycloak IDP, the customized WebWFTL, the various webservices, and the network configurations.

> The `helm` commands have the `--wait` command-line option, which means that, where possible, they will wait until all installed services are running and reporting as healthy. Give these commands time to complete.
