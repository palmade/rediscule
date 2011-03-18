module Palmade::Rediscule
  module Async

    module ClassMethods
      def asinc
        Palmade::Rediscule.jobber.jobs["async"]
      end

      protected

      def method_missing_with_asinc(method, *args, &block)
        if method.to_s =~ /\Aasync_(.*)$/ or method.to_s =~ /\Aperform_(.*)$/
          method = $~[1]

          if self.respond_to?(method)
            asinc_send(method, args)
          else
            method_missing_without_asinc(method, *args, &block)
          end
        else
          method_missing_without_asinc(method, *args, &block)
        end
      end

      def asinc_send(method, args = nil, wait_for_response = false, params = {})
        asinc.order_perform_async(params.merge({
          'class' => self.to_s,
          'method' => method,
          'args' => args
        }))
      end
    end

    protected

    def method_missing_with_asinc(method, *args, &block)
      if method.to_s =~ /\Aasync_(.*)$/ or method.to_s =~ /\Aperform_(.*)$/
        method = $~[1]

        if self.respond_to?(method)
          asinc_send(method, args)
        else
          method_missing_without_asinc(method, *args, &block)
        end
      else
        method_missing_without_asinc(method, *args, &block)
      end
    end

    def asinc_send(method, args = nil, wait_for_response = false, params = {})
      self.class.asinc_send(method, args, wait_for_response, params)
    end

    def self.included(base)
      base.extend(ClassMethods)

      # class method overrides
      class << base
        alias :method_missing_without_asinc :method_missing
        alias :method_missing :method_missing_with_asinc
      end

      # instance method overrides
      base.class_eval do
        alias :method_missing_without_asinc :method_missing
        alias :method_missing :method_missing_with_asinc
      end
    end

  end
end
