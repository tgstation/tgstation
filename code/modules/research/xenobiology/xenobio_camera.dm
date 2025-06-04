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

	///The recycler connected to the camera console
	var/obj/machinery/monkey_recycler/connected_recycler
	///The slimes stored inside the console
	var/list/stored_slimes
	///The single slime potion stored inside the console
	var/obj/item/slimepotion/slime/current_potion
	///The maximum amount of slimes that fit in the machine
	var/max_slimes = 5
	///The amount of monkey cubes inside the machine
	var/monkeys = 0
	/// The HUD for this console
	var/atom/movable/screen/xenobio_console/xeno_hud

	icon_screen = "slime_comp"
	icon_keyboard = "rd_key"

	light_color = LIGHT_COLOR_PINK

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
	xeno_hud.on_update_hud(LAZYLEN(stored_slimes), monkeys, max_slimes)

/obj/machinery/computer/camera_advanced/xenobio/post_machine_initialize()
	. = ..()
	for(var/obj/machinery/monkey_recycler/recycler in GLOB.monkey_recyclers)
		if(get_area(recycler.loc) == get_area(loc))
			connected_recycler = recycler
			connected_recycler.connected += src

/obj/machinery/computer/camera_advanced/xenobio/Destroy()
	QDEL_NULL(current_potion)
	for(var/thing in stored_slimes)
		var/mob/living/basic/slime/stored_slime = thing
		stored_slime.forceMove(drop_location())
	stored_slimes.Cut()
	if(connected_recycler)
		connected_recycler.connected -= src
	connected_recycler = null
	QDEL_NULL(xeno_hud)
	return ..()

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
	RegisterSignal(user, COMSIG_MOB_CTRL_CLICKED, PROC_REF(XenoClickCtrl))
	RegisterSignal(user, COMSIG_MOB_ALTCLICKON, PROC_REF(XenoSlimeClickAlt))
	RegisterSignal(user, COMSIG_XENO_SLIME_CLICK_SHIFT, PROC_REF(XenoSlimeClickShift))
	RegisterSignal(user, COMSIG_XENO_TURF_CLICK_SHIFT, PROC_REF(XenoTurfClickShift))
	if(!user.hud_used)
		return
	user.hud_used.static_inventory += xeno_hud
	user.hud_used.show_hud(user.hud_used.hud_version)

/obj/machinery/computer/camera_advanced/xenobio/remove_eye_control(mob/living/user)
	UnregisterSignal(user, list(
		COMSIG_MOB_CTRL_CLICKED,
		COMSIG_MOB_ALTCLICKON,
		COMSIG_XENO_SLIME_CLICK_SHIFT,
		COMSIG_XENO_TURF_CLICK_SHIFT,
	))
	if(user.hud_used)
		if(xeno_hud)
			user.hud_used.static_inventory -= xeno_hud
			user.hud_used.show_hud(user.hud_used.hud_version)
	return ..()

/obj/machinery/computer/camera_advanced/xenobio/attackby(obj/item/used_item, mob/user, list/modifiers, list/attack_modifiers)
	if(istype(used_item, /obj/item/food/monkeycube))
		monkeys++
		to_chat(user, span_notice("You feed [used_item] to [src]. It now has [monkeys] monkey cubes stored."))
		qdel(used_item)
		xeno_hud.on_update_hud(LAZYLEN(stored_slimes), monkeys, max_slimes)
		return

	if(istype(used_item, /obj/item/storage/bag) || istype(used_item, /obj/item/storage/box/monkeycubes))
		var/obj/item/storage/storage_container = used_item
		var/loaded = FALSE
		for(var/obj/storage_item in storage_container.contents)
			if(istype(storage_item, /obj/item/food/monkeycube))
				loaded = TRUE
				monkeys++
				qdel(storage_item)
		if(loaded)
			to_chat(user, span_notice("You fill [src] with the monkey cubes stored in [used_item]. [src] now has [monkeys] monkey cubes stored."))
			xeno_hud.on_update_hud(LAZYLEN(stored_slimes), monkeys, max_slimes)
		return

	if(istype(used_item, /obj/item/slimepotion/slime))
		var/replaced = FALSE
		if(user && !user.transferItemToLoc(used_item, src))
			return
		if(!QDELETED(current_potion))
			current_potion.forceMove(drop_location())
			replaced = TRUE
		current_potion = used_item
		xeno_hud.update_potion(current_potion)
		to_chat(user, span_notice("You load [used_item] in the console's potion slot[replaced ? ", replacing the previous" : ""]."))

		return

	..()

