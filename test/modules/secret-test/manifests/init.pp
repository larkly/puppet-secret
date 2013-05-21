class secret-test {
  # generate the secret key
  $binsecret = secret('mykey-bin')
  $base64secret = secret('mykey-b64', {'base64' => true })
  $y64secret = secret('mykey-y64', {'y64' => true, 'bytes' => 500 })

  file {'secretfile-bin':
    path    => '/tmp/secretfile-bin',
    ensure  => present,
    mode    => 0666,
    source  => [$binsecret],
  }

  file {'secretfile-b64':
    path    => '/tmp/secretfile-b64',
    ensure  => present,
    mode    => 0666,
    source  => [$base64secret],
  }

  file {'secretfile-y64':
    path    => '/tmp/secretfile-y64',
    ensure  => present,
    mode    => 0666,
    source  => [$y64secret],
  }
}