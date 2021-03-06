node "base-system" {
  include base-hosts
  include base-sudoers
}

node "puppet-agent.local" inherits "base-system" {
  include secret-test
}

node "victim.local" inherits "base-system" {
  include secret-test
}

node "puppet-master.local" inherits "base-system" {
}
