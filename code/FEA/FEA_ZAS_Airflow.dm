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
	Called when airflow quantities exceed AF_HUMAN_STUN_THRESHOLD.
	RETURNS: Null

atom/movable/check_airflow_movable(n)
	Contains checks for moving any object due to airflow.
	n is the percent of 1 Atmosphere that is flowing.
	RETURNS: 1 if the object moves under the air conditions, 0 if it stays put.

atom/movable/airflow_hit(atom/A)
	Contains results of hitting a solid object (A) due to airflow.
	A is the dense object hit.
	Use airflow_speed to determine how fast the projectile was going.


AUTOMATIC PROCS:

Airflow(datum/air_group/A, datum/air_group/B, n, vae/list/turf/simulated/target)
	Causes objects to fly along a pressure gradient.
	Called by airflow calculations finding a high pressure gradient. A and B are two adjacent airgroups.
	n is the pressure difference between them.
	targets is a list of turfs between them.

AirflowSpace(zone/A)
	Causes objects to fly into space.
	Called by airflow to space. A is a airgroup connected to space.

atom/movable/GotoAirflowDest(n)
atom/movable/RepelAirflowDest(n)
	Called by main airflow procs to cause the object to fly to or away from destination at speed n.
	Probably shouldn't call this directly unless you know what you're
	doing and have set airflow_dest. airflow_hit() will be called if the object collides with an obstacle.

*/

mob/proc/airflow_stun()
	//Purpose: AIRFLOW
	//Called by: AIRFLOW
	//Inputs: Hate
	//Outputs: Sadness

	if(weakened <= 0)
		src << pickweight("\red The sudden rush of air knocks you over!"  = 5, "\red You get dragged off your feet by a rush of air!" = 5, "\red <b>FUCKING AIRFLOW!</b>" = 1)
	weakened = max(weakened,5)

mob/living/silicon/airflow_stun()
	return

mob/living/carbon/metroid/airflow_stun()
	return

mob/living/carbon/human/airflow_stun()
	if(buckled) return 0
	if(wear_suit)
		if(wear_suit.flags & SUITSPACE) return 0
	if(shoes)
		if(shoes.flags & NOSLIP) return 0
	if(weakened <= 0)
		src << pickweight("\red The sudden rush of air knocks you over!"  = 5, "\red You get dragged off your feet by a rush of air!" = 5, "\red <b>FUCKING AIRFLOW!</b>" = 1)
	weakened = max(weakened,2)

atom/movable/proc/check_airflow_movable(n)
	//Purpose: Determining if src is movable by airflow.
	//Called by: AIRFLOW
	//Inputs: Movement force
	//Outputs: Boolean of capability to be moved.

	if(anchored && !ismob(src)) return 0

	if(!istype(src,/obj/item) && n < air_master.AF_DENSE_MOVEMENT_THRESHOLD) return 0
	if(ismob(src) && n < air_master.AF_MOB_MOVEMENT_THRESHOLD) return 0

	return 1

mob/dead/observer/check_airflow_movable()
	return 0

mob/living/silicon/check_airflow_movable()
	return 0


obj/item/check_airflow_movable(n)
	. = ..()
	switch(w_class)
		if(2)
			if(n < air_master.AF_SMALL_MOVEMENT_THRESHOLD) return 0
		if(3)
			if(n < air_master.AF_NORMAL_MOVEMENT_THRESHOLD) return 0
		if(4,5)
			if(n < air_master.AF_LARGE_MOVEMENT_THRESHOLD) return 0

