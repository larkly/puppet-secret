class secret-test {
  # generate the secret key
  $binsecret = secret('mykey-bin')
  $base64secret = secret('mykey-b64', {'method' => 'base64' })
  $y64secret = secret('mykey-y64', {'method' => 'y64' })
  $abcsecret16 = secret('mykey-abc16', {'method' => 'alphabet', 'length' => 16 })
  $abcsecret11 = secret('mykey-abc11', {'method' => 'alphabet', 'bytes' => 11 })
  $uuidsecret = secret('myuuid', {'method' => 'uuid'})
  $cephsecret = secret('common-ceph', {'method' => 'ceph'})
  $sharedabc = secret('sharone', {'method' => 'base64', 'secrets_mount' => 'shared-secrets'})

  file {'secretfile-bin':
    path    => '/tmp/secretfile-bin',
    ensure  => present,
    mode    => 0666,
    source  => $binsecret,
  }

  file {'secretfile-b64':
    path    => '/tmp/secretfile-b64',
    ensure  => present,
    mode    => 0666,
    source  => $base64secret,
  }

  file {'secretfile-y64':
    path    => '/tmp/secretfile-y64',
    ensure  => present,
    mode    => 0666,
    source  => $y64secret,
  }

  file {'secretfile-abc16':
    path    => '/tmp/secretfile-abc16',
    ensure  => present,
    mode    => 0666,
    source  => $abcsecret16,
  }

  file {'secretfile-abc11':
    path    => '/tmp/secretfile-abc11',
    ensure  => present,
    mode    => 0666,
    source  => $abcsecret11,
  }

  file {'secretfile-uuid':
    path    => '/tmp/secretfile-uuid',
    ensure  => present,
    mode    => 0666,
    source  => $uuidsecret,
  }

  file {'secretfile-ceph':
    path    => '/tmp/secretfile-ceph',
    ensure  => present,
    mode    => 0666,
    source  => $cephsecret,
  }

  file {'secretfile-shared':
    path    => '/tmp/secretfile-shared',
    ensure  => present,
    mode    => 0666,
    source  => $sharedabc,
  }
}
