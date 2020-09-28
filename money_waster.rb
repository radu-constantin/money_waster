require "sinatra"
require "sinatra/reloader"
require "pry"

configure do
  enable :sessions
  set :session_secret, "secret"
end

before do
  @username = "user"
  @password = "password"
  session[:expenses] ||= []
  session[:selected_expenses] ||= []
end

helpers do
  def total_expenses(array)
    sum = 0
    array.each do |expense|
      sum += expense[:price].to_i
    end
    sum
  end

  def select_expense_timeframe(start_date, end_date)
    start_year, start_month, start_day = start_date.split("-").map {|date| date.to_i}
    end_year, end_month, end_day = end_date.split("-").map {|date| date.to_i}
    session[:expenses].select do |expense|
      (start_year..end_year).include?(expense[:time].year) && 
      (start_month..end_month).include?(expense[:time].month) && 
      (start_day..end_day).include?(expense[:time].day)
    end
  end
end

def login_success?(username, password)
  username == @username && password == @password
end

#Display Home Page
get "/" do
  redirect "/login" unless session[:user]
  erb :index, layout: :layout
end

#Display Login Page
get "/login" do
  erb :login, layout: :layout    
end

#Send information for login authentication
post "/login" do
  if login_success?(params[:username], params[:password])
    session[:user] = params[:username]
    redirect "/"
  else
    redirect "/login"
  end
end

#Log out mechanic
get "/logout" do
  session.delete(:user)
  redirect "/login"
end

post "/new_expense" do
  session[:expenses] << {name: params[:item], price: params[:price], wasted_check: params[:wasted], time: Time.now}
  erb :index, layout: :layout
end

get "/select_timeframe" do
  erb :select_timeframe, layout: :layout
end

get "/stats" do
  erb :stats, layout: :layout
end

post "/stats" do
  session[:selected_expenses] = select_expense_timeframe(params[:start_date], params[:end_date])
  session[:start_date] = params[:start_date]
  session[:end_date] = params[:end_date]
  binding.pry
  redirect "/stats"
end

