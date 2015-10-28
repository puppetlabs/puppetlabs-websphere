require 'puppet/provider/websphere_helper'

Puppet::Type.type(:websphere_jdbc_datasource).provide(:wsadmin, :parent => Puppet::Provider::Websphere_Helper) do

  def scope(what)
    case resource[:scope]
    when 'cell'
      mod_path = "Cell=#{resource[:cell]}"
      get      = "Cell:#{resource[:cell]}"
      path     = "cells/#{resource[:cell]}"
    when 'server'
      mod_path = "Cell=#{resource[:cell]},Server=#{resource[:server]}"
      get      = "Cell:#{resource[:cell]}/Node:#{resource[:node]}/Server:#{resource[:server]}"
      path     = "cells/#{resource[:cell]}/nodes/#{resource[:node]}/servers/#{resource[:server]}"
    when 'cluster'
      mod_path = "Cluster=#{resource[:cluster]}"
      get      = "Cell:#{resource[:cell]}/ServerCluster:#{resource[:cluster]}"
      path     = "cells/#{resource[:cell]}/clusters/#{resource[:cluster]}"
    when 'node'
      mod_path = "Node=#{resource[:node]}"
      get      = "Cell:#{resource[:cell]}/Node:#{resource[:node]}"
      path     = "cells/#{resource[:cell]}/nodes/#{resource[:node]}"
    end

    case what
    when 'mod'
      return mod_path
    when 'get'
      return get
    when 'path'
      return path
    end
  end

  def config_props
    case resource[:data_store_helper_class]
    when 'com.ibm.websphere.rsadapter.DB2UniversalDataStoreHelper'
      configprop = "[[databaseName java.lang.String #{resource[:database]}] "
      configprop += "[driverType java.lang.Integer #{resource[:db2_driver]}] "
      configprop += "[serverName java.lang.String #{resource[:db_server]}] "
      configprop += "[portNumber java.lang.Integer #{resource[:db_port]}]]"
    when 'com.ibm.websphere.rsadapter.MicrosoftSQLServerDataStoreHelper'
      configprop = "[[databaseName java.lang.String #{resource[:database]}] "
      configprop += "[portNumber java.lang.Integer #{resource[:db_port]}] "
      configprop += "[serverName java.lang.String #{resource[:db_server]}]]"
    when 'com.ibm.websphere.rsadapter.Oracle11gDataStoreHelper'
      configprop = "[[URL java.lang.String #{resource[:url]}]]"
    else
      raise Puppet::Error, "Can't deal with #{resource[:data_store_helper_class]}"
    end

    return configprop
  end


  def create
cmd = <<-EOT
provider = AdminConfig.getid( '/#{scope('get')}/JDBCProvider:#{resource[:jdbc_provider]}/' )
AdminTask.createDatasource(provider, '[-name "#{resource[:name]}" \
-jndiName #{resource[:jndi_name]} -dataStoreHelperClassName \
#{resource[:data_store_helper_class]} -containerManagedPersistence \
#{resource[:container_managed_persistence]} -componentManagedAuthenticationAlias \
#{resource[:component_managed_auth_alias]} -configureResourceProperties \
#{config_props} -description "#{resource[:description]}" ]')
AdminConfig.save()
EOT


    self.debug "Creating JDBC Datasource with:\n#{cmd}"
    result = wsadmin(:file => cmd, :user => resource[:user])
    self.debug "Result:\n#{result}"

  end

  def exists?
    cmd = "\"print AdminConfig.list('DataSource', AdminConfig.getid( '/"
    cmd += "#{scope('get')}/'))\""

    self.debug "Querying JDBC Datasource with #{cmd}"
    result = wsadmin(:command => cmd, :user => resource[:user])
    self.debug "Result: #{result}"

    if result =~ /^"?#{resource[:name]}\(#{scope('path')}\|/
      self.debug "Found match for #{resource[:name]}"
      return true
    end

    self.debug "Datasource #{resource[:name]} doesn't seem to exist in #{scope('path')}"
    return false

  end

  def destroy
    cmd = <<-EOT
id = AdminTask.getid( '/Datasource:#{resource[:name]}/' )
AdminTask.deleteDatasource(id)
AdminConfig.save()
EOT
    self.debug "Deleting JDBC DataSource with:\n#{cmd}"
    result = wsadmin(:file => cmd, :user => resource[:user])
    self.debug "Result:\n#{result}"
  end

  def flush
    case resource[:scope]
    when /(server|node)/
      sync_node
    end
  end
end
