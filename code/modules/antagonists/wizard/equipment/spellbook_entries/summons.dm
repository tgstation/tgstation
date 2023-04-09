// Ritual spells which affect the station at large
/// How much threat we need to let these rituals happen on dynamic //monkestation edit: changed to a population check
#define MINIMUM_POP_FOR_RITUALS 35 //monkestation edit: replaced MINIMUM_THREAT_FOR_RITUALS 100

/datum/spellbook_entry/summon/ghosts
	name = "Summon Ghosts"
	desc = "Spook the crew out by making them see dead people. \
		Be warned, ghosts are capricious and occasionally vindicative, \
		and some will use their incredibly minor abilities to frustrate you."
	cost = 0

/datum/spellbook_entry/summon/ghosts/buy_spell(mob/living/carbon/human/user, obj/item/spellbook/book)
	summon_ghosts(user)
	playsound(get_turf(user), 'sound/effects/ghost2.ogg', 50, TRUE)
	return ..()

/datum/spellbook_entry/summon/guns
	name = "Summon Guns"
	desc = "Nothing could possibly go wrong with arming a crew of lunatics just itching for an excuse to kill you. \
		There is a good chance that they will shoot each other first."

/datum/spellbook_entry/summon/guns/can_be_purchased()
	// Summon Guns requires 100 threat. //monkestation edit: now 35 pop
//	var/datum/game_mode/dynamic/mode = SSticker.mode //monkestation edit: not needed for pop checks
	if(get_active_player_count() < MINIMUM_POP_FOR_RITUALS) //monkestation edit: replaces a threat check with this pop check
		return FALSE
	// Also must be config enabled
	return !CONFIG_GET(flag/no_summon_guns)

/datum/spellbook_entry/summon/guns/buy_spell(mob/living/carbon/human/user,obj/item/spellbook/book)
	summon_guns(user, 10)
	playsound(get_turf(user), 'sound/magic/castsummon.ogg', 50, TRUE)
	return ..()

/datum/spellbook_entry/summon/magic
	name = "Summon Magic"
	desc = "Share the wonders of magic with the crew and show them \
		why they aren't to be trusted with it at the same time."

/datum/spellbook_entry/summon/magic/can_be_purchased()
	// Summon Magic requires 100 threat. //monkestation edit: now 35 pop
//	var/datum/game_mode/dynamic/mode = SSticker.mode //monkestation edit: not needed for pop checks
	if(get_active_player_count() < MINIMUM_POP_FOR_RITUALS) //monkestation edit: replaces a threat check with this pop check
		return FALSE
	// Also must be config enabled
	return !CONFIG_GET(flag/no_summon_magic)

/datum/spellbook_entry/summon/magic/buy_spell(mob/living/carbon/human/user,obj/item/spellbook/book)
	summon_magic(user, 10)
	playsound(get_turf(user), 'sound/magic/castsummon.ogg', 50, TRUE)
	return ..()

/datum/spellbook_entry/summon/events
	name = "Summon Events"
	desc = "Give Murphy's law a little push and replace all events with \
		special wizard ones that will confound and confuse everyone. \
		Multiple castings increase the rate of these events. \
		Can only be cast on station." //monkestation edit
	cost = 2
	limit = 5 // Each purchase can intensify it.

/datum/spellbook_entry/summon/events/can_be_purchased()
	// Summon Events requires 100 threat. //monkestation edit: now 35 pop
//	var/datum/game_mode/dynamic/mode = SSticker.mode //monkestation edit: not needed for pop checks
	if(get_active_player_count() < MINIMUM_POP_FOR_RITUALS) //monkestation edit: replaces a threat check with this pop check
		return FALSE
	// Also, must be config enabled
	return !CONFIG_GET(flag/no_summon_events)

/datum/spellbook_entry/summon/events/buy_spell(mob/living/carbon/human/user, obj/item/spellbook/book)
	var/turf/user_turf = get_turf(user) //monkestation edit: you need to be on station to cast summon events to make sure you will also feel the effects
	if(user_turf && !is_station_level(user_turf.z)) //monkestation edit
		to_chat(user, span_warning("You need to be on the station!")) //monkestation edit
		return FALSE //monkestation edit
	summon_events(user)
	playsound(get_turf(user), 'sound/magic/castsummon.ogg', 50, TRUE)
	return ..()

/datum/spellbook_entry/summon/curse_of_madness
	name = "Curse of Madness"
	desc = "Curses the station, warping the minds of everyone inside, causing lasting traumas. Warning: this spell can affect you if not cast from a safe distance."
	cost = 4

/datum/spellbook_entry/summon/curse_of_madness/buy_spell(mob/living/carbon/human/user, obj/item/spellbook/book)
	var/message = tgui_input_text(user, "Whisper a secret truth to drive your victims to madness", "Whispers of Madness")
	if(!message)
		return FALSE
	curse_of_madness(user, message)
	playsound(user, 'sound/magic/mandswap.ogg', 50, TRUE)
	return ..()

#undef MINIMUM_POP_FOR_RITUALS
