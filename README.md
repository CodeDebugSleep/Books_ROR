# CLONING
 - Clone your project inside Ubuntu folder (if using windows)

# STEPS TO DO AFTER CLONING THE PROJECT
- Open project using your preferred IDE. (VSCode if possible)
- open ubuntu(wsl) terminal in your IDE. If terminal used is not from IDE, navigate/cd inside the project directory and run ```bundle install```
- Create the database with ```rake db:create```
- For Database migration: ```rails db:migrate RAILS_ENV=development```
- If you encounter webpacker manifest missing, run ```rails webpacker:install```
- Type rails s - to start the application ```rails s```

# HOW TO USE
- navigate to http://localhost:3000 to go the root page
- navigate to "http://localhost:3000/9780062059932" it will render a json data of the book which has the isbn equal to the parameter. But will only be successfull if isbn is saved in the database.
- navigate to http://localhost:3000/books/9780062059932 it will render the show file from books folder. If isbn passed is not in the database, it will redirect the user to books/new
- navigate to http://localhost:3000/books/new it will redirect the user to a page where user can add a book by filling the required information in the form given.
- to add a book, fill in required fields. Upon reaching author field, if author is not in the autocomplete/suggestion, click new author button to create a new author. Upon saving the author, click again the input field beside author and chose the suggested author. If there are multiple authors, click add author. Everytime author is new click new author.