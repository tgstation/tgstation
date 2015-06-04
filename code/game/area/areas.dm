// Areas.dm

// Added to fix mech fabs 05/2013 ~Sayu
// This is necessary due to lighting subareas.  If you were to go in assuming that things in
// the same logical /area have the parent /area object... well, you would be mistaken.  If you
// want to find machines, mobs, etc, in the same logical area, you will need to check all the
// related areas.  This returns a master contents list to assist in that.
/proc/area_contents(var/area/A)
	if(!istype(A)) return null
	var/list/contents = list()
	for(var/area/LSA in A.related)
		contents += LSA.contents
	return contents


// ===
/area
	var/global/global_uid = 0
	var/uid
	var/list/ambientsounds = list('sound/ambience/ambigen1.ogg','sound/ambience/ambigen3.ogg',\
									'sound/ambience/ambigen4.ogg','sound/ambience/ambigen5.ogg',\
									'sound/ambience/ambigen6.ogg','sound/ambience/ambigen7.ogg',\
									'sound/ambience/ambigen8.ogg','sound/ambience/ambigen9.ogg',\
									'sound/ambience/ambigen10.ogg','sound/ambience/ambigen11.ogg',\
									'sound/ambience/ambigen12.ogg','sound/ambience/ambigen14.ogg')

/area/New()
	icon_state = ""
	layer = 10
	master = src //moved outside the spawn(1) to avoid runtimes in lighting.dm when it references src.loc.loc.master ~Carn
	uid = ++global_uid
	related = list(src)

	if(requires_power)
		luminosity = 0
	else
		power_light = 1			//rastaf0
		power_equip = 1			//rastaf0
		power_environ = 1		//rastaf0
		luminosity = 1
		lighting_use_dynamic = 0

	..()

	power_change()		// all machines set to current power level, also updates lighting icon

	blend_mode = BLEND_MULTIPLY // Putting this in the constructure so that it stops the icons being screwed up in the map editor.



/area/proc/poweralert(var/state, var/obj/source as obj)
	if (state != poweralm)
		poweralm = state
		if(istype(source))	//Only report power alarms on the z-level where the source is located.
			var/list/cameras = list()
			for (var/obj/machinery/camera/C in src)
				cameras += C
			for (var/mob/living/silicon/aiPlayer in player_list)
				if (state == 1)
					aiPlayer.cancelAlarm("Power", src, source)
				else
					aiPlayer.triggerAlarm("Power", src, cameras, source)

			for(var/obj/machinery/computer/station_alert/a in machines)
				if(state == 1)
					a.cancelAlarm("Power", src, source)
				else
					a.triggerAlarm("Power", src, cameras, source)

			for(var/mob/living/simple_animal/drone/D in mob_list)
				if(state == 1)
					D.cancelAlarm("Power", src, source)
				else
					D.triggerAlarm("Power", src, cameras, source)
	return

/area/proc/atmosalert(var/danger_level, var/obj/source as obj)
	if(danger_level != atmosalm)
		if (danger_level==2)
			var/list/cameras = list()
			for(var/area/RA in related)
				for(var/obj/machinery/camera/C in RA)
					cameras += C

			for(var/mob/living/silicon/aiPlayer in player_list)
				aiPlayer.triggerAlarm("Atmosphere", src, cameras, source)
			for(var/obj/machinery/computer/station_alert/a in machines)
				a.triggerAlarm("Atmosphere", src, cameras, source)
			for(var/mob/living/simple_animal/drone/D in mob_list)
				D.triggerAlarm("Atmosphere", src, cameras, source)

		else if (src.atmosalm == 2)
			for(var/mob/living/silicon/aiPlayer in player_list)
				aiPlayer.cancelAlarm("Atmosphere", src, source)
			for(var/obj/machinery/computer/station_alert/a in machines)
				a.cancelAlarm("Atmosphere", src, source)
			for(var/mob/living/simple_animal/drone/D in mob_list)
				D.cancelAlarm("Atmosphere", src, source)

		src.atmosalm = danger_level
		return 1
	return 0

