
/// Status effects that can stack.
/datum/status_effect/stacking
	id = STATUS_EFFECT_ID_ABSTRACT
	duration = STATUS_EFFECT_PERMANENT // Only removed under specific conditions.
	tick_interval = 1 SECONDS // Deciseconds between decays, once decay starts
	alert_type = null
	/// How many stacks are currently accumulated.
	/// Also, the default stacks number given on application.
	var/stacks = 0
	// Deciseconds until ticks start occurring, which removes stacks
	/// (first stack will be removed at this time plus tick_interval)
	var/delay_before_decay
	/// How many stacks are lost per tick (decay trigger)
	var/stack_decay = 1
	/// The threshold for having special effects occur when a certain stack number is reached
	var/stack_threshold
	/// The maximum number of stacks that can be applied
	var/max_stacks
	/// If TRUE, the status effect is consumed / removed when stack_threshold is met
	var/consumed_on_threshold = TRUE
	/// Set to true once the stack_threshold is crossed, and false once it falls back below
	var/threshold_crossed = FALSE

	/// Icon file for overlays applied when the status effect is applied
	var/overlay_file
	/// Icon state for overlays applied when the status effect is applied
	/// States in the file must be given a name, followed by a number which corresponds to a number of stacks.
	/// Put the state name without the number in these state vars
	var/overlay_state
	/// A reference to our overlay appearance
	var/mutable_appearance/status_overlay

/datum/status_effect/stacking/Destroy()
	if(!owner || !status_overlay)
		return ..()

	owner.cut_overlay(status_overlay)
	QDEL_NULL(status_overlay)
	return ..()

/// Effects that occur when the stack count crosses stack_threshold
/datum/status_effect/stacking/proc/threshold_cross_effect()
	return

/// Effects that occur if the status effect is removed due to the stack_threshold being crossed
/datum/status_effect/stacking/proc/stacks_consumed_effect()
	return

/// Effects that occur if the status is removed due to being under 1 remaining stack
/datum/status_effect/stacking/proc/fadeout_effect()
	return

/// Runs every time tick(), causes stacks to decay over time
/datum/status_effect/stacking/proc/stack_decay_effect()
	return

/// Called when the stack_threshold is crossed (stacks go over the threshold)
/datum/status_effect/stacking/proc/on_threshold_cross()
	threshold_cross_effect()
	if(consumed_on_threshold)
		stacks_consumed_effect()
		qdel(src)

/// Called when the stack_threshold is uncrossed / dropped (stacks go under the threshold after being over it)
/datum/status_effect/stacking/proc/on_threshold_drop()
	return

/// Whether the owner can have the status effect.
/// Return FALSE if the owner is not in a valid state (self-deletes the effect), or TRUE otherwise
/datum/status_effect/stacking/proc/can_have_status()
	return owner.stat != DEAD

/// Whether the owner can currently gain stacks or not
/// Return FALSE if the owner is not in a valid state, or TRUE otherwise
/datum/status_effect/stacking/proc/can_gain_stacks()
	return owner.stat != DEAD

/datum/status_effect/stacking/on_creation(mob/living/new_owner, stacks_to_apply)
	. = ..()
	if(.)
		add_stacks(stacks_to_apply)

/datum/status_effect/stacking/on_apply()
	if(!can_have_status())
		return FALSE
	if(!overlay_file || !overlay_state)
		return ..()
	status_overlay = mutable_appearance(overlay_file, "[overlay_state][stacks]")
	var/icon_height = owner.get_cached_height()
	status_overlay.pixel_w = -owner.pixel_x
	status_overlay.pixel_z = FLOOR(icon_height * 0.25, 1)
	status_overlay.transform = matrix() * (icon_height / ICON_SIZE_Y) //scale the status's overlay size based on the target's icon size
	owner.add_overlay(status_overlay)
	return ..()

/datum/status_effect/stacking/tick(seconds_between_ticks)
	if(!can_have_status())
		qdel(src)
	else
		add_stacks(-stack_decay)
		stack_decay_effect()

/// Add (or remove) [stacks_added] stacks to our current stack count.
/datum/status_effect/stacking/proc/add_stacks(stacks_added)
	if(stacks_added > 0 && !can_gain_stacks())
		return FALSE
	if(status_overlay)
		owner.cut_overlay(status_overlay)
	stacks = min(stacks + stacks_added, max_stacks)
	if(stacks <= 0)
		fadeout_effect()
		qdel(src) // deletes status if stacks fall under one
		return

	if(stacks >= stack_threshold && !threshold_crossed) // threshold_crossed check prevents threshold effect from occurring if changing from above threshold to still above threshold
		threshold_crossed = TRUE
		on_threshold_cross()
		if(consumed_on_threshold)
			return
	else if(stacks < stack_threshold && threshold_crossed)
		threshold_crossed = FALSE // resets threshold effect if we fall below threshold so threshold effect can trigger again
		on_threshold_drop()

	if(stacks_added > 0)
		tick_interval += delay_before_decay // refreshes time until decay

	if (status_overlay)
		status_overlay.icon_state = "[overlay_state][stacks]"
		owner.add_overlay(status_overlay)
