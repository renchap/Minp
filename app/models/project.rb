class Project < ActiveRecord::Base
  has_many :tasks	

  def root_tasks
    self.tasks.where(parent_id: nil)
  end

  def tasks_array
    self.root_tasks.map do |task|
      task.array
    end
  end
end
