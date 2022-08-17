class AuthorsController < ApplicationController
  def index
    @author = Author.all
  end

  def create
    required_fields = [:first_name, :last_name]
    is_complete = true
    required_fields.each do | fields |
      if params[fields] == ""
        is_complete = false
      end
    end

    if is_complete
      create_author = Author.create(first_name: params[:first_name], middle_name: params[:middle_name], last_name: params[:last_name])
      if create_author.errors.full_messages.length > 0
        render :json => { :errors => create_author.errors.full_messages }
      else
        render :json => { :author => Author.all }
      end
    else
      render :json => { :errors => "Please fill all the required fields "}
    end
  end

  def show
  end
end
