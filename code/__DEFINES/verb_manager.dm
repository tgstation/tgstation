/**
 * verb queuing thresholds. remember that since verbs execute after SendMaps the player wont see the effects of the verbs on the game world
 * until SendMaps executes next tick, and then when that later update reaches them. thus most player input has a minimum latency of world.tick_lag + player ping.
 * however thats only for the visual effect of player input, when a verb processes the actual latency of game state changes or semantic latency is effectively 1/2 player ping,
 * unless that verb is queued for the next tick in which case its some number probably smaller than world.tick_lag.
 * so some verbs that represent player input are important enough that we only introduce semantic latency if we absolutely need to.
 * its for this reason why player clicks are handled in SSinput before even movement - semantic latency could cause someone to move out of range
 * when the verb finally processes but it was in range if the verb had processed immediately and overtimed.
 */

///queuing tick_usage threshold for verbs that are high enough priority that they only queue if the server is overtiming.
///ONLY use for critical verbs
#define VERB_OVERTIME_QUEUE_THRESHOLD 100
///queuing tick_usage threshold for verbs that need lower latency more than most verbs.
#define VERB_HIGH_PRIORITY_QUEUE_THRESHOLD 95
///default queuing tick_usage threshold for most verbs which can allow a small amount of latency to be processed in the next tick
#define VERB_DEFAULT_QUEUE_THRESHOLD 85

///attempt to queue this verb process if the server is overloaded. evaluates to FALSE if queuing isnt necessary or if it failed.
///_verification_args... are only necessary if the verb_manager subsystem youre using checks them in can_queue_verb()
///if you put anything in _verification_args that ISNT explicitely put in the can_queue_verb() override of the subsystem youre using,
///it will runtime.
#define TRY_QUEUE_VERB(_verb_callback, _tick_check, _subsystem_to_use, _verification_args...) (_queue_verb(_verb_callback, _tick_check, _subsystem_to_use, _verification_args))
///queue wrapper for TRY_QUEUE_VERB() when you want to call the proc if the server isnt overloaded enough to queue
#define QUEUE_OR_CALL_VERB(_verb_callback, _tick_check, _subsystem_to_use, _verification_args...) \
	if(!TRY_QUEUE_VERB(_verb_callback, _tick_check, _subsystem_to_use, _verification_args)) {\
		_verb_callback:InvokeAsync() \
		};

//goes straight to SSverb_manager with default tick threshold
#define DEFAULT_TRY_QUEUE_VERB(_verb_callback, _verification_args...) (TRY_QUEUE_VERB(_verb_callback, VERB_DEFAULT_QUEUE_THRESHOLD, null, _verification_args))
#define DEFAULT_QUEUE_OR_CALL_VERB(_verb_callback, _verification_args...) QUEUE_OR_CALL_VERB(_verb_callback, VERB_DEFAULT_QUEUE_THRESHOLD, null, _verification_args)

//default tick threshold but nondefault subsystem
#define TRY_QUEUE_VERB_FOR(_verb_callback, _subsystem_to_use, _verification_args...) (TRY_QUEUE_VERB(_verb_callback, VERB_DEFAULT_QUEUE_THRESHOLD, _subsystem_to_use, _verification_args))
#define QUEUE_OR_CALL_VERB_FOR(_verb_callback, _subsystem_to_use, _verification_args...) QUEUE_OR_CALL_VERB(_verb_callback, VERB_DEFAULT_QUEUE_THRESHOLD, _subsystem_to_use, _verification_args)
