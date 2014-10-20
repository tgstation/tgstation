// Flags for door_alerts.
#define DOORALERT_ATMOS 1
#define DOORALERT_FIRE  2

/area
	var/global/global_uid = 0
	var/uid

/area/New()
	icon_state = ""
	layer = 10
	master = src //moved outside the spawn(1) to avoid runtimes in lighting.dm when it references loc.loc.master ~Carn
	uid = ++global_uid
	related = list(src)

	if(type == /area)	// override defaults for space. TODO: make space areas of type /area/space rather than /area
		requires_power = 1
		always_unpowered = 1
		lighting_use_dynamic = 0
		power_light = 0
		power_equip = 0
		power_environ = 0
//		lighting_state = 4
		//has_gravity = 0    // Space has gravity.  Because.. because.

	if(requires_power)
		luminosity = 0
	else
		power_light = 0			//rastaf0
		power_equip = 0			//rastaf0
		power_environ = 0		//rastaf0
		luminosity = 1
		lighting_use_dynamic = 0

	..()

//	spawn(15)
	power_change()		// all machines set to current power level, also updates lighting icon
	InitializeLighting()

/*
 * Added to fix mech fabs 05/2013 ~Sayu.
 * This is necessary due to lighting subareas.
 * If you were to go in assuming that things in the same logical /area have
 * the parent /area object... well, you would be mistaken.
 * If you want to find machines, mobs, etc, in the same logical area,
 * you will need to check all the related areas.
 * This returns a master contents list to assist in that.
 */
/proc/area_contents(const/area/A)
	if (!isarea(A))
		return

	var/list/contents = list()

	for(var/area/LSA in A.related)
		contents |= LSA.contents

	return contents

/area/proc/poweralert(var/state, var/obj/source as obj)
	if (state != poweralm)
		poweralm = state
		if(istype(source))	//Only report power alarms on the z-level where the source is located.
			var/list/cameras = list()
			for (var/area/RA in related)
				for (var/obj/machinery/camera/C in RA)
					cameras += C
					if(state == 1)
						C.network.Remove("Power Alarms")
					else
						C.network.Add("Power Alarms")
			for (var/mob/living/silicon/aiPlayer in player_list)
				if(aiPlayer.z == source.z)
					if (state == 1)
						aiPlayer.cancelAlarm("Power", src, source)
					else
						aiPlayer.triggerAlarm("Power", src, cameras, source)
			for(var/obj/machinery/computer/station_alert/a in machines)
				if(a.z == source.z)
					if(state == 1)
						a.cancelAlarm("Power", src, source)
					else
						a.triggerAlarm("Power", src, cameras, source)
	return

/////////////////////////////////////////
// BEGIN /VG/ UNFUCKING OF AIR ALARMS
/////////////////////////////////////////

/area/proc/updateDangerLevel()
	var/danger_level = 0

	// Determine what the highest DL reported by air alarms is
	for (var/area/RA in related)
		for(var/obj/machinery/alarm/AA in RA)
			if((AA.stat & (NOPOWER|BROKEN)) || AA.shorted || AA.buildstage != 2)
				continue
			var/reported_danger_level=AA.local_danger_level
			if(AA.alarmActivated)
				reported_danger_level=2
			if(reported_danger_level>danger_level)
				danger_level=reported_danger_level
			//testing("Danger level at [AA.name]: [AA.local_danger_level] (reported [reported_danger_level])")

	//testing("Danger level decided upon in [name]: [danger_level] (from [atmosalm])")

	// Danger level change?
	if(danger_level != atmosalm)
		// Going to danger level 2 from something else
		if (danger_level == 2)
			var/list/cameras = list()
			for(var/area/RA in related)
				//updateicon()
				for(var/obj/machinery/camera/C in RA)
					cameras += C
					C.network.Add("Atmosphere Alarms")
			for(var/mob/living/silicon/aiPlayer in player_list)
				aiPlayer.triggerAlarm("Atmosphere", src, cameras, src)
			for(var/obj/machinery/computer/station_alert/a in machines)
				a.triggerAlarm("Atmosphere", src, cameras, src)
			door_alerts |= DOORALERT_ATMOS
			UpdateFirelocks()
		// Dropping from danger level 2.
		else if (atmosalm == 2)
			for(var/area/RA in related)
				for(var/obj/machinery/camera/C in RA)
					C.network.Remove("Atmosphere Alarms")
			for(var/mob/living/silicon/aiPlayer in player_list)
				aiPlayer.cancelAlarm("Atmosphere", src, src)
			for(var/obj/machinery/computer/station_alert/a in machines)
				a.cancelAlarm("Atmosphere", src, src)
			door_alerts &= ~DOORALERT_ATMOS
			UpdateFirelocks()
		atmosalm = danger_level
		for (var/obj/machinery/alarm/AA in src)
			if ( !(AA.stat & (NOPOWER|BROKEN)) && !AA.shorted)
				AA.update_icon()
		return 1
	return 0

