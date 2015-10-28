
default['home-lab']['user'] = 'nathwill'
default['postfix']['main']['smtpd_use_tls'] = 'no'
default['ifcfg']['default_if'] = 'enp3s0'

default['authorization']['sudo'].tap do |sudo|
  sudo['users'] = Array(node['home-lab']['user'])
  sudo['passwordless'] = true
end

default['systemd'].tap do |sd|
  sd['hostname'] = 'valhalla.home.nathwill.net'
  sd['locale'].tap do |loc|
    loc['lang'] = 'en_US.UTF-8'
    loc['lc_messages'] = 'en_US.UTF-8'
  end
end

default['openssh']['server'].tap do |ssh|
  ssh['permit_root_login'] = 'no'
  ssh['password_authentication'] = 'no'
end
