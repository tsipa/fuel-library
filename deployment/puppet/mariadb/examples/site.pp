#
# Configuration example

#
# Configuration variables
#

# cluster_nodes => (array) galera nodes list
# node_address  => (string) galera node ipaddress
# bind_address  => (string) ipaddress to bind to
# is_initiator  => (boolean) is primary controller or not

#
# The node definition
#
node /galera/ {

  class { 'mariadb':
     cluster_nodes => $galera_nodes,
     node_address  => $galera_node_address,
     bind_address  => $galera_node_address,
     is_initiator  => $primary_controller,
   }

}

