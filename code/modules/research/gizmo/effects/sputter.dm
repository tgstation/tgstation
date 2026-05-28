#define DEFAULT_OIL_RANGE 3
#define DEFAULT_OIL_CHANCE 8

/// Shake around and spill oil.
/datum/gizmo_effect/sputter
	/// Range in which we can oilerize
	var/oil_range = DEFAULT_OIL_RANGE
	/// Chance for a tile to get oiled
	var/oil_chance = DEFAULT_OIL_CHANCE

/datum/gizmo_effect/sputter/activate(atom/movable/holder, datum/gizmo_effect_combination/master, datum/gizmo_interface/interface)
	playsound(holder, 'sound/effects/splat.ogg', 30)
	for(var/turf/open/tile in oview(oil_range, holder))
		if(prob(oil_chance))
			new /obj/effect/decal/cleanable/blood/oil(tile)

	holder.Shake()

#undef DEFAULT_OIL_RANGE
#undef DEFAULT_OIL_CHANCE
