class mariadb::repos (
) {
  case $::osfamily {
    'Debian': {
    }
    'RedHat': {
      yumrepo { 'mariadb':
        descr    => 'MariaDB',
        baseurl  => 'http://yum.mariadb.org/5.5/centos6-amd64',
        gpgkey   => 'https://yum.mariadb.org/RPM-GPG-KEY-MariaDB',
        gpgcheck => 1,
      }
    }
    default: {
      fail("Unsupported osfamily: ${::osfamily} for os ${::operatingsystem}")
    }
  }
}
