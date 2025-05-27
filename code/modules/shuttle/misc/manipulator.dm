/obj/machinery/shuttle_manipulator
	name = "shuttle manipulator"
	desc = "I shall be telling this with a sigh\n\
		Somewhere ages and ages hence:\n\
		Two roads diverged in a wood, and I,\n\
		I took the one less traveled by,\n\
		And that has made all the difference."

	icon = 'icons/obj/machines/shuttle_manipulator.dmi'
	icon_state = "holograph_on"

	density = TRUE

/obj/machinery/shuttle_manipulator/Initialize(mapload)
	. = ..()
	update_appearance()

/obj/machinery/shuttle_manipulator/on_set_is_operational(old_value)
	. = ..()
	update_appearance()

/obj/machinery/shuttle_manipulator/update_overlays()
	. = ..()
	if(is_operational)
		var/mutable_appearance/hologram = mutable_appearance(icon, "hologram_on", appearance_flags = KEEP_APART|RESET_COLOR)
		hologram.pixel_z += 20
		. += hologram
		var/mutable_appearance/hologram_emissive = emissive_appearance(icon, "hologram_on", src)
		hologram_emissive.pixel_z += 20
		. += hologram_emissive

		var/mutable_appearance/hologram_whiteship = mutable_appearance(icon, "hologram_whiteship", appearance_flags = KEEP_APART|RESET_COLOR)
		hologram_whiteship.pixel_z += 20
		. += hologram_whiteship
		var/mutable_appearance/hologram_whiteship_emissive = emissive_appearance(icon, "hologram_whiteship", src)
		hologram_whiteship_emissive.pixel_z += 20
		. += hologram_whiteship_emissive
