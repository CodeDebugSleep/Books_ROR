class BooksController < ApplicationController
  #THIS METHOD IS TO RENDER THE INDEX VIEW FROM BOOKS FOLDER IN VIEWS
  def index
    render 'books/index'
  end

  #THIS METHOD IS TO GET ALL AUTHOR AND PUBLISHER FROM THE DATABASE. AFTER THAT, IT WILL RENDER A JSON FILE WHICH WILL BE USED FOR THE AUTOCOMPLETE INPUT IN NEW VIEW FILE OF BOOKS
  def get_auth
    render :json => { :author => Author.all, :publisher => Publisher.all }
  end

  #THIS METHOD IS TO RENDER THE NEW VIEW FROM BOOKS FOLDER IN VIEWS
  def new
    render '/books/new'
  end

  #THIS METHOD IS TO SAVE THE DATA OF THE NEWLY ADDED BOOK. BEFORE ADDING IT TO THE DATABASE, IT WILL CHECK FIRST IF ALL THE VALIDATIONS ARE MET. VALIDATIONS FOR THE DATABASE IS SEEN IN THE BOOK MODEL FILE.
  def create
    isbn_13 = convert_to_13(convert_isbn_to_arr)
    is_complete

    #this block of code is to check if the publisher passed is existing in the database. If not, it will add a new publisher in the Publisher database.
    pub_id = Publisher.find_by(name: params[:publisher])
    if pub_id == nil
      pub_id = create_publisher
    end
    if is_complete
      if check_last_digit(convert_isbn_to_arr) #does the process written in function check_last_digit
        create_book = Book.create(title: params[:title], isbn_13: isbn_13, list_price: params[:list_price], publication_year: params[:year], publisher_id: pub_id.id, image_url: params[:url], book_edition: params[:edition])
        if create_book.errors.full_messages.length > 0
          redirect_to "/books/new", flash: { errors: create_book.errors.full_messages }
        else
          saveBookAuthor
          redirect_to "/books/" + isbn_13
        end
      else
        redirect_to "/books/new", flash: { errors: ["ISBN IS INVALID!"] }
      end
    else 
      redirect_to "/books/new", flash: { errors: ["Fill in required fields"] }
    end
  end

  #THIS METHOD IS TO CHECK IF THE REQUIRED FIELDS FROM BOOK FORM HAS A VALUE. IF A FIELD HAS NOT A VALUE IT WILL RETURN FALSE.
  def is_complete
    is_complete = true
    required_fields = [:title, :isbn, :list_price, :year, :publisher, :author]
    required_fields.each do | fields |
      if params[fields] == ""
        is_complete = false
      end
    end
    return is_complete
  end

  #THIS METHOD IS TO CONVERT THE GIVEN ISBN TO AN ARRAY. DOING THIS WILL HELP TO COMPUTE IF THE LAST DIGIT IS CORRECT, WHICH WOULD DETERMINE IF THE GIVEN ISBN IS VALID OR INVALID.
  def convert_isbn_to_arr
    isbn_arr = []
    params[:isbn].each_char { | digit |
      isbn_arr.push(digit)
    }
    return isbn_arr
  end

  #THIS METHOD IS TO CHECK IF THE LAST DIGIT IS CORRECT.
  def check_last_digit(isbn_arr)
    correct_digit(isbn_arr)
    if correct_digit(isbn_arr) == isbn_arr[isbn_arr.length - 1].to_i
      return true
    else
      return false
    end
  end

  #THIS METHOD IS TO GET THE CORRECT LAST DIGIT
  def correct_digit(isbn_arr)
    check = 0
    rem = 0
    result = 0
    #this block of 'if' is if the isbn is 13. Formula for checking the last digit of isbn 13. Digits are alternately multiplied by 1 and 3. To to this, I computed the modulo, if the result is 0 then it should multiply the digit to 1. If the result is 1 then it should multiply the digit to 3. After doing so, all results will be added to each other. 
    if isbn_arr.length == 13 
      isbn_arr.each_with_index { |value, index|
        if index % 2 == 0
          check += (value.to_i * 1) #value here is a String so use to_i to convert it to integer
        elsif index % 2 == 1
          check += (value.to_i * 3)
        end
      }
      #at this point, the check is the result of what we had done earlier, this will then subtract the last digit. We will then get the remainder by Dividing check to 10. After getting the remainder, we then subtract it to 10 again to get the correct digit. If the correct digit is equals to the last digit of the given isbn then this will return true.
      check -= isbn_arr[isbn_arr.length - 1].to_i
      rem = check % 10
      result = 10 - rem
    
    #this block of code is if the passed isbn is 10. To check if the isbn is valid, we have to loop through the array (which is the isbn that was converted to array), then multiply the value from 10 (this 10 will decrease everytime).
    elsif isbn_arr.length == 10
      cnt = 10
      isbn_arr.each { |value| 
        check += (value.to_i * cnt)
        cnt = cnt - 1
      }
      check -= isbn_arr[isbn_arr.length - 1].to_i
      #now that we had finished the earlier process, we now get the correct digit by first, getting the remainder of 'check' divided by 11. After that, we subtract 11 to the remainder. And lastly, we now get the remainder again by getting the modulo of the result divided to 11.
      result +=  ((11 - (check % 11)) % 11)
    end
    return result
  end

  def create_publisher
    create_pub = Publisher.create(name: params[:publisher])
    return create_pub
  end

  #THIS METHOD RENDERS THE SHOW VIEW FILE INSIDE BOOKS FOLDER. IF THE GIVEN ISBN IS NOT IN THE DATABASE IT WILL REDIRECT THE USER TO BOOKS/NEW WHERE THE USER CAN ADD THE BOOK IN THE DATABASE.
  def show
    book_count = Book.where(isbn_13: params[:isbn]).count
    if book_count > 0 
      @book = Book.find_by(isbn_13: params[:isbn])
      @author = Book.find(@book.id).author
      render "books/show"
    elsif book_count == 0
      redirect_to '/books/new'
    end
  end

  #THIS METHOD RENDERS A JSON DATA OF THE SEARCHED BOOK. API ENDPOINT
  def isbn
    #this block of code will check if there are any letters in the given parameter. It returns false if there are none
    if params[:isbn].count("a-zA-Z") > 0 || params[:isbn].length < 10
      render :json => JSON.pretty_generate({:status => "HTTP ERROR 400", :messages => {:message1 => "This page is not working right now", :message2 => "If the problem continues please contact the site owner"} })
    else
      if check_last_digit(convert_isbn_to_arr)
        book = Book.find_by(isbn_13: params[:isbn])
        author = Book.find(book.id).author
        publisher = Book.find(book.id).publisher
        book_authors = []
        isbn_10 = convert_to_10(convert_isbn_to_arr)
        
        author.find_each do |author|
          book_authors.push("#{author.first_name} #{author.last_name}")
        end

        book_object = { :bookData => { :title => book.title, :authors => book_authors.join(", "), :isbn_13 => params[:isbn], :isbn_10 => isbn_10 }, :publisher => publisher.name }
        render :json => JSON.pretty_generate(book_object)
      else
        render :json => JSON.pretty_generate({:web_page_file => "#{Rails.root}/public/404.html",  :status => 404, :messages => {:message1 => "The page you were looking for doesn't exist.", :message2 => "You have mistyped the address or the page may have moved", :message3 => "If you are the application owner check the logs for more information"} }) #this will render a 404 status in json format
        
        #THE NEXT LINE WILL RENDER A VIEW FILE WITH STATUS 404
        # render :file => "#{Rails.root}/public/404.html",  :status => 404
      end
    end
  end

  
  def saveBookAuthor
    book = Book.find_by(title: params[:title])
    params[:author].each { |x|
      BookAuthor.create(author_id: x, book_id: book.id)
    }
  end

  #THIS METHOD IS TO CONVERT THE GIVEN ISBN TO ISBN-13, IF IT IS 13 IT WILL JUST RETURN CONVERTED THE GIVEN ARRAY TO A STRING. IF THE GIVEN ISBN IS ISBN-10, IT WILL THEN CONVERT IT TO MAKE IT ISBN-13
  def convert_to_13(isbn_arr)
    converted_isbn = ""
    if isbn_arr.length == 13
      converted_isbn = isbn_arr.join("")
    elsif isbn_arr.length == 10
      isbn_arr.unshift('9', '7', '8')
      last_digit = correct_digit(isbn_arr)
      isbn_arr.pop();
      converted_isbn = isbn_arr.join("")
      converted_isbn += last_digit.to_s
    end
    return converted_isbn
  end

  #THIS METHOD IS TO CONVERT THE GIVEN ISBN TO ISBN-10
  def convert_to_10(isbn_arr)
    converted_isbn = ""
    for index in 1..3 do
      isbn_arr.shift() #this part is to remove the first 3 numbers from the left.
    end
    last_digit = correct_digit(isbn_arr)
    isbn_arr.pop()
    converted_isbn = isbn_arr.join("")
    converted_isbn += last_digit.to_s
    return converted_isbn
  end
end