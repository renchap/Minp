class Minp.Task extends DS.Model
  name: DS.attr(),
  project: DS.belongsTo('project')
  subtasks: DS.hasMany('task')