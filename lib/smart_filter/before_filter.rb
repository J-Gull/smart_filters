def sort_smart_filter
  if params[:smart_filter]
    search = params[:smart_filter]
    hash = {}
    search.delete_if {|column, value| value[:value] == "" }
    search.each do |column, value|
      if params[:smart_filter][:model].constantize.columns_hash[column].type != :boolean
        hash.merge!({column.to_sym => {value[:criteria] => value[:value]}})
      else
        hash.merge!({column.to_sym => value[:criteria]})
      end
    end
    hash.delete(:model)
    @filtered_results = params[:smart_filter][:model].constantize.smart_filter(hash)
    Rails.logger.warn "#{hash.inspect}"
  end
end
