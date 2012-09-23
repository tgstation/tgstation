/client/proc/kaboom()
	var/power = input(src, "power?", "power?") as num
	var/turf/T = get_turf(src.mob)
	explosion_rec(T, power)

/obj
	var/explosion_resistance

/datum/explosion_turf
	var/turf/turf //The turf which will get ex_act called on it
	var/max_power //The largest amount of power the turf sustained

	New()
		..()
		max_power = 0

	proc/save_power_if_larger(power)
		if(power > max_power)
			max_power = power
			return 1
		return 0

var/list/datum/explosion_turf/explosion_turfs = list()
var/explosion_in_progress = 0

proc/get_explosion_turf(var/turf/T)
	for( var/datum/explosion_turf/ET in explosion_turfs )
		if( T == ET.turf )
			return ET
	var/datum/explosion_turf/ET = new()
	ET.turf = T
	explosion_turfs += ET
	return ET

proc/explosion_rec(turf/epicenter, power)

	var/loopbreak = 0
	while(explosion_in_progress)
		if(loopbreak >= 15) return
		sleep(10)
		loopbreak++

	if(power <= 0) return
	epicenter = get_turf(epicenter)
	if(!epicenter) return

	message_admins("Explosion with size ([power]) in area [epicenter.loc.name] ([epicenter.x],[epicenter.y],[epicenter.z])")
	log_game("Explosion with size ([power]) in area [epicenter.loc.name] ")

	playsound(epicenter, 'sound/effects/explosionfar.ogg', 100, 1, round(power*2,1) )
	playsound(epicenter, "explosion", 100, 1, round(power,1) )

	explosion_in_progress = 1
	explosion_turfs = list()
	var/datum/explosion_turf/ETE = get_explosion_turf()
	ETE.turf = epicenter
	ETE.max_power = power

	//This steap handles the gathering of turfs which will be ex_act() -ed in the next step. It also ensures each turf gets the maximum possible amount of power dealt to it.
	for(var/direction in cardinal)
		var/turf/T = get_step(epicenter, direction)
		T.explosion_spread(power - epicenter.explosion_resistance, direction)

	//This step applies the ex_act effects for the explosion, as planned in the previous step.
	for( var/datum/explosion_turf/ET in explosion_turfs )
		if(ET.max_power <= 0) continue
		if(!ET.turf) continue

		var/severity = 4 - round(max(min( 3, (ET.max_power / 3) ) ,1), 1)
		var/x = ET.turf.x
		var/y = ET.turf.y
		var/z = ET.turf.z
		ET.turf.ex_act(severity)
		if(!ET.turf)
			ET.turf = locate(x,y,z)
		for( var/atom/A in ET.turf )
			A.ex_act(severity)

	explosion_in_progress = 0

/turf
	var/explosion_resistance

/turf/space
	explosion_resistance = 10

/turf/simulated/floor
	explosion_resistance = 1

/turf/simulated/mineral
	explosion_resistance = 2

/turf/simulated/shuttle/floor
	explosion_resistance = 1

/turf/simulated/shuttle/floor4
	explosion_resistance = 1

/turf/simulated/shuttle/plating
	explosion_resistance = 1

/turf/simulated/shuttle/wall
	explosion_resistance = 5

/turf/simulated/wall
	explosion_resistance = 5

/turf/simulated/r_wall
	explosion_resistance = 25

/turf/simulated/wall/r_wall
	explosion_resistance = 25

//Code-wise, a safe value for power is something up to ~25 or ~30.. This does quite a bit of damage to the station.
//direction is the direction that the spread took to come to this tile. So it is pointing in the main blast direction - meaning where this tile should spread most of it's force.
/turf/proc/explosion_spread(power, direction)
	if(power <= 0)
		return

	/*
	sleep(2)
	new/obj/effect/debugging/marker(src)
	*/

	var/datum/explosion_turf/ET = get_explosion_turf(src)
	if(ET.max_power >= power)
		return //The turf already sustained and spread a power greated than what we are dealing with. No point spreading again.
	ET.max_power = power

	var/spread_power = power - src.explosion_resistance //This is the amount of power that will be spread to the tile in the direction of the blast
	var/side_spread_power = power - 2 * src.explosion_resistance //This is the amount of power that will be spread to the side tiles
	for(var/obj/O in src)
		if(O.explosion_resistance)
			spread_power -= O.explosion_resistance
			side_spread_power -= O.explosion_resistance

	var/turf/T = get_step(src, direction)
	T.explosion_spread(spread_power, direction)
	T = get_step(src, turn(direction,90))
	T.explosion_spread(side_spread_power, turn(direction,90))
	T = get_step(src, turn(direction,-90))
	T.explosion_spread(side_spread_power, turn(direction,90))

	/*
	for(var/direction in cardinal)
		var/turf/T = get_step(src, direction)
		T.explosion_spread(spread_power)
	*/

/turf/unsimulated/explosion_spread(power)
	return //So it doesn't get to the parent proc, which simulates explosions