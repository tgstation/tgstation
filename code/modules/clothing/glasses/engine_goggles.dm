//Engineering Mesons

#define MODE_NONE ""
#define MODE_MESON "meson"
#define MODE_TRAY "t-ray"
#define MODE_RAD "radiation"

/obj/item/clothing/glasses/meson/engine
	name = "engineering scanner goggles"
	desc = "Goggles used by engineers. The Meson Scanner mode lets you see basic structural and terrain layouts through walls, the T-ray Scanner mode lets you see underfloor objects such as cables and pipes, and the Radiation Scanner mode let's you see objects contaminated by radiation."
	icon_state = "trayson"
	actions_types = list(/datum/action/item_action/toggle_mode)
	origin_tech = "materials=3;magnets=3;engineering=3;plasmatech=3"

	vision_flags = NONE
	darkness_view = 2
	invis_view = SEE_INVISIBLE_LIVING

	var/list/modes = list(MODE_NONE = MODE_MESON, MODE_MESON = MODE_TRAY, MODE_TRAY = MODE_RAD, MODE_RAD = MODE_NONE)
	var/mode = MODE_NONE
	var/range = 1

/obj/item/clothing/glasses/meson/engine/Initialize()
	. = ..()
	START_PROCESSING(SSobj, src)
	update_icon()

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
			lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE

		if(MODE_TRAY) //undoes the last mode, meson
			vision_flags = NONE
			darkness_view = 2
			lighting_alpha = null

	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if(H.glasses == src)
			H.update_sight()

	update_icon()
	for(var/X in actions)
		var/datum/action/A = X
		A.UpdateButtonIcon()

/obj/item/clothing/glasses/meson/engine/attack_self(mob/user)
	toggle_mode(user, TRUE)

/obj/item/clothing/glasses/meson/engine/process()
	if(mode == MODE_MESON)
		var/turf/T = get_turf(src)
		if(T && T.z == ZLEVEL_MINING)
			toggle_mode(loc)
		return

	if(!ishuman(loc))
		return
	var/mob/living/carbon/human/user = loc
	if(user.glasses != src || !user.client)
		return
	if(mode == MODE_TRAY)
		scan()
	else if(mode == MODE_RAD)
		show_rads()

/obj/item/clothing/glasses/meson/engine/proc/scan()
	for(var/turf/T in range(range, loc))
		for(var/obj/O in T.contents)
			if(O.level != 1)
				continue

			if(O.invisibility == INVISIBILITY_MAXIMUM)
				flick_sonar(O)

/obj/item/clothing/glasses/meson/engine/proc/flick_sonar(obj/pipe)
	var/mob/M = loc
	var/image/I = new(loc = get_turf(pipe))
	var/mutable_appearance/MA = new(pipe)
	MA.alpha = 128
	I.appearance = MA
	flick_overlay(I, list(M.client), 8)

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
		if(get_dist(user, place) >= range*2)	//Rads are easier to see than wires under the floor
			continue
		var/strength = round(rad_places[i] / 1000, 0.1)
		var/image/pic = new(loc = place)
		var/mutable_appearance/MA = new()
		MA.alpha = 128
		MA.maptext = "[strength]k"
		MA.color = "#64C864"
		MA.layer = AREA_LAYER
		pic.appearance = MA
		flick_overlay(pic, list(user.client), 8)

/obj/item/clothing/glasses/meson/engine/update_icon()
	icon_state = "[initial(icon_state)]-[mode]"
	if(istype(loc, /mob/living/carbon/human/))
		var/mob/living/carbon/human/user = loc
		if(user.glasses == src)
			user.update_inv_glasses()

/obj/item/clothing/glasses/meson/engine/tray //atmos techs have lived far too long without tray goggles while those damned engineers get their dual-purpose gogles all to themselves
	name = "optical t-ray scanner"
	desc = "Used by engineering staff to see underfloor objects such as cables and pipes."
	origin_tech = "materials=3;magnets=2;engineering=2"

	range = 2

	modes = list(MODE_NONE = MODE_TRAY, MODE_TRAY = MODE_NONE)

#undef MODE_NONE
#undef MODE_MESON
#undef MODE_TRAY
#undef MODE_RAD