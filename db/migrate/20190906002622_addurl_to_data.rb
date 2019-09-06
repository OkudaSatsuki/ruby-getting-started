class AddurlToData < ActiveRecord::Migration[5.1]
  def change
      add_column :data, :url, :string
  end
end
