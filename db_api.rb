require 'pg'
require 'pry'

class Database
    attr_reader :user_id, :username

    def initialize
        @db = PG.connect(dbname: "expense_log")
        @user_id = nil
        @username = nil
        @errors = []
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
end

p Database.new.username_taken?("radu")