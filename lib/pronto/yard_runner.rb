require 'pronto'
require 'pronto/yard/version'
require 'pronto/yard/yard_junk_wrapper'

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
      wrapper = Yard::YardJunkWrapper.new(path: @patches.repo.path)
      wrapper.run
      wrapper.errors
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
