require 'time'

# This class provides a simple logging utility with some metadata attached:
# - timestamp to the microsecond
# - the process ID
# - logger level
# - the log message
#
# Ex:
#   l = Log.new
#   l.erro('hi there')
#   l.erro('hi there')
#   2022-11-18T01:26:37.086295Z  92967 ERRO hi there
#   ^timestamp to microsecond    ^pid  ^lvl ^log message
class TinyLog
  # filename: the I/O stream to send log messages to
  #   if unspecified, will default to $stdout
  #   if specified, attempts to open a file with the specified name to append to
  def initialize(filename=nil)
    @io = filename ? File.open(filename, 'a') : $stdout
  end

  # the clever bit that annotates the log message with a log level and UTC
  # timestamp
  def method_missing(prefix, *msgs)
    msgs.each do |m|
      m.lines.each do |l|
        @io.puts "#{Time.now.utc.iso8601(6)} #{Process.pid.to_s.rjust(6)} #{prefix.to_s.upcase} #{l}"
      end
    end

    nil
  end
end
