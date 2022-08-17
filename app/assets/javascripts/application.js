//= require jquery
//= require jquery_ujs
$(document).ready(function() {
    let author_arr = [[]];
    let publisher_arr = [];
    let activeInput;
    let auth_id = 0;
    let key = "AIzaSyDG7RFBN3yAjR9ryMapS3dJ8_H15K00Mss" //key for the google book api\
    $("#author_modal").hide();

    $("#authorList").hide();
    $("#pubList").hide();
    if(window.location.href.indexOf("new") != -1) {
        $("#add button").hide(); 
    };

    if(window.location.href.indexOf("authors") != -1) {
        $("#add button").hide();
        $("#search").hide();
    }

    $("#form-btn button").click(function() {
        $("#author_modal").hide();
    });

    
    $.get("/books/get_auth", function(res) {
        author_arr = res.author;
        publisher_arr = res.publisher;
    });

    $(document).on("input", ".publisher", function(e) {
        let input = $(this);
        $("#pubList").show();

        removeElements("pubList");
        for(let i of publisher_arr) {
            if(i.name.toLowerCase().includes(input.val().toLowerCase()) && input.val() != "") {
                let listPub = document.createElement("li");
                listPub.classList.add("list-items");
                listPub.style.cursor = "pointer";

                let word = "<b>" + i.name.substr(0, input.val().length) + "</b>";
                word += i.name.substr(input.val().length);

                //display the value in array;
                listPub.innerHTML = word;
                $("#pubList").append(listPub);
            }
        }
    });

    $(document).on("input", ".author", function(e) {
        let input = $(this);
        author_arr.sort(compare_fname);
        $("#authorList").show();

        //Initially remove all elements (if user erases a letter or adds new letter then clean previous outputs);
        removeElements("authorList");
        for(let i of author_arr) {
            if((i.first_name.toLowerCase().includes(input.val().toLowerCase()) || i.last_name.toLowerCase().includes(input.val().toLowerCase())) && input.val() != "") {
                let listAuthor = document.createElement("li");
                listAuthor.classList.add("list-items");
                listAuthor.style.cursor = "pointer";

                let word = "<b>" + i.first_name.substr(0, input.val().length) + "</b>";
                word += i.first_name.substr(input.val().length);

                //display the value in array;
                listAuthor.innerHTML = word += " " + i.last_name;
                $("#authorList").append(listAuthor);
            }
        }
    });

    $(document).on('click', "li", function() {
        console.log($(this).text());
        for(let i = 0; i < author_arr.length; i++) {
            let h = author_arr[i].first_name + " " + author_arr[i].last_name
            if(h.includes($(this).text())) {
                auth_id = author_arr[i].id;
            }
        }
        displayNames($(this).parent().attr("id"), $(this).text());
        $("#authorList").hide();
        $("#pubList").hide();

    })

    function removeElements(ul_id) {
        let items = $("#" + ul_id + " .list-items");
        items.each(function(item) {
            items.remove();
        })
    }

    $("#myTopnav a").click(function() {
        window.location.href = $(this).attr("href");
    });
    //hides the error message if user clicked the close button
    $("#error_message button").click(function() {
        $(this).parent().hide();
    });
        
    $(".btn-add").click(function() {
        window.location.href = "/books/new"
    });

    let isbn_13_arr = convert_isbn_to_arr($("#i_13").text()); //this is the isbn-13 of the book. Convert it to array first before converting it to isbn-10
    let converted_i_10= convert_to_10(isbn_13_arr)
    $("#i_10").text(converted_i_10);

    if($("#i_13").text().length > 0) {
        $.get("https://www.googleapis.com/books/v1/volumes?q=isbn:" + $("#i_13").text() + "&key=" + key, function(res) {
            $("#desc").text(res.items[0].searchInfo.textSnippet);
        });
    }
    $("#add button").click(function() {
        window.location.href = "/books/new"
    });

    $(".icon").click(function() {
        let x = $("#myTopnav");
        if(x.attr("class") == "topnav") {
            x.attr("class", "topnav responsive");
        }
        else {
            x.attr("class", "topnav");
        }
    });

    $("#addAuthor").click(function() {
        $("<input type = 'text' class = 'author'>").insertBefore($("#authorList"));
    });

    $("#newAuthor").click(function() {
        $("#author_modal").show();
    });

    $(document).on("click", "#form-btn input", function() {
        let form = $("#author_modal form")
        $.post("/authors", form.serialize(), function(res) {
            if(Object.keys(res) == "errors") {
                $("#author_modal .errors").show();
                $('<p>' + res.errors + '</p>').insertAfter("#author_modal .errors");
            }
            else {
                author_arr = res.author;
                $("#author_modal form")[0].reset();
                $("#author_modal").hide();
            }
        });
        return false;
    });

    $("#search button").click(function() {
        let isbn_val = $.trim($("#isbn").val()); //removes any whitespaces
        let last_digit = 0;
        
        if(isbn_val.length == 0) {
            $("#error_message h1").text("TEXT FIELD IS EMPTY!");
            $("#error_message").css("display", "block");
        }
        else {
            let isbn_arr = convert_isbn_to_arr(isbn_val);
            last_digit = isbn_arr[isbn_arr.length - 1];

            if(last_digit != check_digit(isbn_arr)) {
                $("#error_message h1").text("THE ISBN YOU HAVE ENTERED IS INVALID!");
                $("#error_message").css("display", "block");
            }
            else {
                let converted_isbn = "";
                if(isbn_val.length == 13) {
                    window.location.href = "/books/" + isbn_val;
                    converted_isbn = convert_to_10(isbn_arr);
                }
                else if(isbn_val.length == 10) {
                    converted_isbn = convert_to_13(isbn_arr);
                    window.location.href = "/books/" + converted_isbn;
                }
            }
        }
    });

    function convert_isbn_to_arr(isbn) {
        let isbn_arr = [];

        for(let i = 0; i < isbn.length; i++) {
            isbn_arr.push(isbn.charAt(i));
        }
        return isbn_arr;
    }

    //THIS FUNCTION IS TO COMPUTE AND GET THE CORRECT LAST DIGIT OF THE GIVEN ISBN.
    function check_digit(arr) {
        let check = 0;
        let rem = 0;
        let correct_digit = 0;
        if(arr.length == 13) {
            for(let i = 0; i < arr.length - 1; i++) {
                if(i % 2 == 0) {
                    check += (arr[i] * 1);
                }
                else if(i % 2 == 1) {
                    check += (arr[i] * 3);
                }
            }
            //10 here is given and a constant for the formula for checking the last digit of the isbn.
            rem = check % 10; 
            correct_digit = 10 - rem; 
        }
        else if(arr.length == 10) {
            let cnt = 10;
            for(let i = 0; i < arr.length - 1; i++) {
                check += (arr[i] * cnt);
                cnt--;
            }
            correct_digit += ((11 - (check % 11)) % 11); //11 here is given and a constant for the formula for checking the last digit of the isbn.
        }
        return correct_digit;
    }

    function convert_to_10(arr) {
        let converted_isbn = "";
        for(let i = 0; i < 3; i++) {
            arr.shift(); //this part is to remove the first 3 numbers from the left.
        }
        let last_digit = check_digit(arr); //get the last digit of an isbn_10
        arr.pop();
        
        for(let i = 0; i < arr.length; i++) {
            converted_isbn += arr[i]; //convert it to string.
        }
        converted_isbn += last_digit;
        return converted_isbn;
    }

    function convert_to_13(arr) {
        let converted_isbn = "";
        arr.unshift('9', '7', '8');
        let last_digit = check_digit(arr);
        arr.pop();
        for(let i = 0; i < arr.length; i++) {
            converted_isbn += arr[i];
        }
        converted_isbn += last_digit;
        return converted_isbn;
    }

    function compare_fname(a, b) {
        if(a.first_name.toLowerCase() < b.first_name.toLowerCase()) {
            return -1;
        }
        if(a.first_name.toLowerCase() > b.first_name.toLowerCase()) {
            return 1;
        }
        return 0;
    }

    //THIS DISPLAYS THE PICKED NAME ON THE INPUT TEXTBOX
    function displayNames(parent_element, value) {
        if(parent_element == "authorList") {
            $(".author").each(function(item, obj) {
                if($(obj).attr("data-info") == "active") {
                    $(this).val(value);
                    $("<input type = 'hidden' name = 'author[]' value = '" + auth_id + "'>").insertBefore($(this));
                }
            });
        }
        else {
            $(".publisher").val(value)
        }
       
    }

    //THIS SETS AN ATTRIBUTE THAT WOULD DETERMINE WHAT INPUT TEXTBOX IS ACTIVE AND WHERE THE NAME WILL BE PUT.
    $(document).on("focus", ".author", function() {
        $(".author").each(function(item, obj) {
            $(obj).attr("data-info", "");
        });
        $(this).attr("data-info", "active");
    });
});