class CreateTickets < ActiveRecord::Migration
  def change
    create_table :tickets do |t|
      t.string :subject, null: false
      t.text :description, null: false
      t.integer :external_id, null: false

      t.timestamps null: false
    end
  end
end
