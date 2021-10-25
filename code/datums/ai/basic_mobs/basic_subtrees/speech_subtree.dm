/datum/ai_planning_subtree/random_speech
	//The chance of an emote occuring each second
	var/speech_chance = 0
	///Hearable emotes
	var/list/emote_hear = list()
	///Unlike speak_emote, the list of things in this variable only show by themselves with no spoken text. IE: Ian barks, Ian yaps
	var/list/emote_see = list()
	///Possible lines of speech the AI can have
	var/list/speak = list()
	///Possible datum emotes the mob can perform
	var/list/datum_emote_keys = list()

/datum/ai_planning_subtree/random_speech/New()
	. = ..()
	if(speak)
		speak = string_list(speak)
	if(emote_hear)
		emote_hear = string_list(emote_hear)
	if(emote_see)
		emote_see = string_list(emote_see)
	if(datum_emote_keys)
		datum_emote_keys = string_list(datum_emote_keys)

/datum/ai_planning_subtree/random_speech/SelectBehaviors(datum/ai_controller/controller, delta_time)
	if(DT_PROB(speech_chance, delta_time))
		var/audible_emotes_length = emote_hear?.len
		var/non_audible_emotes_length = emote_see?.len
		var/speak_lines_length = speak?.len
		var/datum_emote_key_length = datum_emote_keys?.len

		var/total_choices_length = audible_emotes_length + non_audible_emotes_length + speak_lines_length + datum_emote_key_length

		var/random_number_in_range =  rand(1, total_choices_length)

		if(random_number_in_range <= audible_emotes_length)
			controller.queue_behavior(/datum/ai_behavior/perform_emote, pick(emote_hear))
		else if(random_number_in_range <= (audible_emotes_length + non_audible_emotes_length))
			controller.queue_behavior(/datum/ai_behavior/perform_emote, pick(emote_see))
		else if(random_number_in_range <= (audible_emotes_length + non_audible_emotes_length + speak_lines_length))
			controller.queue_behavior(/datum/ai_behavior/perform_speech, pick(speak))
		else
			controller.queue_behavior(/datum/ai_behavior/perform_datum_emote, pick(datum_emote_keys))

/datum/ai_planning_subtree/random_speech/cockroach
	speech_chance = 5
	emote_hear = list("chitters")

/datum/ai_planning_subtree/random_speech/cow
	speech_chance = 1
	speak = list("moo?","moo","MOOOOOO")
	emote_hear = list("brays.")
	emote_see = list("shakes her head.")

///unlike normal cows, wisdom cows speak of wisdom and won't shut the fuck up
/datum/ai_planning_subtree/random_speech/cow/wisdom
	speech_chance = 15

/datum/ai_planning_subtree/random_speech/cow/wisdom/New()
	. = ..()
	speak = GLOB.wisdoms //Done here so it's setup properly

/datum/ai_planning_subtree/random_speech/pigeon
	speech_chance = 5
	emote_see = list("picks at the ground.", "fluffs up their feathers.")
	datum_emote_keys = list("coo", "flap")

/datum/ai_planning_subtree/random_speech/crab
	speech_chance = 3
	emote_hear = list("clicks.", "clacks.")
	emote_see = list("blows bubbles.")
