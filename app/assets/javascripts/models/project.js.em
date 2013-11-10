class Minp.Project extends DS.Model
  name: DS.attr()
  root_tasks: DS.hasMany('task')
  tasks: DS.hasMany('task')
  rootTasks: ~>
    this.tasks.filter (task) -> task.parent_id == null