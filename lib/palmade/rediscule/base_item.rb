require 'digest/md5'

module Palmade
  module Rediscule
    class BaseItem
      include Constants

      attr_reader :trx_id
      attr_reader :queue
      attr_reader :rcache

      attr_reader :meta

      def self.generate_trx_id
        srand(Time.now.usec)
        Digest::MD5.hexdigest(ITEM_TRX_ID_FORMAT %
                              [
                               rand(0x0010000),
                               rand(0x0010000),
                               rand(0x0010000),
                               rand(0x1000000),
                               rand(0x1000000),
                               String(Time::now.usec) ]).freeze
      end

      def initialize(queue, trx_id = nil)
        @queue = queue
        @rcache = queue.rcache

        @trx_id = trx_id
        @trx_id = self.class.generate_trx_id if @trx_id.nil?

        @item_key = item_key
        @meta = { }
      end

      def exists?
        rcache.exists(item_key)
      end

      def destroy
        rcache.lrem(queue.queue_cache_key, 0, trx_id)
        rcache.del(item_key)
      end

      # retrieve the data
      def get
        json_o = rcache.hget(item_key, Cdata)
        unless json_o.nil?
          Rediscule.json_decode(json_o)
        else
          nil
        end
      end

      # put the data
      def put(o)
        json_o = Rediscule.json_encode(o)
        rcache.hset(item_key, Cdata, json_o)
      end

      # put data and update meta data
      def put_and_update_meta(o)
        put(o)
        put_meta
      end

      # Insert into queue
      def enqueue!
        queue.repush(trx_id)
      end

      def get_meta
        json_meta = rcache.hget(item_key, Cmeta)
        unless json_meta.nil? || json_meta.empty?
          @meta.update(deserialize_meta(json_meta))
        else
          nil
        end
      end

      def put_meta
        rcache.hset(item_key, Cmeta, serialize_meta)
      end

      protected

      def serialize_meta
        Rediscule.json_encode(@meta)
      end

      def deserialize_meta(json_meta)
        Rediscule.json_decode(json_meta)
      end

      def item_key
        if defined?(@item_key)
          @item_key
        else
          [ queue.key_prefix, trx_id ].join(Cslash).freeze
        end
      end
    end
  end
end
