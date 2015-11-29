// Flags for door_alerts.
#define DOORALERT_ATMOS 1
#define DOORALERT_FIRE  2

/area
	var/global/global_uid = 0
	var/uid
	var/obj/machinery/power/apc/areaapc = null

/area/New()
	icon_state = ""
	layer = 10
	uid = ++global_uid
	areas |= src

	if(type == /area)	// override defaults for space. TODO: make space areas of type /area/space rather than /area
		requires_power = 1
		always_unpowered = 1
		lighting_use_dynamic = 0
		power_light = 0
		power_equip = 0
		power_environ = 0
//		lighting_state = 4
		//has_gravity = 0    // Space has gravity.  Because.. because.

	if(!requires_power)
		power_light = 0			//rastaf0
		power_equip = 0			//rastaf0
		power_environ = 0		//rastaf0

	..()

//	spawn(15)
	power_change()		// all machines set to current power level, also updates lighting icon

/area/Destroy()
	..()
	areaapc = null

/*
 * Added to fix mech fabs 05/2013 ~Sayu.
 * This is necessary due to lighting subareas.
 * If you were to go in assuming that things in the same logical /area have
 * the parent /area object... well, you would be mistaken.
 * If you want to find machines, mobs, etc, in the same logical area,
 * you will need to check all the related areas.
 * This returns a master contents list to assist in that.
 * NOTE: Due to a new lighting engine this is now deprecated, but we're keeping this because I can't be bothered to relace everything that references this.
 */
/proc/area_contents(const/area/A)
	if (!isarea(A))
		return

	return A.contents

/area/proc/poweralert(var/state, var/obj/source as obj)
	if (suspend_alert) return
	if (state != poweralm)
		poweralm = state
		if(istype(source))	//Only report power alarms on the z-level where the source is located.
			var/list/cameras = list()
			for(var/obj/machinery/camera/C in src)
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
				if(src in (a.covered_areas))
					if(state == 1)
						a.cancelAlarm("Power", src, source)
					else
						a.triggerAlarm("Power", src, cameras, source)
	return

/area/proc/send_poweralert(var/obj/machinery/computer/station_alert/a)//sending alerts to newly built Station Alert Computers.
	if(!poweralm)
		a.triggerAlarm("Power", src, null, src)

/////////////////////////////////////////
// BEGIN /VG/ UNFUCKING OF AIR ALARMS
/////////////////////////////////////////

/area/proc/updateDangerLevel()
	var/danger_level = 0

	// Determine what the highest DL reported by air alarms is
	for(var/obj/machinery/alarm/AA in src)
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
			//updateicon()
			for(var/obj/machinery/camera/C in src)
				cameras += C
				C.network.Add("Atmosphere Alarms")
			for(var/mob/living/silicon/aiPlayer in player_list)
				aiPlayer.triggerAlarm("Atmosphere", src, cameras, src)
			for(var/obj/machinery/computer/station_alert/a in machines)
				if(src in (a.covered_areas))
					a.triggerAlarm("Atmosphere", src, cameras, src)
			door_alerts |= DOORALERT_ATMOS
			UpdateFirelocks()
		// Dropping from danger level 2.
		else if (atmosalm == 2)
			for(var/obj/machinery/camera/C in src)
				C.network.Remove("Atmosphere Alarms")
			for(var/mob/living/silicon/aiPlayer in player_list)
				aiPlayer.cancelAlarm("Atmosphere", src, src)
			for(var/obj/machinery/computer/station_alert/a in machines)
				if(src in (a.covered_areas))
					a.cancelAlarm("Atmosphere", src, src)
			door_alerts &= ~DOORALERT_ATMOS
			UpdateFirelocks()
		atmosalm = danger_level
		for (var/obj/machinery/alarm/AA in src)
			if ( !(AA.stat & (NOPOWER|BROKEN)) && !AA.shorted)
				AA.update_icon()
		return 1
	return 0

