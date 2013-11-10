class Minp.Task extends DS.Model
  name: DS.attr()
  color: DS.attr()
  subtasks: DS.hasMany('task')
  parent_id: DS.attr()

  d3data: ~> {
    id: this.id
    name: this.name
    color: this.color
    type: 'task'
    children: this.subtasks.map (task) -> task.d3data
  }
