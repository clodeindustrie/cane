require 'parallel'

require 'cane/violation_formatter'
require 'cane/json_formatter'
require 'cane/emacs_formatter'

module Cane
  def run(*args)
    Runner.new(*args).run
  end
  module_function :run

  # Orchestrates the running of checks per the provided configuration, and
  # hands the result to a formatter for display. This is the core of the
  # application, but for the actual entry point see `Cane::CLI`.
  class Runner
    def initialize(spec)
      @opts = spec
      @checks = spec[:checks]
    end

    def run
      outputter.print formatter.new(violations)

      violations.length <= opts.fetch(:max_violations)
    end

    protected

    attr_reader :opts, :checks

    def violations
      @violations ||= checks.
        map {|check| check.new(opts).violations }.
        flatten
    end

    def outputter
      opts.fetch(:out, $stdout)
    end

    def formatter
      if opts[:json]
        JsonFormatter
      elsif opts[:emacs]
        EmacsFormatter
      else
        ViolationFormatter
      end
    end
  end
end
