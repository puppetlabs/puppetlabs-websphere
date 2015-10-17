# IBM WebSphere

__GitHub:__ [https://github.com/joshbeard/puppet-websphere](https://github.com/joshbeard/puppet-websphere)

__Puppet Forge:__ [https://forge.puppetlabs.com/joshbeard/websphere](https://forge.puppetlabs.com/joshbeard/websphere)

#### Table of Contents

1. [Overview](#overview)
2. [TODO](#todo)
3. [Reference](#reference)
    * [Facts](#facts)
    * [Classes](#classes)
    * [Defined Types](#defined-types)
    * [Types](#types)
4. [Usage](#usage)
    * [Examples](#examples)
        * [0. Installation Manager](#0-installation-manager)
        * [1. Base class](#1-the-base-class)
        * [2. An Instance](#2-an-instance)
        * [3. FixPacks](#3-fixpacks)
        * [4. Profiles](#4-profiles)
        * [5. Clusters](#5-clusters)
        * [6. Conclusion](#6-conclusion)
        * [7. Variables](#7-variables)
        * [8. JVM Logs](#8-jvm-logs)
        * [9. JDBC Providers and Datasources](#9-jdbc-providers-and-datasources)
        * [10. IHS](#10-ihs)
5. [Limitations](#limitations)
6. [Dependencies](#dependencies)
7. [Authors](#authors)
8. [Contributors](#contributors)

[![Test Status](https://img.shields.io/travis/joshbeard/puppet-websphere/master.svg?style=flat-square&label=validation%2Flint)](https://travis-ci.org/joshbeard/puppet-websphere)

## Overview

Manages the deployment and configuration of IBM WebSphere Cells.

* DMGR systems and configuration
* Application Servers and configuration
* IHS Servers in the context of WebSphere

Most documentation has been split into individual documents in the [docs](docs)
directory and linked to, in context, throughout this document.

## TODO

There's plenty to do here.  WebSphere is a _huge_ stack and this module only
manages some core functions.  See [CONTRIBUTING.md](CONTRIBUTING.md) for
information on contributing.

Some of the immediate needs:

* Revise types/providers.  Clean up the code, add validation and documentation.
    * `websphere_cluster_member` doesn't manage the individual properties on
      the first run.  The first run creates the member and subsequent runs
      configure it.  Need to resolve this - it's a provider issue.
* Manage WAS security.
* Manage certificates.
* Improve the run order issues.  See the [ISSUES.md](issues.md) file for
  details.
* Documentation and examples.
* Vagrant environment (I have one, just need to clean it up)

## Reference

### Facts

The following facts are provided by this module:

| Fact name                | Description                                      |
| ------------------------ | ------------------------------------------------ |
| *instance*\_name         | This is the name of a WebSphere instance. Basically, the base directory name.
| *instance*\_target       | The full path to where a particular instance is installed.
| *instance*\_user         | The user that "owns" this instance.
| *instance*\_group        | The group that "owns" this instance.
| *instance*\_profilebase  | The full path to where profiles for this instance are located.
| *instance*\_version      | The version of WebSphere an instance is running.
| *instance*\_package      | The package name a WebSphere instance was installed from.
| websphere\_profiles      | A comma-separated list of profiles discovered on a system across instances.
| websphere\_*profile*\_*cell*\_*node*\_soap | The SOAP port for an instance.  This is particuarily relevant on the DMGR so App servers can federate with it.

__Examples:__

Assuming we've installed a WebSphere instance called "WebSphere":

```
websphere_group => webadmins
websphere_name => WebSphere
websphere_package => com.ibm.websphere.NDTRIAL.v85
websphere_profile_base => /opt/IBM/WebSphere/AppServer/profiles
websphere_target => /opt/IBM/WebSphere/AppServer
websphere_user => webadmin
websphere_version => 8.5.5004.20141119_1746
websphere_base_dir => /optIBM
websphere_profile_dmgr_01_cell_01_appnode01_soap => 8878
websphere_profile_dmgr_01_cell_01_node_dmgr_01_soap => 8879
websphere_profiles => PROFILE_DMGR_01
```

Or if we've installed a WebSphere instance called "WebSphere85" to a custom
location:

```
websphere85_group => webadmins
websphere85_name => WebSphere85
websphere85_package => com.ibm.websphere.NDTRIAL.v85
websphere85_profile_base => /opt/myorg/IBM/WebSphere85/AppServer/profiles
websphere85_target => /opt/myorg/IBM/WebSphere85/AppServer
websphere85_user => webadmin
websphere85_version => 8.5.5004.20141119_1746
websphere_base_dir => /opt/myorg/IBM
websphere_profile_dmgr_01_cell_01_appnode01_soap => 8878
websphere_profile_dmgr_01_cell_01_node_dmgr_01_soap => 8879
websphere_profiles => PROFILE_DMGR_01
```


### Classes

Only one class currently exists in this class - the base class. Since this
module was designed for "multiple instances of anything", most things are
_defined types_.

| Class Name | Description                                                    |
| ---------- | -------------------------------------------------------------- |
| websphere  | Base class. Manages a user and group, a couple of data directories for WebSphere, and a YAML fact that includes metadata about WebSphere installations.

The following directories will be managed by the base class:

* `${base_dir}/.java`
* `${base_dir}/.java/systemPrefs`
* `${base_dir}/.java/userPrefs`
* `${base_dir}/workspace`
* `/opt/IBM/.java`
* `/opt/IBM/.java/systemPrefs`
* `/opt/IBM/.java/userPrefs`
* `/opt/IBM/workspace`

These directories appear to be necessary for the proper functionality of the
various IBM tools we use to manage the WebSphere deployment.

### Defined Types

The following defined types are provided by this module.

Each defined type is documented in a separate document in the
[docs/defines](docs/defines) directory.

| Defined Type Name             | Description                                 |
| ----------------------------- | ------------------------------------------- |
| [websphere::instance](docs/defines/instance.md) | Manages the base installation of a WebSphere instance.
| [websphere::package](docs/defines/package.md) | Manages the installation of IBM packages and the ownership of the installation directory.
| [websphere::ownership](docs/defines/ownership.md) | Manages the ownership of a specified path. See notes below for the usecase for this.
| [websphere::profile::dmgr](docs/defines/profile_dmgr.md) | Manages a DMGR profile.
| [websphere::profile::appserver](docs/defines/profile_app.md) | Manages an application server profile.
| [websphere::profile::service](docs/defines/profile_service.md) | Manages the service for a profile (DMGR or Application Server).
| [websphere::ihs::instance](docs/defines/ihs_instance.md) | Manages the installation of an IHS instance.
| [websphere::ihs::server](docs/defines/ihs_server.md) | Manages server instances on an IHS system.
| [websphere::cluster](docs/defines/cluster.md) | Manage WebSphere clusters.
| [websphere::cluster::member](docs/defines/cluster_member.md) | Manage WebSphere cluster members and their services.

### Types

The following native (Ruby) types are provided by this module.

Each type is documented in a separate document in the [docs/types](docs/types)
directory.

| Type                             | Description
| -------------------------------- | ---------------------------------------------------------------- |
| [websphere_app_server](docs/types/websphere_app_server.md) | Manages WebSphere Application Servers
| [websphere_cluster](docs/types/websphere_cluster.md) | Manages the creation of WebSphere clusters on a DMGR.
| [websphere_cluster_member](docs/types/websphere_cluster_member.md) | Manages cluster members, including various settings.
| [websphere_cluster_member_service](docs/types/websphere_cluster_member_service.md) | Manages a cluster member service.
| [websphere_custom_service](docs/types/websphere_custom_service.md) | Manages a custom service.
| [websphere_federate](docs/types/websphere_federate.md) | Manages the federation of an application server with a cell.
| [websphere_host_alias](docs/types/websphere_host_alias.md) | Manages Websphere host aliases.
| [websphere_jdbc_datasource](docs/types/websphere_jdbc_datasource.md) | Manages datasources.
| [websphere_jdbc_provider](docs/types/websphere_jdbc_provider.md) | Manages JDBC providers.
| [websphere_jvm_log](docs/types/websphere_jvm_log.md) | Manages the JVM logging properties for nodes or servers.
| [websphere_node](docs/types/websphere_node.md) | Manages the creation of unmanaged nodes in a WebSphere cell.
| [websphere_sdk](docs/types/websphere_sdk.md) | Manages the SDK version for a WebSphere profile or server.
| [websphere_variable](docs/types/websphere_variable.md) | Manages WebSphere environment variables.
| [websphere_vhost](docs/types/websphere_vhost.md) | Manages WebSphere virtual hosts.
| [websphere_web_server](docs/types/websphere_web_server.md) | Manages the creation and configuration of WebSphere web servers.

## Usage

### Examples

#### 0. Installation Manager

Before you do anything with this module, you need IBM Installation Manager
installed.

A module has been created to manage the IBM Installation Manager, available at
[https://github.com/joshbeard/puppet-ibm_installation_manager](https://github.com/joshbeard/puppet-ibm_installation_manager)

Once you have the module, you can manage the installation of the Installation
Manager like this:

```puppet
class { 'ibm_installation_manager':
  source_dir => '/mnt/myorg/IM',
  target     => '/opt/IBM/InstallationManager',
}
```

Here, we assume the package downloaded from IBM has been extracted to
`/mnt/myorg/IM` and we want to install it to `/opt/IBM/InstallationManager`

__References:__

* [https://github.com/joshbeard/puppet-ibm_installation_manager](https://github.com/joshbeard/puppet-ibm_installation_manager)

#### 1. The base class

To get started, declare the base class.  You should declare this on any
server that will use this module - DMGR, App Servers, and IHS.

In this example, we provide a user and a group.  We want the installation to
be owned and ran by this user/group.

We also specify a `base_dir` (although `/opt/IBM` is the default).  This is
the directory where our IBM software goes.  This is the IBM default.

```puppet
class { 'websphere':
  user     => 'webadmin',
  group    => 'webadmins',
  base_dir => '/opt/IBM',
}
```

#### 2. An instance

The word "instance" used throughout this module basically refers to a
complete installation of WebSphere.  Ideally, you'd just have a single
instance of WebSphere on a given system.  This module, however, does offer
the flexibility to have multiple installations.  This is useful for cases
where you want two different major versions available (e.g. WAS 7 and WAS 8).

In this example, we're installing to the IBM-default location of
`/opt/IBM/WebSphere/AppServer`.  This is actually the module default as well,
but it's specified here for clarity.  We also provide a package and version.

We're assuming the WebSphere installer has been downloaded and extracted to
`/mnt/myorg/was` and the corresponding `repository.config` file is located
there.

The user and group don't need to be specified here, because we specified them
when we declared the base class.  The `instance` defined type will use those
as its defaults.

```puppet
websphere::instance { 'WebSphere85':
  target       => '/opt/IBM/WebSphere/AppServer',
  package      => 'com.ibm.websphere.NDTRIAL.v85',
  version      => '8.5.5000.20130514_1044',
  profile_base => '/opt/IBM/WebSphere/AppServer/profiles',
  repository   => '/mnt/myorg/was/repository.config',
```

Let's assume we have a response file that we want to use.  The response file
contains the package name, version, repository location, and the target to
install to.  We can use it like this:

```puppet
websphere::instance { 'WebSphere85':
  response     => '/mnt/myorg/was/was85_response.xml',
  profile_base => '/opt/IBM/WebSphere/AppServer/profiles',
}
```

__References:__

* [websphere::instance](docs/defines/instance.md)
* [websphere::package](docs/defines/package.md)

#### 3. FixPacks

It's common to install an IBM "FixPack" after the base installation.  Following
the examples above, we've installed WebSphere 8.5.5.0.  Let's say we want to
install the WebSphere 8.5.5.4 fixpack.  We can do so using the
`websphere::package` defined type:

```puppet
websphere::package { 'WebSphere_8554':
  ensure     => 'present',
  package    => 'com.ibm.websphere.NDTRIAL.v85',
  version    => '8.5.5004.20141119_1746',
  repository => '/mnt/myorg/was_8554/repository.config',
  target     => '/opt/IBM/WebSphere/AppServer',
  require    => Websphere::Instance['WebSphere85'],
}
```

In the above example, we're installing the 8.5.5.4 FixPack right on top of
the existing 8.5.5.0 installation.  We also use the `require` metaparameter
to enforce the ordering.

An example of installing Java 7:

```puppet
websphere::package { 'Java7':
  ensure     => 'present',
  package    => 'com.ibm.websphere.IBMJAVA.v71',
  version    => '7.1.2000.20141116_0823',
  target     => '/opt/IBM/WebSphere/AppServer',
  repository => '/mnt/myorg/java7/repository.config',
  require    => Websphere::Package['WebSphere_8554'],
}
```

In the above example, we install the Java 7 package to our WebSphere location.
We also use the `require` metaparameter here to enforce ordering - we want
the Java7 installation to be managed _after_ WebSphere 8.5.5.4 is.

__References:__

* [websphere::package](docs/defines/package.md)
* [websphere::ownership](docs/defines/ownership.md)
* [ibm_pkg](https://github.com/joshbeard/puppet-ibm_installation_manager#type-ibm_pkg) (external)

#### 4. Profiles

Once we have the base software installed, we need to create a profile. A
profile is basically the runtime enironment.  A server can potentially have
multiple profiles.  A DMGR profile is ultimately what defines a given "cell"
in WebSphere.

In the following example, we create a DMGR profile called `PROFILE_DMGR_01`
and call the cell that gets created `CELL_01`.  We also call the DMGR node
`dmgrNode01` in this example.

Finally, we use the `subscribe` metaparameter to set relationships with our
base installations.  If those change, the resources in
`websphere::profile::dmgr` will be refreshed if needed.

```puppet
# Example DMGR profile
websphere::profile::dmgr { 'PROFILE_DMGR_01':
  instance_base => '/opt/IBM/WebSphere/AppServer',
  profile_base  => '/opt/IBM/WebSphere/AppServer/profiles',
  cell          => 'CELL_01',
  node_name     => 'dmgrNode01',
  subscribe     => [
    Websphere::Package['Websphere_8554'],
    Websphere::Package['Java7'],
  ],
}
```

When a DMGR profile is created, this module will use Puppet's _exported
resources_ to export a _file_ resource that contains information needed for
application servers to federate with it.  This includes the SOAP port and the
host name (fqdn).

The DMGR profile will, by default, collect any exported `websphere_node`,
`websphere_web_server`, and `websphere_jvm_log` resources.

An application server's profile looks quite similar:

```puppet
# Example Application Server profile
websphere::profile::appserver { 'PROFILE_APP_001':
  instance_base  => '/opt/IBM/WebSphere/AppServer',
  profile_base   => '/opt/IBM/WebSphere/AppServer/profiles',
  cell           => 'CELL_01',
  template_path  => '/opt/IBM/WebSphere/AppServer/profileTemplates/managed',
  dmgr_host      => 'dmgr.example.com',
  node_name      => 'appNode01',
  manage_sdk     => true,
  sdk_name       => '1.7.1_64',
}
```

Here, we provide the _cell_ that we want to _federate_ with.  We also want
to manage the SDK version and ensure it's set to '1.7.1_64'.

When creating an application server profile, the _file_ resource that was
exported by the DMGR will be _collected_.  The criteria for collecting is
a DMGR hostname and cell name.  This allows the application server to know
which SOAP port to use for federation.  This is the default behavior of the
module.

__References:__

* [websphere::profile::dmgr](docs/defines/profile_dmgr.md)
* [websphere::profile::appserver](docs/defines/profile_app.md)
* [websphere::profile::service](docs/defines/profile_service.md)
* [websphere_sdk](docs/types/websphere_sdk.md)
* [websphere_node](docs/types/websphere_node.md)
* [websphere_web_server](docs/types/websphere_web_server.md)
* [websphere_jvm_log](docs/types/websphere_jvm_log.md)

#### 5. Clusters

Once profiles are created on the DMGR and an application server, we're probably
interested in creating a cluster and adding application servers to it.

__DMGR__

The DMGR should declare a `websphere::cluster` resource:

```puppet
# Manage a cluster on the DMGR
websphere::cluster { 'MyCluster01':
  profile_base => '/opt/IBM/WebSphere/AppServer/profiles',
  dmgr_profile => 'PROFILE_DMGR_01',
  cell         => 'CELL_01',
  require      => Websphere::Profile::Dmgr['PROFILE_DMGR_01'],
}
```

In this example, a cluster called `MyCluster01` will be created.  We need to
provide a `profile_base` and `dmgr_profile` to know _where_ this cluster
should be created.  Additionally, we use the `require` metaparameter to set
a relationship between the profile and the cluster.  We want to ensure that
the profile has been managed before attempting to manage the cluster.

__Application Server__

There's a couple of ways to add cluster members.  The DMGR can explicitly
declare each one or the members themselves can _export_ a resource to do so.

In the following example, we define a `websphere::cluster::member` resource
on an application server and _export_ it.  The two "at" symbols (@@) indicate
that this is an _exported_ resource.

```puppet
# Export myself as a cluster member
@@websphere::cluster::member { 'AppServer01':
  ensure                           => 'present',
  cluster                          => 'MyCluster01',
  node                             => 'appNode01',
  cell                             => 'CELL_01',
  jvm_maximum_heap_size            => '512',
  jvm_verbose_mode_class           => true,
  jvm_verbose_garbage_collection   => false,
  total_transaction_timeout        => '120',
  client_inactivity_timeout        => '20',
  threadpool_webcontainer_max_size => '75',
  runas_user                       => 'webadmin',
  runas_group                      => 'webadmins',
}
```

In this example, we're adding a member from the node `appNode01` that we
created when we managed the profile to the `MyCluster01` cluster in the
`CELL_01` cell.  We're also specifying a few various JVM parameters, including
the "runas" user and group.

__How does this work?__

The DMGR declared the `websphere::cluster` defined type, which will
automatically _collect_ any exported resources that match its _cell_. Every
time Puppet runs on the DMGR, it will search for exported resources to
declare on that host.

On the application server, the "@@" prefixed to the resource type _exports_
that resource, which can be collected by the DMGR the next time Puppet runs.

The examples above illustrate the module's default behavior.  It is possible
to manage clusters without exported resources.

If you do not want to use exported resources, the DMGR host can explicitly
declare each member that it should add.  For example:

```puppet
websphere::cluster::member { 'AppServer01':
  ensure       => 'present',
  cluster      => 'MyCluster01',
  node         => 'appNode01',
  cell         => 'CELL_01',
  profile_base => '/opt/IBM/WebSphere/AppServer/profiles',
  dmgr_profile => 'PROFILE_DMGR_01',
}
```

This is obviously less dynamic.  The user also needs to ensure that the
_profile_ is ready on the application server.

__References:__

* [websphere::cluster](docs/defines/cluster.md)
* [websphere::cluster::member](docs/defines/cluster_member.md)
* [websphere_cluster](docs/types/websphere_cluster.md)
* [websphere_cluster_member](docs/types/websphere_cluster_member.md)
* [websphere_cluster_member_service](docs/types/websphere_cluster_member_service.md)

#### 6. Conclusion

Following the examples above, WebSphere should be installed with a fixpack and
Java7, profiles should be created and federated, and a cluster should be
created with the application server as a member.

At this point, we can tune our installation.

#### 7. Variables

This module provides a type to manage WebSphere environment variables.

In the example below, we want to ensure a variable called `LOG_ROOT` is set
for the _node_ `appNode01`.

__Node scoped variable__

```puppet
# Example of a node scoped variable
websphere_variable { 'appNode01Logs':
  ensure       => 'present',
  variable     => 'LOG_ROOT',
  value        => '/var/log/websphere/wasmgmtlogs/appNode01',
  scope        => 'node',
  node         => 'appNode01',
  cell         => 'CELL_01',
  dmgr_profile => 'PROFILE_APP_001',
  profile_base => '/opt/IBM/WebSphere/AppServer/profiles',
  user         => 'webadmin',
  require      => Websphere::Profile::Appserver['PROFILE_APP_001'],
}
```

__Server scoped variable__

```puppet
# Example of a server scoped variable
# NOTE: This will cause a FAILURE during the first Puppet run because the
# cluster member has not yet been created on the DMGR.
websphere_variable { 'AppServer01Logs':
  ensure       => 'present',
  variable     => 'LOG_ROOT',
  value        => '/opt/log/websphere/appserverlogs',
  scope        => 'server',
  server       => 'AppServer01',
  node         => 'appNode01',
  cell         => 'CELL_01',
  dmgr_profile => 'PROFILE_APP_001',
  profile_base => $profile_base,
  user         => $user,
  require      => Websphere::Profile::Appserver['PROFILE_APP_001'],
}
```

In the example above, we manage a _server_ scoped variable for the
`AppServer01` server.  The `AppServer01` server was created as part of the
`websphere::cluster::member` defined type.

A caveat here is that server-scoped variables _cannot_ be managed until/unless
a corresponding cluster member exists on the DMGR. Some solutions to this are
being thought about, but that's the current reality.

Optionally, these variables can be declared on the DMGR.  This will enable you
to set _relationships_ between the cluster member and the variable resource.
However, this sacrifices some of the dynamic nature of the module.

__Reference:__

* [websphere_variable](docs/types/websphere_variable.md)

#### 8. JVM Logs

This module provides a `websphere_jvm_log` type that can be used to manage
JVM logging properties, such as log rotation criteria.

```puppet
websphere_jvm_log { "AppNode01":
  profile             => 'PROFILE_APP_001',
  profile_base        => '/opt/IBM/WebSphere/AppServer/profiles',
  cell                => 'CELL_01',
  scope               => 'node',
  node                => 'appNode01',
  server              => 'AppServer01',
  out_filename        => '/tmp/SystemOut.log',
  out_rollover_type   => 'BOTH',
  out_rollover_size   => '7',
  out_maxnum          => '200',
  out_start_hour      => '13',
  out_rollover_period => '24',
  err_filename        => '/tmp/SystemErr.log',
  err_rollover_type   => 'BOTH',
  err_rollover_size   => '7',
  err_maxnum          => '3',
  err_start_hour      => '13',
  err_rollover_period => '24',
  require             => Websphere::Profile::Appserver['PROFILE_APP_001'],
}
```

In the example above, we want to manage the JVM logs for the `appNode01` node.

We want to rotate the "out" log based on time and size.  We specify that via
the `_rollover_type` parameter for each. We want to rotate every 7MB, which
we specify via the `_rollover_size` parameter.  We want to keep a maximum of
200 historical logs for the SystemOut, and only 3 for the SystemErr.  We want
the time-based log rotation to occur at "1300" hours (1PM), and rotate every
24 hours.

__Reference:__

* [websphere_jvm_log](docs/types/websphere_jvm_log.md)

#### 9. JDBC Providers and Datasources

This module supports creating JDBC providers and data sources.  At this time,
it does not support the removal of JDBC providers or datasources or changing
their configuration after they're created.

__JDBC Provider:__

An example of creating a JDBC provider called "Puppet Test", using Oracle, at
node scope:

```puppet
websphere_jdbc_provider { 'Puppet Test':
  ensure         => 'present',
  dmgr_profile   => 'PROFILE_DMGR_01',
  profile_base   => '/opt/IBM/WebSphere/AppServer/profiles',
  user           => 'webadmin',
  scope          => 'node',
  cell           => 'CELL_01',
  node           => 'appNode01',
  server         => 'AppServer01',
  dbtype         => 'Oracle',
  providertype   => 'Oracle JDBC Driver',
  implementation => 'Connection pool data source',
  description    => 'Created by Puppet',
  classpath      => '${ORACLE_JDBC_DRIVER_PATH}/ojdbc6.jar',
}
```

__JDBC Datasource:__

An example of creating a datasource, utilizing the JDBC provider we created,
at node scope:

```puppet
websphere_jdbc_datasource { 'Puppet Test':
  ensure                        => 'present',
  dmgr_profile                  => 'PROFILE_DMGR_01',
  profile_base                  => '/opt/IBM/WebSphere/AppServer/profiles',
  user                          => 'webadmin',
  scope                         => 'node',
  cell                          => 'CELL_01',
  node                          => 'appNode01',
  server                        => 'AppServer01',
  jdbc_provider                 => 'Puppet Test',
  jndi_name                     => 'myTest',
  data_store_helper_class       => 'com.ibm.websphere.rsadapter.Oracle11gDataStoreHelper',
  container_managed_persistence => true,
  url                           => 'jdbc:oracle:thin:@//localhost:1521/sample',
  description                   => 'Created by Puppet',
}
```

__JDBC Provider at cell scope:__

```puppet
websphere_jdbc_provider { 'Puppet Test':
  ensure         => 'present',
  dmgr_profile   => 'PROFILE_DMGR_01',
  profile_base   => '/opt/IBM/WebSphere/AppServer/profiles',
  user           => 'webadmin',
  scope          => 'cell',
  cell           => 'CELL_01',
  dbtype         => 'Oracle',
  providertype   => 'Oracle JDBC Driver',
  implementation => 'Connection pool data source',
  description    => 'Created by Puppet',
  classpath      => '${ORACLE_JDBC_DRIVER_PATH}/ojdbc6.jar',
}
```

__JDBC Datasource at cell scope:__

```puppet
websphere_jdbc_datasource { 'Puppet Test':
  ensure                        => 'present',
  dmgr_profile                  => 'PROFILE_DMGR_01',
  profile_base                  => '/opt/IBM/WebSphere/AppServer/profiles',
  user                          => 'webadmin',
  scope                         => 'cell',
  cell                          => 'CELL_01',
  jdbc_provider                 => 'Puppet Test',
  jndi_name                     => 'myTest',
  data_store_helper_class       => 'com.ibm.websphere.rsadapter.Oracle11gDataStoreHelper',
  container_managed_persistence => true,
  url                           => 'jdbc:oracle:thin:@//localhost:1521/sample',
  description                   => 'Created by Puppet',
}
```

__References:__

* [websphere_jdbc_provider](docs/types/websphere_jdbc_provider.md)
* [websphere_jdbc_datasource](docs/types/websphere_jdbc_datasource.md)

#### 10. IHS

This module has basic support for managing IBM HTTP Server (IHS) in the context
of WebSphere.

In the example below, we install IHS to `/opt/IBM/HTTPServer`, install the
WebSphere plug-ins for IHS, and create a server instance.  By default, this
module will automatically _export_ a `websphere_node` and
`websphere_web_server` resource via the `websphere::ihs::server` defined type.
These exported resources will, by default, be _collected_ by the DMGR and
_realized_.  Basically, by default, an IHS server will automatically be
setup in the DMGR's cell.

```puppet
websphere::ihs::instance { 'HTTPServer':
  target           => '/opt/IBM/HTTPServer',
  package          => 'com.ibm.websphere.IHSILAN.v85',
  version          => '8.5.5000.20130514_1044',
  repository       => '/mnt/myorg/ihs/repository.config',
  install_options  => '-properties user.ihs.httpPort=80',
  user             => 'webadmin',
  group            => 'webadmins',
  manage_user      => false,
  manage_group     => false,
  log_dir          => '/opt/log/websphere/httpserver',
  admin_username   => 'httpadmin',
  admin_password   => 'password',
  webroot          => '/opt/web',
}

websphere::package { 'Plugins':
  ensure     => 'present',
  target     => '/opt/IBM/Plugins',
  repository => '/mnt/myorg/plugins/repository.config',
  package    => 'com.ibm.websphere.PLGILAN.v85',
  version    => '8.5.5000.20130514_1044',
  require    => Websphere::Ihs::Instance['HTTPServer'],
}

websphere::ihs::server { 'test':
  target      => '/opt/IBM/HTTPServer',
  log_dir     => '/opt/log/websphere/httpserver',
  plugin_dir  => '/opt/IBM/Plugins/config/test',
  plugin_base => '/opt/IBM/Plugins',
  cell        => 'CELL_01',
  config_file => '/opt/IBM/HTTPServer/conf/httpd_test.conf',
  access_log  => '/opt/log/websphere/httpserver/access_log',
  error_log   => '/opt/log/websphere/httpserver/error_log',
  listen_port => '10080',
  require     => Websphere::Package['Plugins'],
}
```

__References:__

* [websphere::ihs::instance](docs/defines/ihs_instance.md)
* [websphere::package](docs/defines/package.md)
* [websphere::ihs::server](docs/defines/ihs_server.md)
* [websphere_node](docs/types/websphere_node.md)
* [websphere_web_server](docs/types/websphere_web_server.md)

#### Others

TODO: Add more examples here.

See the [examples](examples/) directory for now.

Once it's up, you should be able to reach the DMGR console at something like:

`http://<host>:9060/ibm/console/unsecureLogon.jsp`

## Limitations

Tested and developed with __IBM WebSphere Application Server Network
Deployment.__

Tested and developed with IBM WebSphere __8.5.0.x__ and __8.5.5.x__ on:

* CentOS 6 x86_64
* RHEL 6 x86_64
* AIX 6.1, 7.1

## Dependencies

* [joshbeard/ibm_installation_manager](https://github.com/joshbeard/puppet-ibm_installation_manager)
* [puppetlabs/stdlib](https://forge.puppetlabs.com/puppetlabs/stdlib)
* [puppetlabs/concat](https://forge.puppetlabs.com/puppetlabs/concat)

## Authors

Copyright 2015 Puppet Labs, Inc.

Josh Beard <beard@puppetlabs.com>

## Contributors

* Gabe Schuyler <gabe@puppetlabs.com>
* Jonathan Hooker
