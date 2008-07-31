
def env_or_raise(var_name, human_name)
  if ENV[var_name].blank?
    raise "No #{var_name} value given. Set #{var_name}=#{human_name}"
  else
    return ENV[var_name]
  end  
end

def model_or_raise
  return env_or_raise('MODEL', 'ModelName')
end

def limit_or_nil_string
  ENV['LIMIT'].blank? ? 'nil' : ENV['LIMIT']
end

def all_models
  FileList[File.join(RAILS_ROOT, 'app', 'models', '**', '*.rb')].map do |path|
    File.basename(path, ".rb").classify.constantize
  end
end

namespace :db do
  namespace :fixtures do
    desc "Dump data to the test/fixtures/ directory. Use MODEL=ModelName and LIMIT (optional)"
    task :dump => :environment do
      eval "#{model_or_raise}.to_fixture(#{limit_or_nil_string})"
    end
  end
    
  namespace :data do
    desc "Dump data to the db/data directory. Use MODEL=ModelName and LIMIT (optional)"
    task :dump => :environment do
      eval "#{model_or_raise}.dump_to_file(ENV['DUMP_PATH'], #{limit_or_nil_string})"
      puts "#{model_or_raise} has been dumped to the db folder."
    end

    desc "Load data from the db/data directory. Use MODEL=ModelName"
    task :load => :environment do
      eval "#{model_or_raise}.load_from_file(ENV['DUMP_PATH'˝])"
    end
    
    namespace :dump do
      desc "Dump all models to the db/data directory."
      task :all => :environment do
        all_models.each do |model|
          model.dump_to_file(ENV['DUMP_PATH'])
        end
      end
    end
    
    namespace :load do
      desc "Load all data in yml dump files from the db/data directory."
      task :all => :environment do
        all_models.each do |model|
          begin
            model.load_from_file(ENV['DUMP_PATH'])
          rescue => ex
            puts "Could not load data for #{model} model."
            puts ex
          end
        end
      end
    end
  end
end
