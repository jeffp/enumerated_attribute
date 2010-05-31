require 'cfg'

r=RaceCar.new
r.gear = :second
r.name = 'special'
r.save!

#RaceCar.find_by_gear_and_name(:second, 'special')
car = RaceCar.find_or_create_by_name_and_gear('special', :second)
debugger
car0 = RaceCar.find_or_create_by_name_and_gear('special', :second)
car0