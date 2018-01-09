class CreateTickets < ActiveRecord::Migration
  def change
    create_table :tickets do |t|
      t.string :title, null: false
      t.text :body, null: false
      t.integer :external_id, null: false

      t.timestamps null: false
    end
  end
end
