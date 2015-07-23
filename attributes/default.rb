default['notifiable-diseases']['user'] = "nndd"
default['notifiable-diseases']['app_dir'] = "/u/apps/notifiable-diseases"
default['notifiable-diseases']['dist_dir'] = "#{node['notifiable-diseases']['app_dir']}/current/dist/nndd"
default['notifiable-diseases']['ruby_version'] = "1.9.3-p484"
default['notifiable-diseases']['deploy_action'] = "deploy"

default['notifiable-diseases']['repository'] = "https://github.com/instedd/notifiable-diseases.git"

override['nodejs']['npm']['install_method'] = 'source'
override['nodejs']['npm']['version'] = '1.4.24'
