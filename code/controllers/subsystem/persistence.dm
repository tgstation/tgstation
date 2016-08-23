var/datum/subsystem/persistence/SSpersistence

/datum/subsystem/persistence
	name = "Persistence"
	init_order = -100
	flags = SS_NO_FIRE
	var/savefile/secret_satchels
	var/list/satchel_blacklist 		= list() //this is a typecache
	var/list/new_secret_satchels 	= list() //these are objects
	var/list/old_secret_satchels 	= list() //these are just vars

/datum/subsystem/persistence/New()
	NEW_SS_GLOBAL(SSpersistence)

/datum/subsystem/persistence/Initialize()
	if(!PlaceSecretSatchel())
		PlaceFreeSatchel()
	..()

/datum/subsystem/persistence/proc/CollectData()
	CollectSecretSatchels()

/datum/subsystem/persistence/proc/PlaceSecretSatchel()
	secret_satchels = new /savefile("data/npc_saves/SecretSatchels_[MAP_NAME].sav")
	satchel_blacklist = typecacheof(list(/obj/item/stack/tile/plasteel, /obj/item/weapon/crowbar))

	secret_satchels >> old_secret_satchels
	if(isnull(old_secret_satchels) || isemptylist(old_secret_satchels))
		old_secret_satchels = list()
		return 0

	var/list/chosen_satchel
	if(old_secret_satchels.len >= 20) //guards against low drop pools assuring that one player cannot reliably find his own gear.
		chosen_satchel = pick_n_take(old_secret_satchels)
	secret_satchels << old_secret_satchels
	if(!chosen_satchel || chosen_satchel.len != 3) //Malformed
		return 0

	var/path = text2path(chosen_satchel[3]) //If the item no longer exist, this returns null
	if(!path)
		return 0

	var/obj/item/weapon/storage/backpack/satchel/flat/F = new()
	F.x = chosen_satchel[1]
	F.y = chosen_satchel[2]
	F.z = ZLEVEL_STATION
	if(istype(F.loc,/turf/open/floor) && !istype(F.loc,/turf/open/floor/plating/))
		F.hide(1)
	new path(F)
	return 1

/datum/subsystem/persistence/proc/PlaceFreeSatchel()
	for(var/V in shuffle(get_area_turfs(pick(the_station_areas))))
		var/turf/T = V
		if(istype(T,/turf/open/floor) && !istype(T,/turf/open/floor/plating/))
			new /obj/item/weapon/storage/backpack/satchel/flat/secret(T)
			break

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
		if(savable_obj.len < 1)
			continue
		if(isemptylist(old_secret_satchels))
			old_secret_satchels = list(list(F.x, F.y, "[pick(savable_obj)]"))
		else
			old_secret_satchels.len += 1
			old_secret_satchels[old_secret_satchels.len] = list(F.x, F.y, "[pick(savable_obj)]")
	secret_satchels << old_secret_satchels
