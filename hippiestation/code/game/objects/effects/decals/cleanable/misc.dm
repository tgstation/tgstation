/obj/effect/decal/cleanable/vomit/Initialize()
	. = ..()
	if(prob(50))
		var/datum/reagent/toxin/vomit/V = new
		V.handle_state_change(get_turf(src), 10)
		return INITIALIZE_HINT_QDEL