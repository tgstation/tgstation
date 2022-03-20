///attempt to queue this verb process if the server is overloaded. returns FALSE if queuing isnt necessary or if it failed.
#define TRY_QUEUE_VERB(object, proc, args...) (TICK_CHECK_HIGH_PRIORITY && SSverb_manager.initialized && SSverb_manager.queue_verb(object, proc, args))
