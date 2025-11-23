#define SOLAR_GEN_RATE 2500
#define OCCLUSION_DISTANCE 20
#define PANEL_Z_OFFSET 13
#define PANEL_EDGE_Z_OFFSET (PANEL_Z_OFFSET - 2)

/obj/machinery/power/solar
	name = "solar panel"
	desc = "A solar panel. Generates electricity when in contact with sunlight."
	icon = 'icons/obj/machines/solar.dmi'
	icon_state = "sp_base"
	density = TRUE
	use_power = NO_POWER_USE
	idle_power_usage = 0
	active_power_usage = 0
	max_integrity = 150
	integrity_failure = 0.33


	var/id
	var/obscured = FALSE
	///`[0-1]` measure of obscuration -- multipllier against power generation
	var/sunfrac = 0
	///`[0-360)` degrees, which direction are we facing?
	var/azimuth_current = 0
	var/azimuth_target = 0 //same but what way we're going to face next time we turn
	var/obj/machinery/power/solar_control/control
	///do we need to turn next tick?
	var/needs_to_turn = TRUE
	///do we need to call update_solar_exposure() next tick?
	var/needs_to_update_solar_exposure = TRUE
	var/obj/effect/overlay/panel
	var/obj/effect/overlay/panel_edge

	//used to keep track of what material our panel currently has
	var/datum/material/material_type = /datum/material/glass

	///better glass increases the how much power the solar gives. the power_tier is a multiplier
	var/power_tier = 1

/obj/machinery/power/solar/Initialize(mapload, obj/item/solar_assembly/S)
	. = ..()

	panel_edge = add_panel_overlay("solar_panel_glass_edge", PANEL_EDGE_Z_OFFSET)
	panel = add_panel_overlay("solar_panel_glass", PANEL_Z_OFFSET)

	Make(S)
	connect_to_network()
	RegisterSignal(SSsun, COMSIG_SUN_MOVED, PROC_REF(queue_update_solar_exposure))

/obj/machinery/power/solar/Destroy()
	unset_control() //remove from control computer
	QDEL_NULL(panel)
	QDEL_NULL(panel_edge)
	return ..()

/obj/machinery/power/solar/on_changed_z_level(turf/old_turf, turf/new_turf, same_z_layer, notify_contents)
	. = ..()
	if(same_z_layer)
		return
	SET_PLANE(panel_edge, PLANE_TO_TRUE(panel_edge.plane), new_turf)
	SET_PLANE(panel, PLANE_TO_TRUE(panel.plane), new_turf)

/obj/effect/overlay/solar_panel
	vis_flags = VIS_INHERIT_ID | VIS_INHERIT_ICON
	appearance_flags = TILE_BOUND
	blocks_emissive = EMISSIVE_BLOCK_UNIQUE

/obj/machinery/power/solar/proc/add_panel_overlay(icon_state, z_offset)
	var/obj/effect/overlay/solar_panel/overlay = new(src)
	overlay.icon_state = icon_state
	SET_PLANE_EXPLICIT(overlay, ABOVE_GAME_PLANE, src)
	overlay.pixel_z = z_offset
	vis_contents += overlay
	return overlay

/obj/machinery/power/solar/should_have_node()
	return TRUE

//set the control of the panel to a given computer
/obj/machinery/power/solar/proc/set_control(obj/machinery/power/solar_control/SC)
	unset_control()
	control = SC
	SC.connected_panels += src
	SC.total_capacity += SOLAR_GEN_RATE * power_tier
	queue_turn(SC.azimuth_target)

//set the control of the panel to null and removes it from the control list of the previous control computer if needed
/obj/machinery/power/solar/proc/unset_control()
	if(control)
		control.connected_panels -= src
		control.total_capacity -= SOLAR_GEN_RATE * power_tier
		control = null

/obj/machinery/power/solar/proc/Make(obj/item/solar_assembly/assembly)
	if(!assembly)
		assembly= new /obj/item/solar_assembly(src)
		assembly.glass_type = /obj/item/stack/sheet/glass
		assembly.set_anchored(TRUE)
	else
		assembly.forceMove(src)

/obj/machinery/power/solar/crowbar_act(mob/user, obj/item/I)
	if(I.use_tool(src, user, 0))
		playsound(src.loc, 'sound/items/deconstruct.ogg', 50, TRUE)
		user.visible_message(span_notice("[user] takes the glass off [src]."), span_notice("You take the glass off [src]."))
		deconstruct(TRUE)
	return TRUE

