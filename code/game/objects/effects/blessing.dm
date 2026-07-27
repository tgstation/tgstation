/// Blesses turfs it is created on, then deletes itself
/// For mapper use only
/obj/effect/blessing
	name = "holy blessing"
	desc = "Holy energies interfere with ethereal travel at this location."
	icon = 'icons/effects/effects.dmi'
	icon_state = "blessed"
	/// Is this blessing visible to those with the ability to see blessed tiles? (chaplains)
	var/invisible = FALSE

/obj/effect/blessing/Initialize(mapload)
	. = ..()
	if (!isturf(loc))
		return INITIALIZE_HINT_QDEL
	var/turf/our_turf = loc
	our_turf.AddElement(/datum/element/blessed_turf, invisible)
	return INITIALIZE_HINT_QDEL

/obj/effect/blessing/invisible
	invisible = TRUE
