require "spec_helper"

describe Lita::Handlers::Ruby, lita_handler: true do
  it { routes_command('ruby me 10.times { puts "Hey guise" }').to(:evaluate) }
  it { routes_command('ruby 10.times { puts "Hey guise" }').to(:evaluate) }

  describe '#evaluate' do
    it 'evaluates the expression and messages the result' do
      send_command 'ruby me puts (0..9).map { |n| n ** 2 }.join(",")'
      expect(replies.last).to eq('0,1,4,9,16,25,36,49,64,81')
    end

    it 'can reply multiple times when numerous "puts" are called' do
      send_command 'ruby 3.times { |x| puts "Hello #{ x }" }'
      expect(replies[-3..-1]).to eq(['Hello 0', 'Hello 1', 'Hello 2'])
    end
  end
end
