class Minp.Project extends DS.Model
  name: DS.attr()
  tasks: DS.hasMany('task', async: true)