/area/proc/sendDangerLevel(var/obj/machinery/computer/station_alert/a)//sending alerts to newly built Station Alert Computers.
	var/danger_level = 0

	// Determine what the highest DL reported by air alarms is
	for(var/obj/machinery/alarm/AA in src)
		if((AA.stat & (NOPOWER|BROKEN)) || AA.shorted || AA.buildstage != 2)
			continue
		var/reported_danger_level=AA.local_danger_level
		if(AA.alarmActivated)
			reported_danger_level=2
		if(reported_danger_level>danger_level)
			danger_level=reported_danger_level

	if (danger_level == 2)
		a.triggerAlarm("Atmosphere", src, null, src)


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
	if(name == "Space") //no fire alarms in space
		return
	if( !fire )
		fire = 1
		updateicon()
		mouse_opacity = 0
		door_alerts |= DOORALERT_FIRE
		UpdateFirelocks()
		var/list/cameras = list()
		for (var/obj/machinery/camera/C in src)
			cameras.Add(C)
			C.network.Add("Fire Alarms")
		for (var/mob/living/silicon/ai/aiPlayer in player_list)
			aiPlayer.triggerAlarm("Fire", src, cameras, src)
		for (var/obj/machinery/computer/station_alert/a in machines)
			if(src in (a.covered_areas))
				a.triggerAlarm("Fire", src, cameras, src)

/area/proc/send_firealert(var/obj/machinery/computer/station_alert/a)//sending alerts to newly built Station Alert Computers.
	if(fire)
		a.triggerAlarm("Fire", src, null, src)

/area/proc/firereset()
	if (fire)
		fire = 0
		mouse_opacity = 0
		updateicon()
		for (var/obj/machinery/camera/C in src)
			C.network.Remove("Fire Alarms")
		for (var/mob/living/silicon/ai/aiPlayer in player_list)
			aiPlayer.cancelAlarm("Fire", src, src)
		for (var/obj/machinery/computer/station_alert/a in machines)
			if(src in (a.covered_areas))
				a.cancelAlarm("Fire", src, src)
		door_alerts &= ~DOORALERT_FIRE
		UpdateFirelocks()

/area/proc/radiation_alert()
	if(name == "Space")
		return
	if(!radalert)
		radalert = 1
		updateicon()
	return

/area/proc/reset_radiation_alert()
	if(name == "Space")
		return
	if(radalert)
		radalert = 0
		updateicon()
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
	if(name == "Space") //no parties in space!!!
		return
	if (!( party ))
		party = 1
		updateicon()
		mouse_opacity = 0
	return

/area/proc/partyreset()
	if (party)
		party = 0
		mouse_opacity = 0
		updateicon()
	return

/area/proc/updateicon()
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


/*
#define EQUIP 1
#define LIGHT 2
#define ENVIRON 3
*/

/area/proc/powered(var/chan)		// return true if the area has power to given channel


	if(!requires_power)
		return 1
	if(always_unpowered)
		return 0
	switch(chan)
		if(EQUIP)
			return power_equip
		if(LIGHT)
			return power_light
		if(ENVIRON)
			return power_environ

	return 0

/*
 * Called when power status changes.
 */
/area/proc/power_change()
	for(var/obj/machinery/M in src)	// for each machine in the area
		M.power_change()				// reverify power status (to update icons etc.)
	if (fire || eject || party)
		updateicon()

/area/proc/usage(const/chan)
	switch (chan)
		if (LIGHT)
			return used_light
		if (EQUIP)
			return used_equip
		if (ENVIRON)
			return used_environ
		if (TOTAL)
			return used_light + used_equip + used_environ
		if(STATIC_EQUIP)
			return static_equip
		if(STATIC_LIGHT)
			return static_light
		if(STATIC_ENVIRON)
			return static_environ
	return 0

/area/proc/addStaticPower(value, powerchannel)
	switch(powerchannel)
		if(STATIC_EQUIP)
			static_equip += value
		if(STATIC_LIGHT)
			static_light += value
		if(STATIC_ENVIRON)
			static_environ += value

/area/proc/clear_usage()
	used_equip = 0
	used_light = 0
	used_environ = 0

/area/proc/use_power(const/amount, const/chan)
	switch (chan)
		if(EQUIP)
			used_equip += amount
		if(LIGHT)
			used_light += amount
		if(ENVIRON)
			used_environ += amount

