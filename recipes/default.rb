# Create user

nndd_user = node['notifiable-diseases']['user']
user nndd_user do
  home "/home/#{nndd_user}"
  supports manage_home: true
end


# Install package dependencies

package 'gifsicle'
package 'libpng-dev'


# Install ruby and compass

include_recipe "rbenv::default"
include_recipe "rbenv::ruby_build"

rbenv_ruby node['notifiable-diseases']['ruby_version']

rbenv_gem "compass" do
  ruby_version node['notifiable-diseases']['ruby_version']
end


# Install node, grunt and bower

include_recipe "nodejs"
include_recipe "nodejs::npm"

nodejs_npm('grunt-cli')   { options ["--production"] }
nodejs_npm('bower')       { options ["--production"] }


# Deploy application and build

app_dir = node['notifiable-diseases']['app_dir']

application "notifiable-diseases" do
  revision node['notifiable-diseases']['revision'] if node['notifiable-diseases']['revision']
  repository "https://github.com/instedd/notifiable-diseases.git"
  path app_dir
  owner nndd_user

  action node['notifiable-diseases']['deploy_action']

  rollback_on_error false

  before_deploy do
    directory("#{app_dir}/shared/node_modules")         { owner nndd_user }
    directory("#{app_dir}/shared/bower_components")     { owner nndd_user }
  end

  symlinks 'node_modules' => 'node_modules', 'bower_components' => 'bower_components'

  purge_before_symlink []
  symlink_before_migrate({})
  restart_command ""
  migrate false

  before_restart do
    execute_opts = proc do
      cwd release_path
      user nndd_user
      env 'HOME' => "/home/#{nndd_user}", 'PATH' => "#{ENV['PATH']}:#{node[:rbenv][:root_path]}/shims/"
    end

    execute "npm install",   &execute_opts
    execute "bower install", &execute_opts

    custom_styles = node['notifiable-diseases']['custom_styles']
    settings = node['notifiable-diseases']['settings']

    grunt_args = %W(custom_styles settings).map do |arg|
      value = node['notifiable-diseases'][arg]
      value && "--#{arg.gsub('_', '-')}=\"#{value}\""
    end.compact.join(' ')

    execute "grunt build #{grunt_args}", &execute_opts
  end

end
