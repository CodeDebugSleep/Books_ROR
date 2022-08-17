class Book < ApplicationRecord
  belongs_to :publisher
  has_many :book_authors
  has_many :author, through: :book_authors
  
  validates :title, :isbn_13, :list_price, :publication_year, presence:true
  validates :title, length: { minimum: 2 }
  validates :isbn_13, length: { minimum: 13 }
  validates :publication_year, length: { is: 4 }, numericality: { only_integer: true, less_than_or_equal_to: Date.today.year }
end
