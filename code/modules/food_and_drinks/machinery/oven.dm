#define OVEN_SMOKE_STATE_NONE 0
#define OVEN_SMOKE_STATE_GOOD 1
#define OVEN_SMOKE_STATE_NEUTRAL 2
#define OVEN_SMOKE_STATE_BAD 3

#define OVEN_LID_Y_OFFSET -15

#define OVEN_TRAY_Y_OFFSET -16
#define OVEN_TRAY_X_OFFSET -2

/obj/machinery/oven
	name = "oven"
	desc = "Why do they call it oven when you of in the cold food of out hot eat the food?"
	icon = 'icons/obj/machines/kitchenmachines.dmi'
	icon_state = "oven_off"
	density = TRUE
	pass_flags_self = PASSMACHINE | LETPASSTHROW
	layer = BELOW_OBJ_LAYER
	circuit = /obj/item/circuitboard/machine/oven
	processing_flags = START_PROCESSING_MANUALLY
	resistance_flags = FIRE_PROOF

	///The tray inside of this oven, if there is one.
	var/obj/item/plate/oven_tray/used_tray
	///Whether or not the oven is open.
	var/open = FALSE
	///Looping sound for the oven
	var/datum/looping_sound/oven/oven_loop
	///Current state of smoke coming from the oven
	var/smoke_state = OVEN_SMOKE_STATE_NONE

/obj/machinery/oven/Initialize(mapload)
	. = ..()
	oven_loop = new(src)
	add_tray_to_oven(new /obj/item/plate/oven_tray(src)) //Start with a tray

/obj/machinery/oven/Destroy()
	QDEL_NULL(oven_loop)
	QDEL_NULL(particles)
	. = ..()

/obj/machinery/oven/update_icon_state()
	if(!open && used_tray?.contents.len)
		icon_state = "oven_on"
	else
		icon_state = "oven_off"
	return ..()

/obj/machinery/oven/update_overlays()
	. = ..()
	if(open)
		var/mutable_appearance/door_overlay = mutable_appearance(icon, "oven_lid_open")
		door_overlay.pixel_y = OVEN_LID_Y_OFFSET
		. += door_overlay
	else
		. += mutable_appearance(icon, "oven_lid_closed")
		if(used_tray?.contents.len)
			. += emissive_appearance(icon, "oven_light_mask", src, alpha = src.alpha)

/obj/machinery/oven/process(delta_time)
	..()
	if(!used_tray) //Are we actually working?
		set_smoke_state(OVEN_SMOKE_STATE_NONE)
		return
	///We take the worst smoke state, so if something is burning we always know.
	var/worst_cooked_food_state = 0
	for(var/obj/item/baked_item in used_tray.contents)

		var/signal_result = SEND_SIGNAL(baked_item, COMSIG_ITEM_OVEN_PROCESS, src, delta_time)

		if(signal_result & COMPONENT_HANDLED_BAKING) //This means something responded to us baking!
			if(signal_result & COMPONENT_BAKING_GOOD_RESULT && worst_cooked_food_state < OVEN_SMOKE_STATE_GOOD)
				worst_cooked_food_state = OVEN_SMOKE_STATE_GOOD
			else if(signal_result & COMPONENT_BAKING_BAD_RESULT && worst_cooked_food_state < OVEN_SMOKE_STATE_NEUTRAL)
				worst_cooked_food_state = OVEN_SMOKE_STATE_NEUTRAL
			continue

		worst_cooked_food_state = OVEN_SMOKE_STATE_BAD
		baked_item.fire_act(1000) //Hot hot hot!

		if(DT_PROB(10, delta_time))
			visible_message(span_danger("You smell a burnt smell coming from [src]!"))
	set_smoke_state(worst_cooked_food_state)
	update_appearance()
	use_power(active_power_usage)


/obj/machinery/oven/attackby(obj/item/I, mob/user, params)
	if(open && !used_tray && istype(I, /obj/item/plate/oven_tray))
		if(user.transferItemToLoc(I, src, silent = FALSE))
			to_chat(user, span_notice("You put [I] in [src]."))
			add_tray_to_oven(I, user)
	else
		return ..()

