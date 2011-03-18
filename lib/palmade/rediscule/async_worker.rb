module Palmade::Rediscule
  class AsyncWorker < Worker

    def perform_async
      klass = params['class'].constantize
      method = params['method']
      args = params['args']

      klass.send(method, *args) if klass and method
    end

  end
end
