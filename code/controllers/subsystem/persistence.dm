SUBSYSTEM_DEF(persistence)
	name = "Persistence"
	init_order = INIT_ORDER_PERSISTENCE
	flags = SS_NO_FIRE
	var/secret_satchels
	var/list/satchel_blacklist 		= list() //this is a typecache
	var/list/new_secret_satchels 	= list() //these are objects
	var/list/old_secret_satchels 		= ""

	var/list/obj/structure/chisel_message/chisel_messages = list()
	var/list/saved_messages = list()

	var/trophy_sav
	var/list/saved_trophies = list()

/datum/controller/subsystem/persistence/Initialize()
	LoadSatchels()
	LoadPoly()
	LoadChiselMessages()
	LoadTrophies()
	..()

/datum/controller/subsystem/persistence/proc/LoadSatchels()
	secret_satchels = file("data/npc_saves/SecretSatchels[SSmapping.config.map_name].json")
	if(!fexists(secret_satchels))
		return
	satchel_blacklist = typecacheof(list(/obj/item/stack/tile/plasteel, /obj/item/crowbar))
	var/list/json = list()
	json = json_decode(file2text(secret_satchels))
	old_secret_satchels = json["data"]
	var/placed_satchel = 0
	if(old_secret_satchels.len)
		if(old_secret_satchels.len >= 20) //guards against low drop pools assuring that one player cannot reliably find his own gear.
			var/pos = rand(1, old_secret_satchels.len)
			old_secret_satchels.Cut(pos, pos+1)
			var/obj/item/storage/backpack/satchel/flat/F = new()
			F.x = old_secret_satchels[pos]["x"]
			F.y = old_secret_satchels[pos]["y"]
			F.z = ZLEVEL_STATION
			var/path = text2path(old_secret_satchels[pos]["saved_obj"])
			if(!ispath(path))
				return
			if(isfloorturf(F.loc) && !istype(F.loc, /turf/open/floor/plating/))
				F.hide(1)
			new path(F)
			placed_satchel++

	var/list/free_satchels = list()
	for(var/turf/T in shuffle(block(locate(TRANSITIONEDGE,TRANSITIONEDGE,ZLEVEL_STATION), locate(world.maxx-TRANSITIONEDGE,world.maxy-TRANSITIONEDGE,ZLEVEL_STATION)))) //Nontrivially expensive but it's roundstart only
		if(isfloorturf(T) && !istype(T, /turf/open/floor/plating/))
			free_satchels += new /obj/item/storage/backpack/satchel/flat/secret(T)
			if(!isemptylist(free_satchels) && ((free_satchels.len + placed_satchel) >= (50 - old_secret_satchels.len) * 0.1)) //up to six tiles, more than enough to kill anything that moves
				break

/datum/controller/subsystem/persistence/proc/LoadPoly()
	for(var/mob/living/simple_animal/parrot/Poly/P in GLOB.living_mob_list)
		twitterize(P.speech_buffer, "polytalk")
		break //Who's been duping the bird?!

/datum/controller/subsystem/persistence/proc/LoadChiselMessages()
	var/json_file = file("data/npc_saves/ChiselMessages[SSmapping.config.map_name].json")
	if(!fexists(json_file))
		return
	var/list/json
	json = json_decode(file2text(json_file))

	if(!json)
		return

	var/list/saved_messages = json["data"]

	for(var/item in saved_messages)
		if(!islist(item))
			continue

		var/xvar = item["x"]
		var/yvar = item["y"]
		var/zvar = item["z"]

		if(!xvar || !yvar || !zvar)
			continue

		var/turf/T = locate(xvar, yvar, zvar)
		if(!isturf(T))
			continue

		if(locate(/obj/structure/chisel_message) in T)
			continue

		var/obj/structure/chisel_message/M = new(T)

		if(!QDELETED(M))
			M.unpack(item)

	log_world("Loaded [saved_messages.len] engraved messages on map [SSmapping.config.map_name]")

/datum/controller/subsystem/persistence/proc/LoadTrophies()
	trophy_sav = file("data/npc_saves/TrophyItems.json")
	if(!fexists(trophy_sav))
		return
	var/list/json = list()
	json = json_decode(file2text(trophy_sav))

	if(!json)
		return

	saved_trophies = json["data"]

	SetUpTrophies(saved_trophies.Copy())

/datum/controller/subsystem/persistence/proc/SetUpTrophies(list/trophy_items)
	for(var/A in GLOB.trophy_cases)
		var/obj/structure/displaycase/trophy/T = A
		T.added_roundstart = TRUE

		var/trophy_data = pick_n_take(trophy_items)

		if(!islist(trophy_data))
			continue

		var/list/chosen_trophy = trophy_data

		if(!chosen_trophy || isemptylist(chosen_trophy)) //Malformed
			continue

		var/path = text2path(chosen_trophy["path"]) //If the item no longer exist, this returns null
		if(!path)
			continue

		T.showpiece = new /obj/item/showpiece_dummy(T, path)
		T.trophy_message = chosen_trophy["message"]
		T.placer_key = chosen_trophy["placer_key"]
		T.update_icon()


/datum/controller/subsystem/persistence/proc/CollectData()
	CollectChiselMessages()
	CollectSecretSatchels()
	CollectTrophies()

/datum/controller/subsystem/persistence/proc/CollectSecretSatchels()
	var/list/satchels = list()
	for(var/A in new_secret_satchels)
		var/obj/item/storage/backpack/satchel/flat/F = A
		if(QDELETED(F) || F.z != ZLEVEL_STATION || F.invisibility != INVISIBILITY_MAXIMUM)
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
		var/list/data = list()
		data["x"] = F.x
		data["y"] = F.y
		data["saved_obj"] = pick(savable_obj)
		satchels += list(data)
	var/list/file_data = list()
	file_data["data"] = satchels
	fdel(secret_satchels)
	WRITE_FILE(secret_satchels, json_encode(file_data))

/datum/controller/subsystem/persistence/proc/CollectChiselMessages()
	var/json_file = file("data/npc_saves/ChiselMessages[SSmapping.config.map_name].json")

	for(var/obj/structure/chisel_message/M in chisel_messages)
		saved_messages += list(M.pack())

	log_world("Saved [saved_messages.len] engraved messages on map [SSmapping.config.map_name]")
	var/list/file_data = list()
	file_data["data"] = saved_messages
	fdel(json_file)
	WRITE_FILE(json_file, json_encode(file_data))

/datum/controller/subsystem/persistence/proc/SaveChiselMessage(obj/structure/chisel_message/M)
	saved_messages += list(M.pack()) // dm eats one list


/datum/controller/subsystem/persistence/proc/CollectTrophies()
	var/list/file_data = list()
	file_data["data"] = saved_trophies
	fdel(trophy_sav)
	WRITE_FILE(trophy_sav, json_encode(file_data))

/datum/controller/subsystem/persistence/proc/SaveTrophy(obj/structure/displaycase/trophy/T)
	if(!T.added_roundstart && T.showpiece)
		var/list/data = list()
		data["path"] = T.showpiece.type
		data["message"] = T.trophy_message
		data["placer_key"] = T.placer_key
		saved_trophies += list(data)