/obj/machinery/power/solar/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(machine_stat & BROKEN)
				playsound(loc, 'sound/effects/hit_on_shattered_glass.ogg', 60, TRUE)
			else
				playsound(loc, 'sound/effects/glass/glasshit.ogg', 90, TRUE)
		if(BURN)
			playsound(loc, 'sound/items/tools/welder.ogg', 100, TRUE)


/obj/machinery/power/solar/atom_break(damage_flag)
	. = ..()
	if(.)
		playsound(loc, 'sound/effects/glass/glassbr3.ogg', 100, TRUE)
		unset_control()
		// Make sure user can see it's broken
		var/new_angle = rand(160, 200)
		visually_turn(new_angle)
		azimuth_current = new_angle

/obj/machinery/power/solar/on_deconstruction(disassembled)
	if(disassembled)
		var/obj/item/solar_assembly/assembly = locate() in src
		if(assembly)
			assembly.forceMove(loc)
			if(machine_stat & BROKEN)
				new material_type.shard_type(get_turf(src))
				new material_type.shard_type(get_turf(src))
			else
				new material_type.sheet_type(get_turf(src))
				new material_type.sheet_type(get_turf(src))
	else
		//When smashed to bits
		playsound(src, SFX_SHATTER, 70, TRUE)

		new material_type.shard_type(get_turf(src))
		new material_type.shard_type(get_turf(src))


/obj/machinery/power/solar/update_overlays()
	. = ..()
	panel.icon_state = "solar_panel_[material_type.name][(machine_stat & BROKEN) ? "-b" : null]"
	panel_edge.icon_state = "solar_panel_[material_type.name][(machine_stat & BROKEN) ? "-b" : "_edge"]"


/obj/machinery/power/solar/proc/queue_turn(azimuth)
	needs_to_turn = TRUE
	azimuth_target = azimuth

/obj/machinery/power/solar/proc/queue_update_solar_exposure()
	SIGNAL_HANDLER

	needs_to_update_solar_exposure = TRUE //updating right away would be wasteful if we're also turning later

/**
 * Get the 2.5D transform for the panel, given an angle
 * Arguments:
 * * angle - the angle the panel is facing
 */
/obj/machinery/power/solar/proc/get_panel_transform(angle)
	// 2.5D solar panel works by using a magic combination of transforms
	var/matrix/turner = matrix()
	// Rotate towards sun
	turner.Turn(angle)
	// "Tilt" the panel in 3D towards East and West
	turner.Shear(0, -0.6 * sin(angle))
	// Make it skinny when facing north (away), fat south
	turner.Scale(1, 0.85 * (cos(angle) * -0.5 + 0.5) + 0.15)

	return turner

/obj/machinery/power/solar/proc/visually_turn_part(part, angle)
	var/mid_azimuth = (azimuth_current + angle) / 2

	// actually flip to other direction?
	if(abs(angle - azimuth_current) > 180)
		mid_azimuth = REVERSE_ANGLE(mid_azimuth)

	// Split into 2 parts so it doesn't distort on large changes
	animate(part,
		transform = get_panel_transform(mid_azimuth),
		time = 2.5 SECONDS, easing = CUBIC_EASING|EASE_IN
	)
	animate(
		transform = get_panel_transform(angle),
		time = 2.5 SECONDS, easing = CUBIC_EASING|EASE_OUT
	)

/obj/machinery/power/solar/proc/visually_turn(angle)
	visually_turn_part(panel, angle)
	visually_turn_part(panel_edge, angle)

/obj/machinery/power/solar/proc/update_turn()
	needs_to_turn = FALSE
	if(azimuth_current != azimuth_target)
		visually_turn(azimuth_target)
		azimuth_current = azimuth_target
		occlusion_setup()
		needs_to_update_solar_exposure = TRUE

///trace towards sun to see if we're in shadow
/obj/machinery/power/solar/proc/occlusion_setup()
	obscured = TRUE

	var/distance = OCCLUSION_DISTANCE
	var/target_x = round(sin(SSsun.azimuth), 0.01)
	var/target_y = round(cos(SSsun.azimuth), 0.01)
	var/x_hit = x
	var/y_hit = y
	var/turf/hit

	for(var/run in 1 to distance)
		x_hit += target_x
		y_hit += target_y
		hit = locate(round(x_hit, 1), round(y_hit, 1), z)
		if(IS_OPAQUE_TURF(hit))
			return
		if(hit.x == 1 || hit.x == world.maxx || hit.y == 1 || hit.y == world.maxy) //edge of the map
			break
	obscured = FALSE

