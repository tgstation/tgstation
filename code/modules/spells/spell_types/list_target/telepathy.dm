
/datum/action/cooldown/spell/list_target/telepathy
	name = "Telepathy"
	desc = "Telepathically transmits a message to the target."
	button_icon = 'icons/mob/actions/actions_revenant.dmi'
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
	if(. & SPELL_CANCEL_CAST)
		return

	message = tgui_input_text(owner, "What do you wish to whisper to [cast_on]?", "[src]", max_length = MAX_MESSAGE_LEN)
	if(QDELETED(src) || QDELETED(owner) || QDELETED(cast_on) || !can_cast_spell())
		return . | SPELL_CANCEL_CAST

	if(get_dist(cast_on, owner) > target_radius)
		owner.balloon_alert(owner, "they're too far!")
		return . | SPELL_CANCEL_CAST

	if(!message)
		reset_spell_cooldown()
		return . | SPELL_CANCEL_CAST

/datum/action/cooldown/spell/list_target/telepathy/cast(mob/living/cast_on)
	. = ..()
	log_directed_talk(owner, cast_on, message, LOG_SAY, name)

	var/formatted_message = "<span class='[telepathy_span]'>[message]</span>"

	var/failure_message_for_ghosts = ""

	to_chat(owner, "<span class='[bold_telepathy_span]'>You transmit to [cast_on]:</span> [formatted_message]")
	if(!cast_on.can_block_magic(antimagic_flags, charge_cost = 0)) //hear no evil
		cast_on.balloon_alert(cast_on, "you hear a voice")
		to_chat(cast_on, "<span class='[bold_telepathy_span]'>You hear a voice in your head...</span> [formatted_message]")
	else
		owner.balloon_alert(owner, "transmission blocked!")
		to_chat(owner, span_warning("Something has blocked your transmission!"))
		failure_message_for_ghosts = "<span class='[bold_telepathy_span]'> (blocked by antimagic)</span>"

	for(var/mob/dead/ghost as anything in GLOB.dead_mob_list)
		if(!isobserver(ghost))
			continue

		var/from_link = FOLLOW_LINK(ghost, owner)
		var/from_mob_name = "<span class='[bold_telepathy_span]'>[owner] [src]</span>"
		from_mob_name += failure_message_for_ghosts
		from_mob_name += "<span class='[bold_telepathy_span]'>:</span>"
		var/to_link = FOLLOW_LINK(ghost, cast_on)
		var/to_mob_name = span_name("[cast_on]")

		to_chat(ghost, "[from_link] [from_mob_name] [formatted_message] [to_link] [to_mob_name]")
