
class LogfileReader
  # TODO add ability to search older log files
  attr_reader :logfile_name

  def initialize(logfile_name, with_dates = false)
    @logfile_name = logfile_name
    @with_dates   = with_dates
  end

  def contents
  end

  def search
    # TODO make search
  end

  private

  ##
  # returns all contents of log file. Should be okay to slurp the file, since
  # it's a logfile and has a size limit
  def all_contents
    @contents ||=
      begin
        c = []
        File.foreach(@logfile_name).with_index do |line, index|
          next if index == 0
          c << line
        end
        c
      end
  end

end

