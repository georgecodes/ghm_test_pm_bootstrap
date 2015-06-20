require 'rubygems'
require 'json'

module AMP
	class HostEnc

		def resolve(host_name)
		  conf = JSON.parse(read_file('conf/conf.json'))
		  hostnames = conf['hostnames']
		  hostnames.each do | k,v |
		  		if(host_name.start_with?(k)) 
		  			return get_node_def(v)
		  		end
		  end
		  raise "Could not find node definition"
		end

		def get_node_def(node_def_name)
			content = read_file("nodes/#{node_def_name}.yaml")
			return content
		end

		def read_file(relative_path)
			filename = File.join(File.expand_path(File.dirname(__FILE__)), "../#{relative_path}")
			File.read filename
		end

	end
end