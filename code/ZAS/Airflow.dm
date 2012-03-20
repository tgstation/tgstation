/*

CONTAINS:
All AirflowX() procs, all Variable Setting Controls for airflow, save/load variable tweaks for airflow.

VARIABLES:

atom/movable/airflow_dest
	The destination turf of a flying object.

atom/movable/airflow_speed
	The speed (1-15) at which a flying object is traveling to airflow_dest. Decays over time.


CALLABLE PROCS:

AirflowRepel(turf/T, n, per)
	Causes objects to fly away from a point within a single zone.
	Called manually by air releasers. T is the location of the expanding gas.
	n is the pressure released. per indicates that n is a percent value if nonzero.
	RETURNS: Null

AirflowAttract(turf/T, n, per)
	Causes objects to fly to a point within a single zone.
	Called manually by air consumers. T is the location of the attractor.
	n is the pressure consumed. per indicates that n is a percent value if nonzero.
	RETURNS: Null


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

Airflow(zone/A, zone/B, n)
	Causes objects to fly along a pressure gradient.
	Called by zone updates. A and B are two connected zones.
	n is the pressure difference between them.

AirflowSpace(zone/A)
	Causes objects to fly into space.
	Called by zone updates. A is a zone connected to space.

atom/movable/GotoAirflowDest(n)
atom/movable/RepelAirflowDest(n)
	Called by main airflow procs to cause the object to fly to or away from destination at speed n.
	Probably shouldn't call this directly unless you know what you're
	doing and have set airflow_dest. airflow_hit() will be called if the object collides with an obstacle.

*/

