//Engineering Mesons

/obj/item/clothing/glasses/meson/engine
	name = "Engineering Meson Scanner"
	desc = "Goggles used by engineers. The Meson Scanner mode lets you see basic structural and terrain layouts through walls, regardless of lighting condition. The T-ray Scanner mode lets you see underfloor objects such as cables and pipes."
	icon_state = "meson"
	item_state = "glasses"
	origin_tech = "magnets=2;engineering=2"
	darkness_view = 1
	vision_flags = SEE_TURFS
	invis_view = SEE_INVISIBLE_MINIMUM
	var/state = 0	//0 - regular mesons mode	1 - t-ray mode
	var/invis_objects = list()
	action_button_name = "Change scanning mode"

/obj/item/clothing/glasses/meson/engine/attack_self(mob/user)
	ui_action_click()

/obj/item/clothing/glasses/meson/engine/ui_action_click(mob/user)
	state = !state
	if(state)
		SSobj.processing |= src
		vision_flags = 0
		darkness_view = 2
		invis_view = SEE_INVISIBLE_LIVING
	else
		SSobj.processing.Remove(src)
		vision_flags = SEE_TURFS
		darkness_view = 1
		invis_view = SEE_INVISIBLE_MINIMUM
		invis_update()
	update_icon()

/obj/item/clothing/glasses/meson/engine/process()
	if(!state)
		return null

	if(!istype(loc,/mob/living/carbon/human))
		invis_update()
		return null

	var/mob/living/carbon/human/user = loc
	if(user.glasses != src)
		invis_update()
		return null

	scan()

/obj/item/clothing/glasses/meson/engine/proc/scan()
	var/mob/living/carbon/human/user = loc
	if(user.glasses != src)
		return

	for(var/turf/T in range(1, loc))

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
		if(!t_ray_on() || !(O in range(1, loc)))
			O.invisibility = 101
			invis_objects -= O

/obj/item/clothing/glasses/meson/engine/proc/t_ray_on()
	if(!istype(loc,/mob/living/carbon/human))
		return 0

	var/mob/living/carbon/human/user = loc
	return state & (user.glasses == src)

/obj/item/clothing/glasses/meson/engine/update_icon()
	icon_state = state ? "material" : "meson"
