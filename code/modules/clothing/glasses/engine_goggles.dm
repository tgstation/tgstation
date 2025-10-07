//Engineering Mesons

#define MODE_NONE ""
#define MODE_MESON "meson"
#define MODE_TRAY "t-ray"
#define MODE_SHUTTLE "shuttle"
#define MODE_PIPE_CONNECTABLE "connectable"
#define MODE_ATMOS_THERMAL "atmospheric-thermal"
#define MODE_AREA_BLUEPRINTS "area-blueprints"
#define TEMP_SHADE_CYAN 273.15
#define TEMP_SHADE_GREEN 283.15
#define TEMP_SHADE_YELLOW 300
#define TEMP_SHADE_RED 500

/obj/item/clothing/glasses/meson/engine
	name = "engineering scanner goggles"
	desc = "Goggles used by engineers. The Meson Scanner mode lets you see basic structural and terrain layouts through walls and the T-ray Scanner mode lets you see underfloor objects such as cables and pipes."
	icon_state = "trayson-meson"
	inhand_icon_state = "trayson-meson"
	actions_types = list(/datum/action/item_action/toggle_mode)
	glass_colour_type = /datum/client_colour/glass_colour/gray
	gender = PLURAL
	vision_flags = NONE
	color_cutoffs = null
	/// List of selectable modes that can be used by the goggles
	var/list/modes = list(MODE_NONE, MODE_MESON, MODE_TRAY)
	/// The current mode string that is selected from the modes list (used for icons)
	var/mode = MODE_NONE
	/// The current mode index that is selected from the modes list
	var/mode_index = 1
	/// The distance for how far we can see special objects (only used for pipes and wires)
	var/range = 1
	/// A cache of tracked pipes used in MODE_PIPE_CONNECTABLE
	var/list/connection_images = list()

/obj/item/clothing/glasses/meson/engine/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)
	START_PROCESSING(SSobj, src)
	update_appearance()

/obj/item/clothing/glasses/meson/engine/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/clothing/glasses/meson/engine/proc/toggle_mode(mob/user, voluntary)
	mode_index = WRAP_UP(mode_index, modes.len)
	mode = modes[mode_index]
	to_chat(user, "<span class='[voluntary ? "notice":"warning"]'>[voluntary ? "You turn the goggles":"The goggles turn"] [mode ? "to [mode] mode":"off"][voluntary ? ".":"!"]</span>")
	if(connection_images.len)
		connection_images.Cut()
	switch(mode)
		if(MODE_MESON)
			vision_flags = SEE_TURFS
			color_cutoffs = list(15, 12, 0)
			change_glass_color(/datum/client_colour/glass_colour/yellow)

		if(MODE_TRAY) //undoes the last mode, meson
			vision_flags = NONE
			color_cutoffs = null
			change_glass_color(/datum/client_colour/glass_colour/lightblue)

		if(MODE_PIPE_CONNECTABLE)
			change_glass_color(/datum/client_colour/glass_colour/lightblue)

		if(MODE_SHUTTLE)
			change_glass_color(/datum/client_colour/glass_colour/red)

		if(MODE_AREA_BLUEPRINTS)
			change_glass_color(/datum/client_colour/glass_colour/lightyellow)

		if(MODE_NONE)
			change_glass_color(initial(glass_colour_type))

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.glasses == src)
			H.update_sight()

	update_appearance()
	update_item_action_buttons()

/obj/item/clothing/glasses/meson/engine/attack_self(mob/user)
	toggle_mode(user, TRUE)

/obj/item/clothing/glasses/meson/engine/process()
	if(!ishuman(loc))
		return
	var/mob/living/carbon/human/user = loc
	if(user.glasses != src || !user.client)
		return
	switch(mode)
		if(MODE_TRAY)
			t_ray_scan(user, 8, range)
		if(MODE_SHUTTLE)
			show_shuttle()
		if(MODE_PIPE_CONNECTABLE)
			show_connections()
		if(MODE_ATMOS_THERMAL)
			atmos_thermal(user)
		if(MODE_AREA_BLUEPRINTS)
			show_blueprints(user)

