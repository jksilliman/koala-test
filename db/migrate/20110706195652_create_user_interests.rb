class CreateUserInterests < ActiveRecord::Migration
  def self.up
    create_table :user_interests do |t|
      t.string :user_id
      t.string :interest_id

      t.timestamps
    end
    add_index :user_interests, :user_id
    add_index :user_interests, :interest_id
  end

  def self.down
    drop_table :user_interests
  end
end