proc/Airflow(datum/air_group/A,datum/air_group/B,n,var/list/turf/simulated/target)
	//Purpose: AIRFLOW between two airgroups.
	//Called by: AIRFLOW
	//Inputs: Air group venting, Air group receiving, force of airflow, midpoint turf(s)
	//Outputs: None.

	 //Now n is a percent of one atm.
	n = round((n/air_master.AF_PERCENT_OF)*100,0.1)

	 //Don't go any further if n is lower than the lowest value needed for airflow.
	if(abs(n) < air_master.AF_TINY_MOVEMENT_THRESHOLD)
		return

	if(!target || !target.len)
		return

	//Get lists of things that can be thrown across the room for each zone.
	var/list/pplz = A.movables()
	var/list/otherpplz = B.movables()

	for(var/atom/movable/M in pplz)

		//Check for knocking people over
		if(ismob(M) && n > air_master.AF_HUMAN_STUN_THRESHOLD)
			if(M:nodamage) continue
			M:airflow_stun()

		if(M.check_airflow_movable(n))

			//Check for things that are in range of the midpoint turfs.
			var/fail = 1
			for(var/turf/simulated/T in target)
				if(M in range(T))
					fail = 0
					break
			if(fail)
				continue

			//If they're already being tossed, don't do it again.
			if(!M.airflow_speed)

				M.airflow_dest = pick(target) //Pick a random midpoint to fly towards.

				spawn M.GotoAirflowDest(abs(n) * (air_master.AF_SPEED_MULTIPLIER/10))
				//Send the object flying at a speed determined by n and AF_SPEED_MULTIPLIER.

	//Do it again for the stuff in the other zone, making it fly away.
	for(var/atom/movable/M in otherpplz)

		if(ismob(M) && abs(n) > air_master.AF_HUMAN_STUN_THRESHOLD)
			if(M:nodamage) continue
			M:airflow_stun()

		if(M.check_airflow_movable(abs(n)))

			var/fail = 1
			for(var/turf/simulated/T in target)
				if(M in range(T))
					fail = 0
					break
			if(fail)
				continue

			if(M && !M.airflow_speed)

				M.airflow_dest = pick(target)

				spawn M.RepelAirflowDest(abs(n) * (air_master.AF_SPEED_MULTIPLIER/10))

proc/AirflowSpace(datum/air_group/A)
	//Purpose: AIRFLOW between an airgroup and spess.
	//Called by: AIRFLOW
	//Inputs: Air group venting into space.
	//Outputs: None.
	//    The space version of the Airflow(A,B,n) proc.

	var/n = A.air.total_moles*air_master.AF_SPACE_MULTIPLIER
	//Here, n is determined by the space multiplier constant and the zone's air.

	n = round((n/air_master.AF_PERCENT_OF)*100,0.1)

	if(n < air_master.AF_TINY_MOVEMENT_THRESHOLD) return

	var/list/connected_turfs = A.space_borders //The midpoints are now all the space connections.
	var/list/pplz = A.movables() //We only need to worry about things in the zone, not things in space.

	for(var/atom/movable/M in pplz)

		if(ismob(M) && n > air_master.AF_HUMAN_STUN_THRESHOLD)
			if(M:nodamage) continue
			M:airflow_stun()

		if(M.check_airflow_movable(n))

			var/fail = 1
			for(var/turf/U in connected_turfs)
				if(M in range(U)) fail = 0
			if(fail) continue

			if(!M.airflow_speed)
				M.airflow_dest = pick(connected_turfs)
				spawn
					if(M) M.GotoAirflowDest(n * (air_master.AF_SPEED_MULTIPLIER/10))
					//Sometimes shit breaks, and M isn't there after the spawn.

/atom/movable
	var/turf/airflow_dest
	var/airflow_speed = 0
	var/airflow_time = 0

	proc/GotoAirflowDest(n)
		//Purpose: Moving src between it's current position and where air is dragging them.
		//Called by: AIRFLOW
		//Inputs: Force.
		//Outputs: None.

		if(!airflow_dest) return
		if(airflow_speed < 0) return
		if(airflow_speed)
			airflow_speed = n
			return
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

		airflow_speed = min(round(n),9)
		airflow_speed /= get_dist(src,airflow_dest) //The further away you are, the less you get dragged.
		var
			xo = airflow_dest.x - src.x
			yo = airflow_dest.y - src.y
			od = 0
		airflow_dest = null
		if(!density)
			density = 1
			od = 1 //It wasn't dense, but it is considered it for when being moved by airflow.
		//Main loop to AIRFLOW
		while(airflow_speed > 0)
			if(airflow_speed <= 0) return
			airflow_speed = min(airflow_speed,15)
			airflow_speed -= air_master.AF_SPEED_DECAY
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
			if(ismob(src) && src:client) src:client:move_delay = world.time + 10
		airflow_dest = null
		//You cannot be tossed around by airflow more than once ever 1.5(times tick_multiplier) seconds)
		airflow_speed = -1
		spawn(150 * tick_multiplier) airflow_speed = 0
		//Reset density.
		if(od)
			density = 0

	proc/RepelAirflowDest(n)
		//Purpose: Moving src between it's current position and where air is pushing them.
		//Called by: AIRFLOW
		//Inputs: Force.
		//Outputs: None.

		if(!airflow_dest) return
		if(airflow_speed < 0) return
		if(airflow_speed)
			airflow_speed = n
			return
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
						if(src:shoes.type == /obj/item/clothing/shoes/magboots) return
			src << "\red You are pushed away by airflow!"
		airflow_speed = min(round(n),9)
		airflow_speed /= get_dist(src,airflow_dest) //The further away you are, the less you get dragged.
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
			airflow_speed -= air_master.AF_SPEED_DECAY
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
			if(ismob(src) && src:client) src:client:move_delay = world.time + 10
		airflow_dest = null
		airflow_speed = -1
		spawn(150 * tick_multiplier) airflow_speed = 0
		if(od)
			density = 0

	Bump(atom/A)
		if(airflow_speed > 0 && airflow_dest)
			airflow_hit(A)
		else
			airflow_speed = 0
			. = ..()

