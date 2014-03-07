This is a basic mariadb module.

This sets up a mariadb cluster.

It defines one class:
mariadb
which takes two parameters:
primaryhost = The primary hostin the galera cluster, defaults to ''.
ip = the IP address to use for this host.

The host needs to already be configured to use a repository with the mariadb
and galera packages in it.
