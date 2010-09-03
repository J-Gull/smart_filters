module SmartFilter
  module IntegerType
    private
    def between(column, start, finish)
      ["#{column} BETWEEN ? AND ?", {start => finish}]
    end

    def equals_to(column, term)
      ["#{column} = ?", term]
    end

    def greater_than(column, term)
      ["#{column} > ?", term]
    end

    def less_than(column, term)
      ["#{column} < ?", term]
    end
  end
end
