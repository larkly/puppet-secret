echo "192.168.2.11    puppet-agent.local" >> /etc/hosts

mkdir -p /secrets
chown -R puppet:puppet /secrets

puppet master --mkusers --autosign true
