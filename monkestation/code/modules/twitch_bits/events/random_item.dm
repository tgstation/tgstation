/datum/twitch_event/give_smsword
	event_name = "Give Ook Random Item"
	event_duration = 1 SECONDS
	event_flags = TWITCH_AFFECTS_STREAMER
	id_tag = "give-ook-item"

/datum/twitch_event/give_smsword/run_event(name)
	. = ..()

	for(var/target in targets)
		var/mob/living/debug_uplink_reciever = target
		var/obj/item/gamer_item = pick(subtypesof(/obj/item))
		gamer_item = new gamer_item()
		debug_uplink_reciever.put_in_hands(gamer_item)
