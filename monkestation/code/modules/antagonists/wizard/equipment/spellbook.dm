////////////
// SPELLS //
////////////


/datum/spellbook_entry/lesser_summonapes
	name = "Lesser Summon Apes"
	spell_type = /obj/effect/proc_holder/spell/aoe_turf/conjure/lesser_summonapes
	category = "Defensive"
	cost = 3

/datum/spellbook_entry/mutagenic_pulse
	name = "Mutagenic Pulse"
	spell_type = /obj/effect/proc_holder/spell/aoe_turf/mutagenic_pulse
	cost = 1 // making this cost 1 due to mass produced mutadone effectively countering it


///////////
// ITEMS //
///////////


/datum/spellbook_entry/item/magicspray
	name = "Magical Chem Sprayer"
	desc = "A magic chemical sprayer that will fill itself with unlimited random chemicals."
	item_path = /obj/item/reagent_containers/spray/chemsprayer/magical
	category = "Assistance"
	cost = 1


/////////////
// RITUALS //
/////////////


/datum/spellbook_entry/summon/message//sends a curse of madness message for free without any effect on the crew
	name = "Magical Announcement"
	desc = "Stealth is for NERDS. Tell the station what you really think about them."
	cost = 0

/datum/spellbook_entry/summon/message/Buy(mob/living/carbon/human/user, obj/item/spellbook/book)
	SSblackbox.record_feedback("tally", "wizard_spell_learned", 1, name)
	active = TRUE
	var/message = stripped_input(user, "Tell the station whats on your mind.", "Tell them All")
	if(!message)
		return FALSE
	if(CHAT_FILTER_CHECK(message))
		if(user)
			to_chat(user, "<span class='warning'>You message contains forbidden words, please review the server rules and do not attempt to bypass this filter.</span>")
			return FALSE
	for(var/mob/living/carbon/human/messaged in GLOB.player_list)
		if(messaged.stat == DEAD)
			continue
		var/turf/TTS = get_turf(messaged)
		if(TTS && !is_station_level(TTS.z))
			continue
		to_chat(messaged, "<span class='reallybig hypnophrase'>[message]</span>")
	return TRUE
