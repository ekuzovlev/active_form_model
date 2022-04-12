# frozen_string_literal: true

require 'active_support/deprecation'
require 'active_support/core_ext/class/attribute'

module ActiveFormModel
  module Permittable
    extend ActiveSupport::Concern

    included do
      class_attribute(:_permitted_args, instance_predicate: false, default: [])
    end

    class_methods do
      def new(attrs = nil, &block)
        attrs = _permit_attrs(attrs) if attrs

        super(attrs, &block)
      end

      def permit(*args)
        self._permitted_args = _permitted_args | args
      end

      alias_method :fields, :permit
      deprecate fields: :permit, deprecator: ActiveSupport::Deprecation.new('0.6.0', 'ActiveFormModel')

      def _permit_attrs(attrs)
        attrs.respond_to?(:permit) ? attrs.send(:permit, _permitted_args) : attrs
      end
    end

    def update(attrs = {})
      permitted_attrs = permit_attrs(attrs)
      super(permitted_attrs)
    end

    def update!(attrs = {})
      permitted_attrs = permit_attrs(attrs)
      super(permitted_attrs)
    end

    def assign_attributes(attrs = {})
      permitted_attrs = permit_attrs(attrs)
      super(permitted_attrs)
    end

    private

    def permit_attrs(attrs)
      self.class._permit_attrs(attrs)
    end
  end
end