///calculates the fraction of the sunlight that the panel receives
/obj/machinery/power/solar/proc/update_solar_exposure()
	needs_to_update_solar_exposure = FALSE
	sunfrac = 0
	if(obscured)
		return 0

	var/sun_azimuth = SSsun.azimuth
	if(azimuth_current == sun_azimuth) //just a quick optimization for the most frequent case
		. = 1
	else
		//dot product of sun and panel -- Lambert's Cosine Law
		. = cos(azimuth_current - sun_azimuth)
		. = clamp(round(., 0.01), 0, 1)
	sunfrac = .

/obj/machinery/power/solar/process()
	if(machine_stat & BROKEN)
		return
	// space vines block out sunlight
	var/obj/structure/spacevine/vine = locate(/obj/structure/spacevine) in loc
	if(istype(vine) && !(/datum/spacevine_mutation/transparency in vine.mutations))
		unset_control()
		return

	if(control && (!powernet || control.powernet != powernet))
		unset_control()
	if(needs_to_turn)
		update_turn()
	if(needs_to_update_solar_exposure)
		update_solar_exposure()
	if(sunfrac <= 0)
		return

	var/sgen = SOLAR_GEN_RATE * sunfrac * power_tier
	add_avail(power_to_energy(sgen))
	if(control)
		control.gen += sgen

//Bit of a hack but this whole type is a hack
/obj/machinery/power/solar/fake/Initialize(mapload, obj/item/solar_assembly/S)
	. = ..()
	UnregisterSignal(SSsun, COMSIG_SUN_MOVED)

/obj/machinery/power/solar/fake/process()
	return PROCESS_KILL

//
// Solar Assembly - For construction of solar arrays.
//

/obj/item/solar_assembly
	name = "solar panel assembly"
	desc = "A solar panel assembly kit, allows constructions of a solar panel, or with a tracking circuit board, a solar tracker."
	icon = 'icons/obj/machines/solar.dmi'
	icon_state = "sp_base"
	inhand_icon_state = "electropack"
	lefthand_file = 'icons/mob/inhands/items/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY // Pretty big!
	anchored = FALSE
	var/tracker = 0
	var/glass_type = null
	var/random_offset = 6 //amount in pixels an unanchored assembly may be offset by

/obj/item/solar_assembly/Initialize(mapload)
	. = ..()
	if(!anchored && !pixel_x && !pixel_y)
		randomise_offset(random_offset)

/obj/item/solar_assembly/update_icon_state()
	. = ..()
	icon_state = tracker ? "tracker_base" : "sp_base"

/obj/item/solar_assembly/proc/randomise_offset(amount)
	pixel_x = base_pixel_x + rand(-amount, amount)
	pixel_y = base_pixel_y + rand(-amount, amount)

/obj/item/solar_assembly/set_anchored(anchorvalue)
	. = ..()
	if(isnull(.))
		return
	randomise_offset(anchored ? 0 : random_offset)

