var/datum/subsystem/persistence/SSpersistence

/datum/subsystem/persistence
	name = "Persistence"
	init_order = -100
	flags = SS_NO_FIRE
	var/savefile/secret_satchels
	var/list/satchel_blacklist 		= list() //this is a typecache
	var/list/new_secret_satchels 	= list() //these are objects
	var/old_secret_satchels 		= ""

	var/list/obj/structure/chisel_message/chisel_messages = list()
	var/list/saved_messages = list()
	var/savefile/chisel_messages_sav

/datum/subsystem/persistence/New()
	NEW_SS_GLOBAL(SSpersistence)

/datum/subsystem/persistence/Initialize()
	LoadSatchels()
	LoadPoly()
	LoadChiselMessages()
	..()

/datum/subsystem/persistence/proc/LoadSatchels()
	secret_satchels = new /savefile("data/npc_saves/SecretSatchels.sav")
	satchel_blacklist = typecacheof(list(/obj/item/stack/tile/plasteel, /obj/item/weapon/crowbar))
	secret_satchels[MAP_NAME] >> old_secret_satchels

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
		if(isfloorturf(T) && !istype(T,/turf/open/floor/plating/))
			free_satchels += new /obj/item/weapon/storage/backpack/satchel/flat/secret(T)
			if(!isemptylist(free_satchels) && ((free_satchels.len + placed_satchels) >= (50 - expanded_old_satchels.len) * 0.1)) //up to six tiles, more than enough to kill anything that moves
				break

/datum/subsystem/persistence/proc/PlaceSecretSatchel(list/expanded_old_satchels)
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
	if(isfloorturf(F.loc) && !istype(F.loc,/turf/open/floor/plating/))
		F.hide(1)
	new path(F)
	return 1

/datum/subsystem/persistence/proc/LoadPoly()
	for(var/mob/living/simple_animal/parrot/Poly/P in living_mob_list)
		twitterize(P.speech_buffer, "polytalk")
		break //Who's been duping the bird?!

/datum/subsystem/persistence/proc/LoadChiselMessages()
	chisel_messages_sav = new /savefile("data/npc_saves/ChiselMessages.sav")
	var/saved_json
	chisel_messages_sav[MAP_NAME] >> saved_json

	if(!saved_json)
		return

	var/saved_messages = saved_json

	for(var/item in saved_messages)
		var/turf/T = locate(item["x"], item["y"], ZLEVEL_STATION)
		if(!isturf(T))
			continue
		if(locate(/obj/structure/chisel_message) in T)
			continue
		var/obj/structure/chisel_message/M = new(T)
		M.unpack(item)
		if(!M.loc)
			M.persists = FALSE
			qdel(M)


/datum/subsystem/persistence/proc/CollectData()
	CollectChiselMessages()
	CollectSecretSatchels()

/datum/subsystem/persistence/proc/CollectSecretSatchels()
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
	secret_satchels[MAP_NAME] << old_secret_satchels

/datum/subsystem/persistence/proc/CollectChiselMessages()
	for(var/obj/structure/chisel_message/M in chisel_messages)
		saved_messages += list(M.pack())

	chisel_messages_sav[MAP_NAME] << saved_messages

/datum/subsystem/persistence/proc/SaveChiselMessage(obj/structure/chisel_message/M)
	saved_messages += list(M.pack()) // dm eats one list.
