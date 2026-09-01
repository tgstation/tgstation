/// Occasionally emotes based on the pawn's current happiness level.
/datum/bt_node/ai_behavior/express_happiness
	/// Probability (%) of emoting per per second
	var/emote_probability = 5
	/// Happiness >= this threshold -> happy emotions
	var/high_happiness_threshold = 0.7
	/// Happiness >= this threshold -> moderate emotions
	var/moderate_happiness_threshold = 0.5
	/// Blackboard key holding the happiness value
	var/happiness_key = BB_BASIC_HAPPINESS
	/// Blackboard key holding a custom happy emotions list
	var/happy_key = BB_HAPPY_EMOTIONS
	/// Blackboard key holding a custom moderate emotions list
	var/moderate_key = BB_MODERATE_EMOTIONS
	/// Blackboard key holding a custom sad emotions list
	var/sad_key = BB_SAD_EMOTIONS

	var/static/list/default_happy_emotions = list(
		"celebrates happily!",
		"dances around in excitement!",
	)
	var/static/list/default_moderate_emotions = list(
		"looks satisfied.",
		"trots around.",
	)
	var/static/list/default_depressed_emotions = list(
		"looks depressed...",
		"turns its back and sulks...",
		"looks towards the floor in dissapointment...",
	)

/datum/bt_node/ai_behavior/express_happiness/perform(seconds_per_tick, datum/ai_controller/controller)
	if(!SPT_PROB(emote_probability, seconds_per_tick))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

	var/happiness = controller.blackboard[happiness_key]
	if(isnull(happiness))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

	var/list/emotion_list
	if(happiness >= high_happiness_threshold)
		emotion_list = controller.blackboard[happy_key] || default_happy_emotions
	else if(happiness >= moderate_happiness_threshold)
		emotion_list = controller.blackboard[moderate_key] || default_moderate_emotions
	else
		emotion_list = controller.blackboard[sad_key] || default_depressed_emotions

	if(!length(emotion_list))
		return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED

	var/mob/living/living_pawn = controller.pawn
	living_pawn.manual_emote(pick(emotion_list))
	return AI_BEHAVIOR_INSTANT | AI_BEHAVIOR_SUCCEEDED
