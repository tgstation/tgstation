/obj/machinery/shuttle_manipulator
	name = "shuttle manipulator"
	desc = "I shall be telling this with a sigh\n\
		Somewhere ages and ages hence:\n\
		Two roads diverged in a wood, and I,\n\
		I took the one less traveled by,\n\
		And that has made all the difference."

	icon = 'icons/obj/machines/shuttle_manipulator.dmi'
	icon_state = "holograph_on"
	var/icon_hologram_projection = "hologram_on"
	var/icon_hologram_ship = "hologram_whiteship"

	density = TRUE

/obj/machinery/shuttle_manipulator/Initialize(mapload)
	. = ..()
	update_icon()

/obj/machinery/shuttle_manipulator/Destroy(force)
	if(!force)
		. = QDEL_HINT_LETMELIVE
	else
		. = ..()

/obj/machinery/shuttle_manipulator/update_icon()
	. = ..()
	cut_overlays()
	var/mutable_appearance/hologram_projection = mutable_appearance(icon, icon_hologram_projection)
	hologram_projection.pixel_y = 22
	var/mutable_appearance/hologram_ship = mutable_appearance(icon, icon_hologram_ship)
	hologram_ship.pixel_y = 27
	if(machine_stat & NOPOWER)
		flick("holograph_turnoff", src)
		icon_state = "holograph_off"
		var/mutable_appearance/hologram_turnoff = mutable_appearance(icon, "hologram_turnoff")
		hologram_turnoff.pixel_y = 22
		flick_overlay_view(hologram_turnoff, 0.6 SECONDS)
		cut_overlays()
	else
		flick("holograph_turnon", src)
		icon_state = "holograph_on"
		var/mutable_appearance/hologram_turnon = mutable_appearance(icon, "hologram_turnon")
		hologram_turnon.pixel_y = 22
		flick_overlay_view(hologram_turnon, 0.6 SECONDS)
		cut_overlay(hologram_turnon)
		add_overlay(hologram_projection)
		add_overlay(hologram_ship)
