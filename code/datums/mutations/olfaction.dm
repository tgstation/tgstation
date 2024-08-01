/datum/mutation/human/olfaction
	name = "Transcendent Olfaction"
	desc = "Your sense of smell is comparable to that of a canine."
	quality = POSITIVE
	difficulty = 12
	text_gain_indication = span_notice("Smells begin to make more sense...")
	text_lose_indication = span_notice("Your sense of smell goes back to normal.")
	power_path = /datum/action/cooldown/spell/olfaction
	instability = POSITIVE_INSTABILITY_MODERATE
	synchronizer_coeff = 1

/datum/mutation/human/olfaction/modify()
	. = ..()
	var/datum/action/cooldown/spell/olfaction/to_modify = .
	if(!istype(to_modify)) // null or invalid
		return

	to_modify.sensitivity = GET_MUTATION_SYNCHRONIZER(src)

/datum/action/cooldown/spell/olfaction
	name = "Remember the Scent"
	desc = "Get a scent off of the item you're currently holding to track it. \
		With an empty hand, you'll track the scent you've remembered."
	button_icon_state = "nose"

	cooldown_time = 10 SECONDS
	spell_requirements = NONE

	/// Weakref to the mob we're tracking
	var/datum/weakref/tracking_ref
	/// Our nose's sensitivity
	var/sensitivity = 1

/datum/action/cooldown/spell/olfaction/is_valid_target(atom/cast_on)
	if(!isliving(cast_on))
		return FALSE

	var/mob/living/living_cast_on = cast_on
	if(ishuman(living_cast_on) && !living_cast_on.get_bodypart(BODY_ZONE_HEAD))
		to_chat(owner, span_warning("You have no nose!"))
		return FALSE

	if(HAS_TRAIT(living_cast_on, TRAIT_ANOSMIA)) //Anosmia quirk holders can't smell anything
		to_chat(owner, span_warning("You can't smell!"))
		return FALSE

	return TRUE

/datum/action/cooldown/spell/olfaction/cast(mob/living/cast_on)
	. = ..()
	// Can we sniff? is there miasma in the air?
	var/datum/gas_mixture/air = cast_on.loc.return_air()
	var/list/cached_gases = air.gases

	if(cached_gases[/datum/gas/miasma])
		cast_on.adjust_disgust(sensitivity * 45)
		to_chat(cast_on, span_warning("With your overly sensitive nose, \
			you get a whiff of stench and feel sick! Try moving to a cleaner area!"))
		return

	var/atom/sniffed = cast_on.get_active_held_item()
	if(sniffed)
		pick_up_target(cast_on, sniffed)
	else
		follow_target(cast_on)

/// Attempt to pick up a new target based on the fingerprints on [sniffed].
/datum/action/cooldown/spell/olfaction/proc/pick_up_target(mob/living/caster, atom/sniffed)
	var/mob/living/carbon/old_target = tracking_ref?.resolve()
	var/list/possibles = list()
	var/list/prints = GET_ATOM_FINGERPRINTS(sniffed)
	if(prints)
		for(var/mob/living/carbon/to_check as anything in GLOB.carbon_list)
			if(prints[md5(to_check.dna?.unique_identity)])
				possibles |= to_check

	// There are no finger prints on the atom, so nothing to track
	if(!length(possibles))
		to_chat(caster, span_warning("Despite your best efforts, there are no scents to be found on [sniffed]..."))
		return

	var/mob/living/carbon/new_target = tgui_input_list(caster, "Scent to remember", "Scent Tracking", sort_names(possibles))
	if(QDELETED(src) || QDELETED(caster))
		return

	if(QDELETED(new_target))
		// We don't have a new target OR an old target
		if(QDELETED(old_target))
			to_chat(caster, span_warning("You decide against remembering any scents. \
				Instead, you notice your own nose in your peripheral vision. \
				This goes on to remind you of that one time you started breathing manually and couldn't stop. \
				What an awful day that was."))
			tracking_ref = null

		// We don't have a new target, but we have an old target to fall back on
		else
			to_chat(caster, span_notice("You return to tracking [old_target]. The hunt continues."))
			on_the_trail(caster)
		return

	// We have a new target to track
	to_chat(caster, span_notice("You pick up the scent of [new_target]. The hunt begins."))
	tracking_ref = WEAKREF(new_target)
	on_the_trail(caster)

/// Attempt to follow our current tracking target.
/datum/action/cooldown/spell/olfaction/proc/follow_target(mob/living/caster)
	var/mob/living/carbon/current_target = tracking_ref?.resolve()
	// Either our weakref failed to resolve (our target's gone),
	// or we never had a target in the first place
	if(QDELETED(current_target))
		to_chat(caster, span_warning("You're not holding anything to smell, \
			and you haven't smelled anything you can track. You smell your skin instead; it's kinda salty."))
		tracking_ref = null
		return

	on_the_trail(caster)

/// Actually go through and give the user a hint of the direction our target is.
/datum/action/cooldown/spell/olfaction/proc/on_the_trail(mob/living/caster)
	var/mob/living/carbon/current_target = tracking_ref?.resolve()
	//Using get_turf to deal with those pesky closets that put your x y z to 0
	var/turf/current_target_turf = get_turf(current_target)
	var/turf/caster_turf = get_turf(caster)
	if(!current_target)
		to_chat(caster, span_warning("You're not tracking a scent, but the game thought you were. \
			Something's gone wrong! Report this as a bug."))
		stack_trace("[type] - on_the_trail was called when no tracking target was set.")
		tracking_ref = null
		return

	if(current_target == caster)
		to_chat(caster, span_warning("You smell out the trail to yourself. Yep, it's you."))
		return

	if(caster_turf.z < current_target_turf.z)
		to_chat(caster, span_warning("The trail leads... way up above you? Huh. They must be really, really far away."))
		return

	else if(caster_turf.z > current_target_turf.z)
		to_chat(caster, span_warning("The trail leads... way down below you? Huh. They must be really, really far away."))
		return

	var/direction_text = span_bold("[dir2text(get_dir(caster_turf, current_target_turf))]")
	if(direction_text)
		to_chat(caster, span_notice("You consider [current_target]'s scent. The trail leads [direction_text]."))
