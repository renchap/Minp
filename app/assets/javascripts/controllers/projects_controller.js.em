class Minp.ProjectsController extends Ember.ArrayController

Ember.RSVP.configure('onerror', (error) ->
  Ember.Logger.assert(false, error)
)

class Minp.ProjectController extends Ember.ObjectController
  d3data: ~>
    {
      type: 'project'
      name: this.name
      id: this.id
      children: this.rootTasks.map (task) -> task.d3data
    }
