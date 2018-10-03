require 'bundler'
Bundler.require
Dotenv.load

require_relative '../app/cli/cli_methods.rb'
require_relative '../app/models/artist.rb'
require_relative '../app/models/userartist.rb'
require_relative '../app/models/user.rb'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: 'db/development.db')
require_all 'lib'
