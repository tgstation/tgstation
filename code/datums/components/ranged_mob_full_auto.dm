#define AUTOFIRE_MOUSEUP 1
#define AUTOFIRE_MOUSEDOWN 0

/// Allows a mob to autofire by holding down the cursor
/datum/component/ranged_mob_full_auto
	/// Delay before attempting to fire again, note that this is just when we make attempts and is separate from mob's actual firing cooldown
	var/autofire_shot_delay
	/// Our client for click tracking
	var/client/clicker
	/// Are we currently firing?
	var/is_firing = FALSE
	/// This seems hacky but there can be two MouseDown() without a MouseUp() in between if the user holds click and uses alt+tab, printscreen or similar.
	var/awaiting_status = AUTOFIRE_MOUSEDOWN
	/// What are we currently shooting at?
	var/atom/target
	/// Where are we currently shooting at?
	var/turf/target_loc
	/// When will we next try to shoot?
	COOLDOWN_DECLARE(next_shot_cooldown)

/datum/component/ranged_mob_full_auto/Initialize(autofire_shot_delay = 0.5 SECONDS)
	. = ..()
	if (!isliving(parent))
		return COMPONENT_INCOMPATIBLE

	src.autofire_shot_delay = autofire_shot_delay

	var/mob/living/living_parent = parent
	if (isnull(living_parent.client))
		return
	on_gained_client(parent)

/datum/component/ranged_mob_full_auto/RegisterWithParent()
	RegisterSignal(parent, COMSIG_MOB_LOGIN, PROC_REF(on_gained_client))
	RegisterSignal(parent, COMSIG_MOB_LOGOUT, PROC_REF(on_lost_client))

/datum/component/ranged_mob_full_auto/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_MOB_LOGIN, COMSIG_MOB_LOGOUT))

/datum/component/ranged_mob_full_auto/process(seconds_per_tick)
	if (!try_shooting())
		return PROCESS_KILL

/// Try and take a shot, returns false if we are unable to do so and should stop trying
/datum/component/ranged_mob_full_auto/proc/try_shooting()
	if (!is_firing)
		return FALSE
	if (!COOLDOWN_FINISHED(src, next_shot_cooldown))
		return TRUE // Don't fire but also keep processing

	var/mob/living/living_parent = parent

	if (isnull(target) || get_turf(target) != target_loc) // Target moved or got destroyed since we last aimed.
		set_target(target_loc)
		target = target_loc // So we keep firing on the emptied tile until we move our mouse and find a new target.
	if (get_dist(living_parent, target) <= 0)
		set_target(get_step(living_parent, living_parent.dir)) // Shoot in the direction faced if the mouse is on the same tile as we are.
		target_loc = target
	else if (!CAN_THEY_SEE(target, living_parent))
		stop_firing()
		return FALSE // Can't see shit

	living_parent.face_atom(target)
	COOLDOWN_START(src, next_shot_cooldown, autofire_shot_delay)
	living_parent.RangedAttack(target)
	return TRUE

/// Setter for reference handling
/datum/component/ranged_mob_full_auto/proc/set_target(atom/new_target)
	if (!isnull(target))
		UnregisterSignal(target, COMSIG_QDELETING)
	target = new_target
	if (!isnull(target))
		RegisterSignal(target, COMSIG_QDELETING, PROC_REF(on_target_deleted))

/// Don't hang references
/datum/component/ranged_mob_full_auto/proc/on_target_deleted()
	SIGNAL_HANDLER
	set_target(null)

/// When we gain a client, start tracking clicks
/datum/component/ranged_mob_full_auto/proc/on_gained_client(mob/living/source)
	SIGNAL_HANDLER
	clicker = source.client
	RegisterSignal(clicker, COMSIG_CLIENT_MOUSEDOWN, PROC_REF(on_mouse_down))

/// When we lose our client, stop functioning
/datum/component/ranged_mob_full_auto/proc/on_lost_client(mob/living/source)
	SIGNAL_HANDLER
	if (!isnull(clicker))
		UnregisterSignal(clicker, list(COMSIG_CLIENT_MOUSEDOWN, COMSIG_CLIENT_MOUSEDRAG, COMSIG_CLIENT_MOUSEUP))
	stop_firing()
	clicker = null

