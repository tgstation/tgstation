//verb queuing thresholds. remember that since verbs execute after SendMaps the player wont see the effects of the verbs on the game world
//until SendMaps executes next tick, and then when that later update reaches them. thus most player input has a minimum latency of world.tick_lag + player ping.
//however thats only for the visual effect of player input, when a verb processes the actual latency of game state changes or semantic latency is 0,
//unless that verb is queued for the next tick in which case its some number probably smaller than world.tick_lag.
//so some verbs that represent player input are important enough that we only introduce semantic latency if we absolutely need to.
//its for this reason why player clicks are handled in SSinput before even movement - semantic latency could cause someone to move out of range
//when the verb finally processes but it was in range if the verb had processed immediately and overtimed.

///queuing tick_usage threshold for verbs that are high enough priority that they only queue if the server is overtiming. only use for critical verbs
#define VERB_OVERTIME_QUEUE_THRESHOLD 100
///queuing tick_usage threshold for verbs that need low latency more than most verbs.
#define VERB_HIGH_PRIORITY_QUEUE_THRESHOLD 95
///default queuing tick_usage threshold for most verbs which can allow a small amount of latency to be processed in the next tick
#define VERB_DEFAULT_QUEUE_THRESHOLD 85

///attempt to queue this verb process if the server is overloaded. evaluates to FALSE if queuing isnt necessary or if it failed.
#define TRY_QUEUE_VERB(_object, _proc, _tick_check, _args...) ((TICK_USAGE > _tick_check) && SSverb_manager.initialized && SSverb_manager.queue_verb(_object, _proc, _args))
///queue wrapper for TRY_QUEUE_VERB() when you want to call the proc if the server isnt overloaded enough to queue
#define QUEUE_OR_CALL_VERB(_object, _proc, _tick_check, _args...) if(!TRY_QUEUE_VERB(_object, _proc, _tick_check, _args)) {call(_object, _proc)(_args)};
