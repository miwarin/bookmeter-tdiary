require './bookmeter.rb'

def main(argv)
  b_user = ENV['BOOKMETER_USERNAME']
  b_pass = ENV['BOOKMETER_PASSWORD']
  b_id   = ENV['BOOKMETER_USERID']

  bm = BookMeter::BookMeter.new(b_user, b_pass, b_id)
  text = bm.get
  exit true if text != "{{''}}"
  exit false
end

main(ARGV)
