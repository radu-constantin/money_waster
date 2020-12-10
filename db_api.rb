require 'pg'
require 'pry'

class Database
    attr_reader :user_id, :username

    def initialize
        @db = if Sinatra::Base.production?
            PG.connect(ENV['DATABASE_URL'])
              else
            PG.connect(dbname: "expense_log")
              end
        @user_id = nil
        @username = nil
        @errors = []
    end

    def disconnect
        @db.close
    end

    def query(statement, *params)
        @db.exec_params(statement, params)
    end

    #Checks if there is a match between user input and the username-password pairs in db.
    #If there is, it also assigns that users id as the user id of the session.
    def login_check(username, password)
        sql = <<~SQL
        SELECT * FROM users
        WHERE username = $1 AND password = $2;
        SQL
        check = query(sql, username, password)
        if check.ntuples == 1
            @user_id = check.tuple(0)["id"]
            @username = check.tuple(0)["username"]
            true
        else 
            false 
        end
    end

    def register_new_user(username, password)
        sql = <<~SQL
        INSERT INTO users (username, password)
        VALUES($1, $2);
        check = query(sql, username, password)
        @errors << ERROR_MESSAGE;
        SQL
    end

    def username_taken?(username)
        sql = <<~SQL
        SELECT username FROM users
        WHERE username = $1;
        SQL
        check = query(sql, username)
        check.ntuples == 1 ? true : false
    end

    def insert_expense(name, price, wasted_check, user_id)
        sql = <<~SQL
        INSERT INTO expenses(name, price, wasted_check, user_id)
        VALUES ($1, $2, $3, $4)
        SQL
        query(sql, name, price, wasted_check, user_id)
    end

    def select_expenses(user_id, start_date, end_date)
        sql = <<~SQL
        SELECT id, name, price, wasted_check, time_added FROM expenses
        WHERE user_id = $1 AND time_added BETWEEN $2 AND $3;
        SQL
        selection = query(sql, user_id, start_date, end_date)
        expenses_to_hash(selection)
    end

    def expenses_to_hash(expenses)
        expenses.map do |tuple|
            {
            id: tuple['id'],
            name: tuple['name'],
            price: tuple['price'],
            wasted_check: tuple['wasted_check'],
            date: tuple['time_added']
        }
        end
    end

    def select_specific_expense(expense_id)
        sql = <<~SQL
        SELECT * FROM expenses
        WHERE id = $1;
        SQL
        expenses_to_hash(query(sql, expense_id))
    end

    def edit_expense(new_name, new_price, new_date, new_wasted_check, expense_id)
        sql = <<~SQL
        UPDATE expenses
        SET name = $1, price = $2, time_added = $3, wasted_check = $4
        WHERE id = $5;
        SQL
        query(sql, new_name, new_price, new_date, new_wasted_check, expense_id)
    end
end





