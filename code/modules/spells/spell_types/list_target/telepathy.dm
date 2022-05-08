
/datum/action/cooldown/spell/list_target/telepathy
	name = "Telepathy"
	desc = "Telepathically transmits a message to the target."
	icon_icon = 'icons/mob/actions/actions_revenant.dmi'
	button_icon_state = "r_transmit"

	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	antimagic_flags = MAGIC_RESISTANCE_MIND

	choose_target_message = "Choose a target to whisper to."

	/// The message we send to the next person via telepathy.
	var/message
	/// The span surrounding the telepathy message
	var/telepathy_span = "notice"
	/// The bolded span surrounding the telepathy message
	var/bold_telepathy_span = "boldnotice"

/datum/action/cooldown/spell/list_target/telepathy/before_cast(atom/cast_on)
	. = ..()
	if(!.)
		return FALSE

	message = tgui_input_text(cast_on, "What do you wish to whisper to [cast_on]?", "[src]")
	if(QDELETED(src) || QDELETED(owner) || QDELETED(cast_on) || !can_cast_spell(feedback = FALSE))
		return FALSE
	if(!message)
		reset_spell_cooldown()
		return FALSE

	return TRUE

/datum/action/cooldown/spell/list_target/telepathy/cast(atom/cast_on)
	. = ..()
	log_directed_talk(cast_on, to_telepath_to, message, LOG_SAY, name)

	var/formatted_message = "<span class='[telepathy_span]'>[message]</span>"

	to_chat(cast_on, "<span class='[bold_telepathy_span]'>You transmit to [to_telepath_to]:</span> [formatted_message]")
	if(!to_telepath_to.can_block_magic(antimagic_flags, charge_cost = 0)) //hear no evil
		to_chat(to_telepath_to, "<span class='[bold_telepathy_span]'>You hear something behind you talking...</span> [formatted_message]")

	for(var/mob/dead/ghost as anything in GLOB.dead_mob_list)
		if(!isobserver(ghost))
			continue

		var/from_link = FOLLOW_LINK(ghost, cast_on)
		var/from_mob_name = "<span class='[bold_telepathy_span]'>[cast_on] [src]:</span>"
		var/to_link = FOLLOW_LINK(ghost, to_telepath_to)
		var/to_mob_name = span_name("[to_telepath_to]")

		to_chat(ghost, "[from_link] [from_mob_name] [formatted_message] [to_link] [to_mob_name]")
