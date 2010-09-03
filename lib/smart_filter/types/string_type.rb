module SmartFilter
  module StringType
    private
    def contains(column, term)
      ["#{column} LIKE ?", "%#{term}%"]
    end

    def does_not_contain(column, term)
      ["#{column} NOT LIKE ?", "%#{term}%"]
    end

    def is(column, term)
      ["#{column} = ?", term]
    end

    def starts_with(column, term)
      ["#{column} LIKE ?", "#{term}%"]
    end

    def ends_with(column, term)
      ["#{column} LIKE ?", "%#{term}"]
    end
  end
end