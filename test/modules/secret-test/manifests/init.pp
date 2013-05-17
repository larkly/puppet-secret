class secret-test {
  # generate the secret key
  $secret_path = secret('cryptsetup_key', {'base64' => true })

  file {'secretfile':
    path    => '/tmp/secretfile',
    ensure  => present,
    mode    => 0666,
    source  => [$secret_path],
  }
}