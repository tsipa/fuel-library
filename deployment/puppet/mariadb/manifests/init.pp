#
# package install maria-galera-server & galera(require wsrep_conf)
# configure file template (with nodes list) & inject base settings
# stop service if running
# bootstrap wsrep cluster
#

class mariadb (
  $cluster_nodes = ['127.0.0.1'],
  $node_address  = $::ipaddress_eth1,
  $bind_address  = '0.0.0.0',
  $listen_port   = '3307',
  $is_initiator  = false,
) {

  include mariadb::params

  $packages = $::mariadb::params::packages
  $wsrep_provider = $::mariadb::params::wsrep_provider
  $config_path = $::mariadb::params::config_path

  package { $packages:
    ensure => present,
  }

  File {
    require => Package[$packages],
    ensure  => present,
    owner   => 'root',
    group   => 'root',
    mode    => '0644',
  }

  Exec {
    path      => ['/usr/bin', '/bin'],
    logoutput => true,
  }

  # file { 'mysql_conf':
  #   path   => '/etc/mysql/my.cnf',
  #   source => "puppet:///modules/mariadb/my.cnf",
  # }

  file { 'wsrep_cluster_conf':
    path    => "${config_path}/mariadb.cnf",
    content => template('mariadb/mariadb.erb'),
  }

  if ($::osfamily == 'Debian') {
    file { 'debian_conf':
      path    => '/etc/mysql/debian.cnf',
      mode    => '0600',
      content => template("mariadb/debian.erb"),
      require => Service['mysql'],
    }
  }

  # $is_primaryhost = $::hostname ? {
  #   $cluster_nodes[0] => true,
  #   default           => false,
  # }

  if $is_initiator and str2bool($::bootstrap_wsrep_cluster) {
    # $service_ensure = 'stopped'
    $service_start = $::mariadb::params::bootstrap_cluster_command

    # exec { 'bootstrap_cluster':
    #   command => $::mariadb::params::bootstrap_cluster_command,
    #   require => [Service['mysql'], File['wsrep_cluster_conf']],
    # }

    if ($::osfamily == 'Debian') {
      exec { 'set_dba_passwd':
        command   => "/usr/bin/mysql -e \"SET PASSWORD FOR 'debian-sys-maint'@'localhost' = PASSWORD('${::mariadb::params::dba_passwd}');\"",
        # require   => Exec['bootstrap_cluster'],
        require   => Service['mysql'],
        before    => File['debian_conf'],
        tries     => 6,
        try_sleep => 5,
      }
    }
  } else {
    # $service_ensure = 'running'
    $service_start = undef

    File['wsrep_cluster_conf'] ~> Service['mysql']
  }

  # notify { "IS_PRIMARYHOST: ${is_primaryhost}": }
  # notify { "BOOTSTRAP_WSREP_CLUSTER: ${bootstrap_wsrep_cluster}": }
  # notify { "SERVICE_ENSURE: ${service_ensure}": }

  File['wsrep_cluster_conf'] -> Service['mysql'] -> Exec['activate_cluster_watcher']

  exec { 'activate_cluster_watcher':
    command   => "/usr/bin/mysql -e \"grant usage on *.* to 'cluster_watcher'@'%'; flush privileges;\"",
    unless    => "mysql -NBe \"select 1 from mysql.user where user = 'cluster_watcher'\" | grep -q 1",
    tries     => 6,
    try_sleep => 5,
  }

  service { 'mysql':
    # ensure     => $service_ensure,
    ensure     => 'running',
    #provider   => hiera('service_provider', undef),
    #provider   => undef,
    hasstatus  => true,
    hasrestart => true,
    start      => $service_start,
    # subscribe  => $service_ensure ? {
    #   'running' => File['wsrep_cluster_conf'],
    #   'stopped' => undef,
    # },
  }

}
