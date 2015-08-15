### Type: `websphere_vhost`

Manages the creation or removal of WebSphere virtual hosts.

#### Example

```puppet
websphere_vhost { 'test_vhost':
    cell         => 'CELL_01',
    profile      => 'PROFILE_APP_001',
    profile_base => '/opt/IBM/WebSphere85/AppServer/profiles',
    node         => 'NODE_01',
    user         => 'webadmin',
}
```

#### Parameters

##### `ensure`

Valid values: `present`, `absent`

Defaults to `true`.  Specifies whether this virtual host should exist or not.

##### `name`

The name of the virtual host to manage. Defaults to the resource title.

##### `profile`

Required. The name of the profile to create this application server under.

Examples: `PROFILE_APP_001`

##### `profile_base`

Required. The full path to the profiles directory where the `dmgr_profile` can
be found.  The IBM default is `/opt/IBM/WebSphere/AppServer/profiles`

##### `user`

Optional. The user to run the `wsadmin` command as. Defaults to "root"

##### `wsadmin_user`

Optional. The username for `wsadmin` authentication if security is enabled.

##### `wsadmin_pass`

Optional. The password for `wsadmin` authentication if security is enabled.
