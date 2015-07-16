module Enumerize
  module Scope
    module ActiveRecord
      def enumerize(name, options={})
        super

        _enumerize_module.dependent_eval do
          if self < ::ActiveRecord::Base
            if options[:scope]
              _define_activerecord_scope_methods!(name, options)
            end
          end
        end
      end

      private

      def _define_activerecord_scope_methods!(name, options)
        scope_name = options[:scope] == true ? "with_#{name}" : options[:scope]
        define_singleton_method scope_name do |*values|
          values.reject!(&:blank?)
          if values.blank?
            return all
          else
            values = enumerized_attributes[name].find_values(*values).map(&:value)
            where(name => values)   
          end
        end

        if options[:scope] == true
          define_singleton_method "without_#{name}" do |*values|
            values = enumerized_attributes[name].find_values(*values).map(&:value)
            where(arel_table[name].not_in(values))
          end
        end
      end
    end
  end
end
