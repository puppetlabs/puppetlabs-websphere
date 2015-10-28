require 'puppet/provider/websphere_helper'

Puppet::Type.type(:websphere_jdbc_provider).provide(:wsadmin, :parent => Puppet::Provider::Websphere_Helper) do

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

  def create
cmd = <<-EOT
AdminTask.createJDBCProvider('[-scope #{scope('mod')} -databaseType \
#{resource[:dbtype]} -providerType "#{resource[:providertype]}" \
-implementationType "#{resource[:implementation]}" -name "#{resource[:name]}" \
-description "#{resource[:description]}" -classpath \
[ #{resource[:classpath]} ] -nativePath
EOT

    if resource[:nativepath]
      cmd = "#{cmd.chomp} [ #{resource[:nativepath]} ] "
    else
      cmd = cmd.chomp + ' "" '
    end
    cmd += "]'); AdminConfig.save()"

    self.debug "Creating JDBC Provider with #{cmd}"
    result = wsadmin(:file => cmd, :user => resource[:user])
    self.debug "Result: #{result}"

  end

  def exists?
    cmd = "\"print AdminConfig.list('JDBCProvider', AdminConfig.getid( '/"
    cmd += "#{scope('get')}/'))\""

    self.debug "Querying JDBC Provider with #{cmd}"
    result = wsadmin(:command => cmd, :user => resource[:user])
    self.debug "Result: #{result}"

    if result =~ /^"?#{resource[:name]}\(#{scope('path')}\|/
      self.debug "Found match for #{resource[:name]}"
      return true
    end

    self.debug "#{resource[:name]} doesn't seem to exist."
    return false

  end

  def destroy
    cmd = <<-EOT
id = AdminConfig.getid( '/#{scope('get')}/JDBCProvider:#{resource[:name]}/' )
AdminTask.deleteJDBCProvider(id)
AdminConfig.save()
EOT

    self.debug "Deleting JDBC Provider with:\n#{cmd}"
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
