class GrantAppRoleDml < ActiveRecord::Migration[8.1]
  # Re-applies DML grants to the app role after every db:migrate. Necessary
  # because dropping and recreating the database wipes ALTER DEFAULT
  # PRIVILEGES (it is per-database), so the init script cannot be the
  # source of truth.
  #
  # Migrations run as the owner role (see bin/db), so GRANTs succeed.

  APP_ROLE = "tracklane_app".freeze

  def up
    return if app_role_missing?

    execute <<~SQL
      GRANT CONNECT ON DATABASE #{quote_database} TO #{APP_ROLE};
      GRANT USAGE ON SCHEMA public TO #{APP_ROLE};

      GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO #{APP_ROLE};
      GRANT USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public TO #{APP_ROLE};

      ALTER DEFAULT PRIVILEGES IN SCHEMA public
        GRANT SELECT, INSERT, UPDATE, DELETE ON TABLES TO #{APP_ROLE};
      ALTER DEFAULT PRIVILEGES IN SCHEMA public
        GRANT USAGE, SELECT ON SEQUENCES TO #{APP_ROLE};
    SQL
  end

  def down
    return if app_role_missing?

    execute <<~SQL
      ALTER DEFAULT PRIVILEGES IN SCHEMA public
        REVOKE SELECT, INSERT, UPDATE, DELETE ON TABLES FROM #{APP_ROLE};
      ALTER DEFAULT PRIVILEGES IN SCHEMA public
        REVOKE USAGE, SELECT ON SEQUENCES FROM #{APP_ROLE};

      REVOKE SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public FROM #{APP_ROLE};
      REVOKE USAGE, SELECT ON ALL SEQUENCES IN SCHEMA public FROM #{APP_ROLE};
    SQL
  end

  private

  def app_role_missing?
    !select_value("SELECT 1 FROM pg_roles WHERE rolname = '#{APP_ROLE}'")
  end

  def quote_database
    connection.quote_column_name(connection.current_database)
  end
end
