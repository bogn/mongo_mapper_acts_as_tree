# encoding: UTF-8

Gem::Specification.new do |s|
  s.name = %q{mongo_mapper_acts_as_tree}
  s.version = %q{0.3.3}
  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.files = ["Gemfile", "README.rdoc", "Rakefile", "lib/mongo_mapper_acts_as_tree.rb", "lib/mongo_mapper/plugins/acts_as_tree.rb", "lib/mongo_mapper/plugins/version.rb", "test"]

  s.authors = [%q{Tomas Celizna}]
  s.date = %q{2011-02-24}
  s.email = [%q{tomas.celizna@gmail.com}]
  s.homepage = %q{http://github.com/tomasc/mongo_mapper_acts_as_tree}
  s.require_paths = [%{lib}]
  s.rubygems_version = %q{1.8.8}
  s.summary = %q{Port of classic Rails ActsAsTree for MongoMapper}
  s.platform = Gem::Platform::RUBY

  if s.respond_to? :specification_version then
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
      s.add_runtime_dependency(%q<mongo_mapper>, [">= 0.9"])
      s.add_development_dependency(%q<rake>, [">= 0"])
    else
      s.add_dependency(%q<mongo_mapper>, [">= 0.9"])
      s.add_dependency(%q<rake>, [">= 0"])
    end
  else
    s.add_dependency(%q<mongo_mapper>, [">= 0.9"])
    s.add_dependency(%q<rake>, [">= 0"])
  end
end
