//Xenobio control console
/mob/eye/camera/remote/xenobio
	visible_to_user = TRUE
	var/allowed_area = null

/mob/eye/camera/remote/xenobio/Initialize(mapload)
	var/area/our_area = get_area(loc)
	allowed_area = our_area.name
	. = ..()

/mob/eye/camera/remote/xenobio/setLoc(turf/destination, force_update = FALSE)
	var/area/new_area = get_area(destination)

	if(new_area && new_area.name == allowed_area || new_area && (new_area.area_flags & XENOBIOLOGY_COMPATIBLE))
		return ..()

/mob/eye/camera/remote/xenobio/can_z_move(direction, turf/start, turf/destination, z_move_flags = NONE, mob/living/rider)
	. = ..()
	if(!.)
		return
	var/area/new_area = get_area(.)
	if(new_area.name != allowed_area && !(new_area.area_flags & XENOBIOLOGY_COMPATIBLE))
		return FALSE

#define SUCTION_DELAY 1 DECISECONDS
#define SUCTION_TIME 2 DECISECONDS

/obj/machinery/computer/camera_advanced/xenobio
	name = "Slime management console"
	desc = "A computer used for remotely handling slimes."
	networks = list(CAMERANET_NETWORK_SS13)
	circuit = /obj/item/circuitboard/computer/xenobiology

	icon_screen = "slime_comp"
	icon_keyboard = "rd_key"

	light_color = LIGHT_COLOR_PINK

	/// Weakref to the monkey recycler connected to this console.
	var/datum/weakref/connected_recycler_ref
	/// The slimes stored inside this console.
	var/list/stored_slimes
	/// The slime potion stored inside this console.
	var/obj/item/slimepotion/slime/current_potion
	/// The maximum amount of slimes that fit in this machine.
	var/max_slimes = 5
	/// The amount of monkey cubes inside this machine.
	var/stored_monkeys = 0
	/// The HUD for this console.
	var/atom/movable/screen/xenobio_console/xeno_hud

/obj/machinery/computer/camera_advanced/xenobio/Initialize(mapload)
	. = ..()
	actions += new /datum/action/innate/slime_place(src)
	actions += new /datum/action/innate/slime_pick_up(src)
	actions += new /datum/action/innate/feed_slime(src)
	actions += new /datum/action/innate/monkey_recycle(src)
	actions += new /datum/action/innate/slime_scan(src)
	actions += new /datum/action/innate/feed_potion(src)
	actions += new /datum/action/innate/hotkey_help(src)

	stored_slimes = list()
	xeno_hud = new(null, src)
	xeno_hud.on_update_hud(LAZYLEN(stored_slimes), stored_monkeys, max_slimes)
	register_context()

/obj/machinery/computer/camera_advanced/xenobio/post_machine_initialize()
	. = ..()
	for(var/obj/machinery/monkey_recycler/recycler in GLOB.monkey_recyclers)
		if(get_area(recycler) == get_area(src))
			connected_recycler_ref = WEAKREF(recycler)
			break

/obj/machinery/computer/camera_advanced/xenobio/Destroy()
	QDEL_NULL(current_potion)
	for(var/thing in stored_slimes)
		var/mob/living/basic/slime/stored_slime = thing
		stored_slime.forceMove(drop_location())
	stored_slimes.Cut()
	QDEL_NULL(xeno_hud)
	return ..()

/obj/machinery/computer/camera_advanced/xenobio/add_context(atom/source, list/context, obj/item/held_item, mob/living/user)
	. = ..()

	if(istype(held_item, /obj/item/slimepotion/slime))
		context[SCREENTIP_CONTEXT_LMB] = "[current_potion ? "Swap" : "Insert"] potion"
		return CONTEXTUAL_SCREENTIP_SET
	if(istype(held_item, /obj/item/food/monkeycube))
		context[SCREENTIP_CONTEXT_LMB] = "Insert monkey cubes"
		return CONTEXTUAL_SCREENTIP_SET
	if(istype(held_item, /obj/item/storage/bag) || istype(held_item, /obj/item/storage/box/monkeycubes))
		context[SCREENTIP_CONTEXT_LMB] = "Load monkey cubes"
		return CONTEXTUAL_SCREENTIP_SET
	if(istype(held_item, /obj/item/multitool))
		context[SCREENTIP_CONTEXT_LMB] = "Link monkey recycler"
		return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/computer/camera_advanced/xenobio/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == current_potion)
		current_potion = null
	if(gone in stored_slimes)
		stored_slimes -= gone

