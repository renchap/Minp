class ProjectsController < ApplicationController
  def index
    @projects = Project.all
  end

  def show
    @project = Project.where(id: params[:id]).first

    respond_to do |format|
      format.html
      format.json do
        struct = {
          :name => @project.name,
          :children => @project.tasks_array
        }
        render json: struct
      end
    end
  end
end
