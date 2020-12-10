require "sinatra"
require "sinatra/reloader" if development?
require_relative "db_api.rb"

configure do
  enable :sessions
  set :session_secret, "secret"

end

configure(:development) do
  also_reload "db_api.rb"
end


before do
  @db = Database.new
end

after do
  @db.disconnect
end

helpers do
  def total_expenses(expenses)
    sum = 0
    expenses.each do |expense|
      sum += expense[:price].to_i
    end
    sum
  end

  def login_error?(username, password)
    if @db.login_check(username, password) == false
      "The username or password entered is incorrect!"
    end
  end

  def registration_error?(username)
    "The username is already used." if @db.username_taken?(username)
  end

  def wasted_percentage(total_sum, wasted_sum)
    total_sum > 0 ? (wasted_sum * 100) / total_sum : 0
  end

  def translate_wasted_check(status)
    status == 't' ? 'yes' : 'no'
  end

  def login_check
    unless session[:user_id]
      session[:message] = 'You must be logged in to access this page.'
      redirect "/login"
    end
  end

end

#Display Home Page
get "/" do
  redirect "/login" unless session[:user_id]
  erb :index, layout: :layout
end

#Display Registration Page
get "/register_user" do
  erb :register_user, layout: :layout
end

#Registers a new user
post "/register_user" do
  error = registration_error?(params[:username])
  if error
    session[:message] = error
    erb :register_user, layout: :layout
  else 
    message = "You've been successfully registered."
    session[:message] = message
    @db.register_new_user(params[:username], params[:password])
    redirect "/login"
  end
end

#Display Login Page
get "/login" do
  erb :login, layout: :layout    
end

#Send information for login authentication
post "/login" do
  error = login_error?(params[:username], params[:password])
  if error
    session[:message] = error
    erb :login, layout: :layout
  else
    session[:user_id] = @db.user_id
    session[:username] = @db.username
    redirect "/"
  end
end

#Log out mechanic
get "/logout" do
  session.delete(:user_id)
  session.delete(:username)
  redirect "/login"
end

#Adds a new expense
post "/new_expense" do
  @db.insert_expense(params[:item], params[:price], params[:wasted], session[:user_id])
  erb :index, layout: :layout
end

#Allows selection of a custom timeframe
get "/select_timeframe" do
  login_check
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
  login_check
  @current_day = Time.now.strftime("%Y-%m-%d")
  @start_date = @current_day
  @end_date = @current_day
  session[:previous_page] = "expenses/#{params[:date]}"
  if params[:date] == "this_month"
    @start_date = "#{Time.now.year}-#{Time.now.month}-1" 
  elsif params[:date] == "this_year"
    @start_date = "#{Time.now.year}-01-1"
  elsif params[:date] == "custom"
    @start_date = session[:start_date]
    @end_date = session[:end_date]
  end
  params[:date] == "custom" ? @display_date = "between #{@start_date} and #{@end_date}" : @display_date = params[:date].split("_").join(" ")
  @selected_expenses = @db.select_expenses(session[:user_id], @start_date, @end_date)
  @wasted_money = @selected_expenses.select {|expense| expense[:wasted_check] == 't'}
  @percentage_wasted = wasted_percentage(total_expenses(@selected_expenses), total_expenses(@wasted_money))
  erb :expenses, layout: :layout
end

#Shows and allows edit of specific expense
get "/expense/:id" do
  login_check
  @expense = @db.select_specific_expense(params[:id])
  erb :expense, layout: :layout
end

#Edits specific expense and redirects to home page.
post "/expense/:id" do
  expense = @db.select_specific_expense(params[:id])
  @db.edit_expense(params[:item], params[:price], params[:date], params[:wasted], params[:id])
  redirect "#{session[:previous_page]}"
end



