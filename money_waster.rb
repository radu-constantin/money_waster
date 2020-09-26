require "sinatra"
require "sinatra/reloader"

configure do
  enable :sessions
  set :session_secret, "secret"
end

before do
  @username = "user"
  @password = "password"
  redirect "/login" unless session.has_key?(:user)
end

get "/" do
  erb :index, layout: :layout
end

get "/login" do
  erb :login, layout: :layout    
end

post "/login" do
  if params[:username] == @username && params[:password] == @password
    session[:user] = @username
    redirect "/"
  else
    redirect "/login"
  end
end

