class Task < ActiveRecord::Base
  belongs_to :project
  belongs_to :parent, :class_name => 'Task'
  has_many :subtasks, :class_name => 'Task', :foreign_key => "parent_id"
end
