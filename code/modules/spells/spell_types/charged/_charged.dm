/**
 * ## Channelled spells
 *
 * These spells do something after a channel time.
 * To use this template, all that's needed is for cast() to be implemented.
 */
/datum/action/cooldown/spell/charged
	active_overlay_icon_state = "bg_spell_border_active_yellow"

	/// What message do we display when we start chanelling?
	var/channel_message
	/// Whether we're currently channelling / charging the spell
	var/currently_channeling = FALSE
	/// How long it takes to channel the spell.
	var/channel_time = 10 SECONDS
	/// Flags of the do_after
	var/channel_flags = IGNORE_USER_LOC_CHANGE|IGNORE_HELD_ITEM

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

/datum/action/cooldown/spell/charged/is_action_active(atom/movable/screen/movable/action_button/current_button)
	return currently_channeling

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

	to_chat(cast_on, channel_message)

	if(charge_sound_instance)
		playsound(cast_on, charge_sound_instance, 50, FALSE)

	if(charge_overlay_instance)
		cast_on.add_overlay(charge_overlay_instance)

	currently_channeling = TRUE
	build_all_button_icons(UPDATE_BUTTON_STATUS)
	if(!do_after(cast_on, channel_time, timed_action_flags = channel_flags))
		stop_channel_effect(cast_on)
		return . | SPELL_CANCEL_CAST

/datum/action/cooldown/spell/charged/cast(atom/cast_on)
	. = ..()
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
	build_all_button_icons(UPDATE_BUTTON_STATUS)

/**
 * ### Channelled "Beam" spells
 *
 * Channelled spells that pick a random target from nearby atoms to cast a spell on.
 * Commonly used for beams, hence the name, but nothing's stopping projectiles or whatever from working.
 *
 * If no targets are nearby, cancels the spell and refunds the cooldown.
 */
/datum/action/cooldown/spell/charged/beam
	/// The radius around the caster to find a target.
	var/target_radius = 5
	/// The maximum number of bounces the beam will go before stopping.
	var/max_beam_bounces = 1
	/// Who's our initial beam target? Set in before cast, used in cast.
	var/atom/initial_target

/datum/action/cooldown/spell/charged/beam/Destroy()
	initial_target = null // This like shouuld never hang references but I've seen some cursed things so let's be safe
	return ..()

/datum/action/cooldown/spell/charged/beam/before_cast(atom/cast_on)
	. = ..()
	if(. & SPELL_CANCEL_CAST)
		return

	initial_target = get_target(cast_on)
	if(isnull(initial_target))
		cast_on.balloon_alert(cast_on, "no targets nearby!")
		stop_channel_effect(cast_on)
		return . | SPELL_CANCEL_CAST

/datum/action/cooldown/spell/charged/beam/cast(atom/cast_on)
	. = ..()
	send_beam(cast_on, initial_target, max_beam_bounces)
	initial_target = null

/datum/action/cooldown/spell/charged/beam/proc/send_beam(atom/origin, atom/to_beam, bounces)
	SHOULD_CALL_PARENT(FALSE)
	CRASH("[type] did not implement send_beam and either has no effects or implemented the spell incorrectly.")

/datum/action/cooldown/spell/charged/beam/proc/get_target(atom/center)
	var/list/things = list()
	for(var/atom/nearby_thing in range(target_radius, center))
		if(nearby_thing == owner || nearby_thing == center)
			continue

		things += nearby_thing

	if(!length(things))
		return null

	return pick(things)
