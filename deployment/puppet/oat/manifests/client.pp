class oat::client(
  $server_ip = '127.0.0.1',
  $server_password = 'password',
) {
  notify { "I am oat client. My master is at ${server_ip} with password ${server_password}" :}
}
