def sort_smart_filter
  if params[:smart_filter]
    search = params[:smart_filter]
    hash = {}
    search.delete_if {|column, value| value[:value] == "" }

    search.each do |column, value|
      if params[:smart_filter][:_model].constantize.columns_hash[column].type != :boolean
        hash.merge!({column.to_sym => {value[:criteria] => value[:value]}})
      else
        hash.merge!({column.to_sym => value[:criteria]}) if value[:criteria].present? 
      end
    end

    hash.delete(:_model)
    hash.delete(:_rule)
    @filtered_results = params[:smart_filter][:_model].constantize.smart_filter(hash, params[:smart_filter][:_rule])
    Rails.logger.warn "#{hash.inspect}"
  end
end
