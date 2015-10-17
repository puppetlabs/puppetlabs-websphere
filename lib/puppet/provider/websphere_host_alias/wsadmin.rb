require 'puppet/provider/websphere_helper'

Puppet::Type.type(:websphere_host_alias).provide(:wsadmin, :parent => Puppet::Provider::Websphere_Helper) do

  def exists?
    # If it doesn't exist, the wsadmin should fail but since :failonfail is false it will create 
    ## (J|P)ython is whitespace sensitive, and this bit doesn't do well when
    ## being passed as a normal command-line argument. 
    cmd = <<-END
host_aliases =  AdminConfig.list('HostAlias', AdminConfig.getid( '/Cell:#{resource[:cell]}/VirtualHost:#{resource[:virtual_host]}/')).split(lineSeparator)
for alias in host_aliases:
  hostname = AdminConfig.showAttribute(alias, 'hostname')
  port = AdminConfig.showAttribute(alias, 'port')
  if hostname == '#{resource[:hostname]}' and port == '#{resource[:port]}':
      print hostname + ':' + port
      break
END

     self.debug "Running #{cmd}"
     result = wsadmin(:file => cmd, :user => resource[:user], :failonfail => false)
     self.debug "Result:\n#{result}"

     unless result =~ /.*#{resource[:hostname]}:#{resource[:port]}/
       return false
     end
     true  
  end
  
  def create
    # AdminConfig.create('HostAlias', AdminConfig.getid('/Cell:CELL_01/VirtualHost:TESTING/'), '[[hostname "testing.com"] [port "80"]]')
    cmd = "\"AdminConfig.create('HostAlias', "
    cmd += "AdminConfig.getid('/Cell:#{resource[:cell]}/VirtualHost:#{resource[:virtual_host]}/'), "
    cmd += "'[[hostname \"#{resource[:hostname]}\"] "
    cmd += "[port \"#{resource[:port]}\"]]')\""
    
    self.debug "Running #{cmd}"
    result = wsadmin(:command => cmd, :user => resource[:user])
    self.debug result
  end
  
  def destroy
    cmd = <<-END
host_aliases =  AdminConfig.list('HostAlias', AdminConfig.getid( '/Cell:#{resource[:cell]}/VirtualHost:#{resource[:virtual_host]}/')).split(lineSeparator)
for alias in host_aliases:
  hostname = AdminConfig.showAttribute(alias, 'hostname')
  port = AdminConfig.showAttribute(alias, 'port')
  if hostname == '#{resource[:hostname]}' and port == '#{resource[:port]}':
    AdminConfig.remove(alias)
    AdminConfig.save()
    break
END

    self.debug "Running #{cmd}"
    result = wsadmin(:file => cmd, :user => resource[:user])
    self.debug result

  end

end