/// On mouse down start shooting!
/datum/component/ranged_mob_full_auto/proc/on_mouse_down(client/source, atom/target, turf/location, control, params)
	SIGNAL_HANDLER
	if (awaiting_status != AUTOFIRE_MOUSEDOWN)
		return // Avoid a double mousedown with no mouseup
	var/list/modifiers = params2list(params)

	if (LAZYACCESS(modifiers, SHIFT_CLICK))
		return
	if (LAZYACCESS(modifiers, CTRL_CLICK))
		return
	if (LAZYACCESS(modifiers, MIDDLE_CLICK))
		return
	if (LAZYACCESS(modifiers, RIGHT_CLICK))
		return
	if (LAZYACCESS(modifiers, ALT_CLICK))
		return
	var/mob/living/living_parent = parent
	if (!isturf(living_parent.loc) || living_parent.Adjacent(target))
		return

	if (isnull(location) || istype(target, /atom/movable/screen)) // Clicking on a screen object.
		if (target.plane != CLICKCATCHER_PLANE) // The clickcatcher is a special case. We want the click to trigger then, under it.
			return // If we click and drag on our worn backpack, for example, we want it to open instead.
		set_target(parse_caught_click_modifiers(modifiers, get_turf(source.eye), source))
		params = list2params(modifiers)
		if (isnull(target))
			CRASH("Failed to get the turf under clickcatcher")

	awaiting_status = AUTOFIRE_MOUSEUP
	source.click_intercept_time = world.time // From this point onwards Click() will no longer be triggered.
	if (is_firing)
		stop_firing()

	set_target(target)
	target_loc = get_turf(target)
	INVOKE_ASYNC(src, PROC_REF(start_firing))

/// Start tracking mouse movement and processing our shots
/datum/component/ranged_mob_full_auto/proc/start_firing()
	if (is_firing)
		return

	is_firing = TRUE
	if (!try_shooting()) // First one is immediate
		stop_firing()
		return

	clicker.mouse_override_icon = 'icons/effects/mouse_pointers/weapon_pointer.dmi'
	clicker.mouse_pointer_icon = clicker.mouse_override_icon

	START_PROCESSING(SSprojectiles, src)
	RegisterSignal(clicker, COMSIG_CLIENT_MOUSEUP, PROC_REF(on_mouse_up))
	RegisterSignal(clicker, COMSIG_CLIENT_MOUSEDRAG, PROC_REF(on_mouse_drag))

/// When the mouse moved let's try and shift our aim
/datum/component/ranged_mob_full_auto/proc/on_mouse_drag(client/source, atom/src_object, atom/over_object, turf/src_location, turf/over_location, src_control, over_control, params)
	SIGNAL_HANDLER
	if (!isnull(over_location))
		set_target(over_object)
		target_loc = get_turf(over_object)
		return

	//This happens when the mouse is over an inventory or screen object, or on entering deep darkness, for example.
	var/list/modifiers = params2list(params)
	var/new_target = parse_caught_click_modifiers(modifiers, get_turf(source.eye), source)
	params = list2params(modifiers)

	if (!isnull(new_target))
		set_target(new_target)
		target_loc = new_target
		return

	if (QDELETED(target)) //No new target acquired, and old one was deleted, get us out of here.
		stop_firing()
		CRASH("on_mouse_drag failed to get the turf under screen object [over_object.type]. Old target was incidentally QDELETED.")


	set_target(get_turf(target)) //If previous target wasn't a turf, let's turn it into one to avoid locking onto a potentially moving target.
	target_loc = target
	CRASH("on_mouse_drag failed to get the turf under screen object [over_object.type]")

/// When the mouse is released we should stop
/datum/component/ranged_mob_full_auto/proc/on_mouse_up()
	SIGNAL_HANDLER
	if (awaiting_status != AUTOFIRE_MOUSEUP)
		return
	stop_firing()
	return COMPONENT_CLIENT_MOUSEUP_INTERCEPT

/// Stop watching our mouse and processing shots
/datum/component/ranged_mob_full_auto/proc/stop_firing()
	if (!is_firing)
		return

	is_firing = FALSE
	set_target(null)
	target_loc = null
	STOP_PROCESSING(SSprojectiles, src)
	awaiting_status = AUTOFIRE_MOUSEDOWN

	if (isnull(clicker))
		return
	UnregisterSignal(clicker, list(COMSIG_CLIENT_MOUSEDRAG, COMSIG_CLIENT_MOUSEUP))
	clicker.mouse_override_icon = null
	clicker.mouse_pointer_icon = null

#undef AUTOFIRE_MOUSEUP
#undef AUTOFIRE_MOUSEDOWN
