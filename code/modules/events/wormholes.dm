/datum/round_event_control/wormholes
	name = "Wormholes"
	typepath = /datum/round_event/wormholes
	max_occurrences = 3
	weight = 2
	min_players = 2


/datum/round_event/wormholes
	announceWhen = 10
	endWhen = 60

	var/list/pick_turfs = list()
	var/list/wormholes = list()
	var/shift_frequency = 3
	var/number_of_wormholes = 400

/datum/round_event/wormholes/setup()
	announceWhen = rand(0, 20)
	endWhen = rand(40, 80)

/datum/round_event/wormholes/start()
	for(var/turf/open/floor/T in world)
		if(T.z == ZLEVEL_STATION)
			pick_turfs += T

	for(var/i = 1, i <= number_of_wormholes, i++)
		var/turf/T = pick(pick_turfs)
		wormholes += new /obj/effect/portal/wormhole(T, null, null, -1)

/datum/round_event/wormholes/announce()
	priority_announce("Space-time anomalies detected on the station. There is no additional data.", "Anomaly Alert", 'sound/ai/spanomalies.ogg')

/datum/round_event/wormholes/tick()
	if(activeFor % shift_frequency == 0)
		for(var/obj/effect/portal/wormhole/O in wormholes)
			var/turf/T = pick(pick_turfs)
			if(T)
				O.loc = T

/datum/round_event/wormholes/end()
	GLOB.portals.Remove(wormholes)
	for(var/obj/effect/portal/wormhole/O in wormholes)
		O.loc = null
	wormholes.Cut()


/obj/effect/portal/wormhole
	name = "wormhole"
	desc = "It looks highly unstable; It could close at any moment."
	icon = 'icons/obj/objects.dmi'
	icon_state = "anom"
	mech_sized = TRUE

/obj/effect/portal/wormhole/attack_hand(mob/user)
	teleport(user)

/obj/effect/portal/wormhole/attackby(obj/item/I, mob/user, params)
	teleport(user)

/obj/effect/portal/wormhole/teleport(atom/movable/M)
	if(istype(M, /obj/effect))	//sparks don't teleport
		return
	if(M.anchored)
		if(!(istype(M, /obj/mecha) && mech_sized))
			return

	if(istype(M, /atom/movable))
		var/turf/target
		if(GLOB.portals.len)
			var/obj/effect/portal/P = pick(GLOB.portals)
			if(P && isturf(P.loc))
				target = P.loc
		if(!target)
			return
		do_teleport(M, target, 1, 1, 0, 0) ///You will appear adjacent to the beacon