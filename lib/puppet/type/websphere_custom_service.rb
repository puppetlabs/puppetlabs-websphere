require 'pathname'
Puppet::Type.newtype(:websphere_custom_service) do

  @doc = "Manages custom services"

  ensurable do
    desc <<-EOT
    Valid values: `present`, `absent`

    Defaults to `present`.  Specifies whether this variable should exist or not.
    EOT

    defaultto(:present)

    newvalue(:present) do
      provider.create
    end

    newvalue(:absent) do
      provider.destroy
    end
  end
  
  newparam(:name, :namevar => true) do
    desc "Required. The name of the custom service."
  end
  
   newparam(:cell) do
    desc "Required. The name of the cell."
    validate do |value|
      unless value =~ /^[-0-9A-Za-z._]+$/
        fail("Invalid cell #{value}")
      end
    end
  end
  
  newparam(:profile) do
    desc "The profile to run 'wsadmin' under"
    validate do |value|
      if value.nil? and self[:dmgr_profile].nil?
        raise ArgumentError, 'profile is required'
      end

      if value.nil? and self[:dmgr_profile]
        defaultto self[:dmgr_profile]
      end

      unless value =~ /^[-0-9A-Za-z._]+$/
        raise ArgumentError, "Invalid profile #{value}"
      end
    end
  end
  
  newparam(:dmgr_profile) do
    defaultto { @resource[:profile] }
    desc <<-EOT
    The dmgr profile that this variable should be set under.  Basically, where
    are we finding `wsadmin`

    This is synonomous with the 'profile' parameter.

    Example: dmgrProfile01"
    EOT
  end
  
  newparam(:profile_base) do
    desc "The base directory that profiles are stored.
      Example: /opt/IBM/WebSphere/AppServer/profiles"

    validate do |value|
      unless Pathname.new(value).absolute?
        raise ArgumentError, "Invalid profile_base #{value}"
      end
    end
  end

  newparam(:user) do
    defaultto 'root'
    desc "The user to run 'wsadmin' with"
    validate do |value|
      unless value =~ /^[-0-9A-Za-z._]+$/
        raise ArgumentError, "Invalid user #{value}"
      end
    end
  end

  newparam(:wsadmin_user) do
    desc "The username for wsadmin authentication"
  end

  newparam(:wsadmin_pass) do
    desc "The password for wsadmin authentication"
  end 

  newparam(:node) do
    desc "The name of the node"
    validate do |value|
      unless value =~ /^[-0-9A-Za-z._]+$/
        raise ArgumentError, "Invalid node: #{value}"
      end
    end
  end
  
  newparam(:server) do
	desc "The server name."
  end
  
  newparam(:classpath) do
	desc "The class path for the custom service."
  end
  
  newparam(:enable) do
	desc "True or False to enable."
  end
  
  newparam(:external_config_url) do
	desc "The external config URL for the custom service."
  end
  
  newparam(:description) do
	desc "The description for the custom service."
  end
  
  newparam(:classname) do
	desc "The class name for the custom service."
  end
end
