/datum/spellbook_entry/summon/message//sends a curse of madness message for free without any effect on the crew
	name = "Magical Announcement"
	desc = "Stealth is for NERDS. Tell the station what you really think about them."
	cost = 0
	can_random = FALSE

/datum/spellbook_entry/summon/message/buy_spell(mob/living/carbon/human/user, obj/item/spellbook/book, log_buy = TRUE)
	var/message = tgui_input_text(user, "Tell the station whats on your mind.", "Tell them All")
	if(!message)
		return FALSE
	for(var/mob/living/carbon/human/messaged in GLOB.player_list)
		if(messaged.stat == DEAD)
			continue
		var/turf/messaged_turf = get_turf(messaged)
		if(messaged_turf && !is_station_level(messaged_turf.z))
			continue
		to_chat(messaged, span_reallybig(span_hypnophrase(message)))
	return ..()