/obj/machinery/computer/camera_advanced/xenobio/CreateEye()
	eyeobj = new /mob/eye/camera/remote/xenobio(get_turf(src), src)

	return TRUE

/obj/machinery/computer/camera_advanced/xenobio/GrantActions(mob/living/user)
	. = ..()
	RegisterSignal(user, COMSIG_MOB_CTRL_CLICKED, PROC_REF(user_ctrl_click))
	RegisterSignal(user, COMSIG_MOB_ALTCLICKON, PROC_REF(user_alt_click))
	RegisterSignal(user, COMSIG_CLICK_SHIFT, PROC_REF(user_shift_click))
	if(!user.hud_used)
		return
	user.hud_used.static_inventory += xeno_hud
	user.hud_used.show_hud(user.hud_used.hud_version)

/obj/machinery/computer/camera_advanced/xenobio/remove_eye_control(mob/living/user)
	UnregisterSignal(user, list(
		COMSIG_MOB_CTRL_CLICKED,
		COMSIG_MOB_ALTCLICKON,
		COMSIG_CLICK_SHIFT,
	))
	if(user.hud_used)
		if(xeno_hud)
			user.hud_used.static_inventory -= xeno_hud
			user.hud_used.show_hud(user.hud_used.hud_version)
	return ..()

/obj/machinery/computer/camera_advanced/xenobio/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	. = ..()
	if(.)
		return .

	if(istype(tool, /obj/item/slimepotion/slime))
		return slimepotion_act(user, tool)
	if(istype(tool, /obj/item/food/monkeycube))
		return monkeycube_act(user, tool)
	if(istype(tool, /obj/item/storage/bag) || istype(tool, /obj/item/storage/box/monkeycubes))
		return storage_act(user, tool)
	return NONE

/// Handles inserting a slime potion into the console, potentially swapping out an existing one.
/obj/machinery/computer/camera_advanced/xenobio/proc/slimepotion_act(mob/living/user, obj/item/slimepotion/slime/used_potion)
	if(!user.transferItemToLoc(used_potion, src))
		balloon_alert(user, "can't insert!")
		return ITEM_INTERACT_BLOCKING

	if(!QDELETED(current_potion))
		try_put_in_hand(current_potion, user)
		balloon_alert(user, "swapped")
	else
		balloon_alert(user, "inserted")

	current_potion = used_potion
	xeno_hud.update_potion(current_potion)
	return ITEM_INTERACT_SUCCESS

/// Handles inserting a monkey cube into the console.
/obj/machinery/computer/camera_advanced/xenobio/proc/monkeycube_act(mob/living/user, obj/item/food/monkeycube/used_cube)
	stored_monkeys += 1
	balloon_alert(user, "[stored_monkeys] cube\s stored")
	xeno_hud.on_update_hud(LAZYLEN(stored_slimes), stored_monkeys, max_slimes)
	qdel(used_cube)
	return ITEM_INTERACT_SUCCESS

/// Handles inserting any monkey cubes stored in the tool into the console.
/obj/machinery/computer/camera_advanced/xenobio/proc/storage_act(mob/living/user, obj/item/tool)
	var/loaded_any = FALSE
	for(var/obj/storage_item in tool.contents)
		if(istype(storage_item, /obj/item/food/monkeycube))
			loaded_any = TRUE
			stored_monkeys += 1
			qdel(storage_item)
	if(!loaded_any)
		balloon_alert(user, "no monkey cubes!")
		return ITEM_INTERACT_BLOCKING

	balloon_alert(user, "[stored_monkeys] cube\s stored")
	xeno_hud.on_update_hud(LAZYLEN(stored_slimes), stored_monkeys, max_slimes)
	return ITEM_INTERACT_SUCCESS

/obj/machinery/computer/camera_advanced/xenobio/multitool_act(mob/living/user, obj/item/multitool/tool)
	if(!istype(tool)) // Needed as long as this uses a var on the multitool.
		return NONE
	if(QDELETED(tool.buffer))
		balloon_alert(user, "buffer empty!")
		return ITEM_INTERACT_BLOCKING
	if(!istype(tool.buffer, /obj/machinery/monkey_recycler))
		balloon_alert(user, "can only link recyclers!")
		return ITEM_INTERACT_BLOCKING

	balloon_alert(user, "linked recycler")
	connected_recycler_ref = WEAKREF(tool.buffer)
	return ITEM_INTERACT_SUCCESS

