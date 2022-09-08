/**
 * ## Channelled spells
 *
 * These spells do something after a channel time.
 * To use this template, all that's needed is for cast() to be implemented.
 */
/datum/action/cooldown/spell/charged
	/// What message do we display when we start chanelling?
	var/channel_message
	/// Whether we're currently channelling / charging the spell
	var/currently_channeling = FALSE
	/// How long it takes to channel the spell.
	var/channel_time = 10 SECONDS

	// Overlay optional, applied when we start channelling
	/// What icon should we use for our overlay
	var/charge_overlay_icon
	/// What icon state should we use for our overlay
	var/charge_overlay_state
	/// The actual appearance / our overlay. Don't mess with this
	var/mutable_appearance/charge_overlay_instance

	// Sound optional, played when we start chanelling
	/// What soundpath should we play when we start chanelling
	var/charge_sound
	/// The actual sound we generate, don't mess with this
	var/sound/charge_sound_instance

/datum/action/cooldown/spell/charged/New(Target, original)
	. = ..()
	if(!channel_message)
		channel_message = span_notice("You start chanelling [src]...")

	if(charge_sound)
		charge_sound_instance = sound(charge_sound, channel = CHANNEL_CHARGED_SPELL)

	if(charge_overlay_icon && charge_overlay_state)
		charge_overlay_instance = mutable_appearance(charge_overlay_icon, charge_overlay_state, EFFECTS_LAYER)

/datum/action/cooldown/spell/charged/Destroy()
	if(owner)
		stop_channel_effect(owner)

	charge_overlay_instance = null
	charge_sound_instance = null
	return ..()

/datum/action/cooldown/spell/charged/Remove(mob/living/remove_from)
	stop_channel_effect(remove_from)
	return ..()

/datum/action/cooldown/spell/charged/can_cast_spell(feedback = TRUE)
	. = ..()
	if(!.)
		return FALSE
	if(currently_channeling)
		if(feedback)
			to_chat(owner, span_warning("You're already channeling [src]!"))
		return FALSE

	return TRUE

/datum/action/cooldown/spell/charged/before_cast(atom/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return

	// Always no feedback, it's handled at the end of cast
	. |= SPELL_NO_FEEDBACK

	to_chat(cast_on, channel_message)

	if(charge_sound_instance)
		playsound(cast_on, charge_sound_instance, 50, FALSE)

	if(charge_overlay_instance)
		cast_on.add_overlay(charge_overlay_instance)

	currently_channeling = TRUE
	UpdateButtons()
	if(!do_after(cast_on, channel_time, timed_action_flags = (IGNORE_USER_LOC_CHANGE|IGNORE_HELD_ITEM)))
		stop_channel_effect(cast_on)
		return . | SPELL_CANCEL_CAST

/datum/action/cooldown/spell/charged/cast(atom/cast_on)
	. = ..()
	spell_feedback()
	stop_channel_effect(cast_on)

/datum/action/cooldown/spell/charged/set_statpanel_format()
	. = ..()
	if(!islist(.))
		return

	if(currently_channeling)
		.[PANEL_DISPLAY_STATUS] = "CHANNELING"

/// Interrupts the chanelling effect, removing any overlay or sound playing (for the passed mob)
/datum/action/cooldown/spell/charged/proc/stop_channel_effect(mob/for_who)
	if(charge_overlay_instance)
		for_who.cut_overlay(charge_overlay_instance)

	if(charge_sound_instance)
		for_who.stop_sound_channel(CHANNEL_CHARGED_SPELL)
		// Play a null sound in to cancel the sound playing, because byond
		playsound(for_who, sound(null, repeat = 0, channel = CHANNEL_CHARGED_SPELL), 50, FALSE)

	currently_channeling = FALSE
	UpdateButtons()
