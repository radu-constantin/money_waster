def generate_id
    (0..100).to_a.sample(4).join
end

class List
    attr_reader :expenses
    #the list is iniatilized with the username of the client
    def initialize(username)
        @name = username
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
        if end_date
            self.expenses do |expense|
                
            end
    end
end

class Expense
    attr_reader :id

    def initialize(name)
        @id = generate_id
        @name = ""
        @time = Time.now.strftime("%Y-%m-%d")
    end

    def to_s
        @id
    end
end

list = List.new("radu")
list.add_expense(Expense.new(generate_id))
list.add_expense(Expense.new(generate_id))

p list.select_expenses(2020-10-04)
