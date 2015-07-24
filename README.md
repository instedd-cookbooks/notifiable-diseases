notifiable-diseases
===================

Cookbook for Notifiable Diseases dashboard

## Attributes

All attributes are within `notifiable-diseases` node:

* `user` Name of the user that builds the app
* `app_dir` Directory where the app will be checked out and built
* `dist_dir` Where the app will be built, defaults to `app_dir/current/dist/nndd`
* `ruby_version` Version of ruby to be installed via rbenv where compass will be installed, which is required for the build process
* `deploy_action` Overrides `application` cookbook deploy action, `deploy` by default

Optional attributes:

* `custom_styles` Path to custom SCSS to be used when compiling the app
* `settings` Path to JSON file with custom settings
* `repository` URI of the Git repository to download the code from (defaults to https://github.com/instedd/notifiable-diseases.git)
* `deploy_keys` If set, the recipe will look for a JSON file with that name under `deploy_keys`. Necessary to provision from private forks of NNDD.


## Usage

### notifiable-diseases::default

Include `notifiable-diseases` in your node's `run_list`:

```json
{
  "run_list": [
    "recipe[notifiable-diseases::default]"
  ]
}
```

## Known issues

* `imagemin.js` from node module `imagemin` may fail to load during the build process. If so, manually remove the `app_dir/node_modules` folder, then run `npm cache clean` and `npm install` as the `nndd` user.
