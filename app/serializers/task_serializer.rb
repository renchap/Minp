class TaskSerializer < ActiveModel::Serializer
  embed :ids

  attributes :id, :name, :color, :parent_id
  has_many :subtasks
end
