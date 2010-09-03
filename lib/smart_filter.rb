require 'smart_filter/types/boolean_type'
require 'smart_filter/types/string_type'
require 'smart_filter/types/date_type'
require 'smart_filter/types/integer_type'
require 'smart_filter/generate_sql'
require 'smart_filter/filter.rb'

module SmartFilter
  include BooleanType
  include StringType
  include IntegerType
  include DateType
  include GenerateSQL
  include Filter
end

ActionView::Base.send :include, ViewHelpers
ActiveRecord::Base.send :extend, SmartFilter

require 'smart_filter/before_filter'

ActionController::Base.send :before_filter, :sort_smart_filter
