# Manages DMGR profiles in a WebSphere cell
define websphere::profile::dmgr (
  $instance_base,
  $cell,
  $node_name,
  $profile_base            = undef,
  $profile_name            = $title,
  $user                    = $::websphere::user,
  $group                   = $::websphere::group,
  $dmgr_host               = $::fqdn,
  $template_path           = undef,
  $options                 = undef,
  $manage_service          = true,
  $manage_sdk              = false,
  $sdk_name                = undef,
  $collect_nodes           = true,
  $collect_web_servers     = true,
  $collect_jvm_logs        = true,
  $wsadmin_user            = undef,
  $wsadmin_pass            = undef,
) {

  validate_absolute_path($instance_base)
  validate_string($cell)
  validate_string($node_name)
  validate_string($profile_name)
  validate_string($user)
  validate_string($group)
  validate_string($dmgr_host)

  ## Template path. Figure out a sane default if not explicitly specified.
  if ! $template_path {
    $_template_path = "${instance_base}/profileTemplates/dmgr"
  } else {
    $_template_path = $template_path
  }
  validate_absolute_path($_template_path)

  if ! $profile_base {
    $_profile_base = "${instance_base}/profiles"
  } else {
    $_profile_base = $profile_base
  }
  validate_absolute_path($_profile_base)

  if $manage_sdk and !$sdk_name {
    fail('sdk_name is required when manage_sdk is true. E.g. 1.71_64')
  }

  if ! $options {
    $_options = "-create -profileName ${profile_name} -profilePath ${_profile_base}/${profile_name} -templatePath ${_template_path} -nodeName ${node_name} -hostName ${dmgr_host} -cellName ${cell}"
  } else {
    $_options = $options
  }
  validate_string($_options)

  # Create the DMGR profile
  # IBM's crap almost always exits 0, so we test that the profile directory
  # at leasts exists before saying success.
  exec { "was_profile_dmgr_${title}":
    command => "${instance_base}/bin/manageprofiles.sh ${_options} && test -d ${_profile_base}/${profile_name}",
    creates => "${_profile_base}/${profile_name}",
    path    => '/bin:/usr/bin:/sbin:/usr/sbin',
    user    => $user,
    timeout => 900,
  }

  # Ensure ownership of profile directory is correct
  websphere::ownership { $title:
    user    => $user,
    group   => $group,
    path    => "${_profile_base}/${profile_name}",
    require => Exec["was_profile_dmgr_${title}"],
  }

  # We use the DMGR hostname/fqdn to export a file resource so nodes can
  # federate with us.
  $_dmgr_host = downcase($dmgr_host)
  $_cell      = downcase($cell)
  $_profile   = downcase($profile_name)
  $_node      = downcase($node_name)
  $soap_port  = getvar("websphere_${_profile}_${_cell}_${_node}_soap")

  if $soap_port {
    @@file { "/etc/dmgr_${_dmgr_host}_${_cell}":
      ensure  => 'file',
      content => template("${module_name}/dmgr_federation.yaml.erb"),
    }
  }

  validate_bool($manage_sdk)
  if $manage_sdk {
    websphere_sdk { "${title} SDK Version ${sdk_name}":
      profile             => $profile_name,
      server              => 'all',
      sdkname             => $sdk_name,
      instance_base       => $instance_base,
      new_profile_default => $sdk_name,
      command_default     => $sdk_name,
      user                => $user,
      wsadmin_user        => $wsadmin_user,
      wsadmin_pass        => $wsadmin_pass,
      require             => Exec["was_profile_dmgr_${title}"],
      subscribe           => Websphere::Ownership[$title],
    }
  }

  validate_bool($manage_service)
  if $manage_service {
    websphere::profile::service { $title:
      type         => 'dmgr',
      profile_base => $_profile_base,
      user         => $user,
      wsadmin_user => $wsadmin_user,
      wsadmin_pass => $wsadmin_pass,
      require      => Exec["was_profile_dmgr_${title}"],
      subscribe    => Websphere::Ownership[$title],
    }
  }

  validate_bool($collect_nodes)
  if $collect_nodes {
    Websphere_node <<| cell == $cell and dmgr_host == $dmgr_host |>> {
      profile_base => $_profile_base,
      dmgr_profile => $title,
      user         => $user,
      wsadmin_user => $wsadmin_user,
      wsadmin_pass => $wsadmin_pass,
    }
  }

  validate_bool($collect_web_servers)
  if $collect_web_servers {
    Websphere_web_server <<| cell == $cell and dmgr_host == $dmgr_host |>> {
      profile_base => $_profile_base,
      dmgr_profile => $title,
      user         => $user,
      wsadmin_user => $wsadmin_user,
      wsadmin_pass => $wsadmin_pass,
    }
  }

  validate_bool($collect_jvm_logs)
  if $collect_jvm_logs {
    Websphere_jvm_log <<| cell == $cell and dmgr_host == $dmgr_host |>> {
      profile_base => $_profile_base,
      profile      => $title,
      user         => $user,
      wsadmin_user => $wsadmin_user,
      wsadmin_pass => $wsadmin_pass,
    }
  }

}
