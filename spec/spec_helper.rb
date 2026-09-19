# Abdeckungsmessung nur auf Wunsch: COVERAGE=1 bundle exec rspec
if ENV["COVERAGE"]
  require "simplecov"
  SimpleCov.start do
    add_filter "/spec/"
    # Schwelle knapp unter dem Ist-Stand (80,22 %), damit sie einen Absturz
    # wirklich faengt. Steigt die Abdeckung dauerhaft, darf sie mitwachsen.
    minimum_coverage 75
  end
end

require "bundler/setup"
require "secretariat"

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = ".rspec_status"

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end
  config.filter_run focus: true
  config.run_all_when_everything_filtered = true
end