/obj/item/solar_assembly/attackby(obj/item/item_used, mob/user, list/modifiers, list/attack_modifiers)
	var/turf/solarturf = get_turf(src)

	if(item_used.tool_behaviour == TOOL_WRENCH && isturf(loc))
		if(!solarturf.can_have_cabling()) //allows catwalks
			balloon_alert(user, "can't secure in space!")
			return
		for(var/obj/stuff_in_the_way in solarturf) //prevent anchoring on other machinery or solar assemblies
			if(stuff_in_the_way == src)
				continue
			if(istype(stuff_in_the_way, /obj/item/solar_assembly) && stuff_in_the_way.anchored)
				balloon_alert(user, "secured assembly in the way!")
				return
			if((stuff_in_the_way.density) && !(stuff_in_the_way.flags_1 & ON_BORDER_1))
				balloon_alert(user, "something in the way!")
				return
		set_anchored(!anchored)
		user.visible_message(
			span_notice("[user] [anchored ? null : "un"]wrenches the solar assembly[anchored ? " into place" : null]."),
			span_notice("You [anchored ? null : "un"]wrench the solar assembly[anchored ? " into place" : null]."),
		)
		item_used.play_tool_sound(src, 75)
		return TRUE

	if(tracker)
		if(item_used.tool_behaviour == TOOL_CROWBAR)
			new /obj/item/electronics/tracker(src.loc)
			tracker = FALSE
			update_appearance()
			user.visible_message(span_notice("[user] takes out the electronics from the solar assembly."), span_notice("You take out the electronics from the solar assembly."))
			return TRUE

		//prevent construction if something dense's on our tile
		if(solarturf.is_blocked_turf(exclude_mobs = TRUE, source_atom = src))
			balloon_alert(user, "something in the way!")
			return
		if(!istype(item_used, /obj/item/stack/sheet/glass))
			to_chat(user, span_warning("The tracker only accepts standard, un-reinforced glass."))
			return
		var/obj/item/stack/sheet/my_sheet = item_used
		if(!my_sheet.use(2))
			to_chat(user, span_warning("You don't have enough glass to complete the tracker."))
			return
		playsound(src.loc, 'sound/machines/click.ogg', 50, TRUE)
		user.visible_message(span_notice("[user] places the glass on the solar assembly."),span_notice("You place the glass on the solar assembly."))
		new /obj/machinery/power/tracker/(get_turf(src), src)
		return TRUE

	if(!tracker)
		if(istype(item_used, /obj/item/electronics/tracker))
			if(!user.temporarilyRemoveItemFromInventory(item_used))
				return
			tracker = TRUE
			update_appearance()
			qdel(item_used)
			user.visible_message(span_notice("[user] inserts the electronics into the solar assembly."), span_notice("You insert the electronics into the solar assembly."))
			return TRUE

	//make a list of all the glass
	var/static/list/acceptable_glass_list = typecacheof(list(
		/obj/item/stack/sheet/glass,
		/obj/item/stack/sheet/plasmaglass,
		/obj/item/stack/sheet/titaniumglass,
		/obj/item/stack/sheet/plastitaniumglass,
	))

	if(!acceptable_glass_list[item_used.type])
		//items that arent used above, or arent usable glass will make it here.
		//so we check if its reinfocred glass, or some other item
		if(istype(item_used, /obj/item/stack/sheet/rglass) || istype(item_used, /obj/item/stack/sheet/plasmarglass))
			to_chat(user, span_warning("The solar array will only accept glass or glass alloys that have not been reinforced."))
		//an else statement can be put here if you want something to happen to all the misc items that make it this far
		return

	//prevent construction if something dense's on our tile
	if(solarturf.is_blocked_turf(exclude_mobs = TRUE, source_atom = src))
		balloon_alert(user, "something in the way!")
		return

	if(is_glass_sheet(item_used))
		if(!anchored)
			to_chat(user, span_warning("You need to secure the assembly before you can add glass."))
			return

		var/list/glass_material_to_tier = list(
	    /datum/material/glass = 1,
	    /datum/material/alloy/titaniumglass = 2,
	    /datum/material/alloy/plasmaglass = 3,
	    /datum/material/alloy/plastitaniumglass = 4,
		)

		var/obj/item/stack/sheet/my_sheet = item_used
		if(!my_sheet.use(2))
			to_chat(user, span_warning("You need at least two sheets of glass to complete a solar panel!"))
			return

		var/datum/material/glass_material = my_sheet.material_type
		playsound(src.loc, 'sound/machines/click.ogg', 50, TRUE)
		user.visible_message(span_notice("[user] places the glass on the solar assembly."), span_notice("You place the glass on the solar assembly."))
		var/obj/machinery/power/solar/mySolar = new /obj/machinery/power/solar(get_turf(src), src)
		mySolar.power_tier = glass_material_to_tier[glass_material]
		mySolar.material_type = glass_material
		mySolar.panel.icon_state = "solar_panel_[glass_material.name]"
		mySolar.panel_edge.icon_state = "solar_panel_[glass_material.name]_edge"
		return TRUE
	return ..()

//
// Solar Control Computer
//

/obj/machinery/power/solar_control
	name = "solar panel control"
	desc = "A controller for solar panel arrays."
	icon = 'icons/obj/machines/computer.dmi'
	icon_state = "computer"
	density = TRUE
	use_power = IDLE_POWER_USE
	idle_power_usage = BASE_MACHINE_IDLE_CONSUMPTION
	max_integrity = 200
	integrity_failure = 0.5
	var/icon_screen = "solar"
	var/icon_keyboard = "power_key"
	var/id = 0
	var/gen = 0
	var/lastgen = 0
	var/azimuth_target = 0
	var/azimuth_rate = 1 ///degree change per minute

	var/track = SOLAR_TRACK_OFF ///SOLAR_TRACK_OFF, SOLAR_TRACK_TIMED, SOLAR_TRACK_AUTO

	var/obj/machinery/power/tracker/connected_tracker = null
	var/list/connected_panels = list()

	var/total_capacity //The total amount of power we could generate with all our connected solars

	///History of power supply
	var/list/history = list()
	///Size of history, should be equal or bigger than the solar cycle
	var/record_size = 0
	///Interval between records
	var/record_interval = 60 SECONDS
	///History record timer
	var/next_record = 0

