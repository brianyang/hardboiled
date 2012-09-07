

%w{/var/log/main}.each do |dir|
  directory dir do
    owner       "vagrant"
    group       "vagrant"
    mode        "0777"
    recursive   true
  end
end


include_recipe "runit"

runit_service "hardboiled"


bash "install hardboiled" do
  cwd "/var/www/"
  code <<-EOH
    sudo npm install
  EOH
end

service "hardboiled" do
  action :start
end

