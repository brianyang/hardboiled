Vagrant::Config.run do |config|
  
  config.vm.box = "ubuntu-12.04.1"
  config.vm.box_url = "https://s3.amazonaws.com/vagrant-basebox/ubuntu-12.04.1.box"

  config.vm.share_folder "hardboiled", "/var/www", "."

  config.vm.provision :chef_solo do |chef|
    chef.cookbooks_path = "./.chef/cookbooks"
    chef.roles_path = "./.chef/roles"
    chef.add_role("standalone")
  end

  config.vm.forward_port 80, 8080

end
