# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{rediscule}
  s.version = "0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 1.2") if s.respond_to? :required_rubygems_version=
  s.authors = ["palmade"]
  s.date = %q{2010-12-28}
  s.description = %q{Redis queue helpers}
  s.email = %q{}
  s.extra_rdoc_files = ["lib/palmade/rediscule.rb", "lib/palmade/rediscule/base_item.rb", "lib/palmade/rediscule/base_queue.rb", "lib/palmade/rediscule/configurator.rb", "lib/palmade/rediscule/constants.rb", "lib/palmade/rediscule/daemon.rb", "lib/palmade/rediscule/daemon_puppet.rb", "lib/palmade/rediscule/durable_item.rb", "lib/palmade/rediscule/durable_job.rb", "lib/palmade/rediscule/durable_queue.rb", "lib/palmade/rediscule/janitor.rb", "lib/palmade/rediscule/janitor_puppet.rb", "lib/palmade/rediscule/job.rb", "lib/palmade/rediscule/jobber.rb", "lib/palmade/rediscule/worker.rb"]
  s.files = ["CHANGELOG", "Manifest", "Rakefile", "lib/palmade/rediscule.rb", "lib/palmade/rediscule/base_item.rb", "lib/palmade/rediscule/base_queue.rb", "lib/palmade/rediscule/configurator.rb", "lib/palmade/rediscule/constants.rb", "lib/palmade/rediscule/daemon.rb", "lib/palmade/rediscule/daemon_puppet.rb", "lib/palmade/rediscule/durable_item.rb", "lib/palmade/rediscule/durable_job.rb", "lib/palmade/rediscule/durable_queue.rb", "lib/palmade/rediscule/janitor.rb", "lib/palmade/rediscule/janitor_puppet.rb", "lib/palmade/rediscule/job.rb", "lib/palmade/rediscule/jobber.rb", "lib/palmade/rediscule/worker.rb", "spec/base_queue_spec.rb", "spec/config/jobber.yml", "spec/daemon_spec.rb", "spec/durable_job_spec.rb", "spec/durable_queue_spec.rb", "spec/job_spec.rb", "spec/jobber_spec.rb", "spec/spec.opts", "spec/spec_helper.rb", "rediscule.gemspec"]
  s.homepage = %q{}
  s.rdoc_options = ["--line-numbers", "--inline-source", "--title", "Rediscule"]
  s.require_paths = ["lib"]
  s.rubyforge_project = %q{palmade}
  s.rubygems_version = %q{1.3.7}
  s.summary = %q{Redis queue helpers}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::VERSION) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
