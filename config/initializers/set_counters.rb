class ActiveRecord::Base

  def set_counter(association, value = nil)
    counter_name = "#{association}_count"
    value ||= send(association).count
    connection.update("UPDATE #{self.class.quoted_table_name} SET #{self.class.connection.quote_column_name(counter_name)} = #{value} WHERE #{self.class.connection.quote_column_name(self.class.primary_key)} = #{self.class.quote_value(id)}", "#{self.class.name} UPDATE")
    true
  end

  def set_counters(*associations)
    associations.each { |association| set_counter(association) }
    true
  end
end
