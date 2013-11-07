class Minp.Task extends DS.Model
  name: DS.attr(),
  project: DS.belongsTo('project', async: true)