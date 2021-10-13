/obj/machinery/door/airlock/bronze/trait_limited
	name = "limited access airlock"

/obj/machinery/door/airlock/bronze/trait_limited/Initialize(mapload)
	. = ..()
	var/area/area = get_area(src)
	if (!isnull(area.trait_required))
		desc = "[area.trait_required] only"

/obj/machinery/door/airlock/bronze/trait_limited/allowed(mob/user)
	. = ..()
	if (!.)
		return .

	var/area/area = get_area(src)
	if (isnull(area.trait_required))
		return .

	return HAS_TRAIT(user, area.trait_required)

/obj/machinery/door/airlock/bronze/trait_limited/CanAllowThrough(atom/movable/mover, border_dir)
	return ..() && ismob(mover) && allowed(mover)
