/datum/stationmodule_group
	var/name
	var/force
	var/station_map //Checks if the necessary map is loaded. Leave empty to always spawn regardless of map.
	var/list/possibilities = list()

/datum/controller/subsystem/mapping/proc/randomize_station()
	log_world("Randomizing station...")
	to_chat(world, "<span class='boldannounce'>Randomizing station...</span>")
	for (var/type in subtypesof(/datum/stationmodule_group))
		var/datum/stationmodule_group/inited = new type()
		if(inited.station_map && inited.station_map != SSmapping.config.map_name)
			continue
		var/list/picklist = inited.possibilities.Copy()
		picklist.Add("none")

		var/pick = pick(picklist)

		if (inited.force)
			pick = inited.force

		if (pick == "none")
			log_world("Group: [inited.name] | Picked: Default")
		else
			log_world("Group: [inited.name] | Picked: [pick]")
			var/datum/map_template/temp = module_templates[pick]
			if (isnull(temp))
				log_world("Improperly set up stationgroup (no module template): [pick]")
			else
				temp.load(locate(picklist[pick][1], picklist[pick][2], picklist[pick][3]), centered=FALSE, placeOnTop=TRUE, overWrite=TRUE)

	log_world("Finished randomizing station")
	to_chat(world, "<span class='boldannounce'>Finished randomizing station</span>")

//killingtorcher's admin verb for loading a randomized station template
/client/proc/map_template_load_force()
	set category = "Debug"
	set name = "Map template - Place (Overwrite)"

	var/datum/map_template/template

	var/map = input(usr, "Choose a Map Template to place at your CURRENT LOCATION","Place Map Template") as null|anything in SSmapping.map_templates
	if(!map)
		return
	template = SSmapping.map_templates[map]

	var/turf/T = get_turf(mob)
	if(!T)
		return

	var/list/preview = list()
	for(var/S in template.get_affected_turfs(T,centered = TRUE))
		preview += image('icons/turf/overlays.dmi',S,"greenOverlay")
	usr.client.images += preview
	if(alert(usr,"Confirm location.","Template Confirm","Yes","No") == "Yes")
		if(template.load(T, centered = TRUE, placeOnTop=TRUE, overWrite=TRUE))
			message_admins("<span class='adminnotice'>[key_name_admin(usr)] has placed a map template ([template.name]) at [ADMIN_COORDJMP(T)]</span>")
		else
			to_chat(usr, "Failed to place map")
			usr.client.images -= preview
	else
		usr.client.images -= preview

/proc/qdel_contents(turf/T)
	if (!isturf(T))
		return

	var/list/atom/allAtoms = list()
	for (var/atom/A in T)
		recurse_qdel(A, allAtoms)

	for(var/atom/ToDel in allAtoms)
		qdel(ToDel)

/proc/recurse_qdel(atom/A, list/L)
	for (var/atom/nextA in A.contents)
		recurse_qdel(nextA, L)
	L.Add(A)


/datum/controller/subsystem/mapping/proc/preloadModules(path = "_maps/modules/")
	var/list/filelist = flist(path)
	for (var/map in filelist)
		var/datum/map_template/T = new(path = "[path][map]", rename = "[map]")
		module_templates[map] = T

/datum/stationmodule_group/maint1
	name = "Maintenance 1"
	station_map = "Box Station"
	//force = "alt_maint1.dmm"

/datum/stationmodule_group/maint1/New()
	possibilities["alt_maint1.dmm"] = list(161,149,2)
	..()

/datum/stationmodule_group/maint2
	name = "Maintenance 2"
	station_map = "Box Station"
	//force = "alt_maint2.dmm"

/datum/stationmodule_group/maint2/New()
	possibilities["alt_maint2.dmm"] = list(53,151,2)
	..()

/datum/stationmodule_group/maint3
	name = "Maintenance 3"
	station_map = "Box Station"
	//force = "alt_maint3.dmm"

/datum/stationmodule_group/maint3/New()
	possibilities["alt_maint3.dmm"] = list(189,83,2)
	..()

/datum/stationmodule_group/maint4
	name = "Maintenance 4"
	station_map = "Box Station"
	//force = "alt_maint4.dmm"

/datum/stationmodule_group/maint4/New()
	possibilities["alt_maint4.dmm"] = list(197,81,2)
	..()

/datum/stationmodule_group/maint5
	name = "Maintenance 5"
	station_map = "Box Station"
	//force = "alt_maint5.dmm"

/datum/stationmodule_group/maint5/New()
	possibilities["alt_maint5.dmm"] = list(174,69,2)
	..()

/datum/stationmodule_group/maint_clown
	name = "Maintenance Clown"
	station_map = "Box Station"
	//force = "alt_maint_clown.dmm"

/datum/stationmodule_group/maint_clown/New()
	possibilities["alt_maint_clown.dmm"] = list(82,165,2)
	..()