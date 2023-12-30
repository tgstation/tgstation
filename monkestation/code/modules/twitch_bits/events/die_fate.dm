/datum/twitch_event/free_wiz
	event_name = "Change Ook's Fate"
	event_duration = 1 SECONDS
	event_flags = TWITCH_AFFECTS_STREAMER
	id_tag = T_EVENT_OOK_DIE_FATE
	token_cost = 1000

/datum/twitch_event/free_wiz/run_event(name)
	. = ..()

	for(var/target in targets)
		var/mob/living/future_wiz = target
		var/obj/item/dice/d20/fate/one_use/the_die = new(get_turf(future_wiz))
		future_wiz.put_in_hands(the_die)
		to_chat(future_wiz, span_userdanger("Something apears in your hand and- oh no you fumbled it. That can't be good."))
		addtimer(CALLBACK(the_die, TYPE_PROC_REF(/obj/item/dice, diceroll), future_wiz), 0.5 SECONDS)

//this is more of a joke, could maybe cost 100k bits or something
/datum/twitch_event/free_wiz/everyone
	event_name = "Change Everyone's Fate"
	event_flags = TWITCH_AFFECTS_ALL
	id_tag = T_EVENT_EVERYONE_DIE_FATE
	token_cost = 5002 // :)