/area/proc/firealert(var/obj/source as obj)
	if(always_unpowered == 1) //no fire alarms in space/asteroid
		return

	var/list/cameras = list()

	for(var/area/RA in related)
		if (!( RA.fire ))
			RA.set_fire_alarm_effect()
			for(var/obj/machinery/door/firedoor/D in RA)
				if(!D.blocked)
					if(D.operating)
						D.nextstate = CLOSED
					else if(!D.density)
						spawn(0)
							D.close()
			for(var/obj/machinery/firealarm/F in RA)
				F.update_icon()
		for (var/obj/machinery/camera/C in RA)
			cameras += C

	for (var/obj/machinery/computer/station_alert/a in machines)
		a.triggerAlarm("Fire", src, cameras, source)
	for (var/mob/living/silicon/aiPlayer in player_list)
		aiPlayer.triggerAlarm("Fire", src, cameras, source)
	for (var/mob/living/simple_animal/drone/D in mob_list)
		D.triggerAlarm("Fire", src, cameras, source)
	return

/area/proc/firereset(var/obj/source as obj)
	for(var/area/RA in related)
		if (RA.fire)
			RA.fire = 0
			RA.mouse_opacity = 0
			RA.updateicon()
			for(var/obj/machinery/door/firedoor/D in RA)
				if(!D.blocked)
					if(D.operating)
						D.nextstate = OPEN
					else if(D.density)
						spawn(0)
							D.open()
			for(var/obj/machinery/firealarm/F in RA)
				F.update_icon()

	for (var/mob/living/silicon/aiPlayer in player_list)
		aiPlayer.cancelAlarm("Fire", src, source)
	for (var/obj/machinery/computer/station_alert/a in machines)
		a.cancelAlarm("Fire", src, source)
	for (var/mob/living/simple_animal/drone/D in mob_list)
		D.cancelAlarm("Fire", src, source)
	return

/area/proc/burglaralert(var/obj/trigger)
	if(always_unpowered == 1) //no burglar alarms in space/asteroid
		return

	var/list/cameras = list()

	for(var/area/RA in related)
		//Trigger alarm effect
		RA.set_fire_alarm_effect()
		//Lockdown airlocks
		for(var/obj/machinery/door/airlock/DOOR in RA)
			spawn(0)
				DOOR.close()
				if(DOOR.density)
					DOOR.locked = 1
					DOOR.update_icon()
		for (var/obj/machinery/camera/C in RA)
			cameras += C

	for (var/mob/living/silicon/SILICON in player_list)
		if(SILICON.triggerAlarm("Burglar", src, cameras, trigger))
			//Cancel silicon alert after 1 minute
			spawn(600)
				SILICON.cancelAlarm("Burglar", src, trigger)

/area/proc/set_fire_alarm_effect()
	fire = 1
	updateicon()
	mouse_opacity = 0

/area/proc/readyalert()
	if(name == "Space")
		return
	if(!eject)
		eject = 1
		updateicon()
	return

/area/proc/readyreset()
	if(eject)
		eject = 0
		updateicon()
	return

/area/proc/partyalert()
	if(src.name == "Space") //no parties in space!!!
		return
	if (!( src.party ))
		src.party = 1
		src.updateicon()
		src.mouse_opacity = 0
	return

/area/proc/partyreset()
	if (src.party)
		src.party = 0
		src.mouse_opacity = 0
		src.updateicon()
		for(var/obj/machinery/door/firedoor/D in src)
			if(!D.blocked)
				if(D.operating)
					D.nextstate = OPEN
				else if(D.density)
					spawn(0)
					D.open()
	return

/area/proc/updateicon()
	if ((fire || eject || party) && (!requires_power||power_environ))//If it doesn't require power, can still activate this proc.
		if(fire && !eject && !party)
			icon_state = "blue"
		/*else if(atmosalm && !fire && !eject && !party)
			icon_state = "bluenew"*/
		else if(!fire && eject && !party)
			icon_state = "red"
		else if(party && !fire && !eject)
			icon_state = "party"
		else
			icon_state = "blue-red"
	else
	//	new lighting behaviour with obj lights
		icon_state = null

/area/space/updateicon()
	icon_state = null

/*
#define EQUIP 1
#define LIGHT 2
#define ENVIRON 3
*/

/area/proc/powered(var/chan)		// return true if the area has power to given channel

	if(!master.requires_power)
		return 1
	if(master.always_unpowered)
		return 0
	switch(chan)
		if(EQUIP)
			return master.power_equip
		if(LIGHT)
			return master.power_light
		if(ENVIRON)
			return master.power_environ

	return 0

