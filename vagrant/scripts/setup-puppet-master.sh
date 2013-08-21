echo "192.168.2.11    puppet-agent.local" >> /etc/hosts

cp /vagrant/fileserver.conf /etc/puppet/fileserver.conf

apt-get update
apt-get install -y ceph-common

puppet master --mkusers --autosign true

for p in /secrets /secrets/shared
do
  mkdir -p "$p"
  chown -R puppet:puppet "$p"
done
