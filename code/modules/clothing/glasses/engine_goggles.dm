//Engineering Mesons

#define MODE_NONE ""
#define MODE_MESON "meson"
#define MODE_TRAY "t-ray"
#define MODE_SHUTTLE "shuttle"
#define MODE_PIPE_CONNECTABLE "connectable"
#define MODE_ATMOS_THERMAL "atmospheric-thermal"
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
	darkness_view = 2
	lighting_alpha = null

	var/list/modes = list(MODE_NONE = MODE_MESON, MODE_MESON = MODE_TRAY, MODE_TRAY = MODE_NONE)
	var/mode = MODE_NONE
	var/range = 1
	var/list/connection_images = list()

/obj/item/clothing/glasses/meson/engine/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob, ITEM_SLOT_EYES)
	START_PROCESSING(SSobj, src)
	update_appearance()

/obj/item/clothing/glasses/meson/engine/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/clothing/glasses/meson/engine/proc/toggle_mode(mob/user, voluntary)
	mode = modes[mode]
	to_chat(user, "<span class='[voluntary ? "notice":"warning"]'>[voluntary ? "You turn the goggles":"The goggles turn"] [mode ? "to [mode] mode":"off"][voluntary ? ".":"!"]</span>")
	if(connection_images.len)
		connection_images.Cut()
	switch(mode)
		if(MODE_MESON)
			vision_flags = SEE_TURFS
			darkness_view = 1
			lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
			change_glass_color(user, /datum/client_colour/glass_colour/yellow)

		if(MODE_TRAY) //undoes the last mode, meson
			vision_flags = NONE
			darkness_view = 2
			lighting_alpha = null
			change_glass_color(user, /datum/client_colour/glass_colour/lightblue)

		if(MODE_PIPE_CONNECTABLE)
			change_glass_color(user, /datum/client_colour/glass_colour/lightblue)

		if(MODE_SHUTTLE)
			change_glass_color(user, /datum/client_colour/glass_colour/red)

		if(MODE_NONE)
			change_glass_color(user, initial(glass_colour_type))

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

/obj/item/clothing/glasses/meson/engine/proc/show_shuttle()
	var/mob/living/carbon/human/user = loc
	var/obj/docking_port/mobile/port = SSshuttle.get_containing_shuttle(user)
	if(!port)
		return
	var/list/shuttle_areas = port.shuttle_areas
	for(var/area/region as anything in shuttle_areas)
		for(var/turf/place as anything in region.get_contained_turfs())
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
				arrow = new('icons/obj/atmospherics/pipes/simple.dmi', get_turf(smart), "connection_overlay")
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


	modes = list(MODE_NONE = MODE_TRAY, MODE_TRAY = MODE_PIPE_CONNECTABLE, MODE_PIPE_CONNECTABLE = MODE_ATMOS_THERMAL, MODE_ATMOS_THERMAL = MODE_NONE) // atmos techs now finally have 3 modes on their  goggles!

/obj/item/clothing/glasses/meson/engine/tray/dropped(mob/user)
	. = ..()
	if(connection_images.len)
		connection_images.Cut()

/obj/item/clothing/glasses/meson/engine/shuttle
	name = "shuttle region scanner"
	icon_state = "trayson-shuttle"
	inhand_icon_state = "trayson-shuttle"
	desc = "Used to see the boundaries of shuttle regions."

	modes = list(MODE_NONE = MODE_SHUTTLE, MODE_SHUTTLE = MODE_NONE)


/obj/item/clothing/glasses/meson/engine/atmos_imaging
	name = "atmospheric thermal imaging goggles"
	desc = "Goggles used by Atmospheric Technicians to see the thermal energy of gasses in open areas."
	icon_state = "trayson-atmospheric-thermal"
	inhand_icon_state = "trayson-meson"
	glass_colour_type = /datum/client_colour/glass_colour/gray

	modes = list(MODE_NONE = MODE_ATMOS_THERMAL, MODE_ATMOS_THERMAL = MODE_NONE)

/obj/item/clothing/glasses/meson/engine/atmos_imaging/update_icon_state()
	icon_state = inhand_icon_state = "trayson-[mode]"
	return ..()



/proc/atmos_thermal(mob/viewer, range = 5, duration = 10)
	if(!ismob(viewer) || !viewer.client)
		return
	for(var/turf/open in view(range, viewer))
		if(open.blocks_air)
			continue
		var/datum/gas_mixture/environment = open.return_air()
		var/temp = round(environment.return_temperature())
		var/image/pic = image('icons/turf/overlays.dmi', open, "greyOverlay", ABOVE_ALL_MOB_LAYER)
		// Lower than TEMP_SHADE_CYAN should be deep blue
		switch(temp)
			if(-INFINITY to TEMP_SHADE_CYAN)
				pic.color = COLOR_STRONG_BLUE
			// Between TEMP_SHADE_CYAN and TEMP_SHADE_GREEN
			if(TEMP_SHADE_CYAN to TEMP_SHADE_GREEN)
				pic.color = BlendRGB(COLOR_DARK_CYAN, COLOR_LIME, max(round((temp - TEMP_SHADE_CYAN)/(TEMP_SHADE_GREEN - TEMP_SHADE_CYAN), 0.01), 0))
			// Between TEMP_SHADE_GREEN and TEMP_SHADE_YELLOW
			if(TEMP_SHADE_GREEN to TEMP_SHADE_YELLOW)
				pic.color = BlendRGB(COLOR_LIME, COLOR_YELLOW, clamp(round((temp-TEMP_SHADE_GREEN)/(TEMP_SHADE_YELLOW - TEMP_SHADE_GREEN), 0.01), 0, 1))
			// Between TEMP_SHADE_YELLOW and TEMP_SHADE_RED
			if(TEMP_SHADE_YELLOW to TEMP_SHADE_RED)
				pic.color = BlendRGB(COLOR_YELLOW, COLOR_RED, clamp(round((temp-TEMP_SHADE_YELLOW)/(TEMP_SHADE_RED - TEMP_SHADE_YELLOW), 0.01), 0, 1))
			// Over TEMP_SHADE_RED should be red
			if(TEMP_SHADE_RED to INFINITY)
				pic.color = COLOR_RED
		pic.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
		pic.alpha = 200
		flick_overlay_global(pic, list(viewer.client), duration)


#undef MODE_NONE
#undef MODE_MESON
#undef MODE_TRAY
#undef MODE_SHUTTLE
#undef MODE_PIPE_CONNECTABLE
#undef MODE_ATMOS_THERMAL
#undef TEMP_SHADE_CYAN
#undef TEMP_SHADE_GREEN
#undef TEMP_SHADE_YELLOW
#undef TEMP_SHADE_RED