atom/movable/proc/airflow_hit(atom/A)
	//Purpose: Managing impacts between objects whirled around by airflow.
	//Called by: AIRFLOW
	//Inputs: Object to impact.
	//Outputs: None.

	airflow_speed = -1
	spawn(50 * tick_multiplier) airflow_speed = 0
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
	airflow_speed = -1
	spawn(50 * tick_multiplier) airflow_speed = 0
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
	var/b_loss = airflow_speed * air_master.AF_DAMAGE_MULTIPLIER
	for(var/organ in src:organs)
		var/datum/organ/external/temp = src:organs["[organ]"]
		if (istype(temp, /datum/organ/external))
			switch(temp.name)
				if("head")
					temp.take_damage(b_loss * 0.2, 0)
				if("chest")
					temp.take_damage(b_loss * 0.4, 0)
				if("diaper")
					temp.take_damage(b_loss * 0.1, 0)
	spawn UpdateDamageIcon()
	if(airflow_speed > 10)
		paralysis += round(airflow_speed * air_master.AF_STUN_MULTIPLIER)
		stunned = max(stunned,paralysis + 3)
	else
		stunned += round(airflow_speed * air_master.AF_STUN_MULTIPLIER/2)
	. = ..()

/datum/air_group/proc/movables()
	//Purpose: Returns everything movable.
	//Called by: AIRFLOW
	//Inputs: Possible objects to move.
	//Outputs: None.

	. = list()
	for(var/turf/T in members)
		for(var/atom/A in T)
			. += A

proc/Get_Dir(atom/S,atom/T) //Shamelessly stolen from AJX.AdvancedGetDir
	var/GDist=get_dist(S,T)
	var/GDir=get_dir(S,T)
	if(GDist<=3)
		if(GDist==0) return 0
		if(GDist==1)
			return GDir


	var/X1=S.x*10
	var/X2=T.x*10
	var/Y1=S.y*10
	var/Y2=T.y*10
	var/Ref
	if(GDir==NORTHEAST)
		Ref=(X2/X1)*Y1
		if(Ref-1>Y2) .=EAST
		else if(Ref+1<Y2) .=NORTH
		else .=NORTHEAST
	else if(GDir==NORTHWEST)
		Ref=(1+((1-(X2/X1))))*Y1
		if(Ref-1>Y2) .=WEST
		else if(Ref+1<Y2) .=NORTH
		else .=NORTHWEST
	else if(GDir==SOUTHEAST)
		Ref=(1-((X2/X1)-1))*Y1
		if(Ref-1>Y2) .=SOUTH
		else if(Ref+1<Y2) .=EAST
		else .=SOUTHEAST
	else if(GDir==SOUTHWEST)
		Ref=(X2/X1)*Y1
		if(Ref-1>Y2) .=SOUTH
		else if(Ref+1<Y2) .=WEST
		else .=SOUTHWEST
	else
		return GDir

proc/SaveTweaks()
	var/savefile/F = new("data/game_settings.sav")
	F << air_master
	del F
	world.log << "TWEAKS: Airflow, Plasma and Damage settings saved."
proc/LoadTweaks()
	if(fexists("data/game_settings.sav"))
		var/savefile/F = new("data/game_settings.sav")
		F >> air_master
		del F
		world.log << "TWEAKS: Airflow, Plasma and Damage settings loaded."