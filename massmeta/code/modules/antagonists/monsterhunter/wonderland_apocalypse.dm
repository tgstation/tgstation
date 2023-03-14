
/datum/dimension_theme/wonderland
	icon = 'icons/mob/simple/rabbit.dmi'
	icon_state = "rabbit_white"
	replace_floors = list(/turf/open/misc/grass/jungle/wonderland = 1)
	replace_walls = /turf/closed/wall/mineral/wood
	replace_objs = list(\
		/obj/structure/chair = list(/obj/structure/chair/wood = 1), \
		/obj/machinery/door/airlock = list(/obj/machinery/door/airlock/wood = 1, /obj/machinery/door/airlock/wood/glass = 1), \
		/obj/structure/table = list(/obj/structure/table/wood = 1), \
		/obj/machinery/holopad  = list(/obj/structure/flora/tree/jungle = 1 ), \
		/obj/machinery/atmospherics/components/unary/vent_scrubber = list(/obj/structure/flora/tree/dead = 1))


/turf/open/misc/grass/jungle/wonderland
	underfloor_accessibility = UNDERFLOOR_HIDDEN

/datum/round_event_control/wonderlandapocalypse
	name = "Apocalypse"
	typepath = /datum/round_event/wonderlandapocalypse
	max_occurrences = 0
	weight = 0
	alert_observers = FALSE
	category = EVENT_CATEGORY_SPACE

/datum/round_event/wonderlandapocalypse/announce(fake)

	priority_announce("What the heELl is going on?! WEeE have detected  massive up-spikes in ##@^^?? coming fr*m yoOourr st!*i@n! GeEeEEET out of THERE NOW!!","?????????", 'massmeta/sounds/monster_hunter/monsterhunterintro.ogg')

/datum/round_event/wonderlandapocalypse/start()
	for(var/i = 1, i < 16, i++)
		var/turf/targetloc = get_safe_random_station_turf()
		var/datum/dimension_theme/wonderland/greenery = new()
		new /obj/effect/anomaly/dimensional/wonderland(targetloc, null, FALSE, greenery)
	for(var/i = 1, i < 4, i++)
		var/turf/rabbitloc = get_safe_random_station_turf()
		var/obj/structure/wonderland_rift/rift = new(rabbitloc)
		notify_ghosts("A doorway to the wonderland has been opened!", source = rift, action = NOTIFY_ORBIT, flashwindow = FALSE, header = "Wonderland rift Opened")



/obj/effect/anomaly/dimensional/wonderland
	range = 5
	immortal = TRUE
	drops_core = FALSE

/obj/effect/anomaly/dimensional/wonderland/Initialize(mapload, new_lifespan, drops_core, datum/dimension_theme/grasslands)
	. = ..()
	overlays += mutable_appearance('icons/effects/effects.dmi', "dimensional_overlay")

	animate(src, transform = matrix()*0.85, time = 3, loop = -1)
	animate(transform = matrix(), time = 3, loop = -1)
	theme = grasslands


/obj/effect/anomaly/dimensional/wonderland/prepare_area()
	apply_theme_icon()
	target_turfs = new()
	var/list/turfs = spiral_range_turfs(range, src)
	for (var/turf/turf in turfs)
		if (theme.can_convert(turf))
			target_turfs.Add(turf)

/obj/effect/anomaly/dimensional/wonderland/relocate()
	var/datum/anomaly_placer/placer = new()
	var/area/new_area = placer.findValidArea()
	var/turf/new_turf = placer.findValidTurf(new_area)
	src.forceMove(new_turf)
	prepare_area()


/obj/structure/wonderland_rift
	name = "Wonderland Door"
	desc = "A door leading to a magical beautiful land."
	armor = list(MELEE = 100, BULLET = 0, LASER = 0, ENERGY = 100, BOMB = 100, BIO = 0, FIRE = 100, ACID = 100)
	max_integrity = 300
	icon = 'massmeta/icons/monster_hunter/wonderland_rift.dmi'
	icon_state = "cyborg_rift"
	anchored = TRUE
	density = FALSE
	plane = MASSIVE_OBJ_PLANE
	///Have we already spawned an enemy?
	var/enemy_spawned = FALSE

/obj/structure/wonderland_rift/attack_ghost(mob/user)
	. = ..()
	if(.)
		return
	summon_rabbit(user)
	if(enemy_spawned)
		qdel(src)

/obj/structure/wonderland_rift/proc/summon_rabbit(mob/user)
	var/spawn_check = tgui_alert(user, "Become a Jabberwocky?", "Wonderland Rift", list("Yes", "No"))
	if(spawn_check != "Yes" || !src || QDELETED(src) || QDELETED(user))
		return FALSE

	if(enemy_spawned)
		return FALSE

	enemy_spawned = TRUE
	var/mob/living/simple_animal/hostile/red_rabbit/evil_rabbit = new (get_turf(src))
	evil_rabbit.key = user.key
	to_chat(evil_rabbit, span_boldwarning("Destroy everything, spare no one."))
