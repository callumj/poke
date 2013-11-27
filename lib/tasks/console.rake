desc "Launches a pry instance"
task :console do
  Bundler.require :default, :development
  Poke.system_db.logger = Logger.new(STDOUT)

  command_set = Pry::CommandSet.new do
    command "quit" do |name|
      output.puts "Goodbye!"
      exit
    end
  end

  Pry.start binding, commands: command_set
end