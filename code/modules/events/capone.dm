/datum/round_event_control/capone
	name = "Cognitive Viral Outbreak"
	typepath = /datum/round_event/capone
	max_occurrences = 1
	min_players = 20

/datum/round_event/capone
	fakeable = FALSE

/datum/round_event/capone/start()
	for(var/obj/item/pda/P in GLOB.PDAs)
		var/mob/living/carbon/human/H = P.owner // P.owner is actually just the name text, link this to the actual person
		if(P.toff || !(P in H.get_contents()))
			continue
		if(!istype(H) || !H.client)
			continue
		if(H.stat == DEAD)
			continue
		if(!H.getorgan(/obj/item/organ/brain))
			continue
		
		var/message = "Hello [H.name]! You have been selected to try our new software application, GFriend! Standard messaging rates may apply."
		var/datum/signal/subspace/messaging/pda/signal = new(H, list(
			"name" = "???",
			"job" = "???",
			"message" = message,
			"targets" = list("[P.owner] ([P.ownjob])"),
			"automated" = 1
		))
		signal.send_to_receivers()
		usr.log_message("(PDA: Random Event (Photo Friend)) sent \"[message]\" to [signal.format_target()]", LOG_PDA)

		H.gain_trauma(/datum/brain_trauma/special/photo_friend)
		announce_to_ghosts(H)
