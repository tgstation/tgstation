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

/datum/action/personality_commune/Grant(mob/grant_to)
	if(!istype(grant_to, /mob/living/split_personality))
		return

	return ..()

/datum/action/personality_commune/Trigger(trigger_flags)
	. = ..()
	if(!.)
		return FALSE

	var/datum/brain_trauma/severe/split_personality/trauma = target
	var/mob/living/split_personality/non_controller = usr
	var/client/non_controller_client = non_controller.client

	var/to_send = tgui_input_text(non_controller, "What would you like to tell your other self?", "Commune", max_length = MAX_MESSAGE_LEN)
	if(QDELETED(src) || QDELETED(trauma) || !to_send)
		return FALSE

	var/mob/living/carbon/human/personality_body = trauma.owner
	if(personality_body.client == non_controller_client) // We took control
		return FALSE

	var/user_message = span_boldnotice("You concentrate and send thoughts to your other self:")
	var/user_message_body = span_notice("[to_send]")

	to_chat(non_controller, "[user_message] [user_message_body]")

	personality_body.balloon_alert(personality_body, "you hear a voice")
	to_chat(personality_body, "[fluff_text] [user_message_body]")

	log_directed_talk(non_controller, personality_body, to_send, LOG_SAY, "[name]")
	for(var/dead_mob in GLOB.dead_mob_list)
		if(!isobserver(dead_mob))
			continue
		to_chat(dead_mob, "[FOLLOW_LINK(dead_mob, non_controller)] [span_boldnotice("[non_controller] [name]:")] [span_notice("\"[to_send]\" to")] [span_name("[trauma]")]")

	return TRUE
