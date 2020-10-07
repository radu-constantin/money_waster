require "sinatra"
require "sinatra/reloader"
require "pry"
require_relative "app.rb"

configure do
  enable :sessions
  set :session_secret, "secret"
end

before do
  @username = "user"
  @password = "password"
  session[:list] ||= List.new(@username)
end

helpers do
  def total_expenses(list)
    sum = 0
    list.each do |expense|
      sum += expense.price.to_i
    end
    sum
  end
end


def login_error?(username, password)
  if username != @username || password != @password
    "The username or password entered is incorrect!"
  end
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
  error = login_error?(params[:username], params[:password])
  if error
    session[:error] = error
    erb :login, layout: :layout
  else
    session[:user] = params[:username]
    redirect "/"
  end
end

#Log out mechanic
get "/logout" do
  session.delete(:user)
  redirect "/login"
end

#Adds a new expense
post "/new_expense" do
  new_expense = Expense.new(params[:item], params[:price], params[:wasted])
  session[:list].add_expense(new_expense) 
  erb :index, layout: :layout
  binding.pry
end

#Allows selection of a custom timeframe
get "/select_timeframe" do
  erb :select_timeframe, layout: :layout
end

#Inputs custom timeframe
post "/expenses" do
  session[:start_date] = params[:start_date]
  session[:end_date] = params[:end_date]
  redirect "/expenses/custom"
end

#Shows expense list
get "/expenses/:date" do
  @current_day = Time.now.strftime("%Y-%m-%d")
  @start_date = @current_day
  @end_date = @current_day
  if params[:date] == "today"
    @display_date = "today"
  elsif params[:date] == "this_month"
    @display_date = "this month"
    @start_date = "#{Time.now.year}-#{Time.now.month}-1" 
  elsif params[:date] == "this_year"
    @display_date = "this year"
    @start_date = "#{Time.now.year}-01-1"
  elsif params[:date] == "custom"
    @start_date = session[:start_date]
    @end_date = session[:end_date]
    @display_date = "between #{@start_date} and #{@end_date}"
  end
  @selected_expenses = session[:list].select_expenses(@start_date, @end_date)
  
  erb :expenses, layout: :layout
  #binding.pry
end

#Shows and allows edit of specific expense
get "/expense/:id" do
  @expense = session[:list].select_expense_by_id(params[:id])
  erb :expense, layout: :layout
  #binding.pry
end



