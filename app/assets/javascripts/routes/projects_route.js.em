class Minp.ProjectsRoute extends Ember.Route
  setupController: (controller) ->
    controller.set('model', this.store.findAll("project"))
