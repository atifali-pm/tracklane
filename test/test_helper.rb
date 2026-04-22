ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"
require "rails/test_help"
require_relative "test_helpers/session_test_helper"
require_relative "support/tenant_scoping_helper"

module ActiveSupport
  class TestCase
    # Disable parallelization: the RLS tests rely on role and GUC state
    # on a single connection, so sharing a process is required.
    parallelize(workers: 1)

    # Setup all fixtures in test/fixtures/*.yml for all tests in alphabetical order.
    fixtures :all

    include TenantScopingHelper
  end
end
