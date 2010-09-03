module SmartFilter
  module BooleanType
    private
    def boolean(column, handle)
      ["#{column} = ?", "#{handle}"]
    end
  end
end