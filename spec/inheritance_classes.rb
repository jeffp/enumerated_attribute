require 'enumerated_attribute'

class Base
	enum_attr :base1, %w(^one two three four)
	enum_attr :inherited1, %w(^one two three four)
	enum_attr :inherited2, %w(^one two three four)
end

class Sub < Base
	enum_attr :sub1, %w(one ^two three four)
	enum_attr :inherited1, %w(one ^two three four)
	enum_attr :inherited2, %w(^five six seven eight)
end

class Sub2 < Base
end
