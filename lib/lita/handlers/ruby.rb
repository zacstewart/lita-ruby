module Lita
  module Handlers
    class Ruby < Handler

      class StandardChat
        def initialize(response)
          @response = response
          @buffer = String.new
        end

        def write(string)
          @buffer << string
        end

        def puts(string)
          self.write string
          self.write "\n"
          flush
        end

        def flush
          @response.reply @buffer.strip
          @buffer.clear
        end
      end

      route %r{\Aruby(?: me)?\s+(.+)\Z}i, :evaluate,
        command: true,
        help: {
          'ruby EXPRESSION' => 'Evalutes EXPRESSION with a Ruby interpretor'
        }

      def evaluate(response)
        hijack_stdio_with(response) do
          eval(response.matches.first.first, binding, __FILE__, __LINE__)
        end
      end

      private

      def hijack_stdio_with(response)
        original_stdout = $stdout
        original_stderr = $stderr
        $stdout = StandardChat.new(response)
        $stderr = StandardChat.new(response)
        yield
        $stdout = original_stdout
        $stderr = original_stderr
      end
    end

    Lita.register_handler(Ruby)
  end
end
