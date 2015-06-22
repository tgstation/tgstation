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

/obj/effect/immovablerod/ex_act(test)
	return 0

/obj/effect/immovablerod/Bump(atom/clong)
	playsound(src, 'sound/effects/bang.ogg', 50, 1)
	audible_message("CLANG")

	if(clong && prob(25))
		x = clong.x
		y = clong.y

	if (istype(clong, /turf) || istype(clong, /obj))
		if(clong.density)
			clong.ex_act(2)

	else if (istype(clong, /mob))
		if(istype(clong, /mob/living/carbon/human))
			var/mob/living/carbon/human/H = clong
			H << "The rod penetrates you!"
			H.gib() //blame goof
		if(clong.density || prob(10))
			clong.ex_act(2)
	return
