class Task < ActiveRecord::Base
  belongs_to :project
  belongs_to :parent, :class_name => 'Task'
  has_many :subtasks, :class_name => 'Task', :foreign_key => "parent_id"

  before_create do
    self.project_id |= self.parent.project_id if self.parent_id
  end

  after_commit do 
    Redis.new.publish "project-#{self.project_id}", self.id
  end

  def color
    if parent
      parent.color
    else
      '#' + color_generator.create_hex
    end
  end

  def array
    result = {
      'id' => self.id,
      'color' => self.color,
      'name' => self.name,
      'type' => 'task'
    }
    result['parent'] = self.parent.id if self.parent
    result['children'] = self.subtasks.map { |s| s.array } if self.subtasks.length > 0

    result
  end

  private
  def color_generator
    @cg ||= ColorGenerator.new saturation: 0.7, lightness: 0.4, seed: self.id
  end
end
