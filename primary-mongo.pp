$fuel_settings = parseyaml($astute_settings_yaml)
$ceilometer_hash = $::fuel_settings['ceilometer']
$nodes_hash           = $::fuel_settings['nodes']
$mongo_node = filter_nodes($nodes_hash,'role','mongo')

      class { 'openstack::mongo_primary':
        ceilometer_database         => 'ceilometer',
        ceilometer_metering_secret  => $ceilometer_hash['metering_secret'],
        ceilometer_db_password      => $ceilometer_hash['db_password'],
        ceilometer_replset_members  => [ $mongo_node[0]['internal_address'], $mongo_node[1]['internal_address'] ],
      }

