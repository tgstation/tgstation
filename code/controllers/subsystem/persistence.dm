var/datum/subsystem/persistence/SSpersistence

/datum/subsystem/persistence
	name = "Persistence"
	init_order = -100
	flags = SS_NO_FIRE
	var/savefile/secret_satchels
	var/list/satchel_blacklist 		= list() //this is a typecache
	var/list/new_secret_satchels 	= list() //these are objects
	var/old_secret_satchels 		= ""

/datum/subsystem/persistence/New()
	NEW_SS_GLOBAL(SSpersistence)

/datum/subsystem/persistence/Initialize()
	if(!PlaceSecretSatchel())
		PlaceFreeSatchel()
	..()

/datum/subsystem/persistence/proc/CollectData()
	CollectSecretSatchels()

/datum/subsystem/persistence/proc/PlaceSecretSatchel()
	secret_satchels = new /savefile("data/npc_saves/SecretSatchels.sav")
	satchel_blacklist = typecacheof(list(/obj/item/stack/tile/plasteel, /obj/item/weapon/crowbar))

	secret_satchels[MAP_NAME] >> old_secret_satchels

	if(isnull(old_secret_satchels))
		return 0

	var/list/expanded_old_satchels = splittext(old_secret_satchels,"#")
	var/satchel_string

	if(expanded_old_satchels.len >= 20) //guards against low drop pools assuring that one player cannot reliably find his own gear.
		satchel_string = pick_n_take(expanded_old_satchels)

	old_secret_satchels = jointext(expanded_old_satchels,"#")
	secret_satchels[MAP_NAME] << old_secret_satchels

	var/list/chosen_satchel = splittext(satchel_string,"|")
	if(!chosen_satchel || isemptylist(chosen_satchel) || chosen_satchel.len != 3) //Malformed
		return 0

	var/path = text2path(chosen_satchel[3]) //If the item no longer exist, this returns null
	if(!path)
		return 0

	var/obj/item/weapon/storage/backpack/satchel/flat/F = new()
	F.x = text2num(chosen_satchel[1])
	F.y = text2num(chosen_satchel[2])
	F.z = ZLEVEL_STATION
	if(istype(F.loc,/turf/open/floor) && !istype(F.loc,/turf/open/floor/plating/))
		F.hide(1)
	new path(F)
	return 1

/datum/subsystem/persistence/proc/PlaceFreeSatchel()
	var/satchel_placed = FALSE
	var/breakout = 0
	while(!satchel_placed && breakout <= 5)
		for(var/V in shuffle(get_area_turfs(pick(the_station_areas))))
			var/turf/T = V
			if(istype(T,/turf/open/floor) && !istype(T,/turf/open/floor/plating/))
				new /obj/item/weapon/storage/backpack/satchel/flat/secret(T)
				satchel_placed = TRUE
				break
		breakout++

/datum/subsystem/persistence/proc/CollectSecretSatchels()
	for(var/A in new_secret_satchels)
		var/obj/item/weapon/storage/backpack/satchel/flat/F = A
		if(qdeleted(F) || F.z != ZLEVEL_STATION || F.invisibility != INVISIBILITY_MAXIMUM)
			continue
		var/list/savable_obj = list()
		for(var/obj/O in F)
			if(is_type_in_typecache(O, satchel_blacklist) || O.admin_spawned)
				continue
			if(O.persistence_replacement)
				savable_obj += O.persistence_replacement
			else
				savable_obj += O.type
		if(isemptylist(savable_obj))
			continue
		old_secret_satchels += "[F.x]|[F.y]|[pick(savable_obj)]#"
	secret_satchels[MAP_NAME] << old_secret_satchels
