class ProjectsController < ApplicationController
  def index
    @projects = Project.all
  end

  def show
    @project = Project.where(id: params[:id]).first
    @root_tasks = @project.tasks.where(parent_id: nil)
  end
end