/area/space/powered(chan) //Nope.avi
	return 0

// called when power status changes

/area/proc/power_change()
	for(var/area/RA in related)
		for(var/obj/machinery/M in RA)	// for each machine in the area
			M.power_change()				// reverify power status (to update icons etc.)
		if (fire || eject || party)
			RA.updateicon()

/area/proc/usage(var/chan)
	var/used = 0
	switch(chan)
		if(LIGHT)
			used += master.used_light
		if(EQUIP)
			used += master.used_equip
		if(ENVIRON)
			used += master.used_environ
		if(TOTAL)
			used += master.used_light + master.used_equip + master.used_environ
		if(STATIC_EQUIP)
			used += master.static_equip
		if(STATIC_LIGHT)
			used += master.static_light
		if(STATIC_ENVIRON)
			used += master.static_environ
	return used

/area/proc/addStaticPower(value, powerchannel)
	switch(powerchannel)
		if(STATIC_EQUIP)
			static_equip += value
		if(STATIC_LIGHT)
			static_light += value
		if(STATIC_ENVIRON)
			static_environ += value

/area/proc/clear_usage()

	master.used_equip = 0
	master.used_light = 0
	master.used_environ = 0

/area/proc/use_power(var/amount, var/chan)

	switch(chan)
		if(EQUIP)
			master.used_equip += amount
		if(LIGHT)
			master.used_light += amount
		if(ENVIRON)
			master.used_environ += amount


/area/Entered(A)
	if(!istype(A,/mob/living))	return

	var/mob/living/L = A
	if(!L.ckey)	return

	if(!L.lastarea)
		L.lastarea = get_area(L.loc)
	var/area/newarea = get_area(L.loc)

	L.lastarea = newarea

	// Ambience goes down here -- make sure to list each area seperately for ease of adding things in later, thanks! Note: areas adjacent to each other should have the same sounds to prevent cutoff when possible.- LastyScratch
	if(L.client && !L.client.ambience_playing && L.client.prefs.toggles & SOUND_SHIP_AMBIENCE)
		L.client.ambience_playing = 1
		L << sound('sound/ambience/shipambience.ogg', repeat = 1, wait = 0, volume = 35, channel = 2)

	if(!(L.client && (L.client.prefs.toggles & SOUND_AMBIENCE)))	return //General ambience check is below the ship ambience so one can play without the other

	if(prob(35))
		var/sound = pick(ambientsounds)

		if(!L.client.played)
			L << sound(sound, repeat = 0, wait = 0, volume = 25, channel = 1)
			L.client.played = 1
			spawn(600)			//ewww - this is very very bad
				if(L.&& L.client)
					L.client.played = 0

/proc/has_gravity(atom/AT, turf/T)
	if(!T)
		T = get_turf(AT)
	var/area/A = get_area(T)
	if(istype(T, /turf/space)) // Turf never has gravity
		return 0
	else if(A && A.has_gravity) // Areas which always has gravity
		return 1
	else
		// There's a gravity generator on our z level
		if(T && gravity_generators["[T.z]"] && length(gravity_generators["[T.z]"]))
			return 1
	return 0
/*
/area/proc/clear_docking_area()
	var/list/dstturfs = list()
	var/throwy = world.maxy

	for(var/turf/T in src)
		dstturfs += T
		if(T.y < throwy)
			throwy = T.y

	// hey you, get out of the way!
	for(var/turf/T in dstturfs)
		// find the turf to move things to
		var/turf/D = locate(T.x, throwy - 1, T.z)
		for(var/atom/movable/AM as mob|obj in T)
			if(ismob(AM))
				if(istype(AM, /mob/living))//mobs take damage
					var/mob/living/living_mob = AM
					living_mob.Paralyse(10)
					living_mob.take_organ_damage(80)
					living_mob.anchored = 0 //Unbuckle them so they can be moved
				else
					continue

			//Anything not bolted down is moved, everything else is destroyed
			if(!AM.anchored)
				AM.Move(D, SOUTH)
			else
				qdel(AM)
		if(istype(T, /turf/simulated))
			del(T)

	/*for(var/atom/movable/bug in src) // If someone (or something) is somehow still in the shuttle's docking area...
		if(ismob(bug))
			continue
		qdel(bug)*/
*/