/// Validates whether the target turf can be interacted with.
/obj/machinery/computer/camera_advanced/xenobio/proc/validate_turf(mob/living/user, turf/open/target_turf)
	if(!GLOB.cameranet.checkTurfVis(target_turf))
		target_turf.balloon_alert(user, "outside of view!")
		return FALSE

	var/area/turfarea = get_area(target_turf)
	var/mob/eye/camera/remote/xenobio/remote_eye = user.remote_control
	if(turfarea.name != remote_eye.allowed_area && !(turfarea.area_flags & XENOBIOLOGY_COMPATIBLE))
		target_turf.balloon_alert(user, "invalid area!")
		return FALSE

	return TRUE

///Places every slime in storage on target turf
/obj/machinery/computer/camera_advanced/xenobio/proc/slime_place(turf/open/target_turf)
	spit_out(stored_slimes, target_turf)
	if(stored_slimes.len <= 0)
		return
	if(stored_slimes.len == 1)
		target_turf.visible_message(span_notice("The slime is spat out!"))
	else
		target_turf.visible_message(span_notice("[stored_slimes.len] slimes are spat out!"))
	for(var/mob/living/basic/slime/stored_slime in stored_slimes)
		stored_slime.forceMove(target_turf)
		REMOVE_TRAIT(stored_slime, TRAIT_STASIS, XENOBIO_CONSOLE_TRAIT)
		stored_slime.handle_slime_stasis()
	xeno_hud.on_update_hud(LAZYLEN(stored_slimes), stored_monkeys, max_slimes)

///Places every slime not controlled by a player into the internal storage, respecting its limits
///Returns TRUE to signal it hitting the limit, in case its being called from a loop and we want it to stop
/obj/machinery/computer/camera_advanced/xenobio/proc/slime_pickup(mob/living/user, mob/living/basic/slime/target_slime)
	if(target_slime in stored_slimes)
		// It's possible for this proc to be called on a slime that's already being picked up,
		// so we need to check whether we already have to avoid duplicate entries.
		return FALSE
	if(stored_slimes.len >= max_slimes)
		to_chat(user, span_warning("Slime storage is full."))
		target_slime.balloon_alert(user, "storage full")
		return TRUE
	if(target_slime.ckey)
		to_chat(user, span_warning("The slime wiggled free!"))
		return FALSE
	if(target_slime.buckled)
		target_slime.stop_feeding(silent = TRUE)
	target_slime.visible_message(span_notice("The slime gets sucked up!"))
	suck_up(target_slime)
	target_slime.forceMove(src)
	stored_slimes += target_slime
	ADD_TRAIT(target_slime, TRAIT_STASIS, XENOBIO_CONSOLE_TRAIT)
	xeno_hud.on_update_hud(LAZYLEN(stored_slimes), stored_monkeys, max_slimes)

	return FALSE

///Places one monkey, if possible
/obj/machinery/computer/camera_advanced/xenobio/proc/feed_slime(mob/living/user, turf/open/target_turf)
	if(stored_monkeys < 1)
		to_chat(user, span_warning("[src] needs to have at least 1 monkey stored. Currently has [stored_monkeys] stored_monkeys stored."))
		target_turf.balloon_alert(user, "not enough monkeys")
		return

	var/mob/living/carbon/human/species/monkey/food = new /mob/living/carbon/human/species/monkey(target_turf, TRUE, user)
	if (QDELETED(food))
		return
	food.apply_status_effect(/datum/status_effect/slime_food, user)

	stored_monkeys--
	stored_monkeys = round(stored_monkeys, 0.1) //Prevents rounding errors
	spit_out(food, target_turf)
	xeno_hud.on_update_hud(LAZYLEN(stored_slimes), stored_monkeys, max_slimes)

/// Check whether we can recycle monkeys at all. Optionally, displays a balloon alert over a target atom for feedback.
/obj/machinery/computer/camera_advanced/xenobio/proc/can_recycle_monkeys(mob/living/user, atom/target_atom)
	PRIVATE_PROC(TRUE)
	var/obj/machinery/monkey_recycler/connected_recycler = connected_recycler_ref?.resolve()
	if(isnull(connected_recycler))
		to_chat(user, span_warning("There is no connected monkey recycler. Use a multitool to link one."))
		if(target_atom)
			target_atom.balloon_alert(user, "no recycler linked!")
		return FALSE
	return TRUE

