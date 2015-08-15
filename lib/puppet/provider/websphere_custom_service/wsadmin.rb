require 'puppet/provider/websphere_helper'

Puppet::Type.type(:websphere_custom_service).provide(:wsadmin, :parent => Puppet::Provider::Websphere_Helper) do

  def exists?
    # If it doesn't exist, the wsadmin should fail but since :failonfail is false it will create
    cmd = "\"cs_name =  AdminConfig.list('CustomService', AdminConfig.getid('/Cell:#{resource[:cell]}/Node:#{resource[:node]}/Server:#{resource[:server]}/'));"
    cmd += "print AdminConfig.showAttribute(cs_name, 'displayName')\""
   
    self.debug "Running #{cmd}"
    result = wsadmin(:command => cmd, :user => resource[:user], :failonfail => false)
    self.debug "RESULT IS: #{result}"
   
    unless result =~ /.*#{resource[:name]}.*/
       return false
    end
    true
  end
	
  def create
    # AdminConfig.create('CustomService', AdminConfig.getid('/Cell:CELL_01/Node:FEKETENODE_01/Server:FeketeAppServer01/'), '[[displayName "Introscope Custom Service"] [classpath "/opt/was/wily/WebAppSupport.jar"] [enable "true"] [externalConfigURL ""] [description "Introscope Custom Service"] [classname "com.wily.introscope.api.websphere.IntroscopeCustomService"]]')
     cmd = <<-EOT
\"AdminConfig.create('CustomService', AdminConfig.getid('/Cell:#{resource[:cell]}/Node:#{resource[:node]}/Server:#{resource[:server]}/'), '[[displayName \\"#{resource[:name]}\\"] [classpath \\"#{resource[:classpath]}\\"] [enable \\"#{resource[:enable]}\\"] [externalConfigURL \\"#{resource[:external_config_url]}\\"] [description \\"#{resource[:description]}\\"] [classname \\"#{resource[:classname]}\\"]]');AdminConfig.save()\"
     EOT
		
     self.debug "Running #{cmd}"
     result = wsadmin(:command => cmd, :user => resource[:user])
     self.debug result
  end
	
  def destory
    Puppet.warning("Removal of custom services is not yet implemented.") 
  end
end
