#define HIGH_HAPPINESS_THRESHOLD 0.7
#define MODERATE_HAPPINESS_THRESHOLD 0.5

/datum/ai_planning_subtree/express_happiness
	operational_datums = list(/datum/component/happiness)
	///the key storing our happiness value
	var/happiness_key = BB_BASIC_HAPPINESS
	///list of emotions we relay when happy
	var/static/list/happy_emotions = list(
		"celebrates happily!",
		"dances around in excitement!",
	)
	///our moderate emotions
	var/static/list/moderate_emotions = list(
		"looks satisfied.",
		"trots around.",
	)
	///emotions we display when we are sad
	var/static/list/depressed_emotions = list(
		"looks depressed...",
		"turns its back and sulks...",
		"looks towards the floor in dissapointment...",
	)

/datum/ai_planning_subtree/express_happiness/SelectBehaviors(datum/ai_controller/controller, seconds_per_tick)
	if(!SPT_PROB(5, seconds_per_tick))
		return
	var/happiness_value = controller.blackboard[happiness_key]
	if(isnull(happiness_value))
		return
	var/list/final_list
	switch(happiness_value)
		if(HIGH_HAPPINESS_THRESHOLD to INFINITY)
			final_list = controller.blackboard[BB_HAPPY_EMOTIONS] || happy_emotions
		if(MODERATE_HAPPINESS_THRESHOLD to HIGH_HAPPINESS_THRESHOLD)
			final_list = controller.blackboard[BB_MODERATE_EMOTIONS] || moderate_emotions
		else
			final_list = controller.blackboard[BB_SAD_EMOTIONS] || depressed_emotions
	if(!length(final_list))
		return
	controller.queue_behavior(/datum/ai_behavior/perform_emote, pick(final_list))

#undef HIGH_HAPPINESS_THRESHOLD
#undef MODERATE_HAPPINESS_THRESHOLD
