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

mob/var/tmp/last_airflow_stun = 0
mob/proc/airflow_stun()
	if(stat == 2)
		return 0
	if(last_airflow_stun > world.time - zas_settings.Get(/datum/ZAS_Setting/airflow_stun_cooldown))	return 0
	if(!(status_flags & CANSTUN) && !(status_flags & CANWEAKEN))
		src << "\blue You stay upright as the air rushes past you."
		return 0

	if(weakened <= 0) src << "\red The sudden rush of air knocks you over!"
	weakened = max(weakened,5)
	last_airflow_stun = world.time
	return

mob/living/silicon/airflow_stun()
	return

mob/living/carbon/metroid/airflow_stun()
	return

mob/living/carbon/human/airflow_stun()
	if(last_airflow_stun > world.time - zas_settings.Get(/datum/ZAS_Setting/airflow_stun_cooldown))	return 0
	if(buckled) return 0
	if(shoes)
		if(shoes.flags & NOSLIP) return 0
	if(!(status_flags & CANSTUN) && !(status_flags & CANWEAKEN))
		src << "\blue You stay upright as the air rushes past you."
		return 0

	if(weakened <= 0) src << "\red The sudden rush of air knocks you over!"
	weakened = max(weakened,rand(1,5))
	last_airflow_stun = world.time
	return

atom/movable/proc/check_airflow_movable(n)
	if(anchored && !ismob(src))
		return 0
	if(!istype(src,/obj/item) && n < zas_settings.Get(/datum/ZAS_Setting/airflow_dense_pressure))
		return 0

	return 1

mob/check_airflow_movable(n)
	if(n < zas_settings.Get(/datum/ZAS_Setting/airflow_heavy_pressure))
		return 0
	return 1

mob/dead/observer/check_airflow_movable()
	return 0

mob/living/silicon/check_airflow_movable()
	return 0


obj/item/check_airflow_movable(n)
	. = ..()
	switch(w_class)
		if(2)
			if(n < zas_settings.Get(/datum/ZAS_Setting/airflow_lightest_pressure)) return 0
		if(3)
			if(n < zas_settings.Get(/datum/ZAS_Setting/airflow_light_pressure)) return 0
		if(4,5)
			if(n < zas_settings.Get(/datum/ZAS_Setting/airflow_medium_pressure)) return 0

/*
//The main airflow code. Called by zone updates.
//Zones A and B are air zones. n represents the amount of air moved.

proc/Airflow(zone/A, zone/B)

	var/n = B.air.return_pressure() - A.air.return_pressure()

	 //Don't go any further if n is lower than the lowest value needed for airflow.
	if(abs(n) < zas_settings.Get(/datum/ZAS_Setting/airflow_lightest_pressure)) return

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

	//Get lists of things that can be thrown across the room for each zone (assumes air is moving from zone B to zone A)
	var/list/air_sucked = B.movables()
	var/list/air_repelled = A.movables()
	if(n < 0)
		//air is moving from zone A to zone B
		var/list/temporary_pplz = air_sucked
		air_sucked = air_repelled
		air_repelled = temporary_pplz

	if(zas_settings.Get(/datum/ZAS_Setting/airflow_push) || 1) // If enabled
		for(var/atom/movable/M in air_sucked)
			if(M.last_airflow > world.time - zas_settings.Get(/datum/ZAS_Setting/airflow_delay)) continue

			//Check for knocking people over
			if(ismob(M) && n > zas_settings.Get(/datum/ZAS_Setting/airflow_stun_pressure))
				if(M:status_flags & GODMODE) continue
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
		for(var/atom/movable/M in air_repelled)

			if(M.last_airflow > world.time - zas_settings.Get(/datum/ZAS_Setting/airflow_delay)) continue

			if(ismob(M) && abs(n) > zas_settings.Get(/datum/ZAS_Setting/airflow_medium_pressure))
				if(M:status_flags & GODMODE) continue
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

	if(n < zas_settings.Get(/datum/ZAS_Setting/airflow_lightest_pressure)) return

	var/list/connected_turfs = A.unsimulated_tiles //The midpoints are now all the space connections.
	var/list/pplz = A.movables() //We only need to worry about things in the zone, not things in space.

	if(zas_settings.Get(/datum/ZAS_Setting/airflow_push) || 1) // If enabled
		for(var/atom/movable/M in pplz)
			if(M.last_airflow > world.time - zas_settings.Get(/datum/ZAS_Setting/airflow_delay)) continue

			if(ismob(M) && n > zas_settings.Get(/datum/ZAS_Setting/airflow_stun_pressure))
				var/mob/O = M
				if(O.status_flags & GODMODE) continue
				O.airflow_stun()

			if(M.check_airflow_movable(n))

				var/list/close_turfs = list()
				for(var/turf/U in connected_turfs)
					if(M in range(U)) close_turfs += U
				if(!close_turfs.len) continue

				//If they're already being tossed, don't do it again.
				if(!M.airflow_speed)

					M.airflow_dest = pick(close_turfs) //Pick a random midpoint to fly towards.
					spawn
						if(M) M.GotoAirflowDest(n/10)
						//Sometimes shit breaks, and M isn't there after the spawn.
*/

