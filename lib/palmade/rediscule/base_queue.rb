module Palmade::Rediscule
  class BaseQueue
    include Constants

    DEFAULT_OPTIONS = {

    }

    attr_reader :key_prefix
    attr_reader :queue_cache_key

    attr_reader :item_klass
    attr_reader :rcache

    def initialize(key_prefix, options = { })
      @options = DEFAULT_OPTIONS.merge(options)

      @key_prefix = key_prefix.dup.freeze
      @queue_cache_key = ("%s/queue" % key_prefix).freeze

      @item_klass = BaseItem
    end

    # Push a new item (given the data) to the queue
    def push(o)
      ik = create_item
      ik.put_and_update_meta(o)

      rcache.lpush(queue_cache_key, ik.trx_id)

      ik
    end

    # Push a previously created item to the queue
    def repush(trx_id)
      rcache.lpush(queue_cache_key, trx_id)
    end

    # Pop one item from the queue
    #
    # Returns
    # A newly instantiated Queue item, with the meta pre-loaded
    def pop
      trx_id = rcache.rpop(queue_cache_key)
      unless trx_id.nil? || trx_id.empty?
        ik = create_item(trx_id)
        unless ik.get_meta.nil?
          ik
        else
          nil
        end
      else
        nil
      end
    end

    # Destroy the entire queue, given the queue prefix
    def destroy
      keys = rcache.keys("%s/*" % key_prefix)
      unless keys.nil? || keys.empty?
        rcache.del(*keys)
      end
    end

    # Return number of items in the queue
    def size
      rcache.llen(queue_cache_key)
    end

    def create_item(trx_id = nil)
      item_klass.new(self, trx_id)
    end

    # Internal method: Sets the item klass for this queue.
    def set_item_klass(klass)
      @item_klass = klass
    end

    # Internal method: Sets the redis client instance for this queue.
    def set_rcache(rcache)
      @rcache = rcache
    end
  end
end
