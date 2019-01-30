plan profiles::init_config(TargetSpec $nodes){
  apply_prep($nodes)

  apply($nodes){

    package { 'rsyslog':
      ensure => present,
    }

    service { 'rsyslog':
      ensure  => 'running',
      enable  => 'true',
      require => Package['rsyslog'],
    }

    package { 'fail2ban':
      ensure => present,
    }

    service { 'fail2ban':
      ensure  => 'running',
      enable  => 'true',
      require => Package['fail2ban'],
    }

    group { "${lookup('deploy_group')}":
      ensure => 'present',
    }

    user { "${lookup('deploy_user')}":
      ensure => 'present',
      groups => "${lookup('deploy_group')}",
      managehome => true,
      home   => "/home/${lookup('deploy_user')}",
      shell  => '/bin/bash',
    }

    class { 'sudo': 
      purge               => false,
      config_file_replace => false,
    }

    sudo::conf { "${lookup('deploy_group')}":
      content  => "%${lookup('deploy_group')} ALL=(ALL) NOPASSWD: ALL",
    }

    ssh_authorized_key { "casadilla@casadilla":
      ensure => present,
      user   => "${lookup('deploy_user')}",
      type   => 'ssh-rsa',
      key    => "${lookup('deploy_key')}",
    }
  }
}
