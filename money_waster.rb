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

  def select_expense_timeframe(start_date, end_date, timeframe)
    start_year, start_month, start_day = start_date.split("-").map {|date| date.to_i}
    end_year, end_month, end_day = end_date.split("-").map {|date| date.to_i}
    if timeframe == "custom" || timeframe == "today"
      session[:expenses].select do |expense|
        (start_year..end_year).include?(expense[:time].year) && 
        (start_month..end_month).include?(expense[:time].month) && 
        (start_day..end_day).include?(expense[:time].day)
      end
    elsif timeframe == "this_month"
      session[:expenses].select do |expense|
        (start_year..end_year).include?(expense[:time].year) && 
        (start_month..end_month).include?(expense[:time].month)
      end
    elsif timeframe == "this_year"
      session[:expenses].select do |expense|
        (start_year..end_year).include?(expense[:time].year)
      end
    end
  end
end

def total_expense(expense_array)
  sum = 0
  expense_array.each do |expense|
    sum += expense[:price]
  end
  sum
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
  session[:expenses] << {name: params[:item], price: params[:price], wasted_check: params[:wasted], time: Time.now}
  erb :index, layout: :layout
end

#Allows selection of a custom timeframe
get "/select_timeframe" do
  erb :select_timeframe, layout: :layout
end

#Inputs custom timeframe
post "/expenses" do
  session[:selected_expenses] = select_expense_timeframe(params[:start_date], params[:end_date], "custom")
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
  elsif params[:date] == "this_year"
    @display_date = "this year"
  elsif params[:date] == "custom"
    @start_date = session[:start_date]
    @end_date = session[:end_date]
    @display_date = "between #{@start_date} and #{@end_date}"
  end
  session[:selected_expenses] = select_expense_timeframe(@start_date, @end_date, params[:date])
  erb :expenses, layout: :layout
end



