/// The subsystem used to tick [/datum/ai_controllers] instances. Handling the re-checking of plans.
PROCESSING_SUBSYSTEM_DEF(ai_controllers)
	name = "AI behavior"
	flags = SS_POST_FIRE_TIMING|SS_BACKGROUND
	priority = FIRE_PRIORITY_NPC
	runlevels = RUNLEVEL_GAME | RUNLEVEL_POSTGAME
	init_order = INIT_ORDER_AI_CONTROLLERS
	wait = 8 //Uses the value of CLICK_CD_MELEE because that seemed like a nice standard for the speed of AI behavior

	///an assoc list of all ai_behaviors by type, to
	var/list/ai_behaviors

/datum/controller/subsystem/processing/ai_controllers/Initialize(timeofday)
	SetupAIBehaviors()
	return ..()

/datum/controller/subsystem/processing/ai_controllers/proc/SetupAIBehaviors()
	ai_behaviors = list()
	for(var/i in subtypesof(/datum/ai_behavior))
		var/datum/ai_behavior/ai_behavior = new i
		ai_behaviors[i] = ai_behavior


