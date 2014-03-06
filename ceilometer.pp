$fuel_settings = parseyaml($astute_settings_yaml)
$keystone_hash        = $::fuel_settings['keystone']
$mysql_hash           = $::fuel_settings['mysql']
$access_hash          = $::fuel_settings['access']
$rabbit_hash          = $::fuel_settings['rabbit']


$ceilometer_hash = $::fuel_settings['ceilometer']
$nodes_hash           = $::fuel_settings['nodes']
$mongo_node = filter_nodes($nodes_hash,'role','primary-mongo')
$controller_internal = $mongo_node[0]['internal_address']
$controller_public = $mongo_node[0]['public_address']


$openstack_version = {
  'ceilometer'     => 'latest',
}


#$keystone_db_user = 'keystone'

Class['openstack::db::mysql'] -> Class['openstack::keystone']
Class['openstack::db::mysql'] -> Class['openstack::ceilometer']
Class['nova::rabbitmq'] -> Class['openstack::ceilometer']

if !$rabbit_hash['user'] {
    $rabbit_hash['user'] = 'nova'
}
$rabbit_user = $rabbit_hash['user']


group { "nova":
    ensure => "present",
}

      class { 'nova::rabbitmq':
        userid                 => $rabbit_hash[user],
        password               => $rabbit_hash[password],
        enabled                => true,
        cluster                => false,
        cluster_nodes          => [$controller_internal], #Real node names to install RabbitMQ server onto
        rabbit_node_ip_address => undef,
        port                   => '5672',
      }


    class { 'openstack::db::mysql':
      mysql_root_password     => $mysql_hash[root_password],
      mysql_bind_address      => '0.0.0.0',
      mysql_account_security  => true,
      keystone_db_user        => 'keystone',
      keystone_db_dbname      => 'keystone',
      keystone_db_password    => $keystone_hash[db_password],
      allowed_hosts           => [ '%', $::hostname ],
      enabled                 => true,
      cinder_db_password      => None,
      ceilometer_db_password  => None,
      neutron_db_password     => None,
      nova_db_password        => None,
      glance_db_password      => None,
    }

  class { 'openstack::keystone':
    verbose               => false,
    debug                 => false,
    db_type               => 'mysql',
    db_host               => $controller_internal,
    db_password           => $keystone_hash[db_password],
    db_user      => 'keystone',
    db_name    => 'keystone',
    admin_token           => $keystone_hash[admin_token],
    admin_tenant          => $access_hash[tenant],
    admin_email           => $access_hash[email],
    admin_user            => $access_hash[user],
    admin_password        => $access_hash[password],
    public_address        => $controller_internal,
    internal_address      => $controller_public,
    admin_address         => $controller_internal,
    glance_user_password  => 'None',
    nova_user_password    => 'None',
    cinder                => false,
    cinder_user_password  => 'None',
    quantum               => false,
    ceilometer                => $ceilometer_hash[enabled],
    ceilometer_user_password  => $ceilometer_hash[user_password],
    bind_host             => '0.0.0.0',
    enabled               => true,
    package_ensure        => $::openstack_keystone_version,
    use_syslog            => false,
  }




    class { 'openstack::ceilometer':
      verbose              => false,
      debug                => false,
      use_syslog           => false,
      db_type              => 'mongodb',
      db_host              => $controller_internal,
      db_user              => 'ceilometer',
      db_password          => $ceilometer_hash[db_password],
      db_dbname            => 'ceilometer',
      metering_secret      => $ceilometer_hash[metering_secret],
      #package_ensure       => $::openstack_version['ceilometer'],
      amqp_password        => $rabbit_hash[password],
      amqp_user            => $rabbit_hash[user],
      amqp_hosts           => $controller_internal,
      #rabbit_ha_virtual_ip => false,
      queue_provider       => 'rabbitmq',
      #qpid_password        => $rabbit_hash[password],
      #qpid_userid          => $rabbit_hash[user],
      #qpid_nodes           => $controller_internal,
      keystone_host        => $controller_internal,
      keystone_password    => $ceilometer_hash[user_password],
      bind_host            => '0.0.0.0',
      ha_mode              => false,
      on_controller        => true,
    }

