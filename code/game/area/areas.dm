// Areas.dm



// ===
/area/
	var/global/global_uid = 0
	var/uid

/area/New()

	master = src //moved outside the spawn(1) to avoid runtimes in lighting.dm when it references src.loc.loc.master ~Carn
	src.icon = 'icons/effects/alert.dmi'
	uid = ++global_uid
	spawn(1)
	//world.log << "New: [src] [tag]"
		var/sd_created = findtext(tag,"sd_L")
		sd_New(sd_created)
		if(sd_created)
			related += src
			return
		related = list(src)

		src.icon = 'icons/effects/alert.dmi'
		src.layer = 10
	//	update_lights()
		if(name == "Space")			// override defaults for space
			requires_power = 1
			always_unpowered = 1
			sd_SetLuminosity(1)
			power_light = 0
			power_equip = 0
			power_environ = 0
			//has_gravity = 0    // Space has gravity.  Because.. because.

		if(!requires_power)
			power_light = 0//rastaf0
			power_equip = 0//rastaf0
			power_environ = 0//rastaf0
			luminosity = 1
			sd_lighting = 0			// *DAL*
		else
			luminosity = 0
			area_lights_luminosity = rand(6,9)
			//sd_SetLuminosity(0)		// *DAL*




	/*spawn(5)
		for(var/turf/T in src)		// count the number of turfs (for lighting calc)
			if(no_air)
				T.oxygen = 0		// remove air if so specified for this area
				T.n2 = 0
				T.res_vars()

	*/


	spawn(15)
		src.power_change()		// all machines set to current power level, also updates lighting icon

/*
/proc/get_area(area/A)
	while (A)
		if (istype(A, /area))
			return A

		A = A.loc
	return null
*/
/*
/area/proc/update_lights()
	var/new_power = 0
	for(var/obj/machinery/light/L in src.contents)
		if(L.on)
			new_power += (L.luminosity * 20)
	lighting_power_usage = new_power
	return
*/
/area/proc/poweralert(var/state, var/source)
	if (state != poweralm)
		poweralm = state
		var/list/cameras = list()
		for (var/obj/machinery/camera/C in src)
			cameras += C
		for (var/mob/living/silicon/aiPlayer in player_list)
			if (state == 1)
				aiPlayer.cancelAlarm("Power", src, source)
			else
				aiPlayer.triggerAlarm("Power", src, cameras, source)
		for(var/obj/machinery/computer/station_alert/a in player_list)
			if(state == 1)
				a.cancelAlarm("Power", src, source)
			else
				a.triggerAlarm("Power", src, source)
	return

/area/proc/atmosalert(danger_level)
//	if(src.type==/area) //No atmos alarms in space
//		return 0 //redudant
	if(danger_level != src.atmosalm)
		//src.updateicon()
		//src.mouse_opacity = 0
		if (danger_level==2)
			var/list/cameras = list()
			for(var/area/RA in src.related)
				//src.updateicon()
				for(var/obj/machinery/camera/C in RA)
					cameras += C
			for(var/mob/living/silicon/aiPlayer in player_list)
				aiPlayer.triggerAlarm("Atmosphere", src, cameras, src)
			for(var/obj/machinery/computer/station_alert/a in world)
				a.triggerAlarm("Atmosphere", src, cameras, src)
		else if (src.atmosalm == 2)
			for(var/mob/living/silicon/aiPlayer in player_list)
				aiPlayer.cancelAlarm("Atmosphere", src, src)
			for(var/obj/machinery/computer/station_alert/a in world)
				a.cancelAlarm("Atmosphere", src, src)
		src.atmosalm = danger_level
		return 1
	return 0

/area/proc/firealert()
	if(src.name == "Space") //no fire alarms in space
		return
	if (!( src.fire ))
		src.fire = 1
		src.updateicon()
		src.mouse_opacity = 0
		for(var/obj/machinery/door/firedoor/D in src)
			if(!D.blocked)
				if(D.operating)
					D.nextstate = CLOSED
				else if(!D.density)
					spawn(0)
					D.close()
		var/list/cameras = list()
		for (var/obj/machinery/camera/C in src)
			cameras += C
		for (var/mob/living/silicon/ai/aiPlayer in player_list)
			aiPlayer.triggerAlarm("Fire", src, cameras, src)
		for (var/obj/machinery/computer/station_alert/a in world)
			a.triggerAlarm("Fire", src, cameras, src)
	return

