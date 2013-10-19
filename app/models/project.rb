class Project < ActiveRecord::Base
  has_many :tasks	

  def root_tasks
    self.tasks.where(parent_id: nil)
  end

  def tasks_array
    self.root_tasks.map do |task|
      array_task_item(task)
    end
  end

  private
  def array_task_item(task)
    {
      'taskId' => task.id,
      'color' => task.color,
      'name' => task.name,
      'type' => "task",
      'children' => task.subtasks.map { |s| array_task_item(s) }
    }
  end
end
