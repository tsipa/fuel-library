$fuel_settings = parseyaml($astute_settings_yaml)
$nodes_hash           = $::fuel_settings['nodes']
$controllers = merge_arrays(filter_nodes($nodes_hash,'role','primary-controller'), filter_nodes($nodes_hash,'role','controller'))
$node = filter_nodes($nodes_hash,'name',$::hostname)
$internal_address = $node[0]['internal_address']
$root_password = $fuel_settings['mysql']['root_password']

$galera_cluster_name      = 'openstack'
$enabled                  = true
$custom_mysql_setup_class = 'galera'


if $::fuel_settings['role'] == 'primary-controller' {
  $primary_controller = true
} else {
  $primary_controller = false
}


  class { 'mariadb':
     cluster_nodes => $controllers,
     node_address  => $internal_address,
     bind_address  => $internal_address,
     is_initiator  => $primary_controller,
     root_password => $root_password,
   }


#  class { 'mysql::server':
#    config_hash         => {
#      'bind_address' => '0.0.0.0'
#    }
#    ,
#    galera_cluster_name => $galera_cluster_name,
#    primary_controller  => $primary_controller,
#    galera_node_address => $internal_address,
#    enabled             => $enabled,
#    custom_setup_class  => $custom_mysql_setup_class,
#  }


