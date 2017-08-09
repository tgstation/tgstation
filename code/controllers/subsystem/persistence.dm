SUBSYSTEM_DEF(persistence)
	name = "Persistence"
	init_order = INIT_ORDER_PERSISTENCE
	flags = SS_NO_FIRE
	var/savefile/secret_satchels
	var/list/satchel_blacklist 		= list() //this is a typecache
	var/list/new_secret_satchels 	= list() //these are objects
	var/old_secret_satchels 		= ""

	var/list/obj/structure/chisel_message/chisel_messages = list()
	var/list/saved_messages = list()

	var/savefile/trophy_sav
	var/list/saved_trophies = list()

/datum/controller/subsystem/persistence/Initialize()
	LoadSatchels()
	LoadPoly()
	LoadChiselMessages()
	LoadTrophies()
	..()

/datum/controller/subsystem/persistence/proc/LoadSatchels()
	secret_satchels = new /savefile("data/npc_saves/SecretSatchels.sav")
	satchel_blacklist = typecacheof(list(/obj/item/stack/tile/plasteel, /obj/item/weapon/crowbar))
	secret_satchels[SSmapping.config.map_name] >> old_secret_satchels

	var/list/expanded_old_satchels = list()
	var/placed_satchels = 0

	if(!isnull(old_secret_satchels))
		expanded_old_satchels = splittext(old_secret_satchels,"#")
		if(PlaceSecretSatchel(expanded_old_satchels))
			placed_satchels++
	else
		expanded_old_satchels.len = 0

	var/list/free_satchels = list()
	for(var/turf/T in shuffle(block(locate(TRANSITIONEDGE,TRANSITIONEDGE,ZLEVEL_STATION), locate(world.maxx-TRANSITIONEDGE,world.maxy-TRANSITIONEDGE,ZLEVEL_STATION)))) //Nontrivially expensive but it's roundstart only
		if(isfloorturf(T) && !istype(T, /turf/open/floor/plating/))
			free_satchels += new /obj/item/weapon/storage/backpack/satchel/flat/secret(T)
			if(!isemptylist(free_satchels) && ((free_satchels.len + placed_satchels) >= (50 - expanded_old_satchels.len) * 0.1)) //up to six tiles, more than enough to kill anything that moves
				break

/datum/controller/subsystem/persistence/proc/PlaceSecretSatchel(list/expanded_old_satchels)
	var/satchel_string

	if(expanded_old_satchels.len >= 20) //guards against low drop pools assuring that one player cannot reliably find his own gear.
		satchel_string = pick_n_take(expanded_old_satchels)

	old_secret_satchels = jointext(expanded_old_satchels,"#")
	WRITE_FILE(secret_satchels[SSmapping.config.map_name], old_secret_satchels)

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
	if(isfloorturf(F.loc) && !istype(F.loc, /turf/open/floor/plating/))
		F.hide(1)
	new path(F)
	return 1

/datum/controller/subsystem/persistence/proc/LoadPoly()
	for(var/mob/living/simple_animal/parrot/Poly/P in GLOB.living_mob_list)
		twitterize(P.speech_buffer, "polytalk")
		break //Who's been duping the bird?!

/datum/controller/subsystem/persistence/proc/LoadChiselMessages()
	var/savefile/chisel_messages_sav = new /savefile("data/npc_saves/ChiselMessages.sav")
	var/saved_json
	chisel_messages_sav[SSmapping.config.map_name] >> saved_json

	if(!saved_json)
		return

	var/list/saved_messages = json_decode(saved_json)

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
	trophy_sav = new /savefile("data/npc_saves/TrophyItems.sav")
	var/saved_json
	trophy_sav >> saved_json

	if(!saved_json)
		return

	var/decoded_json = json_decode(saved_json)

	if(!islist(decoded_json))
		return

	saved_trophies = decoded_json

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
	for(var/A in new_secret_satchels)
		var/obj/item/weapon/storage/backpack/satchel/flat/F = A
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
		old_secret_satchels += "[F.x]|[F.y]|[pick(savable_obj)]#"
	WRITE_FILE(secret_satchels[SSmapping.config.map_name], old_secret_satchels)

/datum/controller/subsystem/persistence/proc/CollectChiselMessages()
	var/savefile/chisel_messages_sav = new /savefile("data/npc_saves/ChiselMessages.sav")

	for(var/obj/structure/chisel_message/M in chisel_messages)
		saved_messages += list(M.pack())

	log_world("Saved [saved_messages.len] engraved messages on map [SSmapping.config.map_name]")

	WRITE_FILE(chisel_messages_sav[SSmapping.config.map_name], json_encode(saved_messages))

/datum/controller/subsystem/persistence/proc/SaveChiselMessage(obj/structure/chisel_message/M)
	saved_messages += list(M.pack()) // dm eats one list


/datum/controller/subsystem/persistence/proc/CollectTrophies()
	WRITE_FILE(trophy_sav, json_encode(saved_trophies))

/datum/controller/subsystem/persistence/proc/SaveTrophy(obj/structure/displaycase/trophy/T)
	if(!T.added_roundstart && T.showpiece)
		var/list/data = list()
		data["path"] = T.showpiece.type
		data["message"] = T.trophy_message
		data["placer_key"] = T.placer_key
		saved_trophies += list(data)
