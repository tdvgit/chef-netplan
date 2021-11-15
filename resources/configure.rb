require "yaml"

default_action :create

property :interface,            String,   name_attribute: true
property :renderer,             String,   default: 'networkd'
property :version,              Integer,  default: 2
property :addresses,            Array,    default: []
property :nameservers,          Array,    default: []
property :config_file,          String,   default: '/etc/netplan/60-static-ips.yaml'
property :template_cookbook,    String,   default: 'netplan'
property :template_source,      String,   default: '60-static-ips.yaml.erb'

action :create do
  if new_resource.addresses && new_resource.addresses.to_a.any?
    corrected_addresses   =   []
    
    new_resource.addresses.to_a.each do |address|
      address             =   address.strip
      
      if address =~ /\/\d+$/
        corrected_addresses << address
      else
        corrected_addresses << "#{address}/24"
      end
    end
    
    config = {
      "network" => {
        "version" => new_resource.version,
        "renderer" => new_resource.renderer,
        "ethernets" => {
          new_resource.interface => {
            "addresses" => corrected_addresses
          }
        }
      }
    }
    
    if new_resource.nameservers && new_resource.nameservers.to_a.any?
      config["network"]["ethernets"][new_resource.interface]["nameservers"] ||= {}
      config["network"]["ethernets"][new_resource.interface]["nameservers"]["addresses"] = new_resource.nameservers.to_a
    end
  
    template new_resource.config_file do
      source    new_resource.template_source
      cookbook  new_resource.template_cookbook
      owner     'root'
      group     'root'
      mode      0755

      variables yaml: YAML.dump(config)
    end
  end
  notifies :run, 'execute[apply_netplan_configuration]', :immediately
end

action :delete do
  file new_resource.config_file do
    action :delete
    only_if { ::File.exists?(new_resource.config_file) }
  end
  notifies :run, 'execute[apply_netplan_configuration]', :immediately
end
