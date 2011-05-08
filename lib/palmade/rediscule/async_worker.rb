module Palmade::Rediscule
  class AsyncWorker < Worker
    def perform_async
      klass = eval(params['class'], TOPLEVEL_BINDING)
      method = params['method']
      args = params['args']


      # let's try to pad the arguments
      if (ar = klass.method(method).arity) < 0
        ar = ar * -1

        if args.size < ar
          args.fill(nil, args.size, ar - args.size - 1) if (ar - args.size) > 1
          args.push(Hash.new)
        end
      end

      options = args.last.is_a?(Hash) ? args.pop : Hash.new
      options['worker'] = options[:worker] = self
      args.push(options)

      klass.send(method, *args) if !klass.nil? && !method.nil?
    end
  end
end
