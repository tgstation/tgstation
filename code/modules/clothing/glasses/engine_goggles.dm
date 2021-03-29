//Engineering Mesons

#define MODE_NONE ""
#define MODE_MESON "meson"
#define MODE_TRAY "t-ray"
#define MODE_RAD "radiation"
#define MODE_SHUTTLE "shuttle"

/obj/item/clothing/glasses/meson/engine
	name = "engineering scanner goggles"
	desc = "Goggles used by engineers. The Meson Scanner mode lets you see basic structural and terrain layouts through walls, the T-ray Scanner mode lets you see underfloor objects such as cables and pipes, and the Radiation Scanner mode lets you see objects contaminated by radiation."
	icon_state = "trayson-meson"
	inhand_icon_state = "trayson-meson"
	actions_types = list(/datum/action/item_action/toggle_mode)
	glass_colour_type = /datum/client_colour/glass_colour/gray

	vision_flags = NONE
	darkness_view = 2
	invis_view = SEE_INVISIBLE_LIVING

	var/list/modes = list(MODE_NONE = MODE_MESON, MODE_MESON = MODE_TRAY, MODE_TRAY = MODE_RAD, MODE_RAD = MODE_NONE)
	var/mode = MODE_NONE
	var/range = 1

/obj/item/clothing/glasses/meson/engine/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)
	update_appearance()

/obj/item/clothing/glasses/meson/engine/ComponentInitialize()
	. = ..()
	AddElement(/datum/element/update_icon_updates_onmob)

/obj/item/clothing/glasses/meson/engine/Destroy()
	STOP_PROCESSING(SSobj, src)
	return ..()

/obj/item/clothing/glasses/meson/engine/proc/toggle_mode(mob/user, voluntary)
	mode = modes[mode]
	to_chat(user, "<span class='[voluntary ? "notice":"warning"]'>[voluntary ? "You turn the goggles":"The goggles turn"] [mode ? "to [mode] mode":"off"][voluntary ? ".":"!"]</span>")

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

		if(MODE_RAD)
			change_glass_color(user, /datum/client_colour/glass_colour/lightgreen)

		if(MODE_SHUTTLE)
			change_glass_color(user, /datum/client_colour/glass_colour/red)

		if(MODE_NONE)
			change_glass_color(user, initial(glass_colour_type))

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.glasses == src)
			H.update_sight()

	update_appearance()
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

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
		if(MODE_RAD)
			show_rads()
		if(MODE_SHUTTLE)
			show_shuttle()

/obj/item/clothing/glasses/meson/engine/proc/show_rads()
	var/mob/living/carbon/human/user = loc
	var/list/rad_places = list()
	for(var/datum/component/radioactive/thing in SSradiation.processing)
		var/atom/owner = thing.parent
		var/turf/place = get_turf(owner)
		if(rad_places[place])
			rad_places[place] += thing.strength
		else
			rad_places[place] = thing.strength

	for(var/i in rad_places)
		var/turf/place = i
		if(get_dist(user, place) >= range*5) //Rads are easier to see than wires under the floor
			continue
		var/strength = round(rad_places[i] / 1000, 0.1)
		var/image/pic = image(loc = place)
		var/mutable_appearance/MA = new()
		MA.maptext = MAPTEXT("[strength]k")
		MA.color = "#04e604"
		MA.layer = RAD_TEXT_LAYER
		MA.plane = GAME_PLANE
		pic.appearance = MA
		flick_overlay(pic, list(user.client), 10)

/obj/item/clothing/glasses/meson/engine/proc/show_shuttle()
	var/mob/living/carbon/human/user = loc
	var/obj/docking_port/mobile/port = SSshuttle.get_containing_shuttle(user)
	if(!port)
		return
	var/list/shuttle_areas = port.shuttle_areas
	for(var/r in shuttle_areas)
		var/area/region = r
		for(var/turf/place in region.contents)
			if(get_dist(user, place) > 7)
				continue
			var/image/pic
			if(isshuttleturf(place))
				pic = new('icons/turf/overlays.dmi', place, "greenOverlay", AREA_LAYER)
			else
				pic = new('icons/turf/overlays.dmi', place, "redOverlay", AREA_LAYER)
			flick_overlay(pic, list(user.client), 8)

/obj/item/clothing/glasses/meson/engine/update_icon_state()
	icon_state = inhand_icon_state = "trayson-[mode]"
	return ..()

/obj/item/clothing/glasses/meson/engine/tray //atmos techs have lived far too long without tray goggles while those damned engineers get their dual-purpose gogles all to themselves
	name = "optical t-ray scanner"
	icon_state = "trayson-t-ray"
	inhand_icon_state = "trayson-t-ray"
	desc = "Used by engineering staff to see underfloor objects such as cables and pipes."
	range = 2

	modes = list(MODE_NONE = MODE_TRAY, MODE_TRAY = MODE_NONE)

