# TODO: extract to attributes
nndd_dir = "/opt/notifiable-diseases"
nndd_git = "https://bitbucket.org/instedd/notifiable-diseases.git"
ruby_version = "1.9.3-p484"

include_recipe "rbenv::default"
include_recipe "rbenv::ruby_build"

rbenv_ruby ruby_version

rbenv_gem "compass" do
  ruby_version ruby_version
end

include_recipe "nodejs"
include_recipe "nodejs::npm"

nodejs_npm 'grunt-cli' do
  options ["--production"]
end

nodejs_npm 'bower' do
  options ["--production"]
end

directory nndd_dir do
  owner "root"
  group "root"
  mode 0777 #FIXME
  action :create
end

git nndd_dir do
  repository nndd_git
  revision "master"
  action :sync
end

execute('npm install --unsafe-perm &>> log-npm.txt')    { cwd nndd_dir }
execute('bower install --allow-root &>> log-bower.txt') { cwd nndd_dir }
execute('grunt build &>> log-grunt.txt')                { cwd nndd_dir }
