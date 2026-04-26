class CreateFollows < ActiveRecord::Migration[8.1]
  def change
    create_table :follows do |t|
      t.references :follower, null: false, foreign_key: true
      t.references :followed, null: false, foreign_key: true
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
