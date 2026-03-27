/datum/action/cooldown/mob_cooldown/flock_narrowbeam
	name = "Narrowbeam"
	background_icon = 'troutstation/icons/mob/actions/backgrounds.dmi'
	background_icon_state = "bg_flock"
	overlay_icon_state = "bg_flock_border"
	button_icon = 'icons/obj/clothing/headsets.dmi' // TODO: CUSTOM
	button_icon_state = "headset" // TODO: CUSTOM
	desc = "Speak directly to someone through radio. No one else will hear your message. Unlimited range. You can also do this from within signal-space."
	cooldown_time = 10 SECONDS
	shared_cooldown = NONE
	click_to_activate = TRUE
	ranged_mousepointer = 'icons/effects/mouse_pointers/supplypod_target.dmi'

	/// Message we want to send
	var/message
	/// Span we use to format transmission
	var/transmission_span = "flock"
	/// Bolded span we use to format transmission
	var/bold_transmission_span = "flockbold"

/datum/action/cooldown/mob_cooldown/flock_narrowbeam/Activate(atom/target_atom)
	if(!isliving(target_atom))
		to_chat(owner, span_warning("Let's not talk to [target_atom], actually."))
		return FALSE
	var/mob/living/target_living = target_atom
	var/list/target_radios = get_all_listening_radios_in(target_atom)
	if(!length(target_radios))
		target_living.balloon_alert(owner, "no radio!")
		to_chat(owner, span_warning("Can't find a working radio device to target on [target_living]."))
		return FALSE

	message = tgui_input_text(owner, "What do you wish to transmit to [target_living]?", "[src]", max_length = MAX_MESSAGE_LEN)
	if(QDELETED(src) || QDELETED(owner) || QDELETED(target_atom))
		return FALSE

	disable_cooldown_actions()
	transmit(target_living, message)
	StartCooldown()
	enable_cooldown_actions()
	return TRUE

/datum/action/cooldown/mob_cooldown/flock_narrowbeam/proc/transmit(mob/living/target, message)
	log_directed_talk(owner, target, message, LOG_SAY, name)

	var/formatted_message = "<span class='[transmission_span]'>[message]</span>"

	to_chat(owner, "<span class='[bold_transmission_span]'>You transmit to [target]:</span> [formatted_message]")
	target.balloon_alert(target, "you hear a voice")
	to_chat(target, "<span class='[bold_transmission_span]'>You hear something crackle from the radio...</span> [formatted_message]")

	for(var/mob/dead/ghost as anything in GLOB.dead_mob_list)
		if(!isobserver(ghost))
			continue

		var/from_link = FOLLOW_LINK(ghost, owner)
		var/from_mob_name = "<span class='[bold_transmission_span]'>[owner] [src]:</span>"
		var/to_link = FOLLOW_LINK(ghost, target)
		var/to_mob_name = span_name("[target]")

		to_chat(ghost, "[from_link] [from_mob_name] [formatted_message] [to_link] [to_mob_name]")