/atom/movable/var/tmp/turf/airflow_dest
/atom/movable/var/tmp/airflow_speed = 0
/atom/movable/var/tmp/airflow_time = 0
/atom/movable/var/tmp/last_airflow = 0

// Mainly for bustanuts.
/atom/movable/proc/AirflowCanPush()
	return 1

/mob/AirflowCanPush()
	if (M_HARDCORE in mutations)
		return 0
	return 1

/atom/movable/proc/GotoAirflowDest(n)
	last_airflow = world.time
	if(airflow_dest == loc)
		step_away(src,loc)
	if(ismob(src))
		if(src:status_flags & GODMODE)
			return
		if(istype(src, /mob/living/carbon/human))
			if(src:buckled)
				return
			if(src:shoes)
				if(istype(src:shoes, /obj/item/clothing/shoes/magboots))
					if(src:shoes:magpulse)
						return
		src << "\red You are sucked away by airflow!"
	var/airflow_falloff = 9 - ul_FalloffAmount(airflow_dest) //It's a fast falloff calc.  Very useful.
	if(airflow_falloff < 1)
		airflow_dest = null
		return
	airflow_speed = min(max(n * (9/airflow_falloff),1),9)
	var
		xo = airflow_dest.x - src.x
		yo = airflow_dest.y - src.y
		od = 0
	airflow_dest = null
	if(!density)
		density = 1
		od = 1
	spawn(0)
		while(airflow_speed > 0)
			airflow_speed = min(airflow_speed,15)
			airflow_speed -= zas_settings.Get(/datum/ZAS_Setting/airflow_speed_decay)
			if(airflow_speed > 7)
				if(airflow_time++ >= airflow_speed - 7)
					if(od)
						density = 0
					sleep(tick_multiplier)
			else
				if(od)
					density = 0
				sleep(max(1,10-(airflow_speed+3)) * tick_multiplier)
			if(od)
				density = 1
			if ((!( src.airflow_dest ) || src.loc == src.airflow_dest))
				airflow_dest = locate(Clamp(x + xo, 1, world.maxx), Clamp(y + yo, 1, world.maxy), z)
			if ((src.x == 1 || src.x == world.maxx || src.y == 1 || src.y == world.maxy))
				break
			if(!isturf(loc))
				break
			step_towards(src, src.airflow_dest)
			if(ismob(src) && src:client)
				src:client:move_delay = world.time + zas_settings.Get(/datum/ZAS_Setting/airflow_mob_slowdown)
		airflow_dest = null
		airflow_speed = 0
		airflow_time = 0
		if(od)
			density = 0


