desc "Launches a pry instance"
task :console do
  Bundler.require :default, :development
  Poke.system_db.logger = Logger.new(STDOUT)
  binding.pry
end