/// Check whether we can recycle the target monkey. Optionally takes in a user to display errors to.
/obj/machinery/computer/camera_advanced/xenobio/proc/can_recycle_target_monkey(mob/living/carbon/human/target_human, mob/living/user)
	PRIVATE_PROC(TRUE)
	if(!ismonkey(target_human))
		if(user)
			target_human.balloon_alert(user, "not a monkey!")
		return FALSE
	if(target_human.stat < DEAD)
		if(user)
			target_human.balloon_alert(user, "not dead!")
		return FALSE
	return TRUE

/// Attempts to recycle any monkeys on the targeted turf.
/obj/machinery/computer/camera_advanced/xenobio/proc/try_recycle_monkeys_on_turf(mob/living/user, turf/target_turf)
	if(!can_recycle_monkeys(user, target_turf))
		return FALSE

	var/monkey_found = FALSE
	for(var/mob/living/carbon/human/target_human in target_turf)
		if(!can_recycle_target_monkey(target_human))
			continue
		recycle_monkey(target_human)
		monkey_found = TRUE

	return monkey_found

/// Attempts to recycle the targeted human.
/obj/machinery/computer/camera_advanced/xenobio/proc/try_recycle_target_monkey(mob/living/user, mob/living/carbon/human/target_human, silence_errors = FALSE)
	if(!can_recycle_target_monkey(target_human, user))
		return FALSE
	if(!can_recycle_monkeys(user, target_human))
		return FALSE

	recycle_monkey(target_human)
	return TRUE

/// Recycles a given monkey.
/obj/machinery/computer/camera_advanced/xenobio/proc/recycle_monkey(mob/living/carbon/human/target_monkey)
	var/obj/machinery/monkey_recycler/connected_recycler = connected_recycler_ref?.resolve()
	if(isnull(connected_recycler))
		return

	suck_up(target_monkey)
	target_monkey.visible_message(span_notice("The monkey shoots up as [target_monkey.p_theyre()] reclaimed for recycling!"))
	connected_recycler.use_energy(500 JOULES)
	stored_monkeys += connected_recycler.cube_production
	stored_monkeys = round(stored_monkeys, 0.1) //Prevents rounding errors
	xeno_hud.on_update_hud(LAZYLEN(stored_slimes), stored_monkeys, max_slimes)
	qdel(target_monkey)

/datum/action/innate/slime_place
	name = "Place Slimes"
	button_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "slime_down"

/datum/action/innate/slime_place/Activate()
	if(!target || !isliving(owner))
		return
	var/mob/living/living_owner = owner
	var/turf/eye_turf = get_turf(living_owner.remote_control)
	var/obj/machinery/computer/camera_advanced/xenobio/xeno_console = target

	if(!xeno_console.validate_turf(owner, eye_turf))
		return

	xeno_console.slime_place(eye_turf)

/datum/action/innate/slime_pick_up
	name = "Pick up Slime"
	button_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "slime_up"

/datum/action/innate/slime_pick_up/Activate()
	if(!target || !isliving(owner))
		return
	var/mob/living/living_owner = owner
	var/turf/eye_turf = get_turf(living_owner.remote_control)
	var/obj/machinery/computer/camera_advanced/xenobio/xeno_console = target

	if(!xeno_console.validate_turf(living_owner, eye_turf))
		return

	for(var/mob/living/basic/slime/target_slime in eye_turf)
		if(xeno_console.slime_pickup(living_owner, target_slime)) ///Returns true if we hit our slime pickup limit
			break

/datum/action/innate/feed_slime
	name = "Feed Slimes"
	button_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "monkey_down"

/datum/action/innate/feed_slime/Activate()
	if(!target || !isliving(owner))
		return
	var/mob/living/living_owner = owner
	var/turf/eye_turf = get_turf(living_owner.remote_control)
	var/obj/machinery/computer/camera_advanced/xenobio/xeno_console = target

	if(!xeno_console.validate_turf(living_owner, eye_turf))
		return

	xeno_console.feed_slime(living_owner, eye_turf)