/area/Entered(atom/movable/Obj, atom/OldLoc)
	var/area/oldArea = Obj.areaMaster
	Obj.areaMaster = src
	if(!ismob(Obj))
		return

	var/mob/M = Obj

	// /vg/ - EVENTS!
	CallHook("MobAreaChange", list("mob" = M, "new" = Obj.areaMaster, "old" = oldArea))

	if(isnull(M.client))
		return

	if(M.client.prefs.toggles & SOUND_AMBIENCE)
		if(isnull(M.areaMaster.media_source) && !M.client.ambience_playing)
			M.client.ambience_playing = 1
			var/sound = 'sound/ambience/shipambience.ogg'

			if(prob(35))
				//Ambience goes down here -- make sure to list each area seperately for ease of adding things in later, thanks!
				//Note: areas adjacent to each other should have the same sounds to prevent cutoff when possible.- LastyScratch.
				//TODO: This is dumb - N3X.
				if(istype(src, /area/chapel))
					sound = pick('sound/ambience/ambicha1.ogg', 'sound/ambience/ambicha2.ogg', 'sound/ambience/ambicha3.ogg', 'sound/ambience/ambicha4.ogg')
				else if(istype(src, /area/medical/morgue))
					sound = pick('sound/ambience/ambimo1.ogg', 'sound/ambience/ambimo2.ogg', 'sound/music/main.ogg')
				else if(type == /area)
					sound = pick('sound/ambience/ambispace.ogg', 'sound/music/space.ogg', 'sound/music/main.ogg', 'sound/music/traitor.ogg', 'sound/ambience/spookyspace1.ogg', 'sound/ambience/spookyspace2.ogg')
				else if(istype(src, /area/engineering))
					sound = pick('sound/ambience/ambisin1.ogg', 'sound/ambience/ambisin2.ogg', 'sound/ambience/ambisin3.ogg', 'sound/ambience/ambisin4.ogg')
				else if(istype(src, /area/AIsattele) || istype(src, /area/turret_protected/ai) || istype(src, /area/turret_protected/ai_upload) || istype(src, /area/turret_protected/ai_upload_foyer))
					sound = pick('sound/ambience/ambimalf.ogg')
				else if(istype(src, /area/maintenance/ghettobar))
					sound = pick('sound/ambience/ghetto.ogg')
				else if(istype(src, /area/shuttle/salvage/derelict))
					sound = pick('sound/ambience/derelict1.ogg', 'sound/ambience/derelict2.ogg', 'sound/ambience/derelict3.ogg', 'sound/ambience/derelict4.ogg')
				else if(istype(src, /area/mine/explored) || istype(src, /area/mine/unexplored))
					sound = pick('sound/ambience/ambimine.ogg', 'sound/ambience/song_game.ogg', 'sound/music/torvus.ogg')
				else if(istype(src, /area/maintenance/fsmaint2) || istype(src, /area/maintenance/port) || istype(src, /area/maintenance/aft) || istype(src, /area/maintenance/asmaint))
					sound = pick('sound/ambience/spookymaint1.ogg', 'sound/ambience/spookymaint2.ogg')
				else if(istype(src, /area/tcommsat) || istype(src, /area/turret_protected/tcomwest) || istype(src, /area/turret_protected/tcomeast) || istype(src, /area/turret_protected/tcomfoyer) || istype(src, /area/turret_protected/tcomsat))
					sound = pick('sound/ambience/ambisin2.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/signal.ogg', 'sound/ambience/ambigen10.ogg')
				else
					sound = pick('sound/ambience/ambigen1.ogg', 'sound/ambience/ambigen3.ogg', 'sound/ambience/ambigen4.ogg', 'sound/ambience/ambigen5.ogg', 'sound/ambience/ambigen6.ogg', 'sound/ambience/ambigen7.ogg', 'sound/ambience/ambigen8.ogg', 'sound/ambience/ambigen9.ogg', 'sound/ambience/ambigen10.ogg', 'sound/ambience/ambigen11.ogg', 'sound/ambience/ambigen12.ogg', 'sound/ambience/ambigen14.ogg')

			M << sound(sound, 0, 0, SOUND_AMBIANCE, 25)

			spawn(600) // Ewww - this is very very bad.
				if(M && M.client)
					M.client.ambience_playing = 0

/area/proc/gravitychange(var/gravitystate = 0, var/area/A)


	A.has_gravity = gravitystate

	if(gravitystate)
		for(var/mob/living/carbon/human/H in A)
			if(istype(get_turf(H), /turf/space)) //You can't fall on space
				continue
			if(istype(H.shoes, /obj/item/clothing/shoes/magboots) && (H.shoes.flags & NOSLIP))
				continue
			if(H.locked_to) //Locked to something, anything
				continue

			H.AdjustStunned(5)
			to_chat(H, "<span class='warning'>Gravity!</span>")

