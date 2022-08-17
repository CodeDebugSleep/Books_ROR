Rails.application.routes.draw do
  root 'books#index'
  get 'authors/index'
  post 'authors' => 'authors#create'
  get 'authors/show'

  get 'books/get_auth' => 'books#get_auth'
  get 'books/index' => 'books#index'
  get 'books/new'
  post 'books' => 'books#create'
  get 'books/:isbn' => 'books#show'
  get '/:isbn' => 'books#isbn'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
