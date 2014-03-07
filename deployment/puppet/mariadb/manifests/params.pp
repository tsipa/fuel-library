#
# This class contains the platform differences for keystone
#
class mariadb::params {
  $dba_passwd    = 'Eu57pxmYcjJfm24i'

  case $::osfamily {
    'Debian': {
      $config_path               = '/etc/mysql/conf.d'
      $packages                  = ['mariadb-galera-server', 'galera']
      $bootstrap_cluster_command = "nohup mysqld_safe --wsrep_cluster_address='gcomm://' > /dev/null &"
      $wsrep_provider            = '/usr/lib/galera/libgalera_smm.so'
    }
    'RedHat': {
      $config_path               = '/etc/my.cnf.d'
      $packages                  = ['MariaDB-Galera-server', 'MariaDB-client', 'galera']
      # $bootstrap_cluster_command = "/etc/init.d/mysql start --wsrep-cluster-address='gcomm://'"
      $bootstrap_cluster_command = '/sbin/service mysql bootstrap'
      $wsrep_provider            = '/usr/lib64/galera/libgalera_smm.so'
    }
    'Suse':  {
      $config_path               = '/etc/mysql'
      $packages                  = ['mariadb-galera-cluster', 'mariadb-galera-cluster-client', 'galera']
      $bootstrap_cluster_command = '/sbin/service mysql bootstrap'
      $wsrep_provider            = '/usr/lib64/mysql/plugin/libgalera_smm.so'

    }
  }
}
