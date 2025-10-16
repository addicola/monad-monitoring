#!/bin/sh

echo "Generating Alertmanager configuration..."
echo "ALERTMANAGER_DEFAULT_WEBHOOK_PORT=${ALERTMANAGER_DEFAULT_WEBHOOK_PORT}"

# Base configuration
cat <<EOF > /etc/alertmanager/alertmanager.yml
global:
  resolve_timeout: 5m

route:
  receiver: "default"
  group_wait: 10s
  group_interval: 5m
  repeat_interval: 3h
  routes:
EOF

# Add Discord Receiver if Webhook URL is Set
if [ -n "${DISCORD_WEBHOOK_URL}" ]; then
  echo "Adding Discord receiver..."
  cat <<EOF >> /etc/alertmanager/alertmanager.yml
    - receiver: "discord"
      continue: true
EOF
fi

# Receivers section
cat <<EOF >> /etc/alertmanager/alertmanager.yml
receivers:
  - name: "default"
    webhook_configs:
      - url: "http://localhost:${ALERTMANAGER_DEFAULT_WEBHOOK_PORT}"
EOF

# Add Discord Receiver if Webhook URL is Set
if [ -n "${DISCORD_WEBHOOK_URL}" ]; then
  echo "Adding Discord receiver..."
  cat <<EOF >> /etc/alertmanager/alertmanager.yml
  - name: "discord"
    discord_configs:
      - webhook_url: "${DISCORD_WEBHOOK_URL}"
        send_resolved: true
EOF
fi

echo "Alertmanager configuration generated successfully!"

# Start Alertmanager
exec /bin/alertmanager --config.file=/etc/alertmanager/alertmanager.yml "$@"
