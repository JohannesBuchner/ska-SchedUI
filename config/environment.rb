
require '/home/user/Downloads/jruby-1.6.0.RC1/lib/ruby/gems/1.8/gems/jdbc-mysql-5.1.13/lib/mysql-connector-java-5.1.13.jar'

# Load the rails application
require File.expand_path('../application', __FILE__)

# Initialize the rails application
SchedUI::Application.initialize!
