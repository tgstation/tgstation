/datum/ai_planning_subtree/random_speech
	//The chance of an emote occuring each second
	var/speech_chance = 0
	///Hearable emotes
	var/list/emote_hear = list()
	///Unlike speak_emote, the list of things in this variable only show by themselves with no spoken text. IE: Ian barks, Ian yaps
	var/list/emote_see = list()
	///Possible lines of speech the AI can have
	var/list/speak = list()

/datum/ai_planning_subtree/random_speech/New()
	. = ..()
	if(speak)
		speak = string_list(speak)
	if(emote_hear)
		emote_hear = string_list(emote_hear)
	if(emote_see)
		emote_see = string_list(emote_hear)

/datum/ai_planning_subtree/random_speech/SelectBehaviors(datum/ai_controller/controller, delta_time)
	if(DT_PROB(speech_chance))
		var/audible_emotes_length = emote_hear?.len
		var/non_audible_emotes_length = emote_see?.len
		var/speak_lines_length = speak?.len

		var/total_choices_length = audible_emotes_length + non_audible_emotes_length + speak_lines_length

		var/random_number_in_range =  rand(1, total_choices_length)

		if(random_number_in_range <= audible_emotes_length)
			controller.blackboard[BB_BASIC_MOB_NEXT_EMOTE] = pick(emote_hear)
			LAZYADD(controller.current_behaviors, GET_AI_BEHAVIOR(/datum/ai_behavior/perform_emote/basic_mob))
		else if(random_number_in_range <= audible_emotes_length + non_audible_emotes_length)
			controller.blackboard[BB_BASIC_MOB_NEXT_EMOTE] = pick(emote_see)
			LAZYADD(controller.current_behaviors, GET_AI_BEHAVIOR(/datum/ai_behavior/perform_emote/basic_mob))
		else
			controller.blackboard[BB_BASIC_MOB_NEXT_EMOTE] = pick(speak)
			LAZYADD(controller.current_behaviors, GET_AI_BEHAVIOR(/datum/ai_behavior/perform_speech/basic_mob))



/datum/ai_planning_subtree/random_speech/cockroach
