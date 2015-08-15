### Type: `websphere_custom_service`

Manages the creation or removal of WebSphere custom services.

#### Example

```puppet
  websphere_custom_service { 'Program Custom Service':
    cell                => 'CELL_01',
    node                => 'NODE_01',
    server              => 'AppServer01',
    profile             => 'PROFILE_APP_001',
    profile_base        => '/opt/IBM/WebSphere85/AppServer/profiles',
    user                => 'webadmin',
    classpath           => '/opt/was/program/ProgramAppSupport.jar',
    enable              => true,
    external_config_url => '',
    description         => 'Program Custom Service',
    classname           => 'com.program.api.websphere.ProgramCustomService',
    require             => Websphere::Profile::Appserver['PROFILE_APP_001'],
  }

```

#### Parameters

##### `ensure`

Valid values: `present`, `absent`

Defaults to `true`.  Specifies whether this custom service should exist or not.

##### `name`

The name of the custom service to manage. Defaults to the resource title.

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

##### `classpath`


##### `enable`


##### `external_config_url`


##### `description`


##### `classname`