var/tick_multiplier = 2
vs_control/var

	zone_update_delay = 10
	zone_update_delay_NAME = "Zone Update Delay"
	zone_update_delay_DESC = "The delay in ticks between updates of zones. Increase if lag is bad seemingly because of air."

	zone_share_percent = 2
	zone_share_percent_NAME = "Zone Connection Transfer %"
	zone_share_percent_DESC = "Percent of gas per connected tile that is shared between zones."

	//Used in /mob/carbon/human/life
	OXYGEN_LOSS = 2
	OXYGEN_LOSS_NAME = "Damage - Oxygen Loss"
	OXYGEN_LOSS_DESC = "A multiplier for damage due to lack of air, CO2 poisoning, and vacuum. Does not affect oxyloss\
	from being incapacitated or dying."
	TEMP_DMG = 2
	TEMP_DMG_NAME = "Damage - Temperature"
	TEMP_DMG_DESC = "A multiplier for damage due to body temperature irregularities."
	BURN_DMG = 6
	BURN_DMG_NAME = "Damage - Fire"
	BURN_DMG_DESC = "A multiplier for damage due to direct fire exposure."

	AF_TINY_MOVEMENT_THRESHOLD = 50 //% difference to move tiny items.
	AF_TINY_MOVEMENT_THRESHOLD_NAME = "Airflow - Tiny Movement Threshold %"
	AF_TINY_MOVEMENT_THRESHOLD_DESC = "Percent of 1 Atm. at which items with the tiny weight class will move."
	AF_SMALL_MOVEMENT_THRESHOLD = 70 //% difference to move small items.
	AF_SMALL_MOVEMENT_THRESHOLD_NAME = "Airflow - Small Movement Threshold %"
	AF_SMALL_MOVEMENT_THRESHOLD_DESC = "Percent of 1 Atm. at which items with the small weight class will move."
	AF_NORMAL_MOVEMENT_THRESHOLD = 90 //% difference to move normal items.
	AF_NORMAL_MOVEMENT_THRESHOLD_NAME = "Airflow - Normal Movement Threshold %"
	AF_NORMAL_MOVEMENT_THRESHOLD_DESC = "Percent of 1 Atm. at which items with the normal weight class will move."
	AF_LARGE_MOVEMENT_THRESHOLD = 100 //% difference to move large and huge items.
	AF_LARGE_MOVEMENT_THRESHOLD_NAME = "Airflow - Large Movement Threshold %"
	AF_LARGE_MOVEMENT_THRESHOLD_DESC = "Percent of 1 Atm. at which items with the large or huge weight class will move."
	AF_DENSE_MOVEMENT_THRESHOLD = 120 //% difference to move dense crap and mobs.
	AF_DENSE_MOVEMENT_THRESHOLD_NAME = "Airflow - Dense Movement Threshold %"
	AF_DENSE_MOVEMENT_THRESHOLD_DESC = "Percent of 1 Atm. at which dense objects (canisters, etc.) will be shifted by airflow."
	AF_MOB_MOVEMENT_THRESHOLD = 175
	AF_MOB_MOVEMENT_THRESHOLD_NAME = "Airflow - Human Movement Threshold %"
	AF_MOB_MOVEMENT_THRESHOLD_DESC = "Percent of 1 Atm. at which mobs will be shifted by airflow."

	AF_HUMAN_STUN_THRESHOLD = 130
	AF_HUMAN_STUN_THRESHOLD_NAME = "Airflow - Human Stun Threshold %"
	AF_HUMAN_STUN_THRESHOLD_DESC = "Percent of 1 Atm. at which living things are stunned or knocked over."

	AF_PERCENT_OF = ONE_ATMOSPHERE
	AF_PERCENT_OF_NAME = "Airflow - 100% Pressure"
	AF_PERCENT_OF_DESC = "Normally set to 1 Atm. in kPa, this indicates what pressure is considered 100% by the system."

	AF_SPEED_MULTIPLIER = 4 //airspeed per movement threshold value crossed.
	AF_SPEED_MULTIPLIER_NAME = "Airflow - Speed Increase per 10%"
	AF_SPEED_MULTIPLIER_DESC = "Velocity increase of shifted items per 10% of airflow."
	AF_DAMAGE_MULTIPLIER = 5 //Amount of damage applied per airflow_speed.
	AF_DAMAGE_MULTIPLIER_NAME = "Airflow - Damage Per Velocity"
	AF_DAMAGE_MULTIPLIER_DESC = "Amount of damage applied per unit of speed (1-15 units) at which mobs are thrown."
	AF_STUN_MULTIPLIER = 1.5 //Seconds of stun applied per airflow_speed.
	AF_STUN_MULTIPLIER_NAME = "Airflow - Stun Per Velocity"
	AF_STUN_MULTIPLIER_DESC = "Amount of stun effect applied per unit of speed (1-15 units) at which mobs are thrown."
	AF_SPEED_DECAY = 0.5 //Amount that flow speed will decay with time.
	AF_SPEED_DECAY_NAME = "Airflow - Velocity Lost per Tick"
	AF_SPEED_DECAY_DESC = "Amount of airflow speed lost per tick on a moving object."
	AF_SPACE_MULTIPLIER = 2 //Increasing this will make space connections more DRAMATIC!
	AF_SPACE_MULTIPLIER_NAME = "Airflow - Space Airflow Multiplier"
	AF_SPACE_MULTIPLIER_DESC = "Increasing this multiplier will cause more powerful airflow to space."
	AF_CANISTER_MULTIPLIER = 0.25
	AF_CANISTER_MULTIPLIER_NAME = "Airflow - Canister Airflow Multiplier"
	AF_CANISTER_MULTIPLIER_DESC = "Increasing this multiplier will cause more powerful airflow from single-tile sources like canisters."

mob/proc
	Change_Airflow_Constants()
		set category = "Debug"

		var/choice = input("Which constant will you modify?","Change Airflow Constants")\
		as null|anything in list("Movement Threshold","Speed Multiplier","Damage Multiplier","Stun Multiplier","Speed Decay")

		var/n

		switch(choice)
			if("Movement Threshold")
				n = input("What will you change it to","Change Airflow Constants",vsc.AF_DENSE_MOVEMENT_THRESHOLD) as num
				n = max(1,n)
				vsc.AF_DENSE_MOVEMENT_THRESHOLD = n
				world.log << "vsc.AF_DENSE_MOVEMENT_THRESHOLD set to [n]."
			if("Speed Multiplier")
				n = input("What will you change it to","Change Airflow Constants",vsc.AF_SPEED_MULTIPLIER) as num
				n = max(1,n)
				vsc.AF_SPEED_MULTIPLIER = n
				world.log << "vsc.AF_SPEED_MULTIPLIER set to [n]."
			if("Damage Multiplier")
				n = input("What will you change it to","Change Airflow Constants",vsc.AF_DAMAGE_MULTIPLIER) as num
				vsc.AF_DAMAGE_MULTIPLIER = n
				world.log << "AF_DAMAGE_MULTIPLIER set to [n]."
			if("Stun Multiplier")
				n = input("What will you change it to","Change Airflow Constants",vsc.AF_STUN_MULTIPLIER) as num
				vsc.AF_STUN_MULTIPLIER = n
				world.log << "AF_STUN_MULTIPLIER set to [n]."
			if("Speed Decay")
				n = input("What will you change it to","Change Airflow Constants",vsc.AF_SPEED_DECAY) as num
				vsc.AF_SPEED_DECAY = n
				world.log << "AF_SPEED_DECAY set to [n]."
			if("Space Flow Multiplier")
				n = input("What will you change it to","Change Airflow Constants",vsc.AF_SPEED_DECAY) as num
				vsc.AF_SPEED_DECAY = n
				world.log << "AF_SPEED_DECAY set to [n]."


