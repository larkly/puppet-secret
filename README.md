secret
======

Puppet function to create and manage secrets for nodes on puppet master.

    $secret_path = secret('my_id')

You now have a pointer to your secret, eg: `puppet:///secrets/cryptsetup_key`

You can use it via:

    file { 'secretfile':
      path    => '/my/secretfile',
      ensure  => present,
      mode    => 0600,
      source  => [$secret_path],
    }

Secrets that don't exist will be generated for you.

If you follow the installation correctly, you have an easy ACL-secured per-node secret store on the puppet master. As an added bonus, you can even avoid secrets from getting cached on your puppet nodes.


Installation
------------

1. Create a folder on puppet master where you want to store your secrets. Ideally, this should be outside of puppet configuration (and securely replicated ;) ).

        mkdir -p /secrets

    make sure puppet has access to this folder:

        chown -R puppet:puppet /secrets

2. Configure this path in your `/etc/puppet/fileserver.conf`. Make sure it is on a per-node basis! (to do this, include the '%H' in the path as shown; this makes sure the node's FQDN is part of the access path)

        [secrets]
        path /secrets/%H/
        allow *.mydomain

3. Use it. See examples.


Options
-------

* `secrets_mount` := the mount path in fileserver, where secrets are stored (default: `secrets`)
* `bytes` := the number of bytes to use for generating a new secret (default: `128`)
* `base64` := if `true` will give you a base64 encoded secret instead of binary (default: `false`)

more examples:

* for ascii secret in 200 bytes

        $secret_path = secret('myid', {
          'bytes' => 200,
          'base64' => true
          })

  which will get you something like:

        XgtLsQtcm6Tnxxpxzpo02C3geXKVo1uMMZXbohXWZWLQ3wqMrjEyTEGjImvU4/FIeXj01C+KM8R2oBu28qlLzzZX+4eaWny9n+76bRURbbZmOU7pNks5wB5lw3Y32kVlBiiiu0hMDYjqIuZ7kcwPSpO6a+Cxr/b5iToii13Ni29DXjYZq1SyPwfW3a2/qbIY4ziX3VLCRbWkzugecUVJ8mFXVniUG7Ssvu79XxXKfJJ9Vx9HbMYQJs7VAz0ZHND9FdqMknDEaIw=



Additional information
======================

Limitations
-----------

Don't mistake this for a key-manager. It isn't. This is simply meant for all those task that quickly and easily need an unmanaged secret without extra components and complications.


URI-mapping
-----------

Puppet's fileserver configuration makes sure you have a node-based ACL. It is easy to configure.

With a server configuration like this:

    [secrets]
    path /secrets/%H/
    allow *.mydomain

you will create a `puppet:///secrets/` URI.

If a client called `puppy.com` accesses a secret, eg:

    $secret_path = secret('myid')

this will be mapped into the puppet URI:

    puppet:///secrets/myid

and on the server's filesystem will be turned into reading

    /secrets/puppy.com/myid

Through the generator, the server will make sure the requested file actually exists.
If not, the server will create it with a new secret inside.



License and Author
==================

Author:: Dominik Richter <do.richter@telekom.de>
Copyright:: 2013, Deutsche Telekom AG

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

