require './bookmeter.rb'

def main
  bm = BookMeter::BookMeter.new
  text = bm.get
  exit true if text != "{{''}}"
  exit false
end

main