/obj/item/clothing/glasses/meson/engine/proc/show_shuttle()
	var/mob/living/carbon/human/user = loc
	var/obj/docking_port/mobile/port = SSshuttle.get_containing_shuttle(user)
	if(!port)
		return
	var/list/shuttle_areas = port.shuttle_areas
	for(var/area/region as anything in shuttle_areas)
		for (var/list/zlevel_turfs as anything in region.get_zlevel_turf_lists())
			for (var/turf/place as anything in zlevel_turfs)
				if(get_dist(user, place) > 7)
					continue
				var/image/pic
				if(isshuttleturf(place))
					pic = new('icons/turf/overlays.dmi', place, "greenOverlay", AREA_LAYER)
				else
					pic = new('icons/turf/overlays.dmi', place, "redOverlay", AREA_LAYER)
				flick_overlay_global(pic, list(user.client), 8)

/obj/item/clothing/glasses/meson/engine/proc/show_connections()
	var/mob/living/carbon/human/user = loc

	for(var/obj/machinery/atmospherics/pipe/smart/smart in connection_images)
		if(get_dist(loc, smart.loc) > range)
			connection_images -= smart

	for(var/obj/machinery/atmospherics/pipe/smart/smart in orange(range, user))
		if(!connection_images[smart])
			connection_images[smart] = list()
		for(var/direction in GLOB.cardinals)
			if(!(smart.get_init_directions() & direction))
				continue
			if(!connection_images[smart][dir2text(direction)])
				var/image/arrow
				arrow = new('icons/obj/pipes_n_cables/simple.dmi', get_turf(smart), "connection_overlay")
				arrow.dir = direction
				arrow.layer = smart.layer
				arrow.color = smart.pipe_color
				PIPING_LAYER_DOUBLE_SHIFT(arrow, smart.piping_layer)
				connection_images[smart][dir2text(direction)] = arrow
			if(connection_images.len)
				flick_overlay_global(connection_images[smart][dir2text(direction)], list(user.client), 1.5 SECONDS)

/obj/item/clothing/glasses/meson/engine/update_icon_state()
	icon_state = inhand_icon_state = "trayson-[mode]"
	return ..()

/obj/item/clothing/glasses/meson/engine/tray //atmos techs have lived far too long without tray goggles while those damned engineers get their dual-purpose gogles all to themselves
	name = "optical t-ray scanner"
	icon_state = "trayson-t-ray"
	inhand_icon_state = "trayson-t-ray"
	desc = "Used by engineering staff to see underfloor objects such as cables and pipes."
	range = 2
	modes = list(MODE_NONE, MODE_TRAY, MODE_PIPE_CONNECTABLE, MODE_ATMOS_THERMAL) // atmos techs now finally have 3 modes on their  goggles!

/obj/item/clothing/glasses/meson/engine/tray/dropped(mob/user)
	. = ..()
	if(connection_images.len)
		connection_images.Cut()

/obj/item/clothing/glasses/meson/engine/shuttle
	name = "shuttle region scanner"
	icon_state = "trayson-shuttle"
	inhand_icon_state = "trayson-shuttle"
	desc = "Used to see the boundaries of shuttle regions."
	modes = list(MODE_NONE, MODE_SHUTTLE)


/obj/item/clothing/glasses/meson/engine/atmos_imaging
	name = "atmospheric thermal imaging goggles"
	desc = "Goggles used by Atmospheric Technicians to see the thermal energy of gasses in open areas."
	icon_state = "trayson-atmospheric-thermal"
	inhand_icon_state = "trayson-meson"
	glass_colour_type = /datum/client_colour/glass_colour/gray
	modes = list(MODE_NONE, MODE_ATMOS_THERMAL)

/obj/item/clothing/glasses/meson/engine/atmos_imaging/update_icon_state()
	icon_state = inhand_icon_state = "trayson-[mode]"
	return ..()

