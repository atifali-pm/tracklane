# Reapplies GRANTs to the app role on the current database.
#
# Rails dumps structure.sql with --no-privileges by default (hardcoded in
# Rails 8, not overridable via structure_dump_flags), so GRANTs created
# by the GrantAppRoleDml migration do not survive into structure.sql.
# Any path that loads structure.sql directly (db:create with existing
# structure.sql, db:schema:load, db:test:prepare) ends up with tables the
# app role cannot touch.
#
# This task is idempotent and hooked onto every path that can rebuild the
# schema, so the app role always has DML access to current and future tables.

namespace :db do
  desc "Apply DML grants + default privileges to the tracklane_app role"
  task apply_app_grants: :environment do
    ActiveRecord::Base.connection_pool.with_connection do |connection|
      next unless connection.select_value("SELECT 1 FROM pg_roles WHERE rolname = 'tracklane_app'")

      database = connection.quote_column_name(connection.current_database)
      connection.execute(<<~SQL)
        GRANT CONNECT ON DATABASE #{database} TO tracklane_app;
        GRANT USAGE ON SCHEMA public TO tracklane_app;
        GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO tracklane_app;
        GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO tracklane_app;
        ALTER DEFAULT PRIVILEGES IN SCHEMA public
          GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO tracklane_app;
        ALTER DEFAULT PRIVILEGES IN SCHEMA public
          GRANT USAGE, SELECT ON SEQUENCES TO tracklane_app;
      SQL
    end
  end
end

%w[db:migrate db:schema:load db:structure:load db:test:prepare].each do |task_name|
  Rake::Task[task_name].enhance { Rake::Task["db:apply_app_grants"].invoke } if Rake::Task.task_defined?(task_name)
end
