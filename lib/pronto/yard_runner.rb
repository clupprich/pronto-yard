require 'pronto'
require 'pronto/yard/version'
require 'yard-junk'

module YardJunk
  class Janitor
    class ProntoReporter
      def initialize(errors)
        @errors = errors
      end

      def finalize; end

      def section(_, _, messages)
        messages.each do |message|
          errors << OpenStruct.new(message: message.message, file: message.file, line: message.line)
        end
      end

      def stats(**stat); end

      private

      attr_reader :errors
    end
  end
end

module Pronto
  class YardRunner < Runner
    def initialize(*args)
      super
    end

    # Entry point to our Pronto runner
    def run
      errors = run_yard

      ruby_patches.map do |patch|
        # TODO: Move this to a regex or something, but don't use a private method
        path = patch.send(:new_file_path)
        errors_for_patch = errors.select { |error| error.file == path }

        inspect(patch, errors_for_patch)
      end.flatten.compact
    end

    private

    def run_yard
      errors = []

      # Run in the context of the repo's path
      Dir.chdir(@patches.repo.path) do
        # Silence puts statements
        silent do
          YardJunk::Janitor.new.run.report(:pronto, pronto: [errors])
        end
      end

      errors
    end

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

    def inspect(patch, errors)
      return unless errors.any?

      errors.map do |error|
        patch.added_lines
             .select { |line| line.new_lineno == error.line }
             .map { |line| new_message(error, line) }
      end
    end

    def new_message(error, line)
      path = line.patch.delta.new_file[:path]
      Message.new(path, line, :info, error.message, nil, self.class)
    end
  end
end
