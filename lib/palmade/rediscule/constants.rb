module Palmade::Rediscule
  module Constants
    Cslash = '/'.freeze

    Cdata = 'data'.freeze
    Cmeta = 'meta'.freeze

    Cworked_at = 'worked_at'.freeze
    Crt_at = 'rt_at'.freeze
    Crt_count = 'rt_count'.freeze

    ITEM_TRX_ID_FORMAT = "%04x%04x%04x%06x%06x%s".freeze

    Cjobkey = 'jobkey'.freeze
    Caction = 'action'.freeze
    Cparams = 'params'.freeze
    Corigin = 'origin'.freeze

    Cself = 'self'.freeze

    Clogtimestamp = "%Y-%m-%d %H:%M:%S".freeze
    Clogprocessingformat = ("\n\nProcessing %s#%s %s (for %s at %s)\n" +
                            "  Params: %s").freeze
    Clogcompletedformat =  ("Completed in %.5f (%s reqs/sec) | %s#%s %s").freeze
  end
end