/atom/movable/proc/RepelAirflowDest(n)
	if(airflow_dest == loc)
		step_away(src,loc)
	if(ismob(src))
		if(src:status_flags & GODMODE)
			return
		if(istype(src, /mob/living/carbon/human))
			if(src:buckled)
				return
			if(src:shoes)
				if(istype(src:shoes, /obj/item/clothing/shoes/magboots))
					if(src:shoes.flags & NOSLIP)
						return
		src << "\red You are pushed away by airflow!"
		last_airflow = world.time
	var/airflow_falloff = 9 - ul_FalloffAmount(airflow_dest) //It's a fast falloff calc.  Very useful.
	if(airflow_falloff < 1)
		airflow_dest = null
		return
	airflow_speed = min(max(n * (9/airflow_falloff),1),9)
	var
		xo = -(airflow_dest.x - src.x)
		yo = -(airflow_dest.y - src.y)
		od = 0
	airflow_dest = null
	if(!density)
		density = 1
		od = 1
	spawn(0)
		while(airflow_speed > 0)
			airflow_speed = min(airflow_speed,15)
			airflow_speed -= zas_settings.Get(/datum/ZAS_Setting/airflow_speed_decay)
			if(airflow_speed > 7)
				if(airflow_time++ >= airflow_speed - 7)
					sleep(tick_multiplier)
			else
				sleep(max(1,10-(airflow_speed+3)) * tick_multiplier)
			if ((!( src.airflow_dest ) || src.loc == src.airflow_dest))
				airflow_dest = locate(Clamp(x + xo, 1, world.maxx), Clamp(y + yo, 1, world.maxy), z)
			if ((src.x == 1 || src.x == world.maxx || src.y == 1 || src.y == world.maxy))
				return
			if(!istype(loc, /turf))
				return
			step_towards(src, src.airflow_dest)
			if(ismob(src) && src:client)
				src:client:move_delay = world.time + zas_settings.Get(/datum/ZAS_Setting/airflow_mob_slowdown)
		airflow_dest = null
		airflow_speed = 0
		airflow_time = 0
		if(od)
			density = 0

/atom/movable/Bump(atom/Obstacle)
	if(airflow_speed > 0 && airflow_dest)
		airflow_hit(Obstacle)
	else
		airflow_speed = 0
		airflow_time = 0
		. = ..()

atom/movable/proc/airflow_hit(atom/A)
	airflow_speed = 0
	airflow_dest = null

mob/airflow_hit(atom/A)
	for(var/mob/M in hearers(src))
		M.show_message("\red <B>\The [src] slams into \a [A]!</B>",1,"\red You hear a loud slam!",2)
	//playsound(get_turf(src), "smash.ogg", 25, 1, -1)
	weakened = max(weakened, (istype(A,/obj/item) ? A:w_class : rand(1,5))) //Heheheh
	. = ..()

obj/airflow_hit(atom/A)
	for(var/mob/M in hearers(src))
		M.show_message("\red <B>\The [src] slams into \a [A]!</B>",1,"\red You hear a loud slam!",2)
	//playsound(get_turf(src), "smash.ogg", 25, 1, -1)
	. = ..()

obj/item/airflow_hit(atom/A)
	airflow_speed = 0
	airflow_dest = null

mob/living/carbon/human/airflow_hit(atom/A)
//	for(var/mob/M in hearers(src))
//		M.show_message("\red <B>[src] slams into [A]!</B>",1,"\red You hear a loud slam!",2)
	//playsound(get_turf(src), "punch", 25, 1, -1)
	if(prob(33))
		loc:add_blood(src)
		bloody_body(src)

	var/b_loss = airflow_speed * zas_settings.Get(/datum/ZAS_Setting/airflow_damage)

	var/blocked = run_armor_check("head","melee")
	apply_damage(b_loss/3, BRUTE, "head", blocked, 0, used_weapon = "Airflow")

	blocked = run_armor_check("chest","melee")
	apply_damage(b_loss/3, BRUTE, "chest", blocked, 0, used_weapon = "Airflow")

	blocked = run_armor_check("groin","melee")
	apply_damage(b_loss/3, BRUTE, "groin", blocked, 0, used_weapon = "Airflow")

	if(zas_settings.Get(/datum/ZAS_Setting/airflow_push) || AirflowCanPush())
		if(airflow_speed > 10)
			paralysis += round(airflow_speed * zas_settings.Get(/datum/ZAS_Setting/airflow_stun))
			stunned = max(stunned,paralysis + 3)
		else
			stunned += round(airflow_speed * zas_settings.Get(/datum/ZAS_Setting/airflow_stun)/2)

	. = ..()

zone/proc/movables()
	. = list()
	for(var/turf/T in contents)
		for(var/atom/A in T)
			if(istype(A, /obj/effect) || isobserver(A) || isAIEye(A))
				continue
			. += A
