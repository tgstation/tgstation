/*

CONTAINS:
All AirflowX() procs, all Variable Setting Controls for airflow, save/load variable tweaks for airflow.

VARIABLES:

atom/movable/airflow_dest
	The destination turf of a flying object.

atom/movable/airflow_speed
	The speed (1-15) at which a flying object is traveling to airflow_dest. Decays over time.


OVERLOADABLE PROCS:

mob/airflow_stun()
	Contains checks for and results of being stunned by airflow.
	Called when airflow quantities exceed airflow_medium_pressure.
	RETURNS: Null

atom/movable/check_airflow_movable(n)
	Contains checks for moving any object due to airflow.
	n is the pressure that is flowing.
	RETURNS: 1 if the object moves under the air conditions, 0 if it stays put.

atom/movable/airflow_hit(atom/A)
	Contains results of hitting a solid object (A) due to airflow.
	A is the dense object hit.
	Use airflow_speed to determine how fast the projectile was going.


AUTOMATIC PROCS:

Airflow(zone/A, zone/B)
	Causes objects to fly along a pressure gradient.
	Called by zone updates. A and B are two connected zones.

AirflowSpace(zone/A)
	Causes objects to fly into space.
	Called by zone updates. A is a zone connected to space.

atom/movable/GotoAirflowDest(n)
atom/movable/RepelAirflowDest(n)
	Called by main airflow procs to cause the object to fly to or away from destination at speed n.
	Probably shouldn't call this directly unless you know what you're
	doing and have set airflow_dest. airflow_hit() will be called if the object collides with an obstacle.

*/

vs_control/var

	airflow_lightest_pressure = 15
	airflow_light_pressure = 30
	airflow_medium_pressure = 45
	airflow_heavy_pressure = 60
	airflow_heaviest_pressure = 100

	airflow_damage = 0.3
	airflow_stun = 0.15
	airflow_speed_decay = 1
	airflow_delay = 35 //Time in deciseconds before they can be moved by airflow again.
	airflow_mob_slowdown = 3 //Time in tenths of a second to add as a delay to each movement by a mob.\
	Only active if they are fighting the pull of the airflow.
	airflow_stun_cooldown = 10 //How long, in tenths of a second, to wait before stunning them again.

mob/var/last_airflow_stun = 0
mob/proc/airflow_stun()
	if(last_airflow_stun > world.time - vsc.airflow_stun_cooldown)	return 0
	if(weakened <= 0) src << "\red The sudden rush of air knocks you over!"
	weakened = max(weakened,5)
	last_airflow_stun = world.time

mob/living/silicon/airflow_stun()
	return

mob/living/carbon/metroid/airflow_stun()
	return

mob/living/carbon/human/airflow_stun()
	if(last_airflow_stun > world.time - vsc.airflow_stun_cooldown)	return 0
	if(buckled) return 0
	if(wear_suit)
		if(wear_suit.flags & SUITSPACE) return 0
	if(shoes)
		if(shoes.flags & NOSLIP) return 0
	if(weakened <= 0) src << "\red The sudden rush of air knocks you over!"
	weakened = max(weakened,rand(1,2))
	last_airflow_stun = world.time

atom/movable/proc/check_airflow_movable(n)

	if(anchored && !ismob(src)) return 0

	if(!istype(src,/obj/item) && n < vsc.airflow_heavy_pressure) return 0

	return 1

mob/dead/observer/check_airflow_movable()
	return 0

mob/living/silicon/check_airflow_movable()
	return 0


obj/item/check_airflow_movable(n)
	. = ..()
	switch(w_class)
		if(2)
			if(n < vsc.airflow_lightest_pressure) return 0
		if(3)
			if(n < vsc.airflow_light_pressure) return 0
		if(4,5)
			if(n < vsc.airflow_medium_pressure) return 0

//The main airflow code. Called by zone updates.
//Zones A and B are air zones. n represents the amount of air moved.

