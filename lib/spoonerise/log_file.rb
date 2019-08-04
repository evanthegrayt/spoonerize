#===============================================================#
#  File::        log_file.rb                                    #
#  Description:: Class that handles writing/reading the log     #
#                                                               #
#  Author::      Evan Gray                                      #
#===============================================================#
require 'csv'

module Spoonerise
class LogFile

  attr_reader :logfile

  def initialize
    @logfile ||= File.expand_path(
      File.join(File.dirname(__FILE__), '..', '..', 'log', 'spoonerise.log')
    )
  end

  def write(original, modified, options = '')
    CSV.open(logfile, 'a') { |csv| csv << [date, original, modified, options] }
  end

  def read(&block)
    CSV.foreach(logfile) do |row|
      yield row
    end
  end

  private

  def date
    Time.now.strftime('%Y-%m-%d %H:%M:%S')
  end

end
end