/obj/machinery/computer/camera_advanced/xenobio/multitool_act(mob/living/user, obj/item/multitool/used_multitool)
	. = ..()
	if (istype(used_multitool) && istype(used_multitool.buffer,/obj/machinery/monkey_recycler))
		to_chat(user, span_notice("You link [src] with [used_multitool.buffer] in [used_multitool] buffer."))
		connected_recycler = used_multitool.buffer
		connected_recycler.connected += src
		return TRUE

/*
Boilerplate check for a valid area to perform a camera action in.
Checks if the AI eye is on a valid turf and then checks if the target turf is xenobiology compatible
Due to keyboard shortcuts, the second one is not necessarily the remote eye's location.
*/
/obj/machinery/computer/camera_advanced/xenobio/proc/validate_area(mob/living/user, mob/eye/camera/remote/xenobio/remote_eye, turf/open/target_turf)
	if(!GLOB.cameranet.checkTurfVis(remote_eye.loc))
		to_chat(user, span_warning("Target is not near a camera. Cannot proceed."))
		return FALSE

	var/area/turfarea = get_area(target_turf)
	if(turfarea.name != remote_eye.allowed_area && !(turfarea.area_flags & XENOBIOLOGY_COMPATIBLE))
		to_chat(user, span_warning("Invalid area. Cannot proceed."))
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
		stored_slime.handle_slime_stasis(0)
	xeno_hud.on_update_hud(LAZYLEN(stored_slimes), monkeys, max_slimes)

///Places every slime not controlled by a player into the internal storage, respecting its limits
///Returns TRUE to signal it hitting the limit, in case its being called from a loop and we want it to stop
/obj/machinery/computer/camera_advanced/xenobio/proc/slime_pickup(mob/living/user, mob/living/basic/slime/target_slime)
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
	xeno_hud.on_update_hud(LAZYLEN(stored_slimes), monkeys, max_slimes)

	return FALSE

///Places one monkey, if possible
/obj/machinery/computer/camera_advanced/xenobio/proc/feed_slime(mob/living/user, turf/open/target_turf)
	if(monkeys < 1)
		to_chat(user, span_warning("[src] needs to have at least 1 monkey stored. Currently has [monkeys] monkeys stored."))
		target_turf.balloon_alert(user, "not enough monkeys")
		return

	var/mob/living/carbon/human/species/monkey/food = new /mob/living/carbon/human/species/monkey(target_turf, TRUE, user)
	if (QDELETED(food))
		return
	food.apply_status_effect(/datum/status_effect/slime_food, user)

	monkeys--
	monkeys = round(monkeys, 0.1) //Prevents rounding errors
	spit_out(food, target_turf)
	xeno_hud.on_update_hud(LAZYLEN(stored_slimes), monkeys, max_slimes)

///Recycles the target monkey
/obj/machinery/computer/camera_advanced/xenobio/proc/monkey_recycle(mob/living/user, mob/living/target_mob)
	if(!ismonkey(target_mob))
		return
	if(!target_mob.stat)
		return

	suck_up(target_mob)
	target_mob.visible_message(span_notice("The monkey shoots up as [p_theyre()] reclaimed for recycling!"))
	connected_recycler.use_energy(500 JOULES)
	monkeys += connected_recycler.cube_production
	monkeys = round(monkeys, 0.1) //Prevents rounding errors
	xeno_hud.on_update_hud(LAZYLEN(stored_slimes), monkeys, max_slimes)
	qdel(target_mob)

/datum/action/innate/slime_place
	name = "Place Slimes"
	button_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "slime_down"

/datum/action/innate/slime_place/Activate()
	if(!target || !isliving(owner))
		return
	var/mob/living/owner_mob = owner
	var/mob/eye/camera/remote/xenobio/remote_eye = owner_mob.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/xeno_console = target

	if(!xeno_console.validate_area(owner, remote_eye, remote_eye.loc))
		return

	xeno_console.slime_place(remote_eye.loc)

