class Minp.ApplicationController extends Ember.ObjectController
  currentProject: null,
  projects: ~> this.store.findAll('project')

# Allow to register to events when the window is resized
# http://stackoverflow.com/questions/10843362/how-should-i-bind-to-a-window-function-in-an-ember-view
Minp.windowWrapper = Ember.Object.extend(Ember.Evented, {
  resizeTimer: null
  init: ->
    @_super()
    $(window).on 'resize', =>
      window.clearTimeout(this.resizeTimer)
      this.resizeTimer = setTimeout(Minp.windowWrapper.resize, 100)
      true

  resize: ->
    Minp.windowWrapper.fire('resize')
})