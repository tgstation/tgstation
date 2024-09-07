#define AUTOFIRE_MOUSEUP 0
#define AUTOFIRE_MOUSEDOWN 1

/datum/component/automatic_fire
	var/client/clicker
	var/mob/living/shooter
	var/atom/target
	var/turf/target_loc //For dealing with locking on targets due to BYOND engine limitations (the mouse input only happening when mouse moves).
	var/autofire_stat = AUTOFIRE_STAT_IDLE
	var/mouse_parameters
	/// Time between individual shots.
	var/autofire_shot_delay = 0.3 SECONDS
	/// This seems hacky but there can be two MouseDown() without a MouseUp() in between if the user holds click and uses alt+tab, printscreen or similar.
	var/mouse_status = AUTOFIRE_MOUSEUP
	/// Should dual wielding be allowed?
	var/allow_akimbo

	///windup autofire vars
	///Whether the delay between shots increases over time, simulating a spooling weapon
	var/windup_autofire = FALSE
	///the reduction to shot delay for windup
	var/current_windup_reduction = 0
	///the percentage of autfire_shot_delay that is added to current_windup_reduction
	var/windup_autofire_reduction_multiplier = 0.3
	///How high of a reduction that current_windup_reduction can reach
	var/windup_autofire_cap = 0.3
	///How long it takes for weapons that have spooled-up to reset back to the original firing speed
	var/windup_spindown = 3 SECONDS
	///Timer for tracking the spindown reset timings
	var/timerid
	COOLDOWN_DECLARE(next_shot_cd)

/datum/component/automatic_fire/Initialize(autofire_shot_delay, windup_autofire, windup_autofire_reduction_multiplier, windup_autofire_cap, windup_spindown, allow_akimbo = TRUE)
	. = ..()
	if(!isgun(parent))
		return COMPONENT_INCOMPATIBLE
	var/obj/item/gun = parent
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(wake_up))
	if(autofire_shot_delay)
		src.autofire_shot_delay = autofire_shot_delay
	src.allow_akimbo = allow_akimbo
	if(windup_autofire)
		src.windup_autofire = windup_autofire
		src.windup_autofire_reduction_multiplier = windup_autofire_reduction_multiplier
		src.windup_autofire_cap = windup_autofire_cap
		src.windup_spindown = windup_spindown
	if(autofire_stat == AUTOFIRE_STAT_IDLE && ismob(gun.loc))
		var/mob/user = gun.loc
		wake_up(src, user)


/datum/component/automatic_fire/Destroy()
	autofire_off()
	return ..()

/datum/component/automatic_fire/process(seconds_per_tick)
	if(autofire_stat != AUTOFIRE_STAT_FIRING)
		STOP_PROCESSING(SSprojectiles, src)
		return
	process_shot()

/datum/component/automatic_fire/proc/wake_up(datum/source, mob/user, slot)
	SIGNAL_HANDLER

	if(autofire_stat == AUTOFIRE_STAT_ALERT)
		return //We've updated the firemode. No need for more.
	if(autofire_stat == AUTOFIRE_STAT_FIRING)
		stop_autofiring() //Let's stop shooting to avoid issues.
		return
	if(user.is_holding(parent))
		autofire_on(user.client)

// There is a gun and there is a user wielding it. The component now waits for the mouse click.
/datum/component/automatic_fire/proc/autofire_on(client/usercli)
	SIGNAL_HANDLER

	if(autofire_stat != AUTOFIRE_STAT_IDLE)
		return
	autofire_stat = AUTOFIRE_STAT_ALERT
	if(!QDELETED(usercli))
		clicker = usercli
		shooter = clicker.mob
		RegisterSignal(clicker, COMSIG_CLIENT_MOUSEDOWN, PROC_REF(on_mouse_down))
	if(!QDELETED(shooter))
		RegisterSignal(shooter, COMSIG_MOB_LOGOUT, PROC_REF(autofire_off))
		UnregisterSignal(shooter, COMSIG_MOB_LOGIN)
	RegisterSignals(parent, list(COMSIG_QDELETING, COMSIG_ITEM_DROPPED), PROC_REF(autofire_off))
	parent.RegisterSignal(src, COMSIG_AUTOFIRE_ONMOUSEDOWN, TYPE_PROC_REF(/obj/item/gun/, autofire_bypass_check))
	parent.RegisterSignal(parent, COMSIG_AUTOFIRE_SHOT, TYPE_PROC_REF(/obj/item/gun/, do_autofire))


