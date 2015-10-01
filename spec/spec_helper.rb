bootfile = File.expand_path(File.dirname(__FILE__) + '/../config/boot')
require bootfile

require 'coveralls'
Coveralls.wear!

class RevsUtilsTester
  
  include Revs::Utils
  
end