///Adds a tray to the oven, making sure the shit can get baked.
/obj/machinery/oven/proc/add_tray_to_oven(obj/item/plate/oven_tray, mob/baker)
	used_tray = oven_tray

	if(!open)
		oven_tray.vis_flags |= VIS_HIDE
	vis_contents += oven_tray
	oven_tray.flags_1 |= IS_ONTOP_1
	oven_tray.vis_flags |= VIS_INHERIT_PLANE
	oven_tray.pixel_y = OVEN_TRAY_Y_OFFSET
	oven_tray.pixel_x = OVEN_TRAY_X_OFFSET

	RegisterSignal(used_tray, COMSIG_MOVABLE_MOVED, PROC_REF(on_tray_moved))
	update_baking_audio()
	update_appearance()

///Called when the tray is moved out of the oven in some way
/obj/machinery/oven/proc/on_tray_moved(obj/item/oven_tray, atom/OldLoc, Dir, Forced)
	SIGNAL_HANDLER

	tray_removed_from_oven(oven_tray)

/obj/machinery/oven/proc/tray_removed_from_oven(obj/item/oven_tray)
	SIGNAL_HANDLER
	oven_tray.flags_1 &= ~IS_ONTOP_1
	oven_tray.vis_flags &= ~VIS_INHERIT_PLANE
	vis_contents -= oven_tray
	used_tray = null
	UnregisterSignal(oven_tray, COMSIG_MOVABLE_MOVED)
	update_baking_audio()

/obj/machinery/oven/attack_hand(mob/user, modifiers)
	. = ..()
	open = !open
	if(open)
		playsound(src, 'sound/machines/oven/oven_open.ogg', 75, TRUE)
		set_smoke_state(OVEN_SMOKE_STATE_NONE)
		to_chat(user, span_notice("You open [src]."))
		end_processing()
		if(used_tray)
			used_tray.vis_flags &= ~VIS_HIDE
	else
		playsound(src, 'sound/machines/oven/oven_close.ogg', 75, TRUE)
		to_chat(user, span_notice("You close [src]."))
		if(used_tray)
			begin_processing()
			used_tray.vis_flags |= VIS_HIDE

			// yeah yeah i figure you don't need connect loc for just baking trays
			for(var/obj/item/baked_item in used_tray.contents)
				SEND_SIGNAL(baked_item, COMSIG_ITEM_OVEN_PLACED_IN, src, user)

	update_appearance()
	update_baking_audio()
	return TRUE

/obj/machinery/oven/proc/update_baking_audio()
	if(!oven_loop)
		return
	if(!open && used_tray?.contents.len)
		oven_loop.start()
	else
		oven_loop.stop()

///Updates the smoke state to something else, setting particles if relevant
/obj/machinery/oven/proc/set_smoke_state(new_state)
	if(new_state == smoke_state)
		return
	smoke_state = new_state

	QDEL_NULL(particles)
	switch(smoke_state)
		if(OVEN_SMOKE_STATE_BAD)
			particles = new /particles/smoke()
		if(OVEN_SMOKE_STATE_NEUTRAL)
			particles = new /particles/smoke/steam()
		if(OVEN_SMOKE_STATE_GOOD)
			particles = new /particles/smoke/steam/mild

/obj/machinery/oven/crowbar_act(mob/living/user, obj/item/tool)
	return default_deconstruction_crowbar(tool, ignore_panel = TRUE)

/obj/machinery/oven/wrench_act(mob/living/user, obj/item/tool)
	default_unfasten_wrench(user, tool, time = 2 SECONDS)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/item/plate/oven_tray
	name = "oven tray"
	desc = "Time to bake cookies!"
	icon_state = "oven_tray"
	max_items = 6

#undef OVEN_SMOKE_STATE_NONE
#undef OVEN_SMOKE_STATE_GOOD
#undef OVEN_SMOKE_STATE_NEUTRAL
#undef OVEN_SMOKE_STATE_BAD

#undef OVEN_LID_Y_OFFSET

#undef OVEN_TRAY_Y_OFFSET
#undef OVEN_TRAY_X_OFFSET
