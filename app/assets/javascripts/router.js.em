# For more information see: http://emberjs.com/guides/routing/

Minp.Router.map ->
  @route 'home', { path: '/'}
  @resource 'projects'
  @resource 'project', { path: '/project/:project_id' }
