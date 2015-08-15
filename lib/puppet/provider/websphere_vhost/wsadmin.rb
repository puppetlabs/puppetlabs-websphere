require 'puppet/provider/websphere_helper'

Puppet::Type.type(:websphere_vhost).provide(:wsadmin, :parent => Puppet::Provider::Websphere_Helper) do
  
  def exists?
    cmd = "\"print AdminConfig.list('VirtualHost', AdminConfig.getid('/Cell:#{resource[:cell]}/'))\""

    self.debug "Running #{cmd}"
    result = wsadmin(:command => cmd, :user => resource[:user])
    self.debug result
   
    unless result =~ /#{resource[:name]}\(cells/
      return false
    end
    true
  end
	
  def create
    #AdminConfig.create('VirtualHost', AdminConfig.getid('/Cell:CELL_01/'), '[[name "TESTING"]]')
    cmd = "\"AdminConfig.create('VirtualHost', "
    cmd += "AdminConfig.getid('/Cell:#{resource[:cell]}/'), "
    cmd += "'[[name \"#{resource[:name]}\"]]')\""
	 
    self.debug "Running #{cmd}"
    result = wsadmin(:command => cmd, :user => resource[:user])
    self.debug result
  end
	
  def destroy
cmd = <<-EOT
\"AdminConfig.remove(AdminConfig.getid('/Cell:#{resource[:cell]}/VirtualHost:#{resource[:name]}/'))
AdminConfig.save()\"
   EOT
   
   self.debug "Running #{cmd}"
   wsadmin(:command => cmd, :user => resource[:user])
  end
end
