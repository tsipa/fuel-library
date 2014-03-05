$fuel_settings = parseyaml($astute_settings_yaml)
$ceilometer_hash = $::fuel_settings['ceilometer']
#$nodes_hash           = $::fuel_settings['nodes']
#$mongo_node = filter_nodes($nodes_hash,'role','mongo')

class { 'openstack::mongo_secondary':
}

