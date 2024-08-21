//Xenobio control console
/mob/camera/ai_eye/remote/xenobio
	visible_icon = TRUE
	icon = 'icons/mob/silicon/cameramob.dmi'
	icon_state = "generic_camera"
	var/allowed_area = null

/mob/camera/ai_eye/remote/xenobio/Initialize(mapload)
	var/area/our_area = get_area(loc)
	allowed_area = our_area.name
	. = ..()

/mob/camera/ai_eye/remote/xenobio/setLoc(turf/destination, force_update = FALSE)
	var/area/new_area = get_area(destination)

	if(new_area && new_area.name == allowed_area || new_area && (new_area.area_flags & XENOBIOLOGY_COMPATIBLE))
		return ..()

/mob/camera/ai_eye/remote/xenobio/can_z_move(direction, turf/start, turf/destination, z_move_flags = NONE, mob/living/rider)
	. = ..()
	if(!.)
		return
	var/area/new_area = get_area(.)
	if(new_area.name != allowed_area && !(new_area.area_flags & XENOBIOLOGY_COMPATIBLE))
		return FALSE

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
	return ..()

/obj/machinery/computer/camera_advanced/xenobio/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone == current_potion)
		current_potion = null
	if(gone in stored_slimes)
		stored_slimes -= gone

/obj/machinery/computer/camera_advanced/xenobio/CreateEye()
	eyeobj = new /mob/camera/ai_eye/remote/xenobio(get_turf(src))
	eyeobj.origin = src
	eyeobj.visible_icon = TRUE
	eyeobj.icon = 'icons/mob/silicon/cameramob.dmi'
	eyeobj.icon_state = "generic_camera"

/obj/machinery/computer/camera_advanced/xenobio/GrantActions(mob/living/user)
	. = ..()
	RegisterSignal(user, COMSIG_MOB_CTRL_CLICKED, PROC_REF(XenoClickCtrl))
	RegisterSignal(user, COMSIG_MOB_ALTCLICKON, PROC_REF(XenoSlimeClickAlt))
	RegisterSignal(user, COMSIG_XENO_SLIME_CLICK_SHIFT, PROC_REF(XenoSlimeClickShift))
	RegisterSignal(user, COMSIG_XENO_TURF_CLICK_SHIFT, PROC_REF(XenoTurfClickShift))

/obj/machinery/computer/camera_advanced/xenobio/remove_eye_control(mob/living/user)
	UnregisterSignal(user, list(
		COMSIG_MOB_CTRL_CLICKED,
		COMSIG_MOB_ALTCLICKON,
		COMSIG_XENO_SLIME_CLICK_SHIFT,
		COMSIG_XENO_TURF_CLICK_SHIFT,
	))
	return ..()

/obj/machinery/computer/camera_advanced/xenobio/attackby(obj/item/used_item, mob/user, params)
	if(istype(used_item, /obj/item/food/monkeycube))
		monkeys++
		to_chat(user, span_notice("You feed [used_item] to [src]. It now has [monkeys] monkey cubes stored."))
		qdel(used_item)
		return

	if(istype(used_item, /obj/item/storage/bag))
		var/obj/item/storage/storage_bag = used_item
		var/loaded = FALSE
		for(var/obj/item_in_bag in storage_bag.contents)
			if(istype(item_in_bag, /obj/item/food/monkeycube))
				loaded = TRUE
				monkeys++
				qdel(item_in_bag)
		if(loaded)
			to_chat(user, span_notice("You fill [src] with the monkey cubes stored in [used_item]. [src] now has [monkeys] monkey cubes stored."))
		return

	if(istype(used_item, /obj/item/slimepotion/slime))
		var/replaced = FALSE
		if(user && !user.transferItemToLoc(used_item, src))
			return
		if(!QDELETED(current_potion))
			current_potion.forceMove(drop_location())
			replaced = TRUE
		current_potion = used_item
		to_chat(user, span_notice("You load [used_item] in the console's potion slot[replaced ? ", replacing the one that was there before" : ""]."))
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
/obj/machinery/computer/camera_advanced/xenobio/proc/validate_area(mob/living/user, mob/camera/ai_eye/remote/xenobio/remote_eye, turf/open/target_turf)
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
	for(var/mob/living/basic/slime/stored_slime in stored_slimes)
		stored_slime.forceMove(target_turf)
		stored_slime.visible_message(span_notice("[stored_slime] warps in!"))
		stored_slimes -= stored_slime

///Places every slime not controlled by a player into the internal storage, respecting its limits
///Returns TRUE to signal it hitting the limit, in case its being called from a loop and we want it to stop
/obj/machinery/computer/camera_advanced/xenobio/proc/slime_pickup(mob/living/user, mob/living/basic/slime/target_slime)
	if(stored_slimes.len >= max_slimes)
		to_chat(user, span_warning("Slime storage is full."))
		return TRUE
	if(target_slime.ckey)
		to_chat(user, span_warning("The slime wiggled free!"))
		return FALSE
	if(target_slime.buckled)
		target_slime.stop_feeding(silent = TRUE)
	target_slime.visible_message(span_notice("[target_slime] vanishes in a flash of light!"))
	target_slime.forceMove(src)
	stored_slimes += target_slime

	return FALSE

