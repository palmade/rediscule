module Palmade::Rediscule
  class AsyncWorker < Worker
    def perform_async
      klass = eval(params['class'], TOPLEVEL_BINDING)
      method = params['method']
      args = params['args']

      options = args.last.is_a?(Hash) ? args.pop : Hash.new
      options['worker'] = options[:worker] = self
      args.push(options)

      klass.send(method, *args) if !klass.nil? && !method.nil?
    end
  end
end
