Puppet::Type.newtype(:websphere_session_management_cookies) do  
  @doc = "Manages cookies' settings under session management."
 
  ensurable
  
  newparam(:name, :namevar => true) do
    desc "Required. The name of the cookie."
    validate do |value|
      if value.nil?
        raise ArgumentError, 'The name of the cookie is required'
      end
      unless value =~ /^[-0-9A-Za-z._]+$/
        fail("Invalid name #{value}")
      end
    end
  end

  newparam(:cell) do
    desc "Required. The name of the cell."
    validate do |value|
      if value.nil?
        raise ArgumentError, 'cell is required'
      end
      unless value =~ /^[-0-9A-Za-z._]+$/
        fail("Invalid cell #{value}")
      end
    end
  end
  
  newparam(:node) do
    desc "Required. The name of the node."
    validate do |value|
      if value.nil?
        raise ArgumentError, 'node is required'
      end
      unless value =~ /^[-0-9A-Za-z._]+$/
        fail("Invalid node #{value}")
      end
    end
  end
  
  newparam(:server) do
    desc "Required. The name of the AppServer."
    validate do |value|
      if value.nil?
        raise ArgumentError, 'server is required'
      end
      unless value =~ /^[-0-9A-Za-z._]+$/
        fail("Invalid server #{value}")
      end
    end
  end
  
  newproperty(:maximum_age) do
    desc "The maximum age of the cookie."
    validate do |value|
      if value.nil?
        raise ArgumentError, 'The age of the cookie is required'
      end
      unless value =~ /^-?\d+$/
        fail("Invalid maximum age #{value}")
      end
    end
  end
  
  newproperty(:use_context_root_as_path) do
    desc "true or false whether to use the context root as the cookies' path."
    munge do |value|
      value.to_s
    end
  end
  
  newproperty(:domain) do
    desc "The domain of the cookie."
  end
  
  newproperty(:cookie_path) do
    desc "The cookies' path."
  end
  
  newproperty(:secure) do
    desc "true or false whether to Restrict cookies to HTTPS sessions"
    munge do |value|
      value.to_s
    end
  end
  
  newproperty(:http_only) do
    desc "true or false whether to Set session cookies to HTTPOnly to help prevent cross-site scripting attacks."
    munge do |value|
      value.to_s
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
  
end
