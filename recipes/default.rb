# TODO: extract to attributes
build_dir = "/tmp/nndd-build"
nndd_dir = "/opt/notifiable-diseases"
nndd_git = "https://bitbucket.org/instedd/notifiable-diseases.git"
ruby_version = "1.9.3-p484"


#------ Install ruby and compass

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

directory build_dir do
  recursive true
  action :delete
end

git build_dir do
  repository nndd_git
  revision "master"
  action :sync
end

execute('npm install --unsafe-perm')    { cwd build_dir }
execute('bower install --allow-root') { cwd build_dir }
execute('grunt build')                { cwd build_dir }

execute("mv #{File.join(build_dir,'dist','nndd')} #{nndd_dir}")