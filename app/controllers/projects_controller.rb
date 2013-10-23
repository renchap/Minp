class ProjectsController < ApplicationController
  include Tubesock::Hijack

  before_filter :fetch_project, :except => [:index]

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
          :type => 'project',
          :children => @project.tasks_array
        }
        render json: struct
      end
    end
  end

  def stream
    hijack do |tubesock|
      # Listen on its own thread
      redis_thread = Thread.new do
        # Needs its own redis connection to pub
        # and sub at the same time
        redis = Redis.new
        redis.subscribe "project-#{@project.id}" do |on|
          on.message do |channel, message|
            task = Task.find(message.to_i)
            tubesock.send_data task.array.to_json
          end
        end
      end

      tubesock.onmessage do |m|
        h = JSON.parse(m)
        case h['type']
        when 'newTask'
          Task.create!(h['task'])
        when 'taskNameChange'
          t = Task.find(h['id'])
          t.name = h['newName']
          t.save!
        else
          logger.debug("Unknown message :" + m)
        end
      end
      
      tubesock.onclose do
        # stop listening when client leaves
        redis_thread.kill
      end
    end
  end

  private
  def fetch_project
    @project = Project.find(params[:id].to_i)
  end
end
