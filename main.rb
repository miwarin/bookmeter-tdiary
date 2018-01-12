require './bookmeter.rb'

def main
  bm = BookMeter::BookMeter.new
  text = bm.get
  puts text
  td = BookMeter::Diary.new
  td.set(text)
end

main