//The main airflow code. Called by zone updates.
//Zones A and B are air zones. n represents the amount of air moved.

mob/proc/airflow_stun()
	if(weakened <= 0) src << "\red The sudden rush of air knocks you over!"
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
	if(weakened <= 0) src << "\red The sudden rush of air knocks you over!"
	weakened = max(weakened,2)

atom/movable/proc/check_airflow_movable(n)

	if(anchored && !ismob(src)) return 0

	if(!istype(src,/obj/item) && n < vsc.AF_DENSE_MOVEMENT_THRESHOLD) return 0
	if(ismob(src) && n < vsc.AF_MOB_MOVEMENT_THRESHOLD) return 0

	return 1

mob/dead/observer/check_airflow_movable()
	return 0

mob/living/silicon/check_airflow_movable()
	return 0


obj/item/check_airflow_movable(n)
	. = ..()
	switch(w_class)
		if(2)
			if(n < vsc.AF_SMALL_MOVEMENT_THRESHOLD) return 0
		if(3)
			if(n < vsc.AF_NORMAL_MOVEMENT_THRESHOLD) return 0
		if(4,5)
			if(n < vsc.AF_LARGE_MOVEMENT_THRESHOLD) return 0

proc/Airflow(zone/A,zone/B,n)

	 //Now n is a percent of one atm.
	n = round((n/vsc.AF_PERCENT_OF)*100,0.1)

	 //Don't go any further if n is lower than the lowest value needed for airflow.
	if(abs(n) < vsc.AF_TINY_MOVEMENT_THRESHOLD) return

	//These turfs are the midway point between A and B, and will be the destination point for thrown objects.
	var/list/connected_turfs = A.connections[B]

	//Get lists of things that can be thrown across the room for each zone.
	var/list/pplz = A.movables()
	var/list/otherpplz = B.movables()

	for(var/atom/movable/M in pplz)

		//Check for knocking people over
		if(ismob(M) && n > vsc.AF_HUMAN_STUN_THRESHOLD)
			if(M:nodamage) continue
			M:airflow_stun()

		if(M.check_airflow_movable(n))

			//Check for things that are in range of the midpoint turfs.
			var/fail = 1
			for(var/turf/U in connected_turfs)
				if(M in range(U)) fail = 0
			if(fail) continue

			//If they're already being tossed, don't do it again.
			if(!M.airflow_speed)

				M.airflow_dest = pick(connected_turfs) //Pick a random midpoint to fly towards.

				spawn M.GotoAirflowDest(abs(n) * (vsc.AF_SPEED_MULTIPLIER/10))
				//Send the object flying at a speed determined by n and AF_SPEED_MULTIPLIER.

	//Do it again for the stuff in the other zone, making it fly away.
	for(var/atom/movable/M in otherpplz)

		if(ismob(M) && abs(n) > vsc.AF_HUMAN_STUN_THRESHOLD)
			if(M:nodamage) continue
			M:airflow_stun()

		if(M.check_airflow_movable(abs(n)))

			var/fail = 1
			for(var/turf/U in connected_turfs)
				if(M in range(U)) fail = 0
			if(fail) continue

			if(M && !M.airflow_speed)

				M.airflow_dest = pick(connected_turfs)

				spawn M.RepelAirflowDest(abs(n) * (vsc.AF_SPEED_MULTIPLIER/10))

