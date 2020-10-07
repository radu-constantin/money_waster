require 'pry'
require 'date'

class ID_generator
    @@id_list = []

    def self.generate_id
        id = nil
        loop do
            id = (1..9).to_a.sample(8).join("")
            break if !@@id_list.include?(id)
        end
        @@id_list << id
        id
    end

    def self.show_stored_ids
        @@id_list
    end
end

class List
    attr_reader :expenses
    #the list is initialized with the username of the client
    def initialize(username)
        @owner = username
        @expenses = []
    end

    def add_expense(expense)
        @expenses << expense
    end

    def delete_expense(id)
        @expenses.delete_if do |expense|
            expense.id == id
        end
    end

    def select_expenses(start_date, end_date = nil)
        start_date = Date.strptime(start_date, "%Y-%m-%d")
        end_date = Date.strptime(end_date, "%Y-%m-%d")
            self.expenses.select do |expense|
                expense.comparable_date >= start_date && expense.comparable_date <= end_date
            end
    end

    def select_expense_by_id(id)
        index = self.expenses.index {|expense| expense.id == id}
        self.expenses[index]
    end
end

class Expense
    attr_reader :id, :date, :comparable_date, :name, :price, :wasted_check

    def initialize(name, price, wasted_check)
        @id = ID_generator.generate_id
        @name = name
        @price = price
        @wasted_check = wasted_check
        @date = Time.now.strftime("%Y-%m-%d")
        @comparable_date = Date.strptime(@date, "%Y-%m-%d")
    end

    def to_s
        @id
    end
end


