### Type: `websphere_session_management_cookies`

Manages the creation or removal of WebSphere server cookies.

#### Example

```puppet
# Adding session_management_cookies
websphere_session_management_cookies { 'JSESSIONID':
    cell                     => 'CELL_01',
    node                     => 'NODE_01',
    server                   => 'AppServer01',
    maximum_age              => '-1',
    use_context_root_as_path => false,
    domain                   => '',
    cookie_path              => '/',
    secure                   => true,
    http_only                => true,
    profile                  => 'PROFILE_APP_001',
    profile_base             => '/opt/IBM/WebSphere85/AppServer/profiles',
    user                     => 'webadmin',
}
```

#### Parameters

##### `ensure`

Valid values: `present`, `absent`

Defaults to `true`.  Specifies whether this cookie should exist or not.

##### `name`

The name of the cookie to manage. Defaults to the resource title.

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


#### Properties

##### `maximum_age`

##### `use_context_root_as_path`

##### `domain`

##### `cookie_path`

##### `secure`

##### `http_only`

