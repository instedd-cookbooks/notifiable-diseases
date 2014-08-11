include_recipe "nodejs"

include_recipe "grunt_cookbook::install_grunt_cli"

# grunt build

directory "/opt/notifiable-diseases" do
  owner "root"
  group "root"
  mode 0777 #FIXME
  action :create
end

git "/opt/notifiable-diseases" do
  repository "https://bitbucket.org/instedd/notifiable-diseases.git"
  revision "master"
  action :sync
end