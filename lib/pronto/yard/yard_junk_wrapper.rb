require 'yard-junk/janitor/pronto_reporter'
require 'yard-junk'

module Pronto
  module Yard
    # Wrapper to run and collect errors from YardJunk
    class YardJunkWrapper
      attr_reader :errors

      # @param path [String] The file's path to run yard report
      def initialize(path:)
        @path = path
        @errors = []
      end

      # @return [Array] Return an array of yard errors
      def run
        # Run in the context of the repo's path
        Dir.chdir(path) do
          # YardJunk outputs its version number and other things via `puts`
          silent do
            YardJunk::Janitor.new.run.report(:pronto, pronto: [errors])
          end
        end

        errors
      end

      private

      # Silence $stdout and $stderr for the given block
      def silent
        begin
          original_stderr = $stderr.clone
          original_stdout = $stdout.clone
          $stderr.reopen(File.new('/dev/null', 'w'))
          $stdout.reopen(File.new('/dev/null', 'w'))
          retval = yield
        rescue Exception => e
          $stdout.reopen(original_stdout)
          $stderr.reopen(original_stderr)
          raise e
        ensure
          $stdout.reopen(original_stdout)
          $stderr.reopen(original_stderr)
        end
        retval
      end

      attr_reader :path
    end
  end
end
