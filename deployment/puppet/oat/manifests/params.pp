class oat::params {
  $client_package = 'oat-client'
  $client_service = 'OAT-client'
  $server_package = 'oat-appraiser'
  $server_service = 'oat-appraiser'
  $server_db_sql = '/usr/share/oat-appraiser/oat_db.MySQL'
  $server_data_sql = '/usr/share/oat-appraiser/init.sql'
  $server_tomcat_dir = '/usr/share/tomcat6'
  $server_http_dir = '/var/www/html'
  $server_apps_dir = "${server_tomcat_dir}/webapps"
  $server_oat_function = '/usr/share/oat-appraiser/oat_function'
}
