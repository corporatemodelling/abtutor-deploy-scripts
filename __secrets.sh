# Once you have created values for these secrets, KEEP THEM SOMEWHERE VERY SECURE!!
# If you are running these scripts again (e.g. upgrading some services), then the
# secrets/passwords should be the SAME as the previous run. Changing them between
# runs will probably cause problems.

# Keycloak client secrets. Create some random strings that are unknown to anyone else, and cannot be guessed.
# !
KEYCLOAK_OIDC_CLIENT_SECRET=CreateAUniqueAndRandomStringOfCharactersAndNumbersHere12345
KEYCLOAK_ADMIN_CLIENT_SECRET=CreateAnotherUniqueAndRandomStringOfCharactersAndNumbersHere12345

# Keycloak passwords. Create unique passwords for:
# - the Keycloak "admin" user
# - the Postgres database "bn_keycloak" user (owner of the "bitnami_keycloak" database).
# - the Postgres database "postgres" admin user
# !
KEYCLOAK_ADMIN_PASSWORD=CreateAPassword1!
KEYCLOAK_POSTGRES_PASSWORD=CreateAPassword2!
KEYCLOAK_POSTGRES_ADMIN_PASSWORD=CreateAPassword3!

