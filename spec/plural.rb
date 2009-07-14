require 'enumerated_attribute'

class Plural
		enum_attr :box, %w(small medium large)
		enum_attr :batch, %w(none daily weekly)
		enum_attr :cherry, %w(red green yellow)
		enum_attr :guy, %w(handsome funny cool)
end