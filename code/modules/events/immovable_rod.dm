/*
Immovable rod random event.
The rod will spawn at some location outside the station, and travel in a straight line to the opposite side of the station
Everything solid in the way will be ex_act()'d
In my current plan for it, 'solid' will be defined as anything with density == 1

--NEOFite
*/

/datum/round_event_control/immovable_rod
	name = "Immovable Rod"
	typepath = /datum/round_event/immovable_rod
	max_occurrences = 5
	announcement = 1

/datum/round_event/immovable_rod
	announceWhen = 5

/datum/round_event/immovable_rod/announce()
	priority_announce("What the fuck was that?!", "General Alert")

/datum/round_event/immovable_rod/start()
	var/startside = pick(cardinal)
	var/turf/startT = spaceDebrisStartLoc(startside, 1)
	var/turf/endT = spaceDebrisFinishLoc(startside, 1)
	new /obj/effect/immovablerod(startT, endT)

/obj/effect/immovablerod
	name = "Immovable Rod"
	desc = "What the fuck is that?"
	icon = 'icons/obj/objects.dmi'
	icon_state = "immrod"
	throwforce = 100
	density = 1
	anchored = 1
	var/z_original = 0
	var/destination

/obj/effect/immovablerod/New(atom/start, atom/end)
	loc = start
	z_original = z
	destination = end
	if(end && end.z==z_original)
		walk_towards(src, destination, 1)

/obj/effect/immovablerod/Move()
	if(z != z_original || loc == destination)
		qdel(src)
	return ..()

/obj/effect/immovablerod/Bump(atom/clong)
	if(prob(10))
		playsound(src, 'sound/effects/bang.ogg', 50, 1)
		audible_message("CLANG")

	if(clong)
		x = clong.x
		y = clong.y

	if (istype(clong))
		if(clong.density)
			clong.ex_act(2)

	return

/obj/effect/immovablerod/ex_act()
	return