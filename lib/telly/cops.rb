require "active_support/core_ext/string/inflections"

require_relative "cops/redundant_route"
require_relative "client"

module Telly
  class << self
    def client
      @client ||= begin
          @port = Integer(ENV.fetch("TELLY_PORT", 1890))
          @url = ENV.fetch("TELLY_BASE_URL", "http://localhost:#{@port}/telly")

          start_server!

          Telly::Client.new(@url)
        end
    end

    private

    PID_PATH = File.absolute_path(File.join(".", "tmp", "pids", "telly.pid")).freeze
    SERVER_START_TIMEOUT_SECONDS = 10

    def start_server!
      if File.exist?(PID_PATH)
        @pid = File.read PID_PATH
      else
        @pid = spawn "./bin/rails server --port #{@port} --daemon --pid #{PID_PATH} >/dev/null 2>&1"
        # * 100 because it sleeps for 1/100
        max_count = SERVER_START_TIMEOUT_SECONDS * 100

        count = 0
        until File.exist? PID_PATH or count > max_count
          sleep 0.01
          count += 1
        end
      end
    end

    def stop_server!
      %x(kill `cat #{PID_PATH}` >/dev/null 2>&1) if File.exist? PID_PATH
    end
  end
end

at_exit do
  Telly.send :stop_server!
end