/area/proc/UpdateFirelocks()
	if(door_alerts != 0)
		CloseFirelocks()
	else
		OpenFirelocks()

/area/proc/CloseFirelocks()
	if(doors_down) return
	doors_down=1
	for(var/obj/machinery/door/firedoor/D in all_doors)
		if(!D.blocked)
			if(D.operating)
				D.nextstate = CLOSED
			else if(!D.density)
				spawn()
					D.close()

/area/proc/OpenFirelocks()
	if(!doors_down) return
	doors_down=0
	for(var/obj/machinery/door/firedoor/D in all_doors)
		if(!D.blocked)
			if(D.operating)
				D.nextstate = OPEN
			else if(D.density)
				spawn()
					D.open()

//////////////////////////////////////////////
// END UNFUCKING
//////////////////////////////////////////////

/area/proc/firealert()
	if(lighting_subarea)
		testing("Some jackass called firealert() in a subarea.")
		return
	if(name == "Space") //no fire alarms in space
		return
	if( !fire )
		fire = 1
		updateicon()
		mouse_opacity = 0
		door_alerts |= DOORALERT_FIRE
		UpdateFirelocks()
		var/list/cameras = list()
		for(var/area/RA in related)
			for (var/obj/machinery/camera/C in RA)
				cameras.Add(C)
				C.network.Add("Fire Alarms")
		for (var/mob/living/silicon/ai/aiPlayer in player_list)
			aiPlayer.triggerAlarm("Fire", src, cameras, src)
		for (var/obj/machinery/computer/station_alert/a in machines)
			a.triggerAlarm("Fire", src, cameras, src)

/area/proc/firereset()
	if(lighting_subarea)
		testing("Some jackass called firereset() in a subarea.")
		return
	if (fire)
		fire = 0
		mouse_opacity = 0
		updateicon()
		for(var/area/RA in related)
			for (var/obj/machinery/camera/C in RA)
				C.network.Remove("Fire Alarms")
		for (var/mob/living/silicon/ai/aiPlayer in player_list)
			aiPlayer.cancelAlarm("Fire", src, src)
		for (var/obj/machinery/computer/station_alert/a in machines)
			a.cancelAlarm("Fire", src, src)
		door_alerts &= ~DOORALERT_FIRE
		UpdateFirelocks()

/area/proc/radiation_alert()
	if(lighting_subarea)
		testing("Some jackass called radiation_alert() in a subarea.")
		return
	if(name == "Space")
		return
	if(!radalert)
		radalert = 1
		updateicon()
	return

/area/proc/reset_radiation_alert()
	if(lighting_subarea)
		testing("Some jackass called reset_radiation_alert() in a subarea.")
		return
	if(name == "Space")
		return
	if(radalert)
		radalert = 0
		updateicon()
	return

/area/proc/readyalert()
	if(lighting_subarea)
		testing("Some jackass called readyalert() in a subarea.")
		return
	if(name == "Space")
		return
	if(!eject)
		eject = 1
		updateicon()
	return

/area/proc/readyreset()
	if(lighting_subarea)
		testing("Some jackass called ready_reset() in a subarea.")
		return
	if(eject)
		eject = 0
		updateicon()
	return

/area/proc/partyalert()
	if(lighting_subarea)
		testing("Some jackass called partyalert() in a subarea.")
		return
	if(name == "Space") //no parties in space!!!
		return
	if (!( party ))
		party = 1
		updateicon()
		mouse_opacity = 0
	return

/area/proc/partyreset()
	if(lighting_subarea)
		testing("Some jackass called partyreset() in a subarea.")
		return
	if (party)
		party = 0
		mouse_opacity = 0
		updateicon()
	return

/area/proc/updateicon()
	if(lighting_subarea)
		// Pull from master.
		icon_state=master.icon_state
		return
	if ((fire || eject || party || radalert) && ((!requires_power)?(!requires_power):power_environ))//If it doesn't require power, can still activate this proc.
		// Highest priority at the top.
		if(radalert && !fire)
			icon_state = "radiation"
		else if(fire && !radalert && !eject && !party)
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

	// We're master, Update children.
	for(var/area/A in related)
		if(A && A!=src)
			// Propogate
			A.icon_state=icon_state


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

/*
 * Called when power status changes.
 */
/area/proc/power_change()
	for(var/area/RA in related)
		for(var/obj/machinery/M in RA)	// for each machine in the area
			M.power_change()				// reverify power status (to update icons etc.)
		if (fire || eject || party)
			RA.updateicon()

/area/proc/usage(const/chan)
	switch (chan)
		if (LIGHT)
			return master.used_light
		if (EQUIP)
			return master.used_equip
		if (ENVIRON)
			return master.used_environ
		if (TOTAL)
			return master.used_light + master.used_equip + master.used_environ

	return 0

/area/proc/clear_usage()
	master.used_equip = 0
	master.used_light = 0
	master.used_environ = 0

/area/proc/use_power(const/amount, const/chan)
	switch (chan)
		if(EQUIP)
			master.used_equip += amount
		if(LIGHT)
			master.used_light += amount
		if(ENVIRON)
			master.used_environ += amount

/area/Entered(atom/movable/Obj, atom/OldLoc)
	var/area/oldAreaMaster = Obj.areaMaster
	Obj.areaMaster = master

	if (!ismob(Obj))
		return

	var/mob/M = Obj

	// /vg/ - EVENTS!
	CallHook("MobAreaChange", list("mob" = M, "new" = Obj.areaMaster, "old" = oldAreaMaster))

	// Being ready when you change areas gives you a chance to avoid falling all together.
	if(!oldAreaMaster || !M.areaMaster)
		thunk(M)
	else if (!oldAreaMaster.has_gravity && M.areaMaster.has_gravity && M.m_intent == "run")
		thunk(M)

	if (isnull(M.client))
		return

	if (M.client.prefs.toggles & SOUND_AMBIENCE)
		if (isnull(M.areaMaster.media_source) && !M.client.ambience_playing)
			M.client.ambience_playing = 1
			var/sound = 'sound/ambience/shipambience.ogg'

			if (prob(35))
				// Ambience goes down here -- make sure to list each area seperately for ease of adding things in later, thanks!
				// Note: areas adjacent to each other should have the same sounds to prevent cutoff when possible.- LastyScratch.
				// TODO: This is dumb - N3X.
				if (istype(src, /area/chapel))
					sound = pick('sound/ambience/ambicha1.ogg', 'sound/ambience/ambicha2.ogg', 'sound/ambience/ambicha3.ogg', 'sound/ambience/ambicha4.ogg')
				else if (istype(src, /area/medical/morgue))
					sound = pick('sound/ambience/ambimo1.ogg', 'sound/ambience/ambimo2.ogg', 'sound/music/main.ogg')
				else if (type == /area)
					sound = pick('sound/ambience/ambispace.ogg', 'sound/music/space.ogg', 'sound/music/main.ogg', 'sound/music/traitor.ogg', 'sound/ambience/spookyspace1.ogg', 'sound/ambience/spookyspace2.ogg')
				else if (istype(src, /area/engineering))
					sound = pick('sound/ambience/ambisin1.ogg', 'sound/ambience/ambisin2.ogg', 'sound/ambience/ambisin3.ogg', 'sound/ambience/ambisin4.ogg')
				else if (istype(src, /area/AIsattele) || istype(src, /area/turret_protected/ai) || istype(src, /area/turret_protected/ai_upload) || istype(src, /area/turret_protected/ai_upload_foyer))
					sound = pick('sound/ambience/ambimalf.ogg')
				else if (istype(src, /area/maintenance/ghettobar))
					sound = pick('sound/ambience/ghetto.ogg')
				else if (istype(src, /area/shuttle/salvage/derelict))
					sound = pick('sound/ambience/derelict1.ogg', 'sound/ambience/derelict2.ogg', 'sound/ambience/derelict3.ogg', 'sound/ambience/derelict4.ogg')
				else if (istype(src, /area/mine/explored) || istype(src, /area/mine/unexplored))
					sound = pick('sound/ambience/ambimine.ogg', 'sound/ambience/song_game.ogg', 'sound/music/torvus.ogg')
				else if (istype(src, /area/maintenance/fsmaint2) || istype(src, /area/maintenance/port) || istype(src, /area/maintenance/aft) || istype(src, /area/maintenance/asmaint))
					sound = pick('sound/ambience/spookymaint1.ogg', 'sound/ambience/spookymaint2.ogg')
				else if (istype(src, /area/tcommsat) || istype(src, /area/turret_protected/tcomwest) || istype(src, /area/turret_protected/tcomeast) || istype(src, /area/turret_protected/tcomfoyer) || istype(src, /area/turret_protected/tcomsat))
					sound = pick('sound/ambience/ambisin2.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/ambigen10.ogg')
				else
					sound = pick('sound/ambience/ambigen1.ogg', 'sound/ambience/ambigen3.ogg', 'sound/ambience/ambigen4.ogg', 'sound/ambience/ambigen5.ogg', 'sound/ambience/ambigen6.ogg', 'sound/ambience/ambigen7.ogg', 'sound/ambience/ambigen8.ogg', 'sound/ambience/ambigen9.ogg', 'sound/ambience/ambigen10.ogg', 'sound/ambience/ambigen11.ogg', 'sound/ambience/ambigen12.ogg', 'sound/ambience/ambigen14.ogg')

			M << sound(sound, 0, 0, 0, 25)

			spawn (600) // Ewww - this is very very bad.
				if (M && M.client)
					M.client.ambience_playing = 0

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

