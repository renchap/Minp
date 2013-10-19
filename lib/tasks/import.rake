namespace :import do
  desc 'Import from a Subtask JSON'
  task :subtask, [:file] => :environment do |task, args|
    puts "Importing Subtask project from #{args.file}"
    st = Hash.new
    File.open(args.file, "r" ) { |f| st = JSON.load(f) }
    Project.transaction do
      p = Project.new
      p.name = st['name']

      def add_subtasks(t, o)
        o['subtasks'].each do |s|
          o
          st = t.subtasks.new
          st.project = t.project
          st.name = s['name']
          add_subtasks(st, s)
          st.save!
        end
      end

      st['tasks'].each do |task|
        t = p.tasks.new(name: task['name'])
        add_subtasks(t, task)
        t.save!
      end
      p.save!
      puts "Project #{p.name} successfuly imported"
    end
  end
end