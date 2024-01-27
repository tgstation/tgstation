/datum/job/clown/after_spawn(mob/living/spawned, client/player_client)
	. = ..()
	if(!ishuman(spawned) || !player_client)
		return
	if(HAS_TRAIT(SSstation, STATION_TRAIT_CLOWN_BRIDGE))
		var/obj/item/card/id/card = spawned.get_idcard(hand_first = FALSE)
		if(card)
			card.add_access(list(ACCESS_COMMAND), mode = FORCE_ADD_ALL)
			card.desc += "\n<b>You can see the word \"<span class='honk'>BRIDGE</span>\" hastily scribbled over it in crayon, and nobody knows why the system recognizes this as valid.</b>"
			to_chat(player_client, span_boldnotice("The <span class='honk'>Clown Planet</span> has given all clowns access to a specific weakness in airlock ID scanners, resulting in all clowns having <b>bridge access</b>! Honk!"))
