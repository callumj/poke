desc "Performs reporting"
task :report, :name do |t, args|
  klasses = Poke::Reporters::Base.available_implementations
  if args[:name].nil? || (klass = klasses[args[:name]]).nil?
    STDERR.puts "Must provide a report name to rake"
    klasses.each do |name, klass|
      STDERR.puts " * #{name}"
    end
    exit 1
  end
  
  report = klass.new.results_scope.to_a
  report.each do |obj|
    STDOUT.puts obj.to_s
    STDOUT.puts "-----"
  end
end