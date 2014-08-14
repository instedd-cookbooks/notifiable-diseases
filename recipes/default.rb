nndd_user = node['notifiable-diseases']['user']

user nndd_user

#------ Install ruby and compass

ruby_version = node['notifiable-diseases']['ruby_version']

include_recipe "rbenv::default"
include_recipe "rbenv::ruby_build"

rbenv_ruby ruby_version

rbenv_gem "compass" do
  ruby_version ruby_version
end


#------ Install node, grunt and bower

include_recipe "nodejs"
include_recipe "nodejs::npm"

nodejs_npm('grunt-cli')   { options ["--production"] }
nodejs_npm('bower')       { options ["--production"] }


#------ Clone git and build

build_dir  = "/tmp/nndd-build"
dist_dir = node['notifiable-diseases']['dist_dir']
custom_styles = node['notifiable-diseases']['custom_styles']

directory build_dir do
  recursive true
  action :delete
end

git build_dir do
  user nndd_user
  repository "https://bitbucket.org/instedd/notifiable-diseases.git"
  revision "master"
  action :sync
end

execute('npm install') do
  cwd build_dir
  command "su #{nndd_user} -c 'npm install'"
end

execute('bower install') do
  cwd build_dir
  command "su #{nndd_user} -c 'bower install'"
end

grunt_args = custom_styles && "--custom-styles=#{custom_styles}" || ""
execute("grunt build") do
  cwd build_dir
  command "su #{nndd_user} -c 'grunt build #{grunt_args}'"
end


execute("mv #{File.join(build_dir,'dist','nndd')} #{dist_dir}")