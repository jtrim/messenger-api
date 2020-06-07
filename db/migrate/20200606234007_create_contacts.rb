class CreateContacts < ActiveRecord::Migration[6.0]
  def change
    create_table :contacts, id: :uuid do |t|
      t.references :owner, null: false, type: :uuid
      t.references :user, null: false, type: :uuid
      t.boolean :active
      t.datetime :active_updated_at

      t.timestamps
    end
  end
end