/datum/component/automatic_fire/proc/autofire_off(datum/source)
	SIGNAL_HANDLER
	if(autofire_stat == AUTOFIRE_STAT_IDLE)
		return
	if(autofire_stat == AUTOFIRE_STAT_FIRING)
		stop_autofiring()

	autofire_stat = AUTOFIRE_STAT_IDLE

	if(!QDELETED(clicker))
		UnregisterSignal(clicker, list(COMSIG_CLIENT_MOUSEDOWN, COMSIG_CLIENT_MOUSEUP, COMSIG_CLIENT_MOUSEDRAG))
	mouse_status = AUTOFIRE_MOUSEUP //In regards to the component there's no click anymore to care about.
	clicker = null
	if(!QDELETED(shooter))
		RegisterSignal(shooter, COMSIG_MOB_LOGIN, PROC_REF(on_client_login))
		UnregisterSignal(shooter, COMSIG_MOB_LOGOUT)
	UnregisterSignal(parent, list(COMSIG_QDELETING, COMSIG_ITEM_DROPPED))
	shooter = null
	parent.UnregisterSignal(parent, COMSIG_AUTOFIRE_SHOT)
	parent.UnregisterSignal(src, COMSIG_AUTOFIRE_ONMOUSEDOWN)

/datum/component/automatic_fire/proc/on_client_login(mob/source)
	SIGNAL_HANDLER
	if(!source.client)
		return
	if(source.is_holding(parent))
		autofire_on(source.client)

/datum/component/automatic_fire/proc/on_mouse_down(client/source, atom/_target, turf/location, control, params)
	SIGNAL_HANDLER
	var/list/modifiers = params2list(params) //If they're shift+clicking, for example, let's not have them accidentally shoot.

	if(LAZYACCESS(modifiers, SHIFT_CLICK))
		return
	if(LAZYACCESS(modifiers, CTRL_CLICK))
		return
	if(LAZYACCESS(modifiers, MIDDLE_CLICK))
		return
	if(LAZYACCESS(modifiers, RIGHT_CLICK))
		return
	if(LAZYACCESS(modifiers, ALT_CLICK))
		return
	if(source.mob.throw_mode)
		return
	if(!isturf(source.mob.loc)) //No firing inside lockers and stuff.
		return
	if(get_dist(source.mob, _target) < 2) //Adjacent clicking.
		return

	if(isnull(location) || istype(_target, /atom/movable/screen)) //Clicking on a screen object.
		if(_target.plane != CLICKCATCHER_PLANE) //The clickcatcher is a special case. We want the click to trigger then, under it.
			return //If we click and drag on our worn backpack, for example, we want it to open instead.
		_target = parse_caught_click_modifiers(modifiers, get_turf(source.eye), source)
		params = list2params(modifiers)
		if(!_target)
			CRASH("Failed to get the turf under clickcatcher")

	if(SEND_SIGNAL(src, COMSIG_AUTOFIRE_ONMOUSEDOWN, source, _target, location, control, params) & COMPONENT_AUTOFIRE_ONMOUSEDOWN_BYPASS)
		return

	source.click_intercept_time = world.time //From this point onwards Click() will no longer be triggered.

	if(autofire_stat == (AUTOFIRE_STAT_IDLE))
		CRASH("on_mouse_down() called with [autofire_stat] autofire_stat")
	if(autofire_stat == AUTOFIRE_STAT_FIRING)
		stop_autofiring() //This can happen if we click and hold and then alt+tab, printscreen or other such action. MouseUp won't be called then and it will keep autofiring.

	target = _target
	target_loc = get_turf(target)
	mouse_parameters = params
	INVOKE_ASYNC(src, PROC_REF(start_autofiring))


