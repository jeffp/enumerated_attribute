
class Racer	< ActiveRecord::Base
	enum_attr :gear, %w(reverse ^neutral first second over_drive)
end

