# Once you have created values for these secrets, KEEP THEM SOMEWHERE VERY SECURE!!
# If you are running these scripts again (e.g. upgrading some services), then the
# secrets/passwords should be the SAME as the previous run. Changing them between
# runs will probably cause problems.

# Keycloak client secrets. Create some random strings that are unknown to anyone else, and cannot be guessed.
# !
KEYCLOAK_OIDC_CLIENT_SECRET=CreateAUniqueAndRandomStringOfCharactersAndNumbersHere12345
KEYCLOAK_ADMIN_CLIENT_SECRET=CreateAnotherUniqueAndRandomStringOfCharactersAndNumbersHere12345
# Alternatively, describe existing secrets where these values can be found.
# If the *_SECRET_NAME value is defined, the explicit values above are not used.
# You can define what namespace they are in (if blank, ABTUTOR_K8S_NAMESPACE will be used)
# You can define what key the secret is defined in (if blank, "secret" will be used)
KEYCLOAK_OIDC_CLIENT_SECRET_NAME=""
KEYCLOAK_OIDC_CLIENT_SECRET_NAMESPACE=""
KEYCLOAK_OIDC_CLIENT_SECRET_KEY=""
KEYCLOAK_ADMIN_CLIENT_SECRET_NAME=""
KEYCLOAK_ADMIN_CLIENT_SECRET_NAMESPACE=""
KEYCLOAK_ADMIN_CLIENT_SECRET_KEY=""

# Keycloak passwords. Create unique passwords for:
# - the Keycloak "admin" user
# - the Postgres database "bn_keycloak" user (owner of the "bitnami_keycloak" database).
# - the Postgres database "postgres" admin user
# !
KEYCLOAK_ADMIN_PASSWORD=CreateAPassword1!
KEYCLOAK_POSTGRES_PASSWORD=CreateAPassword2!
KEYCLOAK_POSTGRES_ADMIN_PASSWORD=CreateAPassword3!
# Alternatively, describe existing secrets where these values can be found.
# If the *_SECRET_NAME value is defined, the explicit values above are not used.
# The Keycloak chart does not allow a different namespace to be defined.
# You can define what key the secret is defined in (the default for
# KEYCLOAK_ADMIN_PASSWORD_SECRET_KEY is "admin-password", and the default for
# KEYCLOAK_POSTGRES_PASSWORD_SECRET_KEY is "password").
# NOTE: you cannot define a separate secret or key for the Postgres admin user password.
# If KEYCLOAK_POSTGRES_PASSWORD_SECRET_NAME is defined, it will be used as the secret,
# but the Postgres admin user password MUST be defined in a key called "postgres-password"
KEYCLOAK_ADMIN_PASSWORD_SECRET_NAME=""
KEYCLOAK_ADMIN_PASSWORD_SECRET_KEY=""
KEYCLOAK_POSTGRES_PASSWORD_SECRET_NAME=""
KEYCLOAK_POSTGRES_PASSWORD_SECRET_KEY=""

# reCAPTCHA secrets. Obtain these from Google if required.
# If you don't define a site key, reCAPTCHA will not be enabled.
# !
RECAPTCHA_SITE_KEY=
if [[ -z $RECAPTCHA_SITE_KEY ]]; then
RECAPTCHA_ENABLED=false
else
RECAPTCHA_ENABLED=true
fi
RECAPTCHA_SITE_SECRET=your_site_secret_here
# Alternatively, describe an existing secret where the secret value can be found.
# If the *_SECRET_NAME value is defined, the explicit value above is not used.
# You can define what namespace it is in (if blank, ABTUTOR_K8S_NAMESPACE will be used)
# You can define what key the secret is defined in (if blank, "secret" will be used)
RECAPTCHA_SITE_SECRET_NAME=""
RECAPTCHA_SITE_SECRET_NAMESPACE=""
RECAPTCHA_SITE_SECRET_KEY=""