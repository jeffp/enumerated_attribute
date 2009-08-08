
class RaceCar	< ActiveRecord::Base
	enum_attr :gear, %w(reverse ^neutral first second over_drive)
	enum_attr :choke, %w(^none medium full)
end

#gear = enumerated column attribute
#choke = enumerated non-column attribute
#lights = non-enumerated column attribute

=begin
	t.string :name
	t.string :gear
	t.string :lights
=end
