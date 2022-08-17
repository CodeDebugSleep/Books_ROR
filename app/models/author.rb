class Author < ApplicationRecord
    has_many :book_authors
    has_many :books, through: :book_authors

    validates :first_name, :last_name, presence:true, length: { minimum: 2 }
    validate :check_name

    #DOCU: This function is to validate if the author's name is duplicated or not. 
    #AUTHOR: JUDY MAE MARIANO
    def check_name
        name = ""
        Author.find_each do |author|
            name = "#{author.first_name} #{author.middle_name} #{author.last_name}"
            if name == "#{self.first_name} #{self.middle_name} #{self.last_name}"
                errors.add(:base, "Author's name is already existing in the database.")
            end
        end
    end
end
