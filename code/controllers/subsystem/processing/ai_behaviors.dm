/// The subsystem used to tick [/datum/ai_behavior] instances. Handling the individual actions an AI can take like punching someone in the fucking NUTS
PROCESSING_SUBSYSTEM_DEF(ai_behaviors)
	name = "AI Behavior Ticker"
	flags = SS_POST_FIRE_TIMING|SS_BACKGROUND
	priority = FIRE_PRIORITY_NPC_ACTIONS
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	dependencies = list(
		/datum/controller/subsystem/movement/ai_movement,
	)
	wait = 1
	///List of all ai_behavior singletons, key is the typepath while assigned value is a newly created instance of the typepath. See SetupAIBehaviors()
	var/list/ai_behaviors
	///List of all targeting_strategy singletons, key is the typepath while assigned value is a newly created instance of the typepath. See SetupAIBehaviors()
	var/list/targeting_strategies

/datum/controller/subsystem/processing/ai_behaviors/Initialize()
	SetupAIBehaviors()
	SetupTargetingStrats()
	return SS_INIT_SUCCESS

/datum/controller/subsystem/processing/ai_behaviors/proc/SetupAIBehaviors()
	ai_behaviors = list()
	for(var/behavior_type in subtypesof(/datum/ai_behavior))
		var/datum/ai_behavior/ai_behavior = new behavior_type
		ai_behaviors[behavior_type] = ai_behavior

/datum/controller/subsystem/processing/ai_behaviors/proc/SetupTargetingStrats()
	targeting_strategies = list()
	for(var/target_type in subtypesof(/datum/targeting_strategy))
		var/datum/targeting_strategy/target_start = new target_type
		targeting_strategies[target_type] = target_start