/obj/item/clothing/glasses/meson/engine/admin
	name = "admin imaging goggles"
	desc = "Used by Nanotrasen admins to detect blueprint areas, pipes, thermal, wiring, and pipes."
	range = 7
	modes = list(MODE_NONE, MODE_TRAY, MODE_PIPE_CONNECTABLE, MODE_ATMOS_THERMAL, MODE_AREA_BLUEPRINTS)

/proc/show_blueprints(mob/viewer, range = 7, duration = 10)
	if(!ismob(viewer) || !viewer.client)
		return
	for(var/turf/viewable_turf in view(range, viewer))
		var/area/selected_area = get_area(viewable_turf)
		var/obj/area_overlay = image(selected_area.icon, viewable_turf, initial(selected_area.icon_state), TOPDOWN_ABOVE_WATER_LAYER)
		SET_PLANE_EXPLICIT(area_overlay, ABOVE_GAME_PLANE, viewable_turf)
		area_overlay.appearance_flags = APPEARANCE_UI_IGNORE_ALPHA
		area_overlay.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
		area_overlay.alpha = 255
		flick_overlay_global(area_overlay, list(viewer.client), duration)

/proc/atmos_thermal(mob/viewer, range = 5, duration = 10)
	if(!ismob(viewer) || !viewer.client)
		return
	for(var/turf/open in view(range, viewer))
		if(open.blocks_air)
			continue
		var/datum/gas_mixture/environment = open.return_air()
		var/temp = round(environment.return_temperature())
		var/image/turf_overlay = image('icons/turf/overlays.dmi', open, "greyOverlay", ABOVE_OPEN_TURF_LAYER)
		// Lower than TEMP_SHADE_CYAN should be deep blue
		switch(temp)
			if(-INFINITY to TEMP_SHADE_CYAN)
				turf_overlay.color = COLOR_STRONG_BLUE
			// Between TEMP_SHADE_CYAN and TEMP_SHADE_GREEN
			if(TEMP_SHADE_CYAN to TEMP_SHADE_GREEN)
				turf_overlay.color = BlendRGB(COLOR_DARK_CYAN, COLOR_LIME, max(round((temp - TEMP_SHADE_CYAN)/(TEMP_SHADE_GREEN - TEMP_SHADE_CYAN), 0.01), 0))
			// Between TEMP_SHADE_GREEN and TEMP_SHADE_YELLOW
			if(TEMP_SHADE_GREEN to TEMP_SHADE_YELLOW)
				turf_overlay.color = BlendRGB(COLOR_LIME, COLOR_YELLOW, clamp(round((temp-TEMP_SHADE_GREEN)/(TEMP_SHADE_YELLOW - TEMP_SHADE_GREEN), 0.01), 0, 1))
			// Between TEMP_SHADE_YELLOW and TEMP_SHADE_RED
			if(TEMP_SHADE_YELLOW to TEMP_SHADE_RED)
				turf_overlay.color = BlendRGB(COLOR_YELLOW, COLOR_RED, clamp(round((temp-TEMP_SHADE_YELLOW)/(TEMP_SHADE_RED - TEMP_SHADE_YELLOW), 0.01), 0, 1))
			// Over TEMP_SHADE_RED should be red
			if(TEMP_SHADE_RED to INFINITY)
				turf_overlay.color = COLOR_RED
		turf_overlay.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
		turf_overlay.alpha = 200
		flick_overlay_global(turf_overlay, list(viewer.client), duration)


#undef MODE_NONE
#undef MODE_MESON
#undef MODE_TRAY
#undef MODE_SHUTTLE
#undef MODE_PIPE_CONNECTABLE
#undef MODE_ATMOS_THERMAL
#undef MODE_AREA_BLUEPRINTS
#undef TEMP_SHADE_CYAN
#undef TEMP_SHADE_GREEN
#undef TEMP_SHADE_YELLOW
#undef TEMP_SHADE_RED
