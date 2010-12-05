module Palmade
  module Rediscule
    class DurableItem < BaseItem
      def initialize(queue, trx_id = nil)
        super(queue, trx_id)

        @meta[Crt_count] = 0
        @meta[Cworked_at] = nil
        @meta[Crt_at] = nil
      end

      # TODO: mark this item as working
      def working!
        @meta[Cworked_at] = Time.now.utc
        put_meta
      end

      # TODO: remove from working queue
      def done!
        @meta[Cworked_at] = nil
        put_meta

        # remove from both queues
        rcache.lrem(queue.working_cache_key, 0, trx_id)
        rcache.lrem(queue.retries_cache_key, 0, trx_id)
      end

      # TODO: remove from working queue, and insert into retry queue
      def retry_later
        @meta[Cworked_at] = nil
        @meta[Crt_count] += 1
        @meta[Crt_at] = Time.now.utc + (queue.rt_at_interval * @meta[Crt_count])
        put_meta

        rcache.lpush(queue.retries_cache_key, trx_id)
        rcache.lrem(queue.working_cache_key, 0, trx_id)
      end

      # TODO: remove from retry queue and re-enqueue
      def retry!
        queue.repush(trx_id)
        rcache.lrem(queue.retries_cache_key, 0, trx_id)
      end

      # TODO: check if overdue
      def overdue?
      end

      # TODO: check if time to requeue
      def retry?
      end

      def rt_count
        @meta[Crt_count]
      end

      def worked_at
        @meta[Cworked_at]
      end

      def rt_at
        @meta[Crt_at]
      end

      protected

      def deserialize_meta(json_meta)
        hash_meta = Rediscule.json_decode(json_meta)

        unless hash_meta[Crt_at].nil?
          hash_meta[Crt_at] = Time.parse(hash_meta[Crt_at]).utc
        end

        unless hash_meta[Cworked_at].nil?
          hash_meta[Cworked_at] = Time.parse(hash_meta[Cworked_at]).utc
        end

        hash_meta
      end
    end
  end
end