/datum/action/innate/monkey_recycle
	name = "Recycle Monkeys"
	button_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "monkey_up"

/datum/action/innate/monkey_recycle/Activate()
	if(!target || !isliving(owner))
		return
	var/mob/living/living_owner = owner
	var/turf/eye_turf = get_turf(living_owner.remote_control)
	var/obj/machinery/computer/camera_advanced/xenobio/xeno_console = target

	if(!xeno_console.validate_turf(living_owner, eye_turf))
		return

	xeno_console.try_recycle_monkeys_on_turf(living_owner, eye_turf)

/datum/action/innate/slime_scan
	name = "Scan Slime"
	button_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "slime_scan"

/datum/action/innate/slime_scan/Activate()
	if(!target || !isliving(owner))
		return
	var/mob/living/living_owner = owner
	var/turf/eye_turf = get_turf(living_owner.remote_control)
	var/obj/machinery/computer/camera_advanced/xenobio/xeno_console = target

	if(!xeno_console.validate_turf(living_owner, eye_turf))
		return

	for(var/mob/living/basic/slime/scanned_slime in eye_turf)
		slime_scan(scanned_slime, living_owner)

/datum/action/innate/feed_potion
	name = "Apply Potion"
	button_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "slime_potion"

/datum/action/innate/feed_potion/Activate()
	if(!target || !isliving(owner))
		return

	var/mob/living/living_owner = owner
	var/turf/eye_turf = get_turf(living_owner.remote_control)
	var/obj/machinery/computer/camera_advanced/xenobio/xeno_console = target

	if(!xeno_console.validate_turf(owner, eye_turf))
		return

	if(QDELETED(xeno_console.current_potion))
		to_chat(owner, span_warning("No potion loaded."))
		return

	for(var/mob/living/basic/slime/potioned_slime in eye_turf)
		xeno_console.spit_atom(xeno_console.current_potion, eye_turf)
		xeno_console.current_potion.attack(potioned_slime, living_owner)
		xeno_console.xeno_hud.update_potion(xeno_console.current_potion)
		break

/datum/action/innate/hotkey_help
	name = "Hotkey Help"
	button_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "hotkey_help"

/datum/action/innate/hotkey_help/Activate()
	if(!target || !isliving(owner))
		return

	var/render_list = list()
	render_list += "<b>Click shortcuts:</b>"
	render_list += "&bull; Shift-click a slime to pick it up, or the floor to drop all held slimes."
	render_list += "&bull; Ctrl-click a slime to scan it."
	render_list += "&bull; Alt-click a slime to feed it a potion."
	render_list += "&bull; Ctrl-click or a dead monkey to recycle it, or the floor to place a new monkey."

	to_chat(owner, boxed_message(jointext(render_list, "\n")))

/// Handles console user alt-clicking, forwards to other procs based on target type.
/obj/machinery/computer/camera_advanced/xenobio/proc/user_alt_click(mob/living/user, atom/target)
	SIGNAL_HANDLER

	if(isslime(target))
		alt_click_slime(user, target)
		return COMSIG_MOB_CANCEL_CLICKON
	return NONE

///Feeds a stored potion to a slime
/obj/machinery/computer/camera_advanced/xenobio/proc/alt_click_slime(mob/living/user, mob/living/basic/slime/target_slime)
	var/turf/slime_turf = get_turf(target_slime)
	if(!validate_turf(user, slime_turf))
		return

	if(QDELETED(current_potion))
		to_chat(user, span_warning("No potion loaded."))
		return

	spit_atom(current_potion, slime_turf)
	INVOKE_ASYNC(current_potion, TYPE_PROC_REF(/obj/item/slimepotion/slime, attack), target_slime, user)
	xeno_hud.update_potion(current_potion)

/// Handles console user shift-clicking, forwards to other procs based on target type.
/obj/machinery/computer/camera_advanced/xenobio/proc/user_shift_click(mob/living/user, atom/target)
	SIGNAL_HANDLER

	if(isslime(target))
		shift_click_slime(user, target)
		return COMSIG_MOB_CANCEL_CLICKON
	else if(isopenturf(target))
		shift_click_turf(user, target)
		return COMSIG_MOB_CANCEL_CLICKON
	return NONE

