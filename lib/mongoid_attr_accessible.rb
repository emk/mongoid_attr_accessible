require 'mongoid'

module Mongoid
  module Fields
    module ClassMethods
      def field_with_attr_accessible(name, options = {})
        if options[:accessible]
          attr_accessible(name)
        end
        field_without_attr_accessible(name, options)
      end
      alias_method :field_without_attr_accessible, :field
      alias_method :field, :field_with_attr_accessible
    end
  end

  module Attributes
    module ClassMethods
      # Mark attrs as accessible, and change the default for all other
      # attributes to non-accessible.
      def attr_accessible *attrs
        @attr_accessible ||= []
        @attr_accessible.concat(attrs.map {|a| a.to_sym })
      end

      # Does this class have attr_accessible?
      def have_attr_accessible?
        !@attr_accessible.nil?
      end

      # Is attr accessible via bulk update?
      def attr_accessible?(attr)
        @attr_accessible.include?(attr.to_sym)
      end
    end

    module InstanceMethods
      # Can we write to attr?
      def write_allowed_with_attr_accessible?(attr)
        if self.class.have_attr_accessible?
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
