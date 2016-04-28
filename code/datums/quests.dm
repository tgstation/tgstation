/datum/quest
	var/name = "Unnamed Quest"
	var/atom/movable/host
	var/mob/living/hero
	var/in_progress = FALSE
	var/success = FALSE
	var/list/messages = list()

/datum/quest/proc/begin()
	in_progress = TRUE

/datum/quest/proc/end()
	in_progress = FALSE

/datum/quest/proc/interact()

/datum/quest/proc/add_message(text)
	messages += new /datum/quest_message(text)

/datum/quest/proc/Hear()

/datum/quest/just_say
	name = "Just Say X"
	var/word

/datum/quest/just_say/begin()
	..()
	var/survey_type = pick("dimension", "station", "species", "sector", \
		"organic-subtype", "social and economic class", "gender", \
		"sexual preference", "job", "current state of sanity", "blood type", \
		"intelligence", "memetic tollerance", "$SURVEY_TYPE")

	add_message("Hello, we are doing a audio survey of people of your \
		[survey_type], could you please say the following out loud:")
	add_message(word)
	return TRUE

/datum/quest/just_say/end()
	var/possible_items = pick("light refreshments", "complimentary napkins", \
		"random items we had lying around the office", "expensive foodstuffs",
		"cheap tourist knick nacks", "meaningful dialogues", "pills", \
		"quest rewards", "lizard tails", "human tails", "drone leftovers", \
		"$REWARD_ITEM")

	add_message("Thanks for participating in our survey. Please take these \
		[possible_items] as thanks.")
	success = TRUE
	return TRUE

/datum/quest/just_say/Hear(message, atom/movable/speaker, message_langs, raw_message, radio_freq, spans)
	if(findtext(lowertext(message), word))
		. = end()

/datum/quest/just_say/potato
	name = "Just Say Potato"
	word = "potato"


/datum/quest_message
	var/timestamp
	var/text
	var/list/spans

/datum/quest_message/New(new_text, new_time = null, new_spans = null)
	if(!new_time)
		new_time = worldtime2text()
	if(!new_spans)
		new_spans = list()

	timestamp = new_time
	text = new_text
	spans = new_spans
