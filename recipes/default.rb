execute 'apply_netplan_configuration' do
  command 'netplan apply'
  user    'root'
  action :nothing
end
