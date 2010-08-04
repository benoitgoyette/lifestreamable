# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{lifestreamable}
  s.version = "0.0.2"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Benoit Goyette"]
  s.date = %q{2010-08-04}
  s.description = %q{library to perform social network like lifestream functions, this is the code used on the social network http://legrandclub.rds.ca}
  s.email = %q{benoit.goyette@gmail.com}
  s.files = ["History.txt",
    "Manifest.txt",
    "PostInstall.txt",
    "README.rdoc",
    "Rakefile",
    "generators/lifestreamable_migration/lifestreamable_migration_generator.rb",
    "generators/lifestreamable_migration/templates/migration.rb",
    "lib/lifestreamable/create_observer.rb",
    "lib/lifestreamable/destroy_observer.rb",
    "lib/lifestreamable/lifestream.rb",
    "lib/lifestreamable/lifestreamable.rb",
    "lib/lifestreamable/lifestreamed.rb",
    "lib/lifestreamable/lifestreamer.rb",
    "lib/lifestreamable/observer.rb",
    "lib/lifestreamable/update_observer.rb",
    "lib/lifestreamable.rb",
    "lifestreamable.gemspec",
    "script/console",
    "script/destroy",
    "script/generate",
    "test/test_helper.rb",
    "test/test_lifestreamable.rb"]
  s.homepage = %q{http://lab.pheromone.ca}
  s.rdoc_options = ["--exclude", "."]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{lifestreamable}
  s.rubygems_version = %q{1.3.1}
  s.summary = %q{a rails plugin to collect and report user social actions.}


  # if s.respond_to? :specification_version then
  #   current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
  #   s.specification_version = 3
  #   if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
  #   else
  #   end
  # else
  # end
end


