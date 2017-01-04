/* All mobs within `radius` tiles will have GODMODE set, and will lose it
   after leaving the range. */

/obj/machinery/protector
	name = "protector"
	desc = "Shields all nearby life from harm."
	icon = 'icons/obj/hand_of_god_structures.dmi'
	icon_state = "conduit"
	density = TRUE
	opacity = FALSE
	anchored = TRUE
	pressure_resistance = INFINITY
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/radius = 5
	var/list/mob/living/protected = list()
	var/area/limited_area

/obj/machinery/protector/process()
	var/list/in_range = list()
	for(var/mob/living/L in range(radius, get_turf(src)))
		if(limited_area && get_area(L) != limited_area)
			continue
		in_range += L
		protected |= L
		L.status_flags |= GODMODE

	for(var/m in protected - in_range)
		var/mob/living/L = m
		if(!istype(L))
			protected -= L
		L.status_flags &= ~GODMODE
		protected -= L