//Dakka-dakka
/datum/component/automatic_fire/proc/start_autofiring()
	if(autofire_stat == AUTOFIRE_STAT_FIRING)
		return
	autofire_stat = AUTOFIRE_STAT_FIRING

	clicker.mouse_override_icon = 'icons/effects/mouse_pointers/weapon_pointer.dmi'
	clicker.mouse_pointer_icon = clicker.mouse_override_icon

	if(mouse_status == AUTOFIRE_MOUSEUP) //See mouse_status definition for the reason for this.
		RegisterSignal(clicker, COMSIG_CLIENT_MOUSEUP, PROC_REF(on_mouse_up))
		mouse_status = AUTOFIRE_MOUSEDOWN

	RegisterSignal(shooter, COMSIG_MOB_SWAP_HANDS, PROC_REF(stop_autofiring))

	if(isgun(parent))
		var/obj/item/gun/shoota = parent
		if(!shoota.on_autofire_start(shooter)) //This is needed because the minigun has a do_after before firing and signals are async.
			stop_autofiring()
			return
	if(autofire_stat != AUTOFIRE_STAT_FIRING)
		return //Things may have changed while on_autofire_start() was being processed, due to do_after's sleep.

	if(!process_shot()) //First shot is processed instantly.
		return //If it fails, such as when the gun is empty, then there's no need to schedule a second shot.

	START_PROCESSING(SSprojectiles, src)
	RegisterSignal(clicker, COMSIG_CLIENT_MOUSEDRAG, PROC_REF(on_mouse_drag))


/datum/component/automatic_fire/proc/on_mouse_up(datum/source, atom/object, turf/location, control, params)
	SIGNAL_HANDLER
	UnregisterSignal(clicker, COMSIG_CLIENT_MOUSEUP)
	mouse_status = AUTOFIRE_MOUSEUP
	if(autofire_stat == AUTOFIRE_STAT_FIRING)
		stop_autofiring()
	return COMPONENT_CLIENT_MOUSEUP_INTERCEPT


/datum/component/automatic_fire/proc/stop_autofiring(datum/source, atom/object, turf/location, control, params)
	SIGNAL_HANDLER
	if(autofire_stat != AUTOFIRE_STAT_FIRING)
		return
	STOP_PROCESSING(SSprojectiles, src)
	autofire_stat = AUTOFIRE_STAT_ALERT
	if(clicker)
		clicker.mouse_override_icon = null
		clicker.mouse_pointer_icon = clicker.mouse_override_icon
		UnregisterSignal(clicker, COMSIG_CLIENT_MOUSEDRAG)
	if(!QDELETED(shooter))
		UnregisterSignal(shooter, COMSIG_MOB_SWAP_HANDS)
	target = null
	target_loc = null
	mouse_parameters = null

/datum/component/automatic_fire/proc/on_mouse_drag(client/source, atom/src_object, atom/over_object, turf/src_location, turf/over_location, src_control, over_control, params)
	SIGNAL_HANDLER
	if(isnull(over_location)) //This happens when the mouse is over an inventory or screen object, or on entering deep darkness, for example.
		var/list/modifiers = params2list(params)
		var/new_target = parse_caught_click_modifiers(modifiers, get_turf(source.eye), source)
		params = list2params(modifiers)
		mouse_parameters = params
		if(!new_target)
			if(QDELETED(target)) //No new target acquired, and old one was deleted, get us out of here.
				stop_autofiring()
				CRASH("on_mouse_drag failed to get the turf under screen object [over_object.type]. Old target was incidentally QDELETED.")
			target = get_turf(target) //If previous target wasn't a turf, let's turn it into one to avoid locking onto a potentially moving target.
			target_loc = target
			CRASH("on_mouse_drag failed to get the turf under screen object [over_object.type]")
		target = new_target
		target_loc = new_target
		return
	target = over_object
	target_loc = get_turf(over_object)
	mouse_parameters = params


