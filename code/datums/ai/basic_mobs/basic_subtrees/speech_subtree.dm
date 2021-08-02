/datum/ai_planning_subtree/random_speech
	//The chance of speech occuring each second
	var/speak_chance = 0
	///Possible lines of speech the AI can have
	var/list/speak = list()

/datum/ai_planning_subtree/random_speech/SelectBehaviors(datum/ai_controller/controller, delta_time)
	if(DT_PROB(speak_chance))
		if((emote_hear?.len) || (emote_see?.len))
			var/length = speak.len
			if(emote_hear?.len)
				length += emote_hear.len
			if(emote_see?.len)
				length += emote_see.len
			var/randomValue = rand(1,length)
			if(randomValue <= speak.len)
				say(pick(speak), forced = "poly")
			else
				randomValue -= speak.len
				if(emote_see && randomValue <= emote_see.len)
					manual_emote(pick(emote_see))
				else
					manual_emote(pick(emote_hear))
		else
			say(pick(speak), forced = "Basic Mob")

/datum/ai_planning_subtree/random_emotes
	//The chance of an emote occuring each second
	var/emote_chance = 0
	///Hearable emotes
	var/list/emote_hear = list()
	///Unlike speak_emote, the list of things in this variable only show by themselves with no spoken text. IE: Ian barks, Ian yaps
	var/list/emote_see = list()

/datum/ai_planning_subtree/random_emotes/SelectBehaviors(datum/ai_controller/controller, delta_time)
	if(DT_PROB(emote_chance))
		var/has_audible_emotes = emote_hear?.len
		var/has_non_audible_emotes = emote_see?.len

		///We have both, pick from one of the two.
		if(has_audible_emotes && has_non_audible_emotes)
			var/total_emote_length = emote_hear.len + emote_see.len
			var/pick = rand(1, total_emote_length)
			if(pick <= emote_see.len)
				manual_emote(pick(emote_see))
			else
				manual_emote(pick(emote_hear))

		else if(has_audible_emotes)
			manual_emote(pick(emote_hear))
		else if(has_non_audible_emotes)
			manual_emote(pick(emote_see))