proc/Airflow(zone/A,zone/B)

	var/n = B.air.return_pressure() - A.air.return_pressure()

	 //Don't go any further if n is lower than the lowest value needed for airflow.
	if(abs(n) < vsc.airflow_lightest_pressure) return

	//These turfs are the midway point between A and B, and will be the destination point for thrown objects.
	var/list/connection/connections_A = A.connections
	var/list/turf/connected_turfs = list()
	for(var/connection/C in connections_A) //Grab the turf that is in the zone we are flowing to (determined by n)
		if( ( A == C.A.zone || A == C.zone_A ) && ( B == C.B.zone || B == C.zone_B ) )
			if(n < 0)
				connected_turfs |= C.B
			else
				connected_turfs |= C.A
		else if( ( A == C.B.zone || A == C.zone_B ) && ( B == C.A.zone || B == C.zone_A ) )
			if(n < 0)
				connected_turfs |= C.A
			else
				connected_turfs |= C.B

	//Get lists of things that can be thrown across the room for each zone.
	var/list/pplz = B.movables()
	var/list/otherpplz = A.movables()
	if(n < 0)
		var/list/temporary_pplz = pplz
		pplz = otherpplz
		otherpplz = temporary_pplz

	for(var/atom/movable/M in pplz)

		if(M.last_airflow > world.time - vsc.airflow_delay) continue

		//Check for knocking people over
		if(ismob(M) && n > vsc.airflow_medium_pressure)
			if(M:nodamage) continue
			M:airflow_stun()

		if(M.check_airflow_movable(n))

			//Check for things that are in range of the midpoint turfs.
			var/list/close_turfs = list()
			for(var/turf/U in connected_turfs)
				if(M in range(U)) close_turfs += U
			if(!close_turfs.len) continue

			//If they're already being tossed, don't do it again.
			if(!M.airflow_speed)

				M.airflow_dest = pick(close_turfs) //Pick a random midpoint to fly towards.

				spawn M.GotoAirflowDest(abs(n)/5)

	//Do it again for the stuff in the other zone, making it fly away.
	for(var/atom/movable/M in otherpplz)

		if(M.last_airflow > world.time - vsc.airflow_delay) continue

		if(ismob(M) && abs(n) > vsc.airflow_medium_pressure)
			if(M:nodamage) continue
			M:airflow_stun()

		if(M.check_airflow_movable(abs(n)))

			var/list/close_turfs = list()
			for(var/turf/U in connected_turfs)
				if(M in range(U)) close_turfs += U
			if(!close_turfs.len) continue

			//If they're already being tossed, don't do it again.
			if(!M.airflow_speed)

				M.airflow_dest = pick(close_turfs) //Pick a random midpoint to fly towards.

				spawn M.RepelAirflowDest(abs(n)/5)

proc/AirflowSpace(zone/A)

	//The space version of the Airflow(A,B,n) proc.

	var/n = A.air.return_pressure()
	//Here, n is determined by only the pressure in the room.

	if(n < vsc.airflow_lightest_pressure) return

	var/list/connected_turfs = A.space_tiles //The midpoints are now all the space connections.
	var/list/pplz = A.movables() //We only need to worry about things in the zone, not things in space.

	for(var/atom/movable/M in pplz)

		if(M.last_airflow > world.time - vsc.airflow_delay) continue

		if(ismob(M) && n > vsc.airflow_medium_pressure)
			if(M:nodamage) continue
			M:airflow_stun()

		if(M.check_airflow_movable(n))

			var/list/close_turfs = list()
			for(var/turf/U in connected_turfs)
				if(M in range(U)) close_turfs += U
			if(!close_turfs.len) continue

			//If they're already being tossed, don't do it again.
			if(!M.airflow_speed)

				M.airflow_dest = pick(close_turfs) //Pick a random midpoint to fly towards.
				spawn
					if(M) M.GotoAirflowDest(n/20)
					//Sometimes shit breaks, and M isn't there after the spawn.

