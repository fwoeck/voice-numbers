class GeneratesReports

  attr_reader :table


  def initialize(numbers)
    @table = numbers.table
  end


  def log
    # table.each do |row|
    #   puts row.inspect
    # end
    puts "#{Time.now.utc} :: Generated a report for the last #{table.size} events."
  end


  def store(path='./reports')
    # ...
  end
end
