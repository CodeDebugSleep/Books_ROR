class CreateBooks < ActiveRecord::Migration[6.1]
  def change
    create_table :books do |t|
      t.string :title
      t.string :isbn_13
      t.decimal :list_price
      t.integer :publication_year
      t.string :image_url
      t.integer :book_edition
      t.references :publisher, null: false, foreign_key: true

      t.timestamps
    end
  end
end