proc/AirflowSpace(zone/A)

	//The space version of the Airflow(A,B,n) proc.

	var/n = (A.air.oxygen + A.air.nitrogen + A.air.carbon_dioxide)*vsc.AF_SPACE_MULTIPLIER
	//Here, n is determined by the space multiplier constant and the zone's air.

	n = round((n/vsc.AF_PERCENT_OF)*100,0.1)

	if(n < vsc.AF_TINY_MOVEMENT_THRESHOLD) return

	var/list/connected_turfs = A.space_tiles //The midpoints are now all the space connections.
	var/list/pplz = A.movables() //We only need to worry about things in the zone, not things in space.

	for(var/atom/movable/M in pplz)

		if(ismob(M) && n > vsc.AF_HUMAN_STUN_THRESHOLD)
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
					if(M) M.GotoAirflowDest(n * (vsc.AF_SPEED_MULTIPLIER/10))
					//Sometimes shit breaks, and M isn't there after the spawn.

proc/AirflowRepel(turf/T,n,per = 0)

	//This one is used for air escaping from canisters.
	var/zone/A = T.zone
	if(!A) return

	n *= vsc.AF_CANISTER_MULTIPLIER

	if(!per)
		n = round((n/vsc.AF_PERCENT_OF) * 100,0.1)

	if(n < 0) return
	if(abs(n) > vsc.AF_TINY_MOVEMENT_THRESHOLD)

		var/list/pplz = A.movables()

		for(var/atom/movable/M in pplz)
			var/relative_n = n / max(1,get_dist(T,M)/2)
			if(ismob(M) && relative_n > vsc.AF_HUMAN_STUN_THRESHOLD)
				if(M:nodamage) continue
				M:airflow_stun()

			if(M.check_airflow_movable(relative_n))

				if(!(M in range(T))) continue //Recall that T is the center of the repelling force.

				if(!M.airflow_speed)
					M.airflow_dest = T
					spawn M.RepelAirflowDest(relative_n * (vsc.AF_SPEED_MULTIPLIER/10))

proc/AirflowAttract(turf/T,n,per=0)

	//Same as above, but attracts objects to the target.

	var/zone/A = T.zone
	if(!A) return

	n *= vsc.AF_CANISTER_MULTIPLIER

	if(!per)
		n = round((n/vsc.AF_PERCENT_OF) * 100,0.1)

	if(n < 0) return
	if(abs(n) > vsc.AF_TINY_MOVEMENT_THRESHOLD)
		//world << "Airflow!"
		var/list/pplz = A.movables()
		for(var/atom/movable/M in pplz)
			//world << "[M] / \..."

			var/relative_n = n / max(1,get_dist(T,M)/2)

			if(ismob(M) && relative_n > vsc.AF_HUMAN_STUN_THRESHOLD)
				if(M:nodamage) continue
				M:airflow_stun()

			if(M.check_airflow_movable(relative_n))

				if(!(M in range(T))) continue

				if(!M.airflow_speed)
					M.airflow_dest = T
					spawn M.GotoAirflowDest(relative_n * (vsc.AF_SPEED_MULTIPLIER/10))

atom/movable
	var/turf/airflow_dest
	var/airflow_speed = 0
	var/airflow_time = 0

	proc/GotoAirflowDest(n)
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
			src << "\red You are sucked away by airflow!"
		airflow_speed = min(round(n),9)
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
			airflow_speed -= vsc.AF_SPEED_DECAY
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

	proc/RepelAirflowDest(n)
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
			airflow_speed -= vsc.AF_SPEED_DECAY
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
	var/b_loss = airflow_speed * vsc.AF_DAMAGE_MULTIPLIER
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
		paralysis += round(airflow_speed * vsc.AF_STUN_MULTIPLIER)
		stunned = max(stunned,paralysis + 3)
	else
		stunned += round(airflow_speed * vsc.AF_STUN_MULTIPLIER/2)
	. = ..()

zone/proc/movables()
	. = list()
	for(var/turf/T in contents)
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
	F << vsc
	del F
	world.log << "TWEAKS: Airflow, Plasma and Damage settings saved."
proc/LoadTweaks()
	if(fexists("data/game_settings.sav"))
		var/savefile/F = new("data/game_settings.sav")
		F >> vsc
		del F
		world.log << "TWEAKS: Airflow, Plasma and Damage settings loaded."