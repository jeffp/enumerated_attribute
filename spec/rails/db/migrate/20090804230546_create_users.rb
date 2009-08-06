class CreateUsers < ActiveRecord::Migration
  def self.up
    create_table :users do |t|
      t.string :first_name
      t.integer :age
      t.enum :gender
      #t.string :gender
      t.date :DOB
      t.column :degree, :enum
      t.enum :status
      #t.string :degree
      #t.string :status

      t.timestamps
    end
  end

  def self.down
    drop_table :users
  end
end
