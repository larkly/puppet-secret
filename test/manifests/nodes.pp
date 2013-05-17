node "base-system" {
  include base-hosts
  include base-sudoers
}

node "puppet-agent.local" inherits "base-system" {
}

node "puppet-master.local" inherits "base-system" {
}
