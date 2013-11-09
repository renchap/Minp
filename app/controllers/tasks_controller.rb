class TasksController < ApplicationController
  def index
    if params[:ids]
      @tasks = Task.where(id: params[:ids].map{ |i| i.to_i })
      render json: @tasks
    end
  end
end
