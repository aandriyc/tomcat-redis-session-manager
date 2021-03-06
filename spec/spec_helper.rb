require File.expand_path('../support/requests_helper', __FILE__)

SESSION_PATH = '/session'
SESSIONS_PATH = '/sessions'
SESSION_ATTRIBUTES_PATH = '/session/attributes'
SETTINGS_PATH = '/settings'

# This file was generated by the `rspec --init` command. Conventionally, all
# specs live under a `spec` directory, which RSpec adds to the `$LOAD_PATH`.
# Require this file using `require "spec_helper"` to ensure that it is only
# loaded once.
#
# See http://rubydoc.info/gems/rspec-core/RSpec/Core/Configuration
RSpec.configure do |config|
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  # Run specs in random order to surface order dependencies. If you find an
  # order dependency and want to debug it, you can fix the order by providing
  # the seed, which is printed after each run.
  #     --seed 1234
  config.order = 'random'

  config.include RequestsHelper

  should_build_and_install_on_vagrant = true
  has_built_and_installed_on_vagrant = false

  config.before :all do
    root_project_path = File.expand_path('../../', __FILE__)
    vagrant_path = File.join(root_project_path, 'vagrant', 'tomcat-redis-example')
    example_app_path = File.join(root_project_path, 'example-app')
    #unless `cd #{vagrant_path} && vagrant status --machine-readable | awk -F, '$3 ~ /^state$/ { print $4}'`.strip == 'running'
    #  raise "Expected vagrant to be running."
    #end

    if should_build_and_install_on_vagrant && !has_built_and_installed_on_vagrant
      # build manager
      build_manager_command = <<-eos
        cd #{root_project_path} \
        && gradle clean \
        && gradle build
      eos
      `#{build_manager_command}`

      # build example app
      build_example_app_command = <<-eos
        cd #{example_app_path} \
        && gradle clean \
        && gradle war
      eos
      `#{build_example_app_command}`

      deploy_command = <<-eos
        cd #{vagrant_path} \
        && vagrant ssh -c "\
          sudo service tomcat7 stop \
          && sudo mkdir -p /var/lib/tomcat7/lib \
          && sudo rm -rf /var/lib/tomcat7/lib/tomcat-redis-session-manager* \
          && sudo cp /opt/tomcat-redis-session-manager/build/libs/tomcat-redis-session-manager*.jar /var/lib/tomcat7/lib/ \
          && sudo rm -rf /var/lib/tomcat7/webapps/example* \
          && sudo cp /opt/tomcat-redis-session-manager/example-app/build/libs/example-app*.war /var/lib/tomcat7/webapps/example.war \
          && sudo rm -f /var/log/tomcat7/* \
          && sudo service tomcat7 start \
        "
      eos
      `#{deploy_command}`

      has_built_and_installed_on_vagrant = true
    end
  end
end
