module SmartFilter
  module GenerateSQL
    private
    def conditions(conds, rule)
      # FIXME: Raise error if rule is anything other than AND or OR.
      @final, @terms = [], []

      conds.flatten!.each_with_index do |condition, index|
        index.odd? ? @terms << condition.to_a.flatten : @final << condition
      end
      return [@final.join(" #{rule} "), @terms].flatten
    end

    def generate_sql(column, criteria)
      conditions = []

      if criteria.is_a?(Hash)
        if criteria.keys.first.is_a?(Array)
          criteria.keys.first.each_with_index do |item, index|
            case item
            when "contains"         then conditions << contains(column.name, criteria.values.first[index])
            when "does_not_contain" then conditions << does_not_contain(column.name, criteria.values.first[index])
            when "is"               then conditions << is(column.name, criteria.values.first[index])
            when "starts_with"      then conditions << starts_with(column.name, criteria.values.first[index])
            when "ends_with"        then conditions << ends_with(column.name, criteria.values.first[index])
            when "equals_to"        then conditions << equals_to(column.name, criteria.values.first[index])
            when "greater_than"     then conditions << greater_than(column.name, criteria.values.first[index])
            when "less_than"        then conditions << less_than(column.name, criteria.values.first[index])
            when "between"          then conditions << between(column.name, 
                                                              criteria["between"].first, 
                                                              criteria["between"].last)
            when "on"               then conditions << on(column.name, criteria.values.first[index])
            when "before"           then conditions << before(column.name, criteria.values.first[index])
            when "after"            then conditions << after(column.name, criteria.values.first[index])
            end
          end
        end

      elsif criteria.is_a?(String)
        conditions << boolean(column.name, criteria)
      end

      return conditions
    end
  end
end