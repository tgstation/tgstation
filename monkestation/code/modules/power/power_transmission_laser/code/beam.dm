/obj/effect/transmission_beam
	name = "Shimmering beam"
	icon = 'goon/icons/obj/power.dmi'
	icon_state = "ptl_beam"
	anchored = TRUE

	///used to deal with atoms stepping on us while firing
	var/obj/machinery/power/transmission_laser/host

/obj/effect/transmission_beam/Initialize(mapload, obj/machinery/power/transmission_laser/creator)
	. = ..()
	var/turf/source_turf = get_turf(src)
	if(source_turf)
		RegisterSignal(source_turf, COMSIG_ATOM_ENTERED, PROC_REF(on_entered))
	update_appearance()

/obj/effect/transmission_beam/Destroy(force)
	. = ..()
	var/turf/source_turf = get_turf(src)
	if(source_turf)
		UnregisterSignal(source_turf, COMSIG_ATOM_ENTERED)

/obj/effect/transmission_beam/update_overlays()
	. = ..()
	. += emissive_appearance(icon, "ptl_beam", src)

/obj/effect/transmission_beam/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	host.atom_entered_beam(src, arrived)
