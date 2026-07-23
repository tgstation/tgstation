#define ACTION_WORKING 0
#define ACTION_FAILED 1
#define ACTION_SUCCEEDED 2

/datum/timed_action
	/// Atom performing the action
	var/atom/movable/user
	/// Atoms on which the action is performed
	var/list/targets
	/// Progress bar displayed to the user/override
	var/datum/progressbar/progressbar
	/// Cog visual displayed to everyone else
	var/datum/cogbar/cogbar
	/// Callback to invoke each tick to check for condition validity
	var/datum/callback/extra_checks
	// Start and end world.tick for the action
	var/start_time
	var/end_time
	/// Flags of our action
	var/timed_action_flags = NONE
	/// Status of the action to pass into the main wait loop
	var/status = ACTION_WORKING

/datum/timed_action/New(atom/movable/user, list/targets, delay, show_progress = TRUE, timed_action_flags = NONE, datum/callback/extra_checks = null, cog_icon = null, cog_iconstate = null, mob/bar_override = null)
	. = ..()
	src.user = user
	src.timed_action_flags = timed_action_flags
	src.extra_checks = extra_checks
	if (isnull(targets))
		targets = list(user)
	else if (!islist(targets))
		targets = list(targets)

	src.targets = targets

	if (show_progress)
		if(astype(user, /mob)?.client || bar_override?.client)
			progressbar = new(bar_override || user, delay, targets[1] || user)

		if(!isnull(cog_icon) && delay >= 1 SECONDS)
			cogbar = new(user, cog_icon, cog_iconstate)

#ifdef UNIT_TESTS
	timed_action_flags &= ~IGNORE_SLOWDOWNS // Test dummies are a special case
#endif

	if (!ismob(user))
		timed_action_flags |= IGNORE_HELD_ITEM | IGNORE_INCAPACITATED | IGNORE_SLOWDOWNS
	else if(!(timed_action_flags & IGNORE_SLOWDOWNS))
		delay *= astype(user, /mob).cached_multiplicative_actions_slowdown

	start_time = world.time
	end_time = world.time + delay

	register_signals()

/datum/timed_action/Destroy(force)
	user = null
	targets = null
	// Only qdel these two in case of an await() runtime/early deletion/whatever, otherwise let them play out their animation and self-delete
	if (status == ACTION_WORKING)
		qdel(progressbar)
		qdel(cogbar)
	progressbar = null
	cogbar = null
	extra_checks = null
	STOP_PROCESSING(SStimed_actions, src)
	status = ACTION_FAILED
	return ..()

/datum/timed_action/proc/register_signals()
	RegisterSignal(user, COMSIG_QDELETING, PROC_REF(on_user_deleted))

	if (!(timed_action_flags & IGNORE_USER_LOC_CHANGE))
		RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(on_user_moved))

	if (!(timed_action_flags & IGNORE_INCAPACITATED))
		RegisterSignal(user, SIGNAL_ADDTRAIT(TRAIT_INCAPACITATED), PROC_REF(on_user_incapacitated))

	if (!(timed_action_flags & DO_AFTER_CHECK_NEXT_MOVE))
		RegisterSignal(user, COMSIG_LIVING_CHANGENEXT_MOVE, PROC_REF(on_changenext_move))

	if (!(timed_action_flags & IGNORE_HELD_ITEM))
		RegisterSignal(user, COMSIG_MOB_EQUIPPED_ITEM, PROC_REF(on_item_equipped))
		RegisterSignal(user, COMSIG_MOB_SWAP_HANDS, PROC_REF(on_hands_swapped))
		RegisterSignal(user, COMSIG_MOB_UNEQUIPPED_ITEM, PROC_REF(on_item_dropped))

	for (var/atom/target as anything in targets)
		if (target == user)
			continue
		RegisterSignal(target, COMSIG_QDELETING, PROC_REF(on_target_deleted))
		if (!(timed_action_flags & IGNORE_TARGET_LOC_CHANGE))
			RegisterSignal(target, COMSIG_MOVABLE_MOVED, PROC_REF(on_target_moved))

/datum/timed_action/proc/cancel()
	if (status != ACTION_WORKING)
		return FALSE

	status = ACTION_FAILED
	STOP_PROCESSING(SStimed_actions, src)
	return TRUE

/datum/timed_action/proc/await(delay = world.tick_lag)
	START_PROCESSING(SStimed_actions, src)
	status = ACTION_WORKING

	while (status == ACTION_WORKING && world.time < end_time)
		sleep(world.tick_lag)

	if (status == ACTION_WORKING) // Due to how MC handles sleeping, await will tick first before the subsystem itself, so we need to tick ourselves one last time if we haven't been aborted
		process()

	. = (status == ACTION_SUCCEEDED)

	if (!QDELETED(progressbar))
		progressbar.end_progress()
	if (!QDELETED(cogbar))
		cogbar.remove()

	qdel(src)

/datum/timed_action/process(seconds_per_tick)
	if (extra_checks && !extra_checks.InvokeAsync())
		cancel()
		return

	if (world.time >= end_time)
		status = ACTION_SUCCEEDED
		return PROCESS_KILL

	if(!QDELETED(progressbar))
		progressbar.update(world.time - start_time)

