bootfile = File.expand_path(File.dirname(__FILE__) + '/../config/boot')
require bootfile

class RevsUtilsTester
  
  include Revs::Utils
  
end