///Places one monkey, if possible
/obj/machinery/computer/camera_advanced/xenobio/proc/feed_slime(mob/living/user, turf/open/target_turf)
	if(monkeys < 1)
		to_chat(user, span_warning("[src] needs to have at least 1 monkey stored. Currently has [monkeys] monkeys stored."))
		return

	var/mob/living/carbon/human/species/monkey/food = new /mob/living/carbon/human/species/monkey(target_turf, TRUE, user)
	if (QDELETED(food))
		return

	food.apply_status_effect(/datum/status_effect/slime_food, user)

	monkeys--
	monkeys = round(monkeys, 0.1) //Prevents rounding errors
	to_chat(user, span_notice("[src] now has [monkeys] monkeys stored."))

///Recycles the target monkey
/obj/machinery/computer/camera_advanced/xenobio/proc/monkey_recycle(mob/living/user, mob/living/target_mob)
	if(!ismonkey(target_mob))
		return
	if(!target_mob.stat)
		return

	target_mob.visible_message(span_notice("[target_mob] vanishes as [p_theyre()] reclaimed for recycling!"))
	connected_recycler.use_energy(500 JOULES)
	monkeys += connected_recycler.cube_production
	monkeys = round(monkeys, 0.1) //Prevents rounding errors
	qdel(target_mob)
	to_chat(user, span_notice("[src] now has [monkeys] monkeys stored."))

/datum/action/innate/slime_place
	name = "Place Slimes"
	button_icon = 'icons/mob/actions/actions_silicon.dmi'
	button_icon_state = "slime_down"

/datum/action/innate/slime_place/Activate()
	if(!target || !isliving(owner))
		return
	var/mob/living/owner_mob = owner
	var/mob/camera/ai_eye/remote/xenobio/remote_eye = owner_mob.remote_control
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
	var/mob/camera/ai_eye/remote/xenobio/remote_eye = owner_mob.remote_control
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
	var/mob/camera/ai_eye/remote/xenobio/remote_eye = living_owner.remote_control
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
	var/mob/camera/ai_eye/remote/xenobio/remote_eye = owner_mob.remote_control
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
	var/mob/camera/ai_eye/remote/xenobio/remote_eye = owner_mob.remote_control
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
	var/mob/camera/ai_eye/remote/xenobio/remote_eye = owner_mob.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/xeno_console = target

	if(!xeno_console.validate_area(owner, remote_eye, remote_eye.loc))
		return

	if(QDELETED(xeno_console.current_potion))
		to_chat(owner, span_warning("No potion loaded."))
		return

	for(var/mob/living/basic/slime/potioned_slime in remote_eye.loc)
		xeno_console.current_potion.attack(potioned_slime, owner_mob)
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

	to_chat(owner, examine_block(jointext(render_list, "\n")))

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

	var/mob/camera/ai_eye/remote/xenobio/remote_eye = user.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/xeno_console = remote_eye.origin

	if(!xeno_console.validate_area(user, remote_eye, target_slime.loc))
		return

	if(QDELETED(xeno_console.current_potion))
		to_chat(user, span_warning("No potion loaded."))
		return

	INVOKE_ASYNC(xeno_console.current_potion, TYPE_PROC_REF(/obj/item/slimepotion/slime, attack), target_slime, user)

///Picks up a slime, and places them in the internal storage
/obj/machinery/computer/camera_advanced/xenobio/proc/XenoSlimeClickShift(mob/living/user, mob/living/basic/slime/target_slime)
	SIGNAL_HANDLER

	var/mob/camera/ai_eye/remote/xenobio/remote_eye = user.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/xeno_console = remote_eye.origin

	if(!xeno_console.validate_area(user, remote_eye, target_slime.loc))
		return

	xeno_console.slime_pickup(user, target_slime)

///Places all slimes from the internal storage
/obj/machinery/computer/camera_advanced/xenobio/proc/XenoTurfClickShift(mob/living/user, turf/open/target_turf)
	SIGNAL_HANDLER

	var/mob/living/user_mob = user
	var/mob/camera/ai_eye/remote/xenobio/remote_eye = user_mob.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/xeno_console = remote_eye.origin

	if(!xeno_console.validate_area(user, remote_eye, target_turf))
		return

	slime_place(target_turf)

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
	var/mob/camera/ai_eye/remote/xenobio/remote_eye = user.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/xeno_console = remote_eye.origin

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

	var/mob/camera/ai_eye/remote/xenobio/remote_eye = user.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/xeno_console = remote_eye.origin

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

	var/mob/camera/ai_eye/remote/xenobio/remote_eye = user.remote_control
	var/obj/machinery/computer/camera_advanced/xenobio/xeno_console = remote_eye.origin

	if(!xeno_console.validate_area(user, remote_eye, target_slime.loc))
		return

	slime_scan(target_slime, user)
