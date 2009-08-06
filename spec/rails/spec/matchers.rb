#defines custom rspec matcher for this test
Spec::Matchers.define :be_blank do
  match do |value|
    value == nil || value == ''
  end
end
Spec::Matchers.define :be_nil do
  match do |value|
    value == nil
  end
end

