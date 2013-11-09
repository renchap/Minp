class ProjectSerializer < ActiveModel::Serializer
  embed :ids

  attributes :id, :name
  has_many :tasks

  def tasks
    object.tasks.where(parent_id: nil)
  end
end
