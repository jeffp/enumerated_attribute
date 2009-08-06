
class Company < ActiveRecord::Base
	has_one :license
	has_many :employees
	has_many :contract_workers
	has_many :contractors, :through=>:contract_workers
	enum_attr :status, %w(s_corp c_corp llc), :nil=>true
end
class Employee < ActiveRecord::Base
  belongs_to :company
	enum_attr :status, %w(full_time part_time suspended), :nil=>true
end
class License < ActiveRecord::Base
  belongs_to :company
	enum_attr :status, %w(^current expired)
end
class Contractor < ActiveRecord::Base
	has_many :contract_workers
	has_many :companies, :through=>:contract_workers
	enum_attr :status, %w(^available unavailable)
end
class ContractWorker < ActiveRecord::Base
  belongs_to :company
	belongs_to :contractor
	enum_attr :status, %w(unfresh ^unfresh) #i don't know what to put here
end

#polymorphic
class Comment < ActiveRecord::Base
	belongs_to :document, :polymorphic=>true
	enum_attr :status, %w(^unflagged flagged)
end
class Article < ActiveRecord::Base
	has_one :comment, :as=>:document
	enum_attr :status, %w(^unreviewed accepted)
end
class Image < ActiveRecord::Base
	has_one :comment, :as=>:document
	enum_attr :status, %w(^unreviewed accepted)
end
