module SmartFilter
  module DateType
    private
    def on(column, term)
      ["#{column} LIKE ?", "#{term}%"]
    end

    def before(column, term)
      ["#{column} < ?", "#{term}"]
    end

    def after(column, term)
      ["#{column} > ?", "#{term}"]
    end
  end
end
