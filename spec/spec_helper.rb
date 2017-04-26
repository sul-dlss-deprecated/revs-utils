bootfile = File.expand_path(File.dirname(__FILE__) + '/../config/boot')
require bootfile

require 'coveralls'
Coveralls.wear!

RSpec.configure do |config|

  config.expect_with(:rspec) { |c| c.syntax = :should }

end

class RevsUtilsTester
  
  include Revs::Utils
  
end