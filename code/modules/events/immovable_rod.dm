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
	min_players = 15
	max_occurrences = 5

/datum/round_event/immovable_rod
	announceWhen = 5

/datum/round_event/immovable_rod/announce()
	priority_announce("What the fuck was that?!", "General Alert")

/datum/round_event/immovable_rod/start()
	var/startside = pick(GLOB.cardinal)
	var/turf/startT = spaceDebrisStartLoc(startside, ZLEVEL_STATION)
	var/turf/endT = spaceDebrisFinishLoc(startside, ZLEVEL_STATION)
	new /obj/effect/immovablerod(startT, endT)

/obj/effect/immovablerod
	name = "immovable rod"
	desc = "What the fuck is that?"
	icon = 'icons/obj/objects.dmi'
	icon_state = "immrod"
	throwforce = 100
	density = TRUE
	anchored = TRUE
	var/z_original = 0
	var/destination
	var/notify = TRUE

/obj/effect/immovablerod/New(atom/start, atom/end)
	..()
	if(SSaugury)
		SSaugury.register_doom(src, 2000)
	z_original = z
	destination = end
	if(notify)
		notify_ghosts("\A [src] is inbound!",
			enter_link="<a href=?src=\ref[src];orbit=1>(Click to orbit)</a>",
			source=src, action=NOTIFY_ORBIT)
	GLOB.poi_list += src
	if(end && end.z==z_original)
		walk_towards(src, destination, 1)

/obj/effect/immovablerod/Topic(href, href_list)
	if(href_list["orbit"])
		var/mob/dead/observer/ghost = usr
		if(istype(ghost))
			ghost.ManualFollow(src)

/obj/effect/immovablerod/Destroy()
	GLOB.poi_list -= src
	. = ..()

/obj/effect/immovablerod/Move()
	if((z != z_original) || (loc == destination))
		qdel(src)
	return ..()

/obj/effect/immovablerod/ex_act(severity, target)
	return 0

/obj/effect/immovablerod/Bump(atom/clong)
	if(prob(10))
		playsound(src, 'sound/effects/bang.ogg', 50, 1)
		audible_message("<span class='danger'>You hear a CLANG!</span>")

	if(clong && prob(25))
		x = clong.x
		y = clong.y

	if(isturf(clong) || isobj(clong))
		if(clong.density)
			clong.ex_act(2)

	else if(isliving(clong))
		penetrate(clong)
	else if(istype(clong, type))
		var/obj/effect/immovablerod/other = clong
		visible_message("<span class='danger'>[src] collides with [other]!\
			</span>")
		var/datum/effect_system/smoke_spread/smoke = new
		smoke.set_up(2, get_turf(src))
		smoke.start()
		qdel(src)
		qdel(other)

/obj/effect/immovablerod/proc/penetrate(mob/living/L)
	L.visible_message("<span class='danger'>[L] is penetrated by an immovable rod!</span>" , "<span class='userdanger'>The rod penetrates you!</span>" , "<span class ='danger'>You hear a CLANG!</span>")
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		H.adjustBruteLoss(160)
	if(L && (L.density || prob(10)))
		L.ex_act(2)
