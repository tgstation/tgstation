// This can probably be changed to use mind linker at some point
/datum/action/personality_commune
	name = "Personality Commune"
	desc = "Sends thoughts to your alternate consciousness."
	background_icon_state = "bg_spell"
	button_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "telepathy"
	overlay_icon_state = "bg_spell_border"

	/// Fluff text shown when a message is sent to the pair
	var/fluff_text = span_boldnotice("You hear an echoing voice in the back of your head...")

/datum/action/personality_commune/New(Target)
	. = ..()
	if(!istype(target, /datum/brain_trauma/severe/split_personality))
		stack_trace("[type] was created on a target that isn't a /datum/brain_trauma/severe/split_personality, this doesn't work.")
		qdel(src)

/datum/action/personality_commune/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return FALSE

	var/datum/brain_trauma/severe/split_personality/trauma = target
	if(!istype(trauma))
		CRASH("Personality Commune was triggered on a target that isn't a /datum/brain_trauma/severe/split_personality.")

	var/mob/living/split_personality/person = usr
	if(!istype(person))
		CRASH("Personality Commune was triggered by a usr that isn't /mob/living/split_personality.")

	var/client/sender_client = person.client
	var/to_send = tgui_input_text(person, "What would you like to tell your other self?", "Commune")
	if(QDELETED(src) || QDELETED(trauma) || !to_send)
		return FALSE
	if(trauma.owner.client == sender_client) // We took control
		return FALSE

	var/user_message = span_boldnotice("You concentrate and send thoughts to your other self:")
	var/user_message_body = span_notice("[to_send]")

	to_chat(person, "[user_message] [user_message_body]")

	trauma.owner.balloon_alert(trauma.owner, "you hear a voice")
	to_chat(trauma.owner, "[fluff_text] [user_message_body]")

	log_directed_talk(person, trauma.owner, to_send, LOG_SAY, "[name]")
	for(var/dead_mob in GLOB.dead_mob_list)
		if(!isobserver(dead_mob))
			continue
		to_chat(dead_mob, "[FOLLOW_LINK(dead_mob, person)] [span_boldnotice("[person] [name]:")] [span_notice("\"[to_send]\" to")] [span_name("[trauma]")]")

	return TRUE
