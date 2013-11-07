class Minp.ApplicationController extends Ember.ObjectController
  currentProject: null,
  projects: ~> this.store.findAll('project')
