var/datum/subsystem/persistence/SSpersistence

/datum/subsystem/persistence
	name = "Persistence"
	init_order = -100
	flags = SS_NO_FIRE
	var/savefile/secret_satchels
	var/list/new_secret_satchels = list() //these are objects
	var/list/old_secret_satchels = list() //these are associate

/datum/subsystem/persistence/New()
	NEW_SS_GLOBAL(SSpersistence)

/datum/subsystem/persistence/Initialize()
	PlaceSecretSatchel()
	..()

/datum/subsystem/persistence/proc/CollectData()
	CollectSecretSatchels()

/datum/subsystem/persistence/proc/PlaceSecretSatchel()
	var/list/satchels = list()
	var/list/invalid_satchels = list()
	secret_satchels = new /savefile("data/npc_saves/SecretSatchels.sav")
	while(!secret_satchels.eof)
		var/list/potential_satchel = list()
		secret_satchels >> potential_satchel
		if(potential_satchel["map"] != MAP_NAME)
			invalid_satchels += potential_satchel
			continue
		satchels += potential_satchel
	if(satchels.len < 1)
		return
	var/list/chosen_satchel = pick_n_take(satchels)
	old_secret_satchels = satchels + invalid_satchels
	secret_satchels << old_secret_satchels
	var/path = text2path(chosen_satchel["object"])
	var/obj/item/weapon/storage/backpack/satchel/flat/secret/F = new(chosen_satchel["loc"])
	new path(F) //runtimes intentionally if satchel item has had its path changed/removed

/datum/subsystem/persistence/proc/CollectSecretSatchels()
	world << "<span class='boldannounce'>Here we go</span>"
	var/list/saved_satchels = list()
	for(var/A in new_secret_satchels)
		world << "<span class='boldannounce'>we got satch!</span>"
		var/obj/item/weapon/storage/backpack/satchel/flat/F = A
		if(qdeleted(F) || F.z != ZLEVEL_STATION || F.invisibility != INVISIBILITY_MAXIMUM)
			continue
		var/list/savable_obj = list()
		for(var/obj/O in F)
			if(ispath(O,/obj/item/stack/tile/plasteel) || ispath(O,/obj/item/weapon/crowbar) || O.admin_spawned)
				continue
			savable_obj += O.type
		if(savable_obj.len < 1)
			continue
		world << "<span class='boldannounce'>and it's valid!</span>"
		saved_satchels += list("map" = MAP_NAME, "loc" = F.loc, "object" = pick(savable_obj))
	world << "<span class='boldannounce'>AAAAAAA HERE COMES PAIN</span>"
	secret_satchels << old_secret_satchels + saved_satchels
	world << "<span class='boldannounce'>we did it reddit</span>"