namespace :db do
  
  task :init do
    Poke::Utils::DbManagement.init_system_db(ENV["RECREATE"] == "true")
  end

end