/datum/action/innate/slime_pick_up
	name = "Pick up Slime"
	button_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "slime_up"

/datum/action/innate/slime_pick_up/Activate()
	if(!target || !isliving(owner))
		return
	var/mob/living/owner_mob = owner
	var/mob/eye/camera/remote/xenobio/remote_eye = owner_mob.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/xeno_console = target

	if(!xeno_console.validate_area(owner, remote_eye, remote_eye.loc))
		return

	for(var/mob/living/basic/slime/target_slime in remote_eye.loc)
		if(xeno_console.slime_pickup(owner_mob, target_slime)) ///Returns true if we hit our slime pickup limit
			break

/datum/action/innate/feed_slime
	name = "Feed Slimes"
	button_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "monkey_down"

/datum/action/innate/feed_slime/Activate()
	if(!target || !isliving(owner))
		return
	var/mob/living/living_owner = owner
	var/mob/eye/camera/remote/xenobio/remote_eye = living_owner.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/xeno_console = target

	if(!xeno_console.validate_area(owner, remote_eye, remote_eye.loc))
		return

	xeno_console.feed_slime(living_owner, remote_eye.loc)


/datum/action/innate/monkey_recycle
	name = "Recycle Monkeys"
	button_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "monkey_up"

/datum/action/innate/monkey_recycle/Activate()
	if(!target || !isliving(owner))
		return
	var/mob/living/owner_mob = owner
	var/mob/eye/camera/remote/xenobio/remote_eye = owner_mob.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/xeno_console = target
	var/obj/machinery/monkey_recycler/recycler = xeno_console.connected_recycler

	if(!xeno_console.validate_area(owner, remote_eye, remote_eye.loc))
		return

	if(!recycler)
		to_chat(owner, span_warning("There is no connected monkey recycler. Use a multitool to link one."))
		return

	for(var/mob/living/carbon/human/target_mob in remote_eye.loc)
		xeno_console.monkey_recycle(owner, target_mob)

/datum/action/innate/slime_scan
	name = "Scan Slime"
	button_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "slime_scan"

/datum/action/innate/slime_scan/Activate()
	if(!target || !isliving(owner))
		return
	var/mob/living/owner_mob = owner
	var/mob/eye/camera/remote/xenobio/remote_eye = owner_mob.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/xeno_console = target

	if(!xeno_console.validate_area(owner, remote_eye, remote_eye.loc))
		return

	for(var/mob/living/basic/slime/scanned_slime in remote_eye.loc)
		slime_scan(scanned_slime, owner_mob)

/datum/action/innate/feed_potion
	name = "Apply Potion"
	button_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "slime_potion"

/datum/action/innate/feed_potion/Activate()
	if(!target || !isliving(owner))
		return

	var/mob/living/owner_mob = owner
	var/mob/eye/camera/remote/xenobio/remote_eye = owner_mob.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/xeno_console = target

	if(!xeno_console.validate_area(owner, remote_eye, remote_eye.loc))
		return

	if(QDELETED(xeno_console.current_potion))
		to_chat(owner, span_warning("No potion loaded."))
		return

	for(var/mob/living/basic/slime/potioned_slime in remote_eye.loc)
		xeno_console.spit_atom(xeno_console.current_potion, get_turf(remote_eye))
		xeno_console.current_potion.attack(potioned_slime, owner_mob)
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

//
// Alternate clicks for slime, monkey and open turf if using a xenobio console

/mob/living/basic/slime/ShiftClick(mob/user)
	SEND_SIGNAL(user, COMSIG_XENO_SLIME_CLICK_SHIFT, src)
	..()

/turf/open/ShiftClick(mob/user)
	SEND_SIGNAL(user, COMSIG_XENO_TURF_CLICK_SHIFT, src)
	..()

