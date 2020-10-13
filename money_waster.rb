require "sinatra"
require "sinatra/reloader"
require "pry"
require_relative "app.rb"

configure do
  enable :sessions
  set :session_secret, "secret"
  set :bind , '0.0.0.0'
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

  def login_error?(username, password)
    if username != @username || password != @password
      "The username or password entered is incorrect!"
    end
  end

  def wasted_percentage(total_sum, wasted_sum)
    total_sum > 0 ? (wasted_sum * 100) / total_sum : 0
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
    session[:previous_page] = "/expenses/today"
  elsif params[:date] == "this_month"
    @display_date = "this month"
    @start_date = "#{Time.now.year}-#{Time.now.month}-1" 
    session[:previous_page] = "/expenses/this_month"
  elsif params[:date] == "this_year"
    @display_date = "this year"
    @start_date = "#{Time.now.year}-01-1"
    session[:previous_page] = "/expenses/this_year"
  elsif params[:date] == "custom"
    @start_date = session[:start_date]
    @end_date = session[:end_date]
    session[:previous_page] = "/expenses/custom"
    @display_date = "between #{@start_date} and #{@end_date}"
  end
  @selected_expenses = session[:list].select_expenses(@start_date, @end_date)
  @wasted_money = @selected_expenses.select {|expense| expense.wasted_check == "yes"}
  @percentage_wasted = wasted_percentage(total_expenses(@selected_expenses), total_expenses(@wasted_money))
  erb :expenses, layout: :layout
end

#Shows and allows edit of specific expense
get "/expense/:id" do
  @expense = session[:list].select_expense_by_id(params[:id])
  erb :expense, layout: :layout
end

#Edits specific expense and redirects to home page.
post "/expense/:id" do
  expense = session[:list].select_expense_by_id(params[:id])
  expense.name = params[:item]
  expense.price = params[:price]
  expense.date = params[:date]
  expense.wasted_check = params[:wasted]
  redirect "#{session[:previous_page]}"
end



