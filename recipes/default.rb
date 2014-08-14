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
  repository "https://bitbucket.org/instedd/notifiable-diseases.git"
  revision "master"
  action :sync
end

execute('npm install --unsafe-perm')    { cwd build_dir }
execute('bower install --allow-root')   { cwd build_dir }

grunt_args = custom_styles && "--custom-styles=#{custom_styles}" || ""
execute("grunt build #{grunt_args}")    { cwd build_dir }


execute("mv #{File.join(build_dir,'dist','nndd')} #{dist_dir}")