/area/proc/set_apc(var/obj/machinery/power/apc/apctoset)
	areaapc = apctoset

/area/proc/remove_apc(var/obj/machinery/power/apc/apctoremove)
	if(areaapc == apctoremove)
		areaapc = null

/area/proc/get_turfs()
	var/list/L = list()
	for(var/turf/T in contents)
		L |= T

	return L

/area/proc/get_atoms()
	var/list/L = list()
	for(var/atom/A in contents)
		L |= A

	return L

/area/proc/get_shuttle()
	for(var/datum/shuttle/S in shuttles)
		if(S.linked_area == src) return S
	return null

/area/proc/displace_contents()
	var/list/dstturfs = list()
	var/throwy = world.maxy

	for(var/turf/T in src)
		dstturfs += T
		if(T.y < throwy)
			throwy = T.y

	// hey you, get out of the way!
	for(var/turf/T in dstturfs)
			// find the turf to move things to
		var/turf/D = locate(T.x, throwy - 1, 1)
					//var/turf/E = get_step(D, SOUTH)
		for(var/atom/movable/AM as mob|obj in T)
			AM.Move(D)
		if(istype(T, /turf/simulated))
			qdel(T)

//This proc adds all turfs in the list to the parent area, calling change_area on everything
//Returns nothing
/area/proc/add_turfs(var/list/L)
	for(var/turf/T in L)
		if(T in L) continue
		var/area/old_area = get_area(T)

		L += T

		T.change_area(old_area,src)
		for(var/atom/movable/AM in T.contents)
			AM.change_area(old_area,src)

var/list/ignored_keys = list("loc", "locs", "parent_type", "vars", "verbs", "type", "x", "y", "z","group","contents","air","light","areaMaster","underlays","lighting_overlay")
var/list/moved_landmarks = list(latejoin, wizardstart) //Landmarks that are moved by move_area_to and move_contents_to
var/list/transparent_icons = list("diagonalWall3","swall_f5","swall_f6","swall_f9","swall_f10") //icon_states for which to prepare an underlay