/// Picks up a slime, and places them in the internal storage.
/obj/machinery/computer/camera_advanced/xenobio/proc/shift_click_slime(mob/living/user, mob/living/basic/slime/target_slime)
	if(!validate_turf(user, get_turf(target_slime)))
		return

	slime_pickup(user, target_slime)

/// Places all slimes from the internal storage.
/obj/machinery/computer/camera_advanced/xenobio/proc/shift_click_turf(mob/living/user, turf/open/target_turf)
	if(!validate_turf(user, target_turf))
		return

	slime_place(target_turf, user)

/// Handles console user ctrl-clicking, forwards to other procs based on target type.
/obj/machinery/computer/camera_advanced/xenobio/proc/user_ctrl_click(mob/living/user, atom/target)
	SIGNAL_HANDLER

	if(isopenturf(target))
		ctrl_click_turf(user, target)
		return COMSIG_MOB_CANCEL_CLICKON
	else if(ismonkey(target))
		ctrl_click_monkey(user, target)
		return COMSIG_MOB_CANCEL_CLICKON
	else if(isslime(target))
		ctrl_click_slime(user, target)
		return COMSIG_MOB_CANCEL_CLICKON
	return NONE

/// Attempts to recycle all monkeys on the turf, otherwise places a monkey from the internal storage.
/obj/machinery/computer/camera_advanced/xenobio/proc/ctrl_click_turf(mob/living/user, turf/open/target_turf)
	if(!validate_turf(user, target_turf))
		return

	// Attempt to recycle any monkeys on the turf first.
	if(try_recycle_monkeys_on_turf(user, target_turf))
		return

	feed_slime(user, target_turf)

/// Picks up a dead monkey for recycling.
/obj/machinery/computer/camera_advanced/xenobio/proc/ctrl_click_monkey(mob/living/user, mob/living/carbon/human/target_human)
	if(!validate_turf(user, get_turf(target_human)))
		return

	try_recycle_target_monkey(user, target_human)

/// Scans the target slime.
/obj/machinery/computer/camera_advanced/xenobio/proc/ctrl_click_slime(mob/living/user, mob/living/basic/slime/target_slime)
	if(!validate_turf(user, get_turf(target_slime)))
		return

	slime_scan(target_slime, user)

/// Sucks the target mob up into the console.
/obj/machinery/computer/camera_advanced/xenobio/proc/suck_up(mob/living/target_mob)
	if(!isliving(target_mob))
		return
	var/mobturf = get_turf(target_mob)
	new /obj/effect/abstract/xenosuction(mobturf)
	new /obj/effect/abstract/sucked_atom(mobturf, target_mob, TRUE)
	/// Make the mob invisible so it doesn't get seen during the animation
	target_mob.SetInvisibility(INVISIBILITY_MAXIMUM, id=XENOBIO_CONSOLE_TRAIT)
	addtimer(CALLBACK(target_mob, TYPE_PROC_REF(/atom,RemoveInvisibility), XENOBIO_CONSOLE_TRAIT), SUCTION_DELAY + SUCTION_TIME)
	addtimer(CALLBACK(src, PROC_REF(handle_xeno_sounds), mobturf, FALSE), SUCTION_DELAY)


/// Shoots the target mob(s) out of the console
/obj/machinery/computer/camera_advanced/xenobio/proc/spit_out(list/mobs_to_spit, turf/open/target_turf)
	if(isnull(mobs_to_spit) || isnull(target_turf))
		return
	if(!islist(mobs_to_spit))
		mobs_to_spit = list(mobs_to_spit)
	if(!LAZYLEN(mobs_to_spit))
		return
	new /obj/effect/abstract/xenosuction(target_turf)
	for(var/mob/living/shot_mob in mobs_to_spit)
		new /obj/effect/abstract/sucked_atom(target_turf, shot_mob, FALSE)
		shot_mob.SetInvisibility(INVISIBILITY_MAXIMUM, id=XENOBIO_CONSOLE_TRAIT)
		addtimer(CALLBACK(shot_mob, TYPE_PROC_REF(/atom,RemoveInvisibility), XENOBIO_CONSOLE_TRAIT), SUCTION_DELAY + SUCTION_TIME)
	addtimer(CALLBACK(src, PROC_REF(handle_xeno_sounds), target_turf, TRUE), SUCTION_DELAY)