atom/movable
	var/turf/airflow_dest
	var/airflow_speed = 0
	var/airflow_time = 0
	var/last_airflow = 0

	proc/GotoAirflowDest(n)
		if(!airflow_dest) return
		if(airflow_speed < 0) return
		if(last_airflow > world.time - vsc.airflow_delay) return
		if(airflow_speed)
			airflow_speed = n/max(get_dist(src,airflow_dest),1)
			return
		last_airflow = world.time
		if(airflow_dest == loc)
			step_away(src,loc)
		if(ismob(src))
			if(src:nodamage) return
			if(istype(src, /mob/living/carbon/human))
				if(istype(src, /mob/living/carbon/human))
					if(src:buckled) return
					if(src:wear_suit)
						if(src:wear_suit.flags & SUITSPACE) return
					if(src:shoes)
						if(src:shoes.type == /obj/item/clothing/shoes/magboots && src:shoes.flags & NOSLIP) return
			src << "\red You are sucked away by airflow!"
		airflow_speed = min(round(n)/max(sqrt(get_dist(src,airflow_dest)),1),9)
		var
			xo = airflow_dest.x - src.x
			yo = airflow_dest.y - src.y
			od = 0
		airflow_dest = null
		if(!density)
			density = 1
			od = 1
		while(airflow_speed > 0)
			if(airflow_speed <= 0) return
			airflow_speed = min(airflow_speed,15)
			airflow_speed -= vsc.airflow_speed_decay
			if(airflow_speed > 7)
				if(airflow_time++ >= airflow_speed - 7)
					sleep(1 * tick_multiplier)
			else
				sleep(max(1,10-(airflow_speed+3)) * tick_multiplier)
			if ((!( src.airflow_dest ) || src.loc == src.airflow_dest))
				src.airflow_dest = locate(min(max(src.x + xo, 1), world.maxx), min(max(src.y + yo, 1), world.maxy), src.z)
			if ((src.x == 1 || src.x == world.maxx || src.y == 1 || src.y == world.maxy))
				return
			step_towards(src, src.airflow_dest)
			if(ismob(src) && src:client) src:client:move_delay = world.time + vsc.airflow_mob_slowdown
		airflow_dest = null
		airflow_speed = 0
		airflow_time = 0
		if(od)
			density = 0

	proc/RepelAirflowDest(n)
		if(!airflow_dest) return
		if(airflow_speed < 0) return
		if(last_airflow > world.time - vsc.airflow_delay) return
		if(airflow_speed)
			airflow_speed = n/max(get_dist(src,airflow_dest),1)
			return
		last_airflow = world.time
		if(airflow_dest == loc)
			step_away(src,loc)
		if(ismob(src))
			if(src:nodamage) return
			if(istype(src, /mob/living/carbon/human))
				if(istype(src, /mob/living/carbon/human))
					if(src:buckled) return
					if(src:wear_suit)
						if(src:wear_suit.flags & SUITSPACE) return
					if(src:shoes)
						if(src:shoes.type == /obj/item/clothing/shoes/magboots && src:shoes.flags & NOSLIP) return
			src << "\red You are pushed away by airflow!"
		airflow_speed = min(round(n)/max(sqrt(get_dist(src,airflow_dest)),1),9)
		var
			xo = -(airflow_dest.x - src.x)
			yo = -(airflow_dest.y - src.y)
			od = 0
		airflow_dest = null
		if(!density)
			density = 1
			od = 1
		while(airflow_speed > 0)
			if(airflow_speed <= 0) return
			airflow_speed = min(airflow_speed,15)
			airflow_speed -= vsc.airflow_speed_decay
			if(airflow_speed > 7)
				if(airflow_time++ >= airflow_speed - 7)
					sleep(1 * tick_multiplier)
			else
				sleep(max(1,10-(airflow_speed+3)) * tick_multiplier)
			if ((!( src.airflow_dest ) || src.loc == src.airflow_dest))
				src.airflow_dest = locate(min(max(src.x + xo, 1), world.maxx), min(max(src.y + yo, 1), world.maxy), src.z)
			if ((src.x == 1 || src.x == world.maxx || src.y == 1 || src.y == world.maxy))
				return
			step_towards(src, src.airflow_dest)
			if(ismob(src) && src:client) src:client:move_delay = world.time + vsc.airflow_mob_slowdown
		airflow_dest = null
		airflow_speed = 0
		airflow_time = 0
		if(od)
			density = 0

	Bump(atom/A)
		if(airflow_speed > 0 && airflow_dest)
			airflow_hit(A)
		else
			airflow_speed = 0
			airflow_time = 0
			. = ..()

atom/movable/proc/airflow_hit(atom/A)
	airflow_speed = 0
	airflow_dest = null

mob/airflow_hit(atom/A)
	for(var/mob/M in hearers(src))
		M.show_message("\red <B>[src] slams into [A]!</B>",1,"\red You hear a loud slam!",2)
	playsound(src.loc, "smash.ogg", 25, 1, -1)
	. = ..()

obj/airflow_hit(atom/A)
	for(var/mob/M in hearers(src))
		M.show_message("\red <B>[src] slams into [A]!</B>",1,"\red You hear a loud slam!",2)
	playsound(src.loc, "smash.ogg", 25, 1, -1)
	. = ..()

obj/item/airflow_hit(atom/A)
	airflow_speed = 0
	airflow_dest = null

mob/living/carbon/human/airflow_hit(atom/A)
	for(var/mob/M in hearers(src))
		M.show_message("\red <B>[src] slams into [A]!</B>",1,"\red You hear a loud slam!",2)
	playsound(src.loc, "punch", 25, 1, -1)
	loc:add_blood(src)
	if (src.wear_suit)
		src.wear_suit.add_blood(src)
	if (src.w_uniform)
		src.w_uniform.add_blood(src)
	var/b_loss = airflow_speed * vsc.airflow_damage

	var/blocked = run_armor_check("head","melee")
	apply_damage(b_loss/3, BRUTE, "head", blocked, 0, "Airflow")

	blocked = run_armor_check("chest","melee")
	apply_damage(b_loss/3, BRUTE, "chest", blocked, 0, "Airflow")

	blocked = run_armor_check("groin","melee")
	apply_damage(b_loss/3, BRUTE, "groin", blocked, 0, "Airflow")

	if(airflow_speed > 10)
		paralysis += round(airflow_speed * vsc.airflow_stun)
		stunned = max(stunned,paralysis + 3)
	else
		stunned += round(airflow_speed * vsc.airflow_stun/2)
	. = ..()

zone/proc/movables()
	. = list()
	for(var/turf/T in contents)
		for(var/atom/A in T)
			. += A