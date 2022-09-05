require 'date'
require 'rails/all'

now = DateTime.now
p DateTime.new(now.year,now.month,now.day,now.hour,now.minute,now.second) + 1.days

p [].empty?