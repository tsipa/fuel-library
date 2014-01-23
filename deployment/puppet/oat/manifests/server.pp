class oat::server (
  $server_password = 'password',
  $mysql_host = '127.0.0.1',
  $mysql_user = 'oat',
  $mysql_password = 'oat',
  $mysql_database = 'oat_db',
  $mysql_port = '3206',
) inherits oat::params {
  notify { "I an oat server with password ${server_password}" :} ->
  notify { "I will install ${oat::params::server_package}" :} ->
  notify { "And run service ${oat::params::server_service}" :}

  #package { $oat::params::server_package :
  # ensure => installed,
  #}

  $tomcat_dir = $oat::params::server_tomcat_dir
  $http_dir = $oat::params::server_http_dir
  $apps_dir = $oat::params::server_apps_dir
  $oat_function = $oat::params::server_oat_function
  $ip12file = $oat::params::server_ip12file
  $ipassfile = $oat::params::server_ipassfile
  $idomfile = $oat::params::server_idomfile
  $iloc = $oat::params::server_iloc
  $keystore = $oat::params::server_keystore
  $truststore = $oat::params::server_truststore
  $libdir = $oat::params::server_libdir
  $oat_port = $oat::params::server_oat_port
  $min_spare_threads = $oat::params::min_spare_threads
  $max_spare_threads = $oat::params::max_spare_threads
  $max_threads = $oat::params::max_threads

  package { $oat::params::server_package:
    ensure => present,
  }

  file { '/tmp/link_jars.sh' :
    ensure => present,
    owner  => 'root',
    mode => '0755',
    content => template('oat/link_jars.sh.erb'),
  }

  file { '/tmp/truststore.sh' :
    ensure => present,
    owner  => 'root',
    mode => '0755',
    content => template('oat/truststore.sh.erb'),
  }

  file { "${tomcat_dir}/conf/context.xml" :
    ensure => present,
    owner  => 'root',
    mode => '0644',
    content => template('oat/tomcat_context.xml.erb'),
  }

  file { "${tomcat_dir}/conf/server.xml" :
    ensure => present,
    owner  => 'root',
    mode => '0644',
    content => template('oat/tomcat_server.xml.erb'),
  }

  file { "${tomcat_dir}/webapps/HisWebServices/WEB-INF/classes/hibernateOat.cfg.xml" :
    ensure => present,
    owner  => 'root',
    mode => '0644',
    content => template('oat/hibernateOat.cfg.xml.erb'),
  }

  service { $oat::params::server_service :
    ensure => running,
    enabled => true,
  }

  mysql::db { $mysql_database :
    user => $mysql_user,
    password => $mysql_password,
    host => $mysql_host,
  }

  exec { 'import_db' :
    path => '/tmp/',
    command => "mysql -u ${mysql_user} -p${mysql_password} -h${mysql_host} -D ${mysql_database} < ${oat::params::server_db_sql}",
    unless => 'mysql -u ${mysql_user} -p${mysql_password} -h${mysql_host} -D ${mysql_database} "describe table alerts"',
  }

  exec { 'import_data' :
    path => '/tmp/',
    command => "mysql -u ${mysql_user} -p${mysql_password} -h${mysql_host} -D ${mysql_database} < ${oat::params::server_data_sql}",
    unless => 'mysql -u ${mysql_user} -p${mysql_password} -h${mysql_host} -D ${mysql_database} "describe table PCR_manifest"',
  }
  
  Mysql::Db[$mysql_database] -> Exec['import_db'] -> Exec['import_data']
  # -> Service[$oat::params::server_service]
  Package[$oat::params::server_package] -> File['/etc/oat.conf'] ~> Service[$oat::params::server_service]

}
