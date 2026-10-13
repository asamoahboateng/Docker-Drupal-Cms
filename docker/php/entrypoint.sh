#!/bin/sh
set -e

# Write the msmtp config on every start, so changing .env + `docker compose up -d`
# is enough to switch between Mailpit and a real SMTP provider.
#
#   MAIL_TRANSPORT=mailpit  -> every mail is caught by Mailpit (testing)
#   MAIL_TRANSPORT=smtp     -> mails are really sent through SMTP_HOST

if [ "${MAIL_TRANSPORT:-mailpit}" = "smtp" ] && [ -z "${SMTP_HOST}" ]; then
  echo "WARNING: MAIL_TRANSPORT=smtp but SMTP_HOST is empty in .env, falling back to Mailpit." >&2
  MAIL_TRANSPORT=mailpit
fi

if [ "${MAIL_TRANSPORT:-mailpit}" = "smtp" ]; then
  host="${SMTP_HOST}"
  port="${SMTP_PORT:-587}"
  tls="${SMTP_TLS:-on}"
  starttls="${SMTP_STARTTLS:-on}"
  user="${SMTP_USER}"
  echo "Mail: sending for real via ${host}:${port}" >&2
else
  host=mailpit
  port=1025
  tls=off
  starttls=off
  user=
  echo "Mail: caught by Mailpit (set MAIL_TRANSPORT=smtp in .env to send for real)" >&2
fi

cat > /etc/msmtprc <<EOF
defaults
tls ${tls}
tls_starttls ${starttls}
tls_trust_file /etc/ssl/certs/ca-certificates.crt

account default
host ${host}
port ${port}
from ${SMTP_FROM:-noreply@example.com}
EOF

if [ -n "${user}" ]; then
  printf 'auth on\nuser %s\npassword %s\n' "${user}" "${SMTP_PASSWORD}" >> /etc/msmtprc
else
  echo 'auth off' >> /etc/msmtprc
fi

chown www-data:www-data /etc/msmtprc
chmod 600 /etc/msmtprc

exec docker-php-entrypoint "$@"
