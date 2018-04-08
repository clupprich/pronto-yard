module YardJunk
  class Janitor
    # Reporter that populates an array with the generated messages by YardJunk (so they can be reused elsewhere).
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
