desc "Launches a pry instance"
task :console do
  Bundler.require :default, :development
  binding.pry
end