/area/proc/firereset()
	if (src.fire)
		src.fire = 0
		src.mouse_opacity = 0
		src.updateicon()
		for(var/obj/machinery/door/firedoor/D in src)
			if(!D.blocked)
				if(D.operating)
					D.nextstate = OPEN
				else if(D.density)
					spawn(0)
					D.open()
		for (var/mob/living/silicon/ai/aiPlayer in player_list)
			aiPlayer.cancelAlarm("Fire", src, src)
		for (var/obj/machinery/computer/station_alert/a in player_list)
			a.cancelAlarm("Fire", src, src)
	return

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
	if ((fire || eject || party) && ((!requires_power)?(!requires_power):power_environ))//If it doesn't require power, can still activate this proc.
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

	return used

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

	var/sound = null
	var/musVolume = 25
	sound = 'ambigen1.ogg'


	if (ismob(A))

		if (istype(A, /mob/dead/observer)) return
		if (!A:ckey)
			return

		if(istype(A,/mob/living))
			if(!A:lastarea)
				A:lastarea = get_area(A:loc)
			//world << "Entered new area [get_area(A:loc)]"
			var/area/newarea = get_area(A:loc)
			var/area/oldarea = A:lastarea
			if((oldarea.has_gravity == 0) && (newarea.has_gravity == 1) && (A:m_intent == "run")) // Being ready when you change areas gives you a chance to avoid falling all together.
				thunk(A)

			A:lastarea = newarea

		//if (A:ear_deaf) return

		if (A && A:client && !A:client:ambience_playing && !A:client:no_ambi) // Ambience goes down here -- make sure to list each area seperately for ease of adding things in later, thanks! Note: areas adjacent to each other should have the same sounds to prevent cutoff when possible.- LastyScratch
			A:client:ambience_playing = 1
			A << sound('shipambience.ogg', repeat = 1, wait = 0, volume = 35, channel = 2)

		switch(src.name)
			if ("Chapel") sound = pick('ambicha1.ogg','ambicha2.ogg','ambicha3.ogg','ambicha4.ogg')
			if ("Morgue") sound = pick('ambimo1.ogg','ambimo2.ogg','title2.ogg')
			if ("Space") sound = pick('ambispace.ogg','title2.ogg',)
			if ("Engine Control", "Engineering", "Engineering SMES") sound = pick('ambisin1.ogg','ambisin2.ogg','ambisin3.ogg','ambisin4.ogg')
			if ("AI Satellite Teleporter Room") sound = pick('ambimalf.ogg')
			if ("AI Upload Foyer") sound = pick('ambimalf.ogg')
			if ("AI Upload Chamber") sound = pick('ambimalf.ogg')
			if ("Mine")
				sound = pick('ambimine.ogg')
				musVolume = 25
			else
				sound = pick('ambigen1.ogg','ambigen3.ogg','ambigen4.ogg','ambigen5.ogg','ambigen6.ogg','ambigen7.ogg','ambigen8.ogg','ambigen9.ogg','ambigen10.ogg','ambigen11.ogg','ambigen12.ogg','ambigen14.ogg')

		if(findtext(src.name, "Telecommunications"))
			sound = pick('ambisin2.ogg', 'signal.ogg', 'signal.ogg', 'ambigen10.ogg')

		if (prob(35))
			if(A && A:client && !A:client:played)
				A << sound(sound, repeat = 0, wait = 0, volume = musVolume, channel = 1)
				A:client:played = 1
				spawn(600)
					if(A && A:client)
						A:client:played = 0


/area/proc/gravitychange(var/gravitystate = 0, var/area/A)

	A.has_gravity = gravitystate

	for(var/area/SubA in A.related)
		SubA.has_gravity = gravitystate

		if(gravitystate)
			for(var/mob/living/carbon/human/M in SubA)
				thunk(M)

/area/proc/thunk(mob)
	if(istype(mob,/mob/living/carbon/human/))  // Only humans can wear magboots, so we give them a chance to.
		if((istype(mob:shoes, /obj/item/clothing/shoes/magboots) && (mob:shoes.flags & NOSLIP)))
			return

	if(istype(get_turf(mob), /turf/space)) // Can't fall onto nothing.
		return

	if((istype(mob,/mob/living/carbon/human/)) && (mob:m_intent == "run")) // Only clumbsy humans can fall on their asses.
		mob:AdjustStunned(5)
		mob:AdjustWeakened(5)

	else if (istype(mob,/mob/living/carbon/human/))
		mob:AdjustStunned(2)
		mob:AdjustWeakened(2)

	mob << "Gravity!"

