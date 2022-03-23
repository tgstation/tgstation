
/datum/action/cooldown/spell/telepathy
	name = "Telepathy"
	desc = "Telepathically transmits a message to the target."
	icon_icon = 'icons/mob/actions/actions_revenant.dmi'
	button_icon_state = "r_transmit"

	spell_requirements = NONE

	/// The next mob we send a telepathy message to.
	var/mob/living/to_telepath_to
	/// The message sent to to_telepath_to
	var/message

	/// Radius around the caster that living targets are picked to choose from
	var/telepathy_radius = 7
	/// The span surrounding the telepathy message
	var/telepathy_span = "notice"
	/// The bolded span surrounding the telepathy message
	var/bold_telepathy_span = "boldnotice"

	/// Whether we're blocked by antimagic
	var/blocked_by_antimagic = FALSE
	/// Whether we're blocked by holiness
	var/blocked_by_holy = FALSE
	/// Whether we're blocked by tinfoil
	var/blocked_by_tinfoil = TRUE

/datum/action/cooldown/spell/telepathy/before_cast(atom/cast_on)
	. = ..()
	if(!.)
		return FALSE

	var/list/mobs_to_chose = get_telepathy_targets(cast_on)
	if(!length(mobs_to_chose))
		to_chat(cast_on, span_warning("No targets nearby."))
		return FALSE

	var/mob/living/chosen_mob = tgui_input_list(cast_on, "Choose a target to whisper to.", "[src]", sort_names(mobs_to_chose))
	if(QDELETED(src) || QDELETED(cast_on) || QDELETED(chosen_mob))
		return FALSE

	message = tgui_input_text(cast_on, "What do you wish to whisper to [chosen_mob]?", "[src]")
	if(QDELETED(src) || QDELETED(cast_on) || !message)
		return FALSE

	to_telepath_to = chosen_mob
	return TRUE

/datum/action/cooldown/spell/telepathy/cast(atom/cast_on)
	. = ..()
	log_directed_talk(cast_on, to_telepath_to, message, LOG_SAY, "[src]")

	var/formatted_message = "<span class='[telepathy_span]'>[message]</span>"

	to_chat(cast_on, "<span class='[bold_telepathy_span]'>You transmit to [to_telepath_to]:</span> [formatted_message]")
	if(!to_telepath_to.anti_magic_check(blocked_by_antimagic, blocked_by_holy, blocked_by_tinfoil, 0)) //hear no evil
		to_chat(to_telepath_to, "<span class='[bold_telepathy_span]'>You hear something behind you talking...</span> [formatted_message]")

	for(var/mob/dead/ghost as anything in GLOB.dead_mob_list)
		if(!isobserver(ghost))
			continue

		var/from_link = FOLLOW_LINK(ghost, cast_on)
		var/from_mob_name = "<span class='[bold_telepathy_span]'>[cast_on] [src]:</span>"
		var/to_link = FOLLOW_LINK(ghost, to_telepath_to)
		var/to_mob_name = span_name("[to_telepath_to]")

		to_chat(ghost, "[from_link] [from_mob_name] [formatted_message] [to_link] [to_mob_name]")

	to_telepath_to = null

/datum/action/cooldown/spell/telepathy/proc/get_telepathy_targets(atom/center)
	var/list/mobs_to_chose = list()
	for(var/mob/living/living_thing in view(telepathy_radius, center))
		mobs_to_chose += living_thing

	return mobs_to_chose
