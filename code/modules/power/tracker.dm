#define TRACKER_Y_OFFSET 13

//Solar tracker

//Machine that tracks the sun and reports its direction to the solar controllers
//As long as this is working, solar panels on same powernet will track automatically

/obj/machinery/power/tracker
	name = "solar tracker"
	desc = "A solar directional tracker."
	icon = 'icons/obj/solar.dmi'
	icon_state = "tracker_base"
	density = TRUE
	use_power = NO_POWER_USE
	max_integrity = 250
	integrity_failure = 0.2

	var/id = 0
	var/obj/machinery/power/solar_control/control
	var/obj/effect/overlay/tracker_dish
	var/current_azimuth

/obj/machinery/power/tracker/Initialize(mapload, obj/item/solar_assembly/S)
	. = ..()

	tracker_dish = new()
	tracker_dish.vis_flags = VIS_INHERIT_ID | VIS_INHERIT_ICON
	tracker_dish.appearance_flags = TILE_BOUND
	tracker_dish.icon_state = "tracker"
	tracker_dish.layer = FLY_LAYER
	tracker_dish.plane = ABOVE_GAME_PLANE
	tracker_dish.pixel_y = TRACKER_Y_OFFSET
	vis_contents += tracker_dish

	Make(S)
	connect_to_network()
	RegisterSignal(SSsun, COMSIG_SUN_MOVED, .proc/sun_update)

/obj/machinery/power/tracker/Destroy()
	unset_control() //remove from control computer
	return ..()

/obj/machinery/power/tracker/proc/set_control(obj/machinery/power/solar_control/SC)
	unset_control()
	control = SC
	SC.connected_tracker = src

//set the control of the tracker to null and removes it from the previous control computer if needed
/obj/machinery/power/tracker/proc/unset_control()
	if(control)
		if(control.track == SOLAR_TRACK_AUTO)
			control.track = SOLAR_TRACK_OFF
		control.connected_tracker = null
		control = null

/**
 * Get the 2.5D transform for the tracker, given an angle
 * Arguments:
 * * angle - the angle the panel is facing
 */
/obj/machinery/power/tracker/proc/get_tracker_transform(angle)
	// 2.5D solar tracker works by using a magic combination of transforms
	var/matrix/turner = matrix()
	// Rotate towards sun
	turner.Turn(angle)
	// Make it skinny on the floor plane
	turner.Scale(1, 0.5)

	return turner

///Tell the controller to turn the solar panels
/obj/machinery/power/tracker/proc/sun_update(datum/source, azimuth)
	SIGNAL_HANDLER

	var/mid_azimuth = (current_azimuth + azimuth) / 2
	// actually flip to other direction?
	if(abs(azimuth - current_azimuth) > 180)
		mid_azimuth = (mid_azimuth + 180) % 360

	// Split into 2 parts so it doesn't distort on large changes
	animate(tracker_dish, \
		transform = get_tracker_transform(mid_azimuth), \
		time = 2.5 SECONDS, easing = CUBIC_EASING|EASE_IN \
	)
	animate( \
		transform = get_tracker_transform(azimuth), \
		time = 2.5 SECONDS, easing = CUBIC_EASING|EASE_OUT \
	)

	current_azimuth = azimuth

	if(control && control.track == SOLAR_TRACK_AUTO)
		control.set_panels(azimuth)

/obj/machinery/power/tracker/proc/Make(obj/item/solar_assembly/S)
	if(!S)
		S = new /obj/item/solar_assembly(src)
		S.glass_type = /obj/item/stack/sheet/glass
		S.tracker = 1
		S.update_appearance()
		S.set_anchored(TRUE)
	S.forceMove(src)

/obj/machinery/power/tracker/crowbar_act(mob/user, obj/item/I)
	playsound(src.loc, 'sound/machines/click.ogg', 50, TRUE)
	user.visible_message(span_notice("[user] begins to take the glass off [src]."), span_notice("You begin to take the glass off [src]..."))
	if(I.use_tool(src, user, 50))
		playsound(src.loc, 'sound/items/deconstruct.ogg', 50, TRUE)
		user.visible_message(span_notice("[user] takes the glass off [src]."), span_notice("You take the glass off [src]."))
		deconstruct(TRUE)
	return TRUE

/obj/machinery/power/tracker/atom_break(damage_flag)
	. = ..()
	if(.)
		playsound(loc, 'sound/effects/glassbr3.ogg', 100, TRUE)
		unset_control()

/obj/machinery/power/tracker/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(disassembled)
			var/obj/item/solar_assembly/S = locate() in src
			if(S)
				S.forceMove(loc)
				S.give_glass(machine_stat & BROKEN)
		else
			playsound(src, "shatter", 70, TRUE)
			new /obj/item/shard(src.loc)
			new /obj/item/shard(src.loc)
	qdel(src)

// Tracker Electronic

/obj/item/electronics/tracker
	name = "tracker electronics"

#undef TRACKER_Y_OFFSET
