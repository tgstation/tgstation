/datum/twitch_event/free_wiz
	event_name = "Change Ook's Fate"
	event_duration = 1 SECONDS
	event_flags = TWITCH_AFFECTS_STREAMER
	id_tag = "ook-die-fate"
	token_cost = 2500

/datum/twitch_event/free_wiz/run_event(name)
	. = ..()

	for(var/target in targets)
		var/mob/living/future_wiz = target
		var/obj/item/dice/d20/fate/one_use/the_die = new(get_turf(future_wiz))
		future_wiz.put_in_hands(the_die)
		to_chat(future_wiz, span_warning("Something apears in your hand and- oh no you fumbled it. That can't be good."))
		the_die.diceroll(future_wiz)

//this is more of a joke, could maybe cost 100k bits or something
/datum/twitch_event/free_wiz/everyone
	event_name = "Change Everyone's Fate"
	event_flags = TWITCH_AFFECTS_ALL
	id_tag = "everyone-die-fate"
	token_cost = 5002 // :)
