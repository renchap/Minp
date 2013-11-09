class ProjectWithTasksSerializer < ProjectSerializer
  embed :ids, include: true
end