# Set this to the email address of a user who is in charge of the project.
# !
ADMINISTRATOR_EMAIL_ADDRESS=superuser@abtutor.com

# Host and port for your email server.
# This is currently configured for Mailhog, which is installed
# by the 0-dev script. For production, use your own email server.
# !
EMAIL_SMTP_HOST=mailhog
EMAIL_SMTP_PORT=1025
# If SMTP server needs authentication, set this to true, and provide user/pwd.
EMAIL_SMTP_AUTH=false
EMAIL_SMTP_USER=username
EMAIL_SMTP_PASSWORD=password

# Address and display name to use in emails that are sent by Keycloak
# (the From email address does not have to actually exist).
# !
EMAIL_KEYCLOAK_FROM_ADDRESS=noreply@abtutor.com
EMAIL_KEYCLOAK_DISPLAY_NAME="ABtutor User Authentication Services"

