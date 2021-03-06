module SmartFilter
  module Filter
    def smart_filter(options, rule)
      @conds = []
      columns.each do |column|
        @conds << generate_sql(column, options[column.name.to_sym]) if options[column.name.to_sym]
      end
      @conds.empty? ? (return []) : (return find(:all, :conditions => conditions(@conds, rule)))
    end
  end
end