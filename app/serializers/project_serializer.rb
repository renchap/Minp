class ProjectSerializer < ActiveModel::Serializer
  embed :ids

  attributes :id, :name
  has_many :tasks
end