/obj/machinery/power/solar_control/Initialize(mapload)
	. = ..()
	RegisterSignal(SSsun, COMSIG_SUN_MOVED, PROC_REF(timed_track))
	connect_to_network()
	if(powernet)
		set_panels(azimuth_target)
	azimuth_rate = SSsun.base_rotation
	record_interval = SSsun.wait
	history["supply"] = list()
	history["capacity"] = list()

/obj/machinery/power/solar_control/Destroy()
	for(var/obj/machinery/power/solar/M in connected_panels)
		M.unset_control()
	if(connected_tracker)
		connected_tracker.unset_control()
	return ..()

//search for unconnected panels and trackers in the computer powernet and connect them
/obj/machinery/power/solar_control/proc/search_for_connected()
	if(powernet)
		for(var/obj/machinery/power/M in powernet.nodes)
			if(istype(M, /obj/machinery/power/solar))
				// space vines block out sunlight
				var/obj/structure/spacevine/vine = locate(/obj/structure/spacevine) in loc
				if(istype(vine) && !(/datum/spacevine_mutation/transparency in vine.mutations))
					continue

				var/obj/machinery/power/solar/S = M
				if(!S.control) //i.e unconnected
					S.set_control(src)
			else if(istype(M, /obj/machinery/power/tracker))
				if(!connected_tracker) //if there's already a tracker connected to the computer don't add another
					var/obj/machinery/power/tracker/T = M
					if(!T.control) //i.e unconnected
						T.set_control(src)

///Record the generated power supply and capacity for history
/obj/machinery/power/solar_control/proc/record()
	if(record_size == 0)
		record_size = 1 + ROUND_UP(360 / (azimuth_rate * abs(SSsun.azimuth_mod))) //History contains full sun cycle

	if(world.time >= next_record)
		next_record = world.time + record_interval

		var/list/supply = history["supply"]
		if(powernet)
			supply += round(lastgen)
		if(supply.len > record_size)
			supply.Cut(1, 2)

		var/list/capacity = history["capacity"]
		if(powernet)
			capacity += total_capacity
		if(capacity.len > record_size)
			capacity.Cut(1, 2)

/obj/machinery/power/solar_control/update_overlays()
	. = ..()
	if(machine_stat & NOPOWER)
		. += mutable_appearance(icon, "[icon_keyboard]_off")
		return

	. += mutable_appearance(icon, icon_keyboard)
	if(machine_stat & BROKEN)
		. += mutable_appearance(icon, "[icon_state]_broken")
		return
	. += mutable_appearance(icon, icon_screen)

/obj/machinery/power/solar_control/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "SolarControl", name)
		ui.open()

/obj/machinery/power/solar_control/ui_data()
	var/data = list()
	data["supply"] = round(lastgen)
	data["capacity"] = total_capacity
	data["azimuth_current"] = azimuth_target
	data["azimuth_rate"] = azimuth_rate
	data["max_rotation_rate"] = SSsun.base_rotation * 2
	data["tracking_state"] = track
	data["connected_panels"] = connected_panels.len
	data["connected_tracker"] = (connected_tracker ? TRUE : FALSE)
	data["history"] = history
	return data

/obj/machinery/power/solar_control/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	if(action == "azimuth")
		var/adjust = text2num(params["adjust"])
		var/value = text2num(params["value"])
		if(adjust)
			value = azimuth_target + adjust
		if(value != null)
			set_panels(value)
			return TRUE
		return FALSE
	if(action == "azimuth_rate")
		var/adjust = text2num(params["adjust"])
		var/value = text2num(params["value"])
		if(adjust)
			value = azimuth_rate + adjust
		if(value != null)
			azimuth_rate = round(clamp(value, -2 * SSsun.base_rotation, 2 * SSsun.base_rotation), 0.01)
			return TRUE
		return FALSE
	if(action == "tracking")
		var/mode = text2num(params["mode"])
		track = mode
		if(mode == SOLAR_TRACK_AUTO)
			if(connected_tracker)
				connected_tracker.sun_update(SSsun, SSsun.azimuth)
			else
				track = SOLAR_TRACK_OFF
		return TRUE
	if(action == "refresh")
		search_for_connected()
		return TRUE
	return FALSE

