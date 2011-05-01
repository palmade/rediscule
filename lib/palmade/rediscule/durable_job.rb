module Palmade::Rediscule
  class DurableJob < Job
    def maintain
      # check overdue items
      check_overdue_items

      # check delayed items
      check_retry_items
    end

    protected

    def check_overdue_items
      overdue = queue.check_overdue
      unless overdue.empty?
        logger.warn { "Found #{overdue.size} overdue items" }
        overdue.each do |item|
          item.retry_later
          logger.warn { "  #{item.trx_id} #{item.rt_count} #{item.rt_at}" }
        end
      end
    end

    def check_retry_items
      retries = queue.check_retries
      unless retries.empty?
        logger.warn { "Found #{retries.size} items for retrying" }
        retries.each do |item|
          item.retry!
          logger.warn { "  #{item.trx_id} #{item.rt_count} #{item.rt_at}" }
        end
      end
    end

    def default_queue_klass
      Palmade::Rediscule::DurableQueue
    end
  end
end
