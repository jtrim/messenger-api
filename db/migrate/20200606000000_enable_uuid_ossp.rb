class EnableUuidOssp < ActiveRecord::Migration[6.0]
  def change
    execute 'CREATE EXTENSION IF NOT EXISTS "pgcrypto";'
  end
end
