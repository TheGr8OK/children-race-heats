class CreateRaces < ActiveRecord::Migration[7.2]
  def change
    create_table :races do |t|
      t.string :title
      t.integer :status, default: 1

      t.timestamps
    end
  end
end
