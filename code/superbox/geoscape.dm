#define GEO_OFF 0
#define GEO_ON 1
#define GEO_TURNON 2
#define GEO_TURNOFF 3

#define GEO_ANIM_LENGTH 6

/obj/machinery/geoscape
	name = "geoscape projector"
	desc = "<i>And how can man die better\n\
		Than facing fearful odds,\n\
		For the ashes of his fathers,\n\
		And the temples of his Gods.</i>"

	icon = 'icons/obj/machines/shuttle_manipulator.dmi'
	icon_state = "holograph_on"

	anchored = TRUE
	density = TRUE

	pixel_x = -16
	layer = 4

	var/state = GEO_ON

/obj/machinery/geoscape/Initialize()
	. = ..()
	finish_turnon()

// INTERACTIONS

/obj/machinery/geoscape/emag_act(mob/user)
	if(!(obj_flags & EMAGGED) && (state == GEO_OFF || state == GEO_ON))
		obj_flags |= EMAGGED
		to_chat(user, "<span class='notice'>You emag [src].</span>")
		// update description and visuals
		desc = "<i>Scientia Potentia Est.</i>"
		if (state == GEO_OFF)
			turnon()
		else // GEO_ON
			turnoff()

/obj/machinery/geoscape/attackby(obj/item/W, mob/living/user, params)
	if (obj_flags & EMAGGED)
		to_chat(user, "<span class='notice'>\The [src] isn't responding.</span>")
		return

	if (!(ACCESS_HEADS in W.GetAccess()))
		to_chat(user, "<span class='warning'>Access denied.</span>")
		return

	if (state == GEO_ON)
		turnoff()
		to_chat(user, "<span class='notice'>You turn off [src].</span>")
	else if (state == GEO_OFF)
		turnon()
		to_chat(user, "<span class='notice'>You turn on [src].</span>")

/obj/machinery/geoscape/attack_ai(mob/user)
	if (obj_flags & EMAGGED)
		to_chat(user, "<span class='notice'>\The [src] isn't responding.</span>")
		return

	if (state == GEO_ON)
		turnoff()
		to_chat(user, "<span class='notice'>You turn off [src].</span>")
	else if (state == GEO_OFF)
		turnon()
		to_chat(user, "<span class='notice'>You turn on [src].</span>")

// STATE MACHINE

/obj/machinery/geoscape/proc/un_emag() // for debugging
	obj_flags &= ~EMAGGED
	update_icon()

/obj/machinery/geoscape/proc/turnon()
	state = GEO_TURNON
	update_icon()
	addtimer(CALLBACK(src, .proc/finish_turnon), GEO_ANIM_LENGTH)

/obj/machinery/geoscape/proc/finish_turnon()
	state = GEO_ON
	update_icon()

/obj/machinery/geoscape/proc/turnoff()
	state = GEO_TURNOFF
	update_icon()
	addtimer(CALLBACK(src, .proc/finish_turnoff), GEO_ANIM_LENGTH)

/obj/machinery/geoscape/proc/finish_turnoff()
	if (obj_flags & EMAGGED)
		turnon()
		return
	state = GEO_OFF
	update_icon()

// RENDERING

/obj/machinery/geoscape/update_icon()
	var/mutable_appearance/projector
	var/mutable_appearance/display

	switch(state)
		if (GEO_OFF)
			icon_state = "holograph_off"
		if (GEO_ON)
			icon_state = "holograph_on"
			projector = mutable_appearance(icon, "hologram_on")
			if(obj_flags & EMAGGED)
				display = mutable_appearance('icons/obj/machines/geoscape.dmi', "exalt")
			else
				display = mutable_appearance('icons/obj/machines/geoscape.dmi', "globe")
		if (GEO_TURNON)
			icon_state = "holograph_turnon"
			projector = mutable_appearance(icon, "hologram_turnon")
		if (GEO_TURNOFF)
			icon_state = "holograph_turnoff"
			projector = mutable_appearance(icon, "hologram_turnoff")

	cut_overlays()
	if (projector)
		projector.pixel_y = 22
		add_overlay(projector)
	if (display)
		display.pixel_x = (64 - 72) / 2
		display.pixel_y = 27
		add_overlay(display)
