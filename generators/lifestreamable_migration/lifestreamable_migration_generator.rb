class LifestreamableMigrationGenerator < Rails::Generator::Base
  default_options :skip_migration => false
  
  def manifest
    record do |m|
      unless options[:skip_migration]
        m.migration_template "migration.rb", 'db/migrate', :migration_file_name => "create_lifestreams"
      end
    end
  end
  
protected

  def add_options!(opt)
    opt.separator ''
    opt.separator 'Options:'
    opt.on("--skip-migration", "Don't generate a migration") { |v| options[:skip_migration] = v }
  end
  
end
