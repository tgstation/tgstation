//Engineering Mesons

/obj/item/clothing/glasses/meson/engine
	name = "Engineering Scanner Goggles"
	desc = "Goggles used by engineers. The Meson Scanner mode lets you see basic structural and terrain layouts through walls, regardless of lighting condition. The T-ray Scanner mode lets you see underfloor objects such as cables and pipes."
	icon_state = "trayson-meson"
	action_button_name = "Change Scanning Mode"

	var/mode = 0	//0 - regular mesons mode	1 - t-ray mode
	var/invis_objects = list()
	var/range = 1

/obj/item/clothing/glasses/meson/engine/attack_self()
	ui_action_click()

/obj/item/clothing/glasses/meson/engine/ui_action_click()
	mode = !mode

	if(mode)
		SSobj.processing |= src
		vision_flags = 0
		darkness_view = 2
		invis_view = SEE_INVISIBLE_LIVING
		loc << "<span class='notice'>You toggle the goggles' scanning mode to \[T-Ray].</span>"
	else
		SSobj.processing.Remove(src)
		vision_flags = SEE_TURFS
		darkness_view = 1
		invis_view = SEE_INVISIBLE_MINIMUM
		loc << "<span class='notice'>You toggle the goggles' scanning mode to \[Meson].</span>"
		invis_update()

	update_icon()

/obj/item/clothing/glasses/meson/engine/process()
	if(!mode)
		return

	if(!istype(loc,/mob/living/carbon/human))
		invis_update()
		return

	var/mob/living/carbon/human/user = loc
	if(user.glasses != src)
		invis_update()
		return

	scan()

/obj/item/clothing/glasses/meson/engine/proc/scan()
	for(var/turf/T in range(range, loc))

		if(!T.intact)
			continue

		for(var/obj/O in T.contents)
			if(O.level != 1)
				continue

			if(O.invisibility == 101)
				O.invisibility = 0
				invis_objects += O

	spawn(5)
		invis_update()

/obj/item/clothing/glasses/meson/engine/proc/invis_update()
	for(var/obj/O in invis_objects)
		if(!t_ray_on() || !(O in range(range, loc)))
			invis_objects -= O
			var/turf/T = O.loc
			if(T && T.intact)
				O.invisibility = 101

/obj/item/clothing/glasses/meson/engine/proc/t_ray_on()
	if(!istype(loc,/mob/living/carbon/human))
		return 0

	var/mob/living/carbon/human/user = loc
	return mode & (user.glasses == src)

/obj/item/clothing/glasses/meson/engine/update_icon()
	icon_state = mode ? "trayson-tray" : "trayson-meson"
	if(istype(loc,/mob/living/carbon/human/))
		var/mob/living/carbon/human/user = loc
		if(user.glasses == src)
			user.update_inv_glasses()

/obj/item/clothing/glasses/meson/engine/tray //atmos techs have lived far too long without tray goggles while those damned engineers get their dual-purpose gogles all to themselves
	name = "Optical T-Ray Scanner"
	desc = "Used by engineering staff to see underfloor objects such as cables and pipes."
	icon_state = "trayson-tray_off"
	action_button_name = "Toggle Scanner Power"

	mode = 1
	var/on = 0
	vision_flags = 0
	darkness_view = 2
	invis_view = SEE_INVISIBLE_LIVING
	range = 2

/obj/item/clothing/glasses/meson/engine/tray/process()
	if(!on)
		return
	..()

/obj/item/clothing/glasses/meson/engine/tray/update_icon()
	icon_state = "trayson-tray[on ? "" : "_off"]"
	if(istype(loc,/mob/living/carbon/human/))
		var/mob/living/carbon/human/user = loc
		if(user.glasses == src)
			user.update_inv_glasses()

/obj/item/clothing/glasses/meson/engine/tray/ui_action_click()
	on = !on

	if(on)
		SSobj.processing |= src
		loc << "<span class='notice'>You turn the goggles on.</span>"
	else
		SSobj.processing.Remove(src)
		loc << "<span class='notice'>You turn the goggles off.</span>"
		invis_update()

	update_icon()

/obj/item/clothing/glasses/meson/engine/tray/t_ray_on()
	return on && ..()