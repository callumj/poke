namespace :db do
  
  task :init do
    if ENV["RECREATE"]
      Poke::SystemModels.constants.each do |const|
        klass = Poke::SystemModels.const_get const
        next unless klass < Sequel::Model
        Poke.system_db.execute "DROP TABLE IF EXISTS `#{klass.table_name.to_s}`"
      end
    end
    load File.join(APP_PATH, "db.rb")
  end

end