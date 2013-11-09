class TaskSerializer < ActiveModel::Serializer
  embed :ids

  attributes :id, :name
  has_many :subtasks
end
