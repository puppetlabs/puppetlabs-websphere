require 'puppet/provider/websphere_helper'

Puppet::Type.type(:websphere_session_management_cookies).provide(:wsadmin, :parent => Puppet::Provider::Websphere_Helper) do

  mk_resource_methods

  def exists?
    @property_hash[:ensure] == :present
  end

  def create
    @property_flush[:ensure] = :present
  end

  def destroy
    @property_flush[:ensure] = :absent
  end 

  def initialize(value={})
    super(value)
    @property_flush = {}
  end

  def modify
    if @property_flush[:ensure] == :absent
        return
    end

    # AdminConfig.modify('(cells/CELL_01/nodes/APPNODE_01/servers/alpha|server.xml#Cookie_1435255093513)', '[[maximumAge "-1"] [name "JSESSIONID"] [useContextRootAsPath "false"] [domain ""] [path "/"] [secure "true"] [httpOnly "true"]]')
   
    cmd = <<-EOT
\"print AdminConfig.list('Cookie' , '#{resource[:name]}\\(cells/#{resource[:cell]}\\/nodes\\/#{resource[:node]}\\/servers\\/#{resource[:server]}\\|server\\.xml#Cookie_\\d*\\)')\"
    EOT

    result = wsadmin(:command => cmd, :user => resource[:user], :failonfail => false)
    
    unless result =~ /#{resource[:name]}\(cells.*/
      Puppet.warning( "Cookie does not exist. Shouldn't actually happen")
    end

    id = result.match(/(?!.*#Cookie_)\d+(?=\))/)

    cmd = <<-EOT
\"AdminConfig.modify('(cells/#{resource[:cell]}/nodes/#{resource[:node]}/servers/#{resource[:server]}|server.xml#Cookie_#{id})', '[[maximumAge \\"#{resource[:maximum_age]}\\"] [name \\"#{resource[:name]}\\"] [useContextRootAsPath \\"#{resource[:use_context_root_as_path]}\\"] [domain \\"#{resource[:domain]}\\"] [path \\"#{resource[:cookie_path]}\\"] [secure \\"#{resource[:secure]}\\"] [httpOnly \\"#{resource[:http_only]}\\"]]');AdminConfig.save()\"
    EOT

    result = wsadmin(:command => cmd, :user => resource[:user])
  end

  def maximum_age=(value)
    @property_flush[:maximum_age] = value
  end

  def use_context_root_as_path=(value)
    @property_flush[:use_context_root_as_path] = value
  end

  def domain=(value)
    @property_flush[:domain] = value
  end

  def cookie_path=(value)
    @property_flush[:cookie_path] = value
  end

  def secure=(value)
    @property_flush[:secure] = value
  end

  def http_only=(value)
    @property_flush[:http_only] = value
  end

  def flush
     modify()
  end
end

