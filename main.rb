require './bookmeter.rb'

def main(argv)
  b_user = ENV['BOOKMETER_USERNAME']
  b_pass = ENV['BOOKMETER_PASSWORD']
  b_id   = ENV['BOOKMETER_USERID']
  t_user = ENV['TDIARY_USERNAME']
  t_pass = ENV['TDIARY_PASSWORD']
  t_uri  = argv[0]

  bm = BookMeter::BookMeter.new(b_user, b_pass, b_id)
  text = bm.get
  puts text

  td = BookMeter::Diary.new(t_user, t_pass, t_uri)
  td.set(text)
end

main(ARGV)