/obj/machinery/power/solar_control/attackby(obj/item/I, mob/living/user, list/modifiers, list/attack_modifiers)
	if(I.tool_behaviour == TOOL_SCREWDRIVER)
		if(I.use_tool(src, user, 20, volume=50))
			if (src.machine_stat & BROKEN)
				to_chat(user, span_notice("The broken glass falls out."))
				var/obj/structure/frame/computer/A = new /obj/structure/frame/computer( src.loc )
				new /obj/item/shard( src.loc )
				var/obj/item/circuitboard/computer/solar_control/M = new /obj/item/circuitboard/computer/solar_control( A )
				for (var/obj/C in src)
					C.forceMove(drop_location())
				A.circuit = M
				A.state = 3
				A.icon_state = "3"
				A.set_anchored(TRUE)
				qdel(src)
			else
				to_chat(user, span_notice("You disconnect the monitor."))
				var/obj/structure/frame/computer/A = new /obj/structure/frame/computer( src.loc )
				var/obj/item/circuitboard/computer/solar_control/M = new /obj/item/circuitboard/computer/solar_control( A )
				for (var/obj/C in src)
					C.forceMove(drop_location())
				A.circuit = M
				A.state = 4
				A.icon_state = "4"
				A.set_anchored(TRUE)
				qdel(src)
	else if(!user.combat_mode && !(I.item_flags & NOBLUDGEON))
		attack_hand(user)
	else
		return ..()

/obj/machinery/power/solar_control/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(machine_stat & BROKEN)
				playsound(src.loc, 'sound/effects/hit_on_shattered_glass.ogg', 70, TRUE)
			else
				playsound(src.loc, 'sound/effects/glass/glasshit.ogg', 75, TRUE)
		if(BURN)
			playsound(src.loc, 'sound/items/tools/welder.ogg', 100, TRUE)

/obj/machinery/power/solar_control/atom_break(damage_flag)
	. = ..()
	if(.)
		playsound(loc, 'sound/effects/glass/glassbr3.ogg', 100, TRUE)

/obj/machinery/power/solar_control/process()
	lastgen = gen
	gen = 0
	if(connected_tracker && (!powernet || connected_tracker.powernet != powernet))
		connected_tracker.unset_control()
	record()

///Ran every time the sun updates.
/obj/machinery/power/solar_control/proc/timed_track()
	SIGNAL_HANDLER

	if(track == SOLAR_TRACK_TIMED)
		azimuth_target += azimuth_rate
		set_panels(azimuth_target)

///Rotates the panel to the passed angles
/obj/machinery/power/solar_control/proc/set_panels(azimuth)
	azimuth = clamp(round(azimuth, 0.01), -360, 719.99)
	if(azimuth >= 360)
		azimuth -= 360
	if(azimuth < 0)
		azimuth += 360
	azimuth_target = azimuth

	for(var/obj/machinery/power/solar/S in connected_panels)
		S.queue_turn(azimuth)

//
// MISC
//

/obj/item/paper/guides/jobs/engi/solars
	name = "paper- 'Going green! Setup your own solar array instructions.'"
	default_raw_text = "<h1>Welcome</h1><p>At greencorps we love the environment, and space. With this package you are able to help mother nature and produce energy without any usage of fossil fuel or plasma! Singularity energy is dangerous while solar energy is safe, which is why it's better. Now here is how you setup your own solar array.</p><p>You can make a solar panel by wrenching the solar assembly onto a cable node. Adding a glass panel, any non reinforced glass will do, will finish the construction of your solar panel. It is that easy!</p><p>Now after setting up 19 more of these solar panels you will want to create a solar tracker to keep track of our mother nature's gift, the sun. These are the same steps as before except you insert the tracker equipment circuit into the assembly before performing the final step of adding the glass. You now have a tracker! Now the last step is to add a computer to calculate the sun's movements and to send commands to the solar panels to change direction with the sun. Setting up the solar computer is the same as setting up any computer, so you should have no trouble in doing that. You do need to put a wire node under the computer, and the wire needs to be connected to the tracker.</p><p>Congratulations, you should have a working solar array. If you are having trouble, here are some tips. Make sure all solar equipment are on a cable node, even the computer. You can always deconstruct your creations if you make a mistake.</p><p>That's all to it, be safe, be green!</p>"

#undef SOLAR_GEN_RATE
#undef OCCLUSION_DISTANCE
#undef PANEL_Z_OFFSET
#undef PANEL_EDGE_Z_OFFSET
