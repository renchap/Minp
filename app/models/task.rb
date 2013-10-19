class Task < ActiveRecord::Base
  belongs_to :project
  belongs_to :parent, :class_name => 'Task'
  has_many :subtasks, :class_name => 'Task', :foreign_key => "parent_id"

  def color
    if parent
      parent.color
    else
      '#' + color_generator.create_hex
    end
  end

  private
  def color_generator
    @cg ||= ColorGenerator.new saturation: 0.7, lightness: 0.4, seed: self.id
  end
end
