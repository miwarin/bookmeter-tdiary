require './bookmeter.rb'

def main
  bm = BookMeter.new
  text = bm.get
  puts text
  td = Diary.new
  td.set(text)
end

main
