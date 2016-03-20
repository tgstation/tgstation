//Vaults are structures that are randomly spawned as a part of the main map
//They're stored in maps/randomVaults/ as .dmm files

//HOW TO ADD YOUR OWN VAULTS:
//1. make a map in the maps/randomVaults/ folder (1 zlevel only please)
//2. add the map's name to the vault_map_names list
//3. the game will handle the rest

#define MINIMUM_VAULT_AMOUNT 1 //Amount of guaranteed vault spawns

//#define SPAWN_ALL_VAULTS //Uncomment to spawn all existing vaults (otherwise only some will spawn)!

//List of spawnable vaults is in code/modules/randomMaps/vault_definitions.dm

/area/random_vault
	name = "random vault area"
	desc = "Spawn a vault in there somewhere"
	icon_state = "random_vault"

//Because areas are shit and it's easier that way!

//Each of these areas can only create ONE vault. Only using /area/random_vault/v1 for the entire map will result in ONE vault being created.
//Placing them over (or even near) shuttle docking ports will sometimes result in a vault spawning on top of a shuttle docking port. This isn't a big problem, since
//shuttles can destroy the vaults, but it's better to avoid that
//If you want more vaults, feel free to add more subtypes of /area/random_vault. You don't have to add these subtypes to any lists or anything - just map it and the game will handle the rest.

//"/area/random_vault" DOESN'T spawn any vaults!!!
/area/random_vault/v1
/area/random_vault/v2
/area/random_vault/v3
/area/random_vault/v4
/area/random_vault/v5
/area/random_vault/v6
/area/random_vault/v7
/area/random_vault/v8
/area/random_vault/v9
/area/random_vault/v10

/proc/generate_vaults()
	var/area/space = get_space_area

	var/list/list_of_vault_spawners = shuffle(typesof(/area/random_vault) - /area/random_vault)
	var/list/list_of_vaults = typesof(/datum/vault) - /datum/vault

	for(var/vault_path in list_of_vaults) //Turn a list of paths into a list of objects
		list_of_vaults.Add(new vault_path)
		list_of_vaults.Remove(vault_path)

	//Start processing the list of vaults

	if(map.only_spawn_map_exclusive_vaults) //If the map spawns only map-exclusive vaults - remove all vaults that aren't exclusive to this map
		for(var/datum/vault/V in list_of_vaults)

			if(V.exclusive_to_maps.Find(map.nameShort) || V.exclusive_to_maps.Find(map.nameLong))
				continue

			list_of_vaults.Remove(V)
	else //Map spawns all vaults - remove all vaults that are exclusive to other maps
		for(var/datum/vault/V in list_of_vaults)

			if(V.exclusive_to_maps.len)
				if(!V.exclusive_to_maps.Find(map.nameShort) && !V.exclusive_to_maps.Find(map.nameLong))
					list_of_vaults.Remove(V)

	for(var/datum/vault/V in list_of_vaults) //Remove all vaults that can't spawn on this map
		if(V.map_blacklist.len)
			if(V.map_blacklist.Find(map.nameShort) || V.map_blacklist.Find(map.nameLong))
				list_of_vaults.Remove(V)

	var/failures = 0
	var/successes = 0
	var/vault_number = rand(MINIMUM_VAULT_AMOUNT, min(list_of_vaults.len, list_of_vault_spawners.len))

	#ifdef SPAWN_ALL_VAULTS
	#warning Spawning all vaults!
	vault_number = min(list_of_vaults.len, list_of_vault_spawners.len)
	#endif

	message_admins("<span class='info'>Spawning [vault_number] vaults (in [list_of_vault_spawners.len] areas)...</span>")

	for(var/T in list_of_vault_spawners) //Go through all subtypes of /area/random_vault
		var/area/A = locate(T) //Find the area

		if(!A || !A.contents.len) //Area is empty and doesn't exist - skip
			continue

		if(list_of_vaults.len > 0 && vault_number>0)
			vault_number--

			var/vault_x
			var/vault_y
			var/vault_z

			var/turf/TURF = get_turf(pick(A.contents))

			vault_x = TURF.x
			vault_y = TURF.y
			vault_z = TURF.z

			var/datum/vault/new_vault = pick(list_of_vaults) //Pick a random path from list_of_vaults (like /datum/vault/spacegym)

			if(!new_vault.only_spawn_once)
				list_of_vaults.Remove(new_vault)

			var/path_file = "[new_vault.map_directory][new_vault.map_name].dmm"

			if(fexists(path_file))
				var/list/L = maploader.load_map(file(path_file), vault_z, vault_x, vault_y)
				new_vault.initialize(L)

				message_admins("<span class='info'>Loaded [path_file]: [formatJumpTo(locate(vault_x, vault_y, vault_z))].")
				successes++
			else
				message_admins("<span class='danger'>Can't find [path_file]!</span>")
				failures++

		for(var/turf/TURF in A) //Replace all of the temporary areas with space
			space.contents.Add(TURF)
			TURF.change_area(A, space)

	message_admins("<span class='info'>Loaded [successes] vaults successfully, [failures] failures.</span>")
