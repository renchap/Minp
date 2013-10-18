class Task < ActiveRecord::Base
  belongs_to :project
  belongs_to :parent, :class_name => 'Task'
end