///Feeds a stored potion to a slime
/obj/machinery/computer/camera_advanced/xenobio/proc/XenoSlimeClickAlt(mob/living/user, mob/living/basic/slime/target_slime)
	SIGNAL_HANDLER

	. = COMSIG_MOB_CANCEL_CLICKON
	if(!isslime(target_slime))
		return

	var/mob/eye/camera/remote/xenobio/remote_eye = user.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/xeno_console = remote_eye.origin_ref.resolve()

	if(!xeno_console.validate_area(user, remote_eye, target_slime.loc))
		return

	if(QDELETED(xeno_console.current_potion))
		to_chat(user, span_warning("No potion loaded."))
		return

	spit_atom(current_potion, get_turf(target_slime))
	INVOKE_ASYNC(xeno_console.current_potion, TYPE_PROC_REF(/obj/item/slimepotion/slime, attack), target_slime, user)
	xeno_hud.update_potion(xeno_console.current_potion)

///Picks up a slime, and places them in the internal storage
/obj/machinery/computer/camera_advanced/xenobio/proc/XenoSlimeClickShift(mob/living/user, mob/living/basic/slime/target_slime)
	SIGNAL_HANDLER

	var/mob/eye/camera/remote/xenobio/remote_eye = user.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/xeno_console = remote_eye.origin_ref.resolve()

	if(!xeno_console.validate_area(user, remote_eye, target_slime.loc))
		return

	xeno_console.slime_pickup(user, target_slime)

///Places all slimes from the internal storage
/obj/machinery/computer/camera_advanced/xenobio/proc/XenoTurfClickShift(mob/living/user, turf/open/target_turf)
	SIGNAL_HANDLER

	var/mob/living/user_mob = user
	var/mob/eye/camera/remote/xenobio/remote_eye = user_mob.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/xeno_console = remote_eye.origin_ref.resolve()

	if(!xeno_console.validate_area(user, remote_eye, target_turf))
		return

	slime_place(target_turf, user)

/obj/machinery/computer/camera_advanced/xenobio/proc/XenoClickCtrl(mob/living/user, atom/target)
	SIGNAL_HANDLER

	if(isopenturf(target))
		XenoTurfClickCtrl(user, target)
	else if(ismonkey(target))
		XenoMonkeyClickCtrl(user, target)
	else if(isslime(target))
		XenoSlimeClickCtrl(user, target)

	return COMSIG_MOB_CANCEL_CLICKON

///Places a monkey from the internal storage
/obj/machinery/computer/camera_advanced/xenobio/proc/XenoTurfClickCtrl(mob/living/user, turf/open/target_turf)
	if(!isopenturf(target_turf))
		return

	var/cleanup = FALSE
	var/mob/eye/camera/remote/xenobio/remote_eye = user.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/xeno_console = remote_eye.origin_ref.resolve()

	if(!xeno_console.validate_area(user, remote_eye, target_turf))
		return

	for(var/mob/monkey in target_turf)
		if(ismonkey(monkey) && monkey.stat == DEAD)
			cleanup = TRUE
			xeno_console.monkey_recycle(user, monkey)

	if(!cleanup)
		xeno_console.feed_slime(user, target_turf)

///Picks up a dead monkey for recycling
/obj/machinery/computer/camera_advanced/xenobio/proc/XenoMonkeyClickCtrl(mob/living/user, mob/living/carbon/human/target_mob)
	if(!ismonkey(target_mob))
		return

	var/mob/eye/camera/remote/xenobio/remote_eye = user.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/xeno_console = remote_eye.origin_ref.resolve()

	if(!xeno_console.connected_recycler)
		to_chat(user, span_warning("There is no connected monkey recycler. Use a multitool to link one."))
		return

	if(!xeno_console.validate_area(user, remote_eye, target_mob.loc))
		return

	xeno_console.monkey_recycle(user, target_mob)

/// Scans the target slime
/obj/machinery/computer/camera_advanced/xenobio/proc/XenoSlimeClickCtrl(mob/living/user, mob/living/basic/slime/target_slime)
	if(!isslime(target_slime))
		return

	var/mob/eye/camera/remote/xenobio/remote_eye = user.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/xeno_console = remote_eye.origin_ref.resolve()

	if(!xeno_console.validate_area(user, remote_eye, target_slime.loc))
		return

	slime_scan(target_slime, user)

/// Sucks the target mob up into the console
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
