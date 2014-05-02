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
        hijack_stdout_with(response) do
          begin
            eval(response.matches.first.first, binding, __FILE__, __LINE__)
          rescue => error
            puts error.inspect
          end
        end
      end

      private

      def hijack_stdout_with(response)
        original_stdout = $stdout
        $stdout = StandardChat.new(response)
        yield
        $stdout = original_stdout
      end
    end

    Lita.register_handler(Ruby)
  end
end
