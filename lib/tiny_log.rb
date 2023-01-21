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
  # buffering: whether or not to buffer log output
  #   true, or not specified: log buffering is enabled
  #   false: log buffering is disabled - most useful for dev/test environments
  #     where you want to watch output in realtime
  # background_thread: whether logging should be done in a background Thread
  #   true, or not specified, use a Thread to write to the log every 5 seconds
  #   false, write to the log immediately
  def initialize(filename: nil, buffering: true, background_thread: true)
    @buffering = !!buffering
    @io = filename.is_a?(String) ? File.open(filename, 'a') : $stdout

    if background_thread
      @msg_queue = Queue.new
      @background_thread = Thread.new do |t|
        loop do
          @msg_queue
            .length
            .times{ @io.puts @msg_queue.shift }
          sleep 5
        end
      end
    end
  end

  # the clever bit that annotates the log message with a log level and UTC
  # timestamp
  def method_missing(prefix, *msgs)
    msgs.each{|m| _build_lines(m).each{|l| @background_thread ? @msg_queue << l : @io.puts(l) } }
    @io.flush unless @buffering

    nil
  end

  def _build_lines(m)
    m.to_s.lines.map do |l|
      "#{Time.now.utc.iso8601(6)} #{Process.pid.to_s.rjust(6)} #{prefix.to_s.upcase} #{l}"
    end
  end
end