/datum/component/automatic_fire/proc/process_shot()
	if(autofire_stat != AUTOFIRE_STAT_FIRING)
		return FALSE
	if(!COOLDOWN_FINISHED(src, next_shot_cd))
		return TRUE
	if(QDELETED(target) || get_turf(target) != target_loc) //Target moved or got destroyed since we last aimed.
		target = target_loc //So we keep firing on the emptied tile until we move our mouse and find a new target.
	if(get_dist(shooter, target) <= 0)
		target = get_step(shooter, shooter.dir) //Shoot in the direction faced if the mouse is on the same tile as we are.
		target_loc = target
	else if(!CAN_THEY_SEE(target, shooter))
		stop_autofiring() //Elvis has left the building.
		return FALSE
	shooter.face_atom(target)
	var/next_delay = autofire_shot_delay
	if(windup_autofire)
		next_delay = clamp(next_delay - current_windup_reduction, round(autofire_shot_delay * windup_autofire_cap), autofire_shot_delay)
		current_windup_reduction = (current_windup_reduction + round(autofire_shot_delay * windup_autofire_reduction_multiplier))
		timerid = addtimer(CALLBACK(src, PROC_REF(windup_reset), FALSE), windup_spindown, TIMER_UNIQUE|TIMER_OVERRIDE|TIMER_STOPPABLE)
	if(HAS_TRAIT(shooter, TRAIT_DOUBLE_TAP))
		next_delay = round(next_delay * 0.5, SSprojectiles.wait)
	COOLDOWN_START(src, next_shot_cd, next_delay)
	if(SEND_SIGNAL(parent, COMSIG_AUTOFIRE_SHOT, target, shooter, allow_akimbo, mouse_parameters) & COMPONENT_AUTOFIRE_SHOT_SUCCESS)
		return TRUE
	stop_autofiring()
	return FALSE

/// Reset for our windup, resetting everything back to initial values after a variable set amount of time (determined by var/windup_spindown).
/datum/component/automatic_fire/proc/windup_reset(deltimer)
	current_windup_reduction = initial(current_windup_reduction)
	if(deltimer && timerid)
		deltimer(timerid)

// Gun procs.

/obj/item/gun/proc/on_autofire_start(mob/living/shooter)
	if(semicd || shooter.incapacitated || !can_trigger_gun(shooter))
		return FALSE
	if(!can_shoot())
		shoot_with_empty_chamber(shooter)
		return FALSE
	var/obj/item/bodypart/other_hand = shooter.has_hand_for_held_index(shooter.get_inactive_hand_index())
	if(weapon_weight == WEAPON_HEAVY && (shooter.get_inactive_held_item() || !other_hand))
		balloon_alert(shooter, "use both hands!")
		return FALSE
	return TRUE


/obj/item/gun/proc/autofire_bypass_check(datum/source, client/clicker, atom/target, turf/location, control, params)
	SIGNAL_HANDLER
	if(clicker.mob.get_active_held_item() != src)
		return COMPONENT_AUTOFIRE_ONMOUSEDOWN_BYPASS


/obj/item/gun/proc/do_autofire(datum/source, atom/target, mob/living/shooter, allow_akimbo, params)
	SIGNAL_HANDLER
	if(semicd || shooter.incapacitated)
		return NONE
	if(!can_shoot())
		shoot_with_empty_chamber(shooter)
		return NONE
	INVOKE_ASYNC(src, PROC_REF(do_autofire_shot), source, target, shooter, allow_akimbo, params)
	return COMPONENT_AUTOFIRE_SHOT_SUCCESS //All is well, we can continue shooting.


/obj/item/gun/proc/do_autofire_shot(datum/source, atom/target, mob/living/shooter, allow_akimbo, params)
	var/obj/item/gun/akimbo_gun = shooter.get_inactive_held_item()
	var/bonus_spread = 0
	if(istype(akimbo_gun) && weapon_weight < WEAPON_MEDIUM && allow_akimbo)
		if(akimbo_gun.weapon_weight < WEAPON_MEDIUM && akimbo_gun.can_trigger_gun(shooter))
			bonus_spread = dual_wield_spread
			addtimer(CALLBACK(akimbo_gun, TYPE_PROC_REF(/obj/item/gun, process_fire), target, shooter, TRUE, params, null, bonus_spread), 0.1 SECONDS)
	process_fire(target, shooter, TRUE, params, null, bonus_spread)

#undef AUTOFIRE_MOUSEUP
#undef AUTOFIRE_MOUSEDOWN
