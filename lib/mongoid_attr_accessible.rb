require 'mongoid'

module Mongoid
  module Fields
    module ClassMethods
      def field_with_attr_accessible(name, options = {})
        if options[:accessible]
          attr_accessible_internal(name)
        end
        field_without_attr_accessible(name, options)
      end
      alias_method :field_without_attr_accessible, :field
      alias_method :field, :field_with_attr_accessible
    end
  end

  module Attributes
    module ClassMethods
      # :nodoc: Mark a single field as accessible, but only if
      # attr_accessible appears elsewhere in this class.
      def attr_accessible_internal(*attrs)
        @attr_accessible ||= []
        @attr_accessible.concat(attrs.map {|a| a.to_sym })
      end

      # Mark attrs as accessible, and change the default for all other
      # attributes to non-accessible.
      def attr_accessible(*attrs)
        attr_accessible_internal(*attrs)
        @has_attr_accessible = true
      end

      # Does this class have attr_accessible?
      def has_attr_accessible?
        !@has_attr_accessible.nil?
      end

      # Is attr accessible via bulk update?
      def attr_accessible?(attr)
        @attr_accessible.include?(attr.to_sym)
      end
    end

    module InstanceMethods
      # Can we write to attr?
      def write_allowed_with_attr_accessible?(attr)
        if self.class.has_attr_accessible?
          self.class.attr_accessible?(attr)
        else
          write_allowed_without_attr_accessible?(attr)
        end
      end
      alias_method :write_allowed_without_attr_accessible?, :write_allowed?
      alias_method :write_allowed?, :write_allowed_with_attr_accessible?
    end
  end
end