/// Shoots the target atom out of the tube. Used for anything that isn't a mob (I.e. potions)
/obj/machinery/computer/camera_advanced/xenobio/proc/spit_atom(atom/movable/target_atom, turf/open/target_turf)
	if(isnull(target_atom))
		return
	if(isnull(target_turf))
		target_turf = get_turf(target_atom)
	new /obj/effect/abstract/xenosuction(target_turf)
	var/ispot = istype(target_atom, /obj/item/slimepotion/slime)
	new /obj/effect/abstract/sucked_atom(target_turf, target_atom, FALSE, ispot)
	addtimer(CALLBACK(src, PROC_REF(handle_xeno_sounds), target_turf, TRUE), SUCTION_DELAY)
	if(ispot)
		addtimer(CALLBACK(src, PROC_REF(handle_shatter_sound), target_turf), SUCTION_DELAY+SUCTION_TIME)

///Plays the sound in the given location. Easier to call w/ addtimer()
/obj/machinery/computer/camera_advanced/xenobio/proc/handle_xeno_sounds(turf/open/target_turf, spitting)
	var/tubesound = 'sound/effects/compressed_air/air_suck.ogg'
	if(spitting)
		tubesound = 'sound/effects/compressed_air/air_shoot.ogg'
	playsound(target_turf, tubesound, 50, TRUE, SHORT_RANGE_SOUND_EXTRARANGE)

///The sound that plays when a potion shatters. Easier to call w/ addtimer()
/obj/machinery/computer/camera_advanced/xenobio/proc/handle_shatter_sound(turf/open/target_turf)
	playsound(target_turf, SFX_SHATTER, 35, TRUE, MEDIUM_RANGE_SOUND_EXTRARANGE)

/// An abstract effect to simulate sucking the atom up or spitting it out
/obj/effect/abstract/sucked_atom
	layer = MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	/// The initial alpha of the atom, because slimes can be semi-transparent
	var/mob_initial_alpha = 255

/obj/effect/abstract/sucked_atom/Initialize(mapload, atom/movable/copying, sucking = FALSE, shatter = FALSE)
	. = ..()
	if(!ismovable(copying))
		return
	appearance = copying.appearance
	mob_initial_alpha = copying.alpha
	layer = MOB_LAYER
	if(sucking)
		suck_up()
	else
		pixel_y = 64
		alpha = 0
		shoot_out(shatter)

/// Shoots the mob visual upwards into the pipe then deletes it
/obj/effect/abstract/sucked_atom/proc/suck_up()
	QDEL_IN(src, SUCTION_DELAY + SUCTION_TIME)
	animate(src, time = SUCTION_DELAY)
	animate(time = SUCTION_TIME, easing = CUBIC_EASING | EASE_IN, pixel_y = 64, alpha = 0)

/// Shoots the mob visual out then deletes it
/obj/effect/abstract/sucked_atom/proc/shoot_out(shatter)
	QDEL_IN(src, SUCTION_DELAY + SUCTION_TIME)
	animate(src, time = SUCTION_DELAY, flags = ANIMATION_PARALLEL)
	animate(time = SUCTION_TIME, easing = (shatter ? LINEAR_EASING : BOUNCE_EASING), pixel_y = 0, flags = ANIMATION_PARALLEL)

	animate(src, time = SUCTION_DELAY, flags = ANIMATION_PARALLEL)
	animate(time = SUCTION_TIME, easing = CUBIC_EASING | EASE_OUT, alpha = mob_initial_alpha, flags = ANIMATION_PARALLEL)


/// The tube that sucks up/spits out the mob
/obj/effect/abstract/xenosuction
	icon = 'icons/effects/effects.dmi'
	icon_state = "xenotube_back"
	layer = BELOW_MOB_LAYER
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	blocks_emissive = EMISSIVE_BLOCK_NONE
	pixel_y = 48
	alpha = 0

/obj/effect/abstract/xenosuction/Initialize(mapload)
	. = ..()
	add_overlay(mutable_appearance(icon, "xenotube_fore", layer = ABOVE_MOB_LAYER))
	QDEL_IN(src, SUCTION_DELAY*2 + SUCTION_TIME)
	animate(src, time = SUCTION_DELAY, alpha = 255, pixel_y = 32)
	animate(time = SUCTION_TIME)
	animate(time = SUCTION_DELAY, alpha = 0, pixel_y = 48)

#undef SUCTION_TIME
#undef SUCTION_DELAY
