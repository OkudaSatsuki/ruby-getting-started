class CreateData < ActiveRecord::Migration[5.1]
  def change
    create_table :data do |t|
      t.string :name
      t.string :first
      t.string :third
      t.string :fifth

      t.timestamps
    end
  end
end
