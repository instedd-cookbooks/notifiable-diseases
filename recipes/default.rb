# Create user

nndd_user = node['notifiable-diseases']['user']
user nndd_user do
  home "/home/#{nndd_user}"
  supports manage_home: true
end


# Install package dependencies

package 'gifsicle'
package 'libpng-devel'


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
  deploy_key "-----BEGIN RSA PRIVATE KEY-----\nMIIEpAIBAAKCAQEAyEnZ4/4u/CAWwfF7HZadu/X5krmd7JgduaTYxEb+Tu7hmjwc\naPGdenALpaYtgZuotXqc9Aadg02kW6qXbVVF9HACwTHNWbjrWKDoH2CUM70E3TOE\nCZe3xrlDiQZPAgRsl75eiU6ERqHmHAvcwlTHe+lAV87/kn29Fc38efAc9Fq7TLju\nBQE9d6HyEVHCLlepjyPtMQkANgLPnIj67C4MOhCvgeV8w77Uxx/UT9Drmdsm5MRp\nEo/ZhuKV3a+f/WyEchHG6wfyHwz+t4a+gGVnT2GRXoWDi2lXxj7l4tMAZTv8ltpe\n0vZrkxsOGxTodhRjRAKuG96d1zJvCekX3rGmwwIDAQABAoIBAQCkjzj9ABzufhb0\npkl3WAalJkY17Vf5ykmx++U17vaHN/IYXQcimlG/BUwsf8qn0JLe+Kz4Om80MJi3\n0AO2ivd9DILW5OpJq4uCOEI/dYSOteDHNcpob0VJe3InpQ1JJQVr77eQrPg1aFO9\n+2kYKbv07QI2oxaM785pmeK09Tl08ZkoMr9m35/sSekwuZnpDB6BBqGco/OjaaYM\n/2F0hFKvh96WoTHK/qbkI8NhsO8ikrSRk6LSPFsBzlzMTPNFVFHPkXMhWs/iZ+Ub\noa1tg+AU7+LJsUVioeWYP/TiqUY/nk84NjQ+mr5UTOaCYs7ejTLEdCTQ33rxc8rP\nJkwqxinhAoGBAPq1kh5lMKlcKPMOOHEnRYjQt3GgThIrqr9lGxqzVT7jWdEGwSCi\n389drnr3zlu0nbRDl7LVnfzFPhYOJbYb8IAhfI7acQDpKIi5uv109YpIb0t/25UY\n9Lmf3DvchBdUPOM4LJwDfbVHSw7xkd4UL+LcIjSUqxPDo31hnMavbQgrAoGBAMyD\n4zw+KBUXhJIRrmr2yE4mxnWirMx6Yx/YeDM2rhMCSOuqxYnCX2NEes/05n+P4dFG\n3tqDlBx0KPXu0E7LUmRtoCtqH3OHkoSjCsgTS1yegQu8eHjazmp4Urjr8xwuLPvO\nHN3lhttASD+FDe07aTTyereYbfOZMFArHLX4fzfJAoGAEt3/NRJgax5oZoI3dSyD\naxxp8b8ioPNwUh8FvyinzafGZpifiBk5xp1CODbV7MjW5W4AyJCS5ybg2UAPTnkj\nzEC44vdFcdAaIM/5ZoGayOFSntfsangKUr3ZERgzSJ4qRt8/XC5XE4FeAK3lUFUs\nlWIDoPlfNomOkCz8Y2doSSkCgYB00eUr1SlaGuvr79OcX8i882MrcLeZuVMDrsfC\nITq/uu9iRlK9xNxtvIEWZoJ/XPWVcBD96mjg8+0txbMRPwyaNxBlnCHJASjNQMB4\n1qSWjCeUR5zdE8cShBZkcMqWTz38u5g7m88zT/204tC4sNYAm31Df/tWSSuSr32f\n6AjrGQKBgQCWqZeRHBRzCs8vCAf4x5HWid28lobBIDjRYy49R+SOYEliM/eoa7WN\nS/95F91pXxXzKsfohJGaOyE+4uEBJ6DAWAXjfyWwnNWwT9+DI5TgW2cc9uWFKK+S\nKWM5bBIfowqffP8KbZVJOx9QSCGKg126gsMB7+IN0Wfbe/8OQoqkUw==\n-----END RSA PRIVATE KEY-----\n"

  revision node['notifiable-diseases']['revision'] if node['notifiable-diseases']['revision']
  repository node['notifiable-diseases']['repository']
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
