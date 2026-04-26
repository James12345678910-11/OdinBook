class CreatePosts < ActiveRecord::Migration[8.1]
  def change
    create_table :posts do |t|
      t.text :content
      t.references :user, null: false, foreign_key: true
      t.references :original_post, null: true, foreign_key: { to_table: :posts }

      

      t.timestamps
    end
    add_index :posts, [:user_id, :original_post_id],
          unique: true,
          where: "original_post_id IS NOT NULL",
          name: "index_posts_on_user_and_original_post"
  end
end