/obj/item/clothing/glasses/meson/engine/shuttle
	name = "shuttle region scanner"
	icon_state = "trayson-shuttle"
	inhand_icon_state = "trayson-shuttle"
	desc = "Used to see the boundaries of shuttle regions."

	modes = list(MODE_NONE = MODE_SHUTTLE, MODE_SHUTTLE = MODE_NONE)

/obj/item/clothing/glasses/meson/engine/smart
	name = "optical t-ray scanner"
	icon_state = "trayson-t-ray"
	inhand_icon_state = "trayson-t-ray"
	desc = "Used by engineering staff to see underfloor objects such as cables and pipes."
	range = 3
	var/choosen_color

/obj/item/clothing/glasses/meson/engine/smart/attack_self(mob/user)
	var/list/colors = list()

	colors["amethyst"] = icon('icons/hud/radial.dmi', "amethyst")
	colors["blue"] = icon('icons/hud/radial.dmi', "blue")
	colors["brown"] = icon('icons/hud/radial.dmi', "brown")
	colors["cyan"] = icon('icons/hud/radial.dmi', "cyan")
	colors["dark"] = icon('icons/hud/radial.dmi', "dark")
	colors["green"] = icon('icons/hud/radial.dmi', "green")
	colors["grey"] = icon('icons/hud/radial.dmi', "grey")
	colors["orange"] = icon('icons/hud/radial.dmi', "orange")
	colors["purple"] = icon('icons/hud/radial.dmi', "purple")
	colors["red"] = icon('icons/hud/radial.dmi', "red")
	colors["violet"] = icon('icons/hud/radial.dmi', "violet")
	colors["yellow"] = icon('icons/hud/radial.dmi', "yellow")
	colors["none"] = icon('icons/hud/radial.dmi', "none")
	var/choice = show_radial_menu(
		user,
		src,
		colors,
		custom_check = CALLBACK(src, .proc/check_interactable, user),
		require_near = TRUE,
	)

	if (!choice)
		return
	switch (choice)
		if("amethyst")
			choosen_color = GLOB.pipe_paint_colors["amethyst"]
		if("blue")
			choosen_color = GLOB.pipe_paint_colors["blue"]
		if("brown")
			choosen_color = GLOB.pipe_paint_colors["brown"]
		if("cyan")
			choosen_color = GLOB.pipe_paint_colors["cyan"]
		if("dark")
			choosen_color = GLOB.pipe_paint_colors["dark"]
		if("green")
			choosen_color = GLOB.pipe_paint_colors["green"]
		if("grey")
			choosen_color = GLOB.pipe_paint_colors["grey"]
		if("orange")
			choosen_color = GLOB.pipe_paint_colors["orange"]
		if("purple")
			choosen_color = GLOB.pipe_paint_colors["purple"]
		if("red")
			choosen_color = GLOB.pipe_paint_colors["red"]
		if("violet")
			choosen_color = GLOB.pipe_paint_colors["violet"]
		if("yellow")
			choosen_color = GLOB.pipe_paint_colors["yellow"]
		if("none")
			choosen_color = null

/obj/item/clothing/glasses/meson/engine/smart/proc/check_interactable(mob/user)
	if (!can_interact(user))
		return FALSE
	return TRUE

/obj/item/clothing/glasses/meson/engine/smart/process()
	if(!ishuman(loc))
		return
	var/mob/living/carbon/human/user = loc
	if(user.glasses != src || !user.client)
		return
	if(choosen_color == null)
		return
	for(var/turf/turf in orange(3, user))
		for(var/obj/machinery/atmospherics/pipe/smart/smart in turf.contents)
			if(smart.pipe_color == choosen_color)
				var/obj/effect/smart_pipe = new
				smart_pipe.appearance = smart.pipe_appearance
				smart_pipe.layer = HIGH_OBJ_LAYER
				smart_pipe.vis_flags |= VIS_INHERIT_DIR | VIS_INHERIT_ID
				smart.vis_contents += smart_pipe
				addtimer(CALLBACK(src, .proc/remove_vis, smart, smart_pipe), 2 SECONDS)

/obj/item/clothing/glasses/meson/engine/smart/proc/remove_vis(obj/machinery/atmospherics/pipe/smart/smart, obj/effect/smart_pipe)
	smart.vis_contents -= smart_pipe

#undef MODE_NONE
#undef MODE_MESON
#undef MODE_TRAY
#undef MODE_RAD
#undef MODE_SHUTTLE