/area/proc/move_contents_to(var/area/A, var/turftoleave=null, var/direction = null)
	//Takes: Area. Optional: turf type to leave behind.
	//Returns: Nothing.
	//Notes: Attempts to move the contents of one area to another area.
	//       Movement based on lower left corner. Tiles that do not fit
	//		 into the new area will not be moved.

	if(!A || !src) return 0

	var/list/turfs_src = get_area_turfs(src.type)
	var/list/turfs_trg = get_area_turfs(A.type)

	var/src_min_x = 0
	var/src_min_y = 0
	for (var/turf/T in turfs_src)
		if(T.x < src_min_x || !src_min_x) src_min_x	= T.x
		if(T.y < src_min_y || !src_min_y) src_min_y	= T.y

	var/trg_min_x = 0
	var/trg_min_y = 0

	for (var/turf/T in turfs_trg)
		if(T.x < trg_min_x || !trg_min_x) trg_min_x	= T.x
		if(T.y < trg_min_y || !trg_min_y) trg_min_y	= T.y

	var/list/refined_src = new/list()
	for(var/turf/T in turfs_src)
		refined_src += T
		refined_src[T] = new/datum/coords
		var/datum/coords/C = refined_src[T]
		C.x_pos = (T.x - src_min_x)
		C.y_pos = (T.y - src_min_y)

	var/list/refined_trg = new/list()
	for(var/turf/T in turfs_trg)
		refined_trg += T
		refined_trg[T] = new/datum/coords
		var/datum/coords/C = refined_trg[T]
		C.x_pos = (T.x - trg_min_x)
		C.y_pos = (T.y - trg_min_y)

	var/list/fromupdate = new/list()
	var/list/toupdate = new/list()

	moving:
		for (var/turf/T in refined_src)
			var/area/AA = get_area(T)
			var/datum/coords/C_src = refined_src[T]
			for (var/turf/B in refined_trg)
				var/datum/coords/C_trg = refined_trg[B]
				if(C_src.x_pos == C_trg.x_pos && C_src.y_pos == C_trg.y_pos)

					var/old_dir1 = T.dir
					var/old_icon_state1 = T.icon_state
					var/old_icon1 = T.icon
					var/image/undlay = image("icon"=B.icon,"icon_state"=B.icon_state,"dir"=B.dir)
					undlay.overlays = B.overlays
					var/prevtype = B.type

					var/turf/X = B.ChangeTurf(T.type)
					for(var/key in T.vars)
						if(key in ignored_keys) continue
						if(istype(T.vars[key],/list))
							var/list/L = T.vars[key]
							X.vars[key] = L.Copy()
						else
							X.vars[key] = T.vars[key]
					if(ispath(prevtype,/turf/space))//including the transit hyperspace turfs
						/*if(ispath(AA.type, /area/syndicate_station/start) || ispath(AA.type, /area/syndicate_station/transit))//that's the snowflake to pay when people map their ships over the snow.
							X.underlays += undlay
						else */if(T.underlays.len)
							X.underlays = T.underlays
						else
							X.underlays += undlay
					else
						X.underlays += undlay
					X.dir = old_dir1
					X.icon_state = old_icon_state1
					X.icon = old_icon1 //Shuttle floors are in shuttle.dmi while the defaults are floors.dmi

					var/turf/simulated/ST = T

					if(istype(ST) && ST.zone)
						var/turf/simulated/SX = X

						if(!SX.air)
							SX.make_air()

						SX.air.copy_from(ST.zone.air)
						ST.zone.remove(ST)

					/* Quick visual fix for some weird shuttle corner artefacts when on transit space tiles */
					if(direction && findtext(X.icon_state, "swall_s"))

						// Spawn a new shuttle corner object
						var/obj/corner = new()
						corner.forceMove(X)
						corner.density = 1
						corner.anchored = 1
						corner.icon = X.icon
						corner.icon_state = replacetext(X.icon_state, "_s", "_f")
						corner.tag = "delete me"
						corner.name = "wall"

						// Find a new turf to take on the property of
						var/turf/nextturf = get_step(corner, direction)
						if(!nextturf || !istype(nextturf, /turf/space))
							nextturf = get_step(corner, turn(direction, 180))


						// Take on the icon of a neighboring scrolling space icon
						X.icon = nextturf.icon
						X.icon_state = nextturf.icon_state


					for(var/obj/O in T)

						// Reset the shuttle corners
						if(O.tag == "delete me")
							X.icon = 'icons/turf/shuttle.dmi'
							X.icon_state = replacetext(O.icon_state, "_f", "_s") // revert the turf to the old icon_state
							X.name = "wall"
							del(O) // prevents multiple shuttle corners from stacking
							continue
						if(!istype(O,/obj)) continue
						O.forceMove(X)
					for(var/mob/M in T)
						if(!M.can_shuttle_move())
							continue
						M.forceMove(X)

//					var/area/AR = X.loc

//					if(AR.lighting_use_dynamic)							//TODO: rewrite this code so it's not messed by lighting ~Carn
//						X.opacity = !X.opacity
//						X.SetOpacity(!X.opacity)

					toupdate += X

					if(turftoleave)
						fromupdate += T.ChangeTurf(turftoleave)
					else
						if(ispath(AA.type, /area/syndicate_station/start))
							T.ChangeTurf(/turf/unsimulated/floor)
							T.icon = 'icons/turf/snow.dmi'
							T.icon_state = "snow"
						else
							T.ChangeTurf(get_base_turf(T.z))
							if(istype(T, /turf/space))
								switch(universe.name)	//for some reason using OnTurfChange doesn't actually do anything in this case.
									if("Hell Rising")
										T.overlays += "hell01"
									if("Supermatter Cascade")
										T.overlays += "end01"


					refined_src -= T
					refined_trg -= B
					continue moving

	var/list/doors = new/list()

	if(toupdate.len)
		for(var/turf/simulated/T1 in toupdate)
			for(var/obj/machinery/door/D2 in T1)
				doors += D2
			/*if(T1.parent)
				air_master.groups_to_rebuild += T1.parent
			else
				air_master.mark_for_update(T1)*/

	if(fromupdate.len)
		for(var/turf/simulated/T2 in fromupdate)
			for(var/obj/machinery/door/D2 in T2)
				doors += D2
			/*if(T2.parent)
				air_master.groups_to_rebuild += T2.parent
			else
				air_master.mark_for_update(T2)*/

	for(var/obj/machinery/door/D in doors)
		D.update_nearby_tiles()
