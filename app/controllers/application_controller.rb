require "./config/environment"
require "./app/models/user"
class ApplicationController < Sinatra::Base

  configure do
    set :views, "app/views"
    enable :sessions
    set :session_secret, "password_security"
  end

  get "/" do
    erb :index
  end

  get "/signup" do
    erb :signup
  end

  post "/signup" do
    #your code here
    if params[:username] == "" || params[:password] == ""
      redirect '/failure'
    else
      User.create(:username => params[:username], :password => params[:password])
      redirect '/login'
    end
  end

  get '/account' do
    @user = User.find(session[:user_id])
    erb :account
  end


  get "/login" do
    erb :login
  end

  post "/login" do
    ##your code here
    @user = User.find_by(:username => params[:username])
    if @user && @user.authenticate(params[:password])
      session[:user_id] = @user.id
      redirect '/account'
    else
      redirect '/failure'
    end
  end

  get "/failure" do
    erb :failure
  end

  get "/logout" do
    session.clear
    redirect "/"
  end

  helpers do
    def logged_in?
      !!session[:user_id]
    end

    def current_user
      User.find(session[:user_id])
    end
  end

  get '/desposit' do
    amount = params[:amount]
    @user = User.find_by_id(session[:id])
    if @user
      @user.balance += amount
      erb :success
    else
      erb :failed_transaction
    end
    @error_message = "Something happend. Sorry please try again."
  end

  get '/withdraw' do
    amount = params[:amount]
    @user = User.find_by_id(session[:id])
    if @user && @user.balance >= amount
      @user.balance -= amount
      erb :success
    else
      @error_message = "Balance is less for withdrawal."
      erb :failed_transaction
    end
  end
end
