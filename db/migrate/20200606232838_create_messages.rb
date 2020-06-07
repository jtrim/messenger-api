class CreateMessages < ActiveRecord::Migration[6.0]
  def change
    create_table :messages, id: :uuid do |t|
      t.datetime :sent_at, null: false
      t.datetime :read_at
      t.text :content, null: false
      t.references :sender, null: false, type: :uuid
      t.references :recipient, null: false, type: :uuid

      t.timestamps
    end
  end
end