/datum/timed_action/proc/on_user_deleted(datum/source)
	SIGNAL_HANDLER
	user = null
	cancel()

/datum/timed_action/proc/on_target_deleted(datum/source)
	SIGNAL_HANDLER
	targets -= source
	cancel()

/datum/timed_action/proc/on_user_incapacitated(datum/source)
	SIGNAL_HANDLER
	cancel()

/datum/timed_action/proc/on_changenext_move(datum/source, next_move, delay)
	SIGNAL_HANDLER
	if (next_move > world.time)
		cancel()

/datum/timed_action/proc/on_item_equipped(mob/source, obj/item/item, slot)
	SIGNAL_HANDLER
	// We picked up an item
	if (item == source.get_active_held_item())
		cancel()

/datum/timed_action/proc/on_hands_swapped(datum/source)
	SIGNAL_HANDLER
	cancel()

/datum/timed_action/proc/on_item_dropped(mob/source, obj/item/item_dropping, force, atom/newloc, no_move, invdrop, silent, hand_index)
	SIGNAL_HANDLER
	// Dropped held item
	if (source.active_hand_index == hand_index)
		cancel()

/datum/timed_action/proc/on_user_moved(datum/source, atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER

	if (user.loc == old_loc)
		return

	if (isnull(user.drift_handler))
		cancel()
		return

	for (var/atom/target as anything in targets)
		if (!target.Adjacent(user))
			cancel()
			return

/datum/timed_action/proc/on_target_moved(atom/movable/source, atom/old_loc, dir, forced, list/old_locs)
	SIGNAL_HANDLER

	if (source.loc == old_loc)
		return

	if (isnull(source.drift_handler) || !source.Adjacent(user))
		cancel()

/**
 * Timed action involving one mob user. Target is optional.
 *
 * Checks that `user` does not move, change hands, get stunned, etc. for the
 * given `delay`. Returns `TRUE` on success or `FALSE` on failure.
 *
 * - user - The mob performing the action.
 * - delay - The time in deciseconds. Use the SECONDS define for readability. `1 SECONDS` is 10 deciseconds.
 * - target - The target of the action. This is where the progressbar will display.
 * - timed_action_flags - Flags to control the behavior of the timed action.
 * - show_progress - Whether to display a progress bar / cogbar.
 * - extra_checks - Additional checks to perform before the action is executed.
 * - interaction_key - The assoc key under which the do_after is capped, with max_interact_count being the cap. Interaction key will default to target if not set.
 * - max_interact_count - The maximum amount of interactions allowed.
 * - cog_icon - The icon file of the cog. Default: 'icons/effects/progressbar.dmi'
 * - cog_iconstate - The icon state of the cog. Default: "Cog"
 * - bar_override - Mob which should see the bar instead of the user
 */
/proc/do_after(atom/movable/user, delay, atom/target, timed_action_flags = NONE, show_progress = TRUE, datum/callback/extra_checks, interaction_key, max_interact_count = 1, cog_icon = 'icons/effects/progressbar.dmi', cog_iconstate = "cog", mob/bar_override = null)
	if (!user)
		return FALSE

	ASSERT(isnum(delay), "do_after was passed a non-number delay: [delay || "null"].")
	ASSERT(!isnum(target), "a do_after created by [user] had a target set as [target] - probably intended to be the time instead.")
	ASSERT(!isatom(delay), "a do_after created by [user] had a timer of [delay] - probably intended to be the target instead.")

	if (delay <= 0)
		return TRUE

	if(!interaction_key && ismob(user))
		if(!islist(target))
			interaction_key = target
		else
			var/list/temp = list()
			for(var/atom/atom as anything in target)
				temp += ref(atom)

			sortTim(temp, GLOBAL_PROC_REF(cmp_text_asc))
			interaction_key = jointext(temp, "-")

	if(interaction_key && ismob(user)) // Do we have a interaction_key now?
		var/mob/as_mob = user
		var/current_interaction_count = LAZYACCESS(as_mob.do_afters, interaction_key)
		if(current_interaction_count >= max_interact_count) // We are at our peak
			return
		LAZYSET(as_mob.do_afters, interaction_key, current_interaction_count + 1)

	SEND_SIGNAL(user, COMSIG_DO_AFTER_BEGAN)

	var/datum/timed_action/action = new(user, target, delay, show_progress, timed_action_flags, extra_checks, cog_icon, cog_iconstate, bar_override)
	. = action.await()

	if(interaction_key && ismob(user))
		var/mob/as_mob = user
		var/reduced_interaction_count = LAZYACCESS(as_mob.do_afters, interaction_key)
		if(reduced_interaction_count > 1) // Not done yet!
			LAZYSET(as_mob.do_afters, interaction_key, reduced_interaction_count - 1)
		else
			LAZYREMOVE(as_mob.do_afters, interaction_key)
	SEND_SIGNAL(user, COMSIG_DO_AFTER_ENDED)

#undef ACTION_WORKING
#undef ACTION_FAILED
#undef ACTION_SUCCEEDED
