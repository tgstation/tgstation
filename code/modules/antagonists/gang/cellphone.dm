GLOBAL_LIST_EMPTY(gangster_cell_phones)

/obj/item/gangster_cellphone
	name = "cell phone"
	desc = "TODO: funny joke about the 80s, brick phones"
	icon = 'icons/obj/gang/cell_phone.dmi'
	icon_state = "phone_off"
	throwforce = 15 // these things are dense as fuck
	var/gang_id = "Grove Street Families"
	var/activated = FALSE

/obj/item/gangster_cellphone/Initialize(mapload)
	. = ..()
	GLOB.gangster_cell_phones += src
	become_hearing_sensitive()

/obj/item/gangster_cellphone/Destroy()
	GLOB.gangster_cell_phones -= src
	. = ..()

/obj/item/gangster_cellphone/attack_self(mob/user, modifiers)
	. = ..()
	if(!activated)
		to_chat(user, "You turn on [src].")
		icon_state = "phone_on"
		activated = TRUE
	else
		to_chat(user, "You turn off [src].")
		icon_state = "phone_off"
		activated = FALSE

/obj/item/gangster_cellphone/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, list/message_mods)
	. = ..()
	if(!activated)
		return
	if(get_turf(speaker) != get_turf(src))
		return
	broadcast_message(raw_message, speaker)

/obj/item/gangster_cellphone/proc/broadcast_message(message, atom/movable/speaker)
	for(var/obj/item/gangster_cellphone/brick in GLOB.gangster_cell_phones)
		if(brick.gang_id == gang_id)
			brick.say_message(message, speaker)
	for(var/mob/dead/observer/player_mob in GLOB.player_list)
		if(!istype(player_mob, /mob/dead/observer))
			continue
		if(QDELETED(player_mob)) //Some times nulls and deleteds stay in this list. This is a workaround to prevent ic chat breaking for everyone when they do.
			continue //Remove if underlying cause (likely byond issue) is fixed. See TG PR #49004.
		if(player_mob.stat != DEAD) //not dead, not important
			continue
		if(get_dist(player_mob, src) > 7 || player_mob.z != z) //they're out of range of normal hearing
			if(!(player_mob.client.prefs.chat_toggles & CHAT_GHOSTEARS)) //they're talking normally and we have hearing at any range off
				continue
		var/link = FOLLOW_LINK(player_mob, src)	
		to_chat(player_mob, span_gangradio("[link] <b>[speaker.name]</b> \[CELL: [gang_id]\] says, \"[message]\""))
		
/obj/item/gangster_cellphone/proc/say_message(message, atom/movable/speaker)
	for(var/mob/living/carbon/human/cellphone_hearer in get_turf(src))
		if(HAS_TRAIT(cellphone_hearer, TRAIT_DEAF))
			continue
		to_chat(cellphone_hearer, span_gangradio("<b>[speaker.name]</b> \[CELL: [gang_id]\] says, \"[message]\""))
