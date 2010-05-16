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
        !@has_attr_accessible.nil? or
          if superclass.respond_to?(:has_attr_accessible?)
            superclass.has_attr_accessible?
          else
            false
          end
      end

      # Is attr accessible via bulk update?
      def attr_accessible?(attr)
        @attr_accessible.include?(attr.to_sym) or
          if superclass.respond_to?(:attr_accessible?)
            superclass.attr_accessible?(attr)
          else
            false
          end
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

      # We completely disable Mongoid.allow_dynamic_fields for classes
      # where attr_accessible is true, just to be on the safe side.
      def set_allowed_with_attr_accessible?(attr)
        if self.class.has_attr_accessible?
          false
        else
          set_allowed_without_attr_accessible?(attr)
        end
      end
      alias_method :set_allowed_without_attr_accessible?, :set_allowed?
      alias_method :set_allowed?, :set_allowed_with_attr_accessible?
    end
  end
end
