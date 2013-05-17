echo "192.168.2.11    puppet-agent.local" >> /etc/hosts


puppet master --mkusers --autosign true

mkdir -p /secrets
chown -R puppet:puppet /secrets
