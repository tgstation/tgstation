GLOBAL_LIST_EMPTY(clients) //all clients
GLOBAL_LIST_EMPTY(admins) //all clients whom are admins
GLOBAL_PROTECT(admins)
GLOBAL_LIST_EMPTY(deadmins) //all ckeys who have used the de-admin verb.

GLOBAL_LIST_EMPTY(directory) //all ckeys with associated client
GLOBAL_LIST_EMPTY(stealthminID) //reference list with IDs that store ckeys, for stealthmins

GLOBAL_LIST_INIT(dangerous_turfs, typecacheof(list(
	/turf/open/lava,
	/turf/open/chasm,
	/turf/open/space,
	/turf/open/openspace)))

/// List of types of abstract mob which shouldn't usually exist in the world on its own if we're spawning random mobs
GLOBAL_LIST_INIT(abstract_mob_types, list(
	/mob/living/basic/blob_minion,
	/mob/living/basic/construct,
	/mob/living/basic/heretic_summon,
	/mob/living/basic/mining,
	/mob/living/basic/pet,
	/mob/living/basic,
	/mob/living/basic/spider,
	/mob/living/carbon/alien/adult,
	/mob/living/carbon/alien,
	/mob/living/carbon/human/consistent,
	/mob/living/carbon/human/dummy/consistent,
	/mob/living/carbon/human/dummy,
	/mob/living/carbon/human/species,
	/mob/living/carbon,
	/mob/living/silicon,
	/mob/living/simple_animal/bot,
	/mob/living/simple_animal/hostile/asteroid/elite,
	/mob/living/simple_animal/hostile/asteroid,
	/mob/living/simple_animal/hostile/construct,
	/mob/living/simple_animal/hostile/guardian,
	/mob/living/simple_animal/hostile/megafauna,
	/mob/living/simple_animal/hostile/mimic, // Cannot exist if spawned without being passed an item reference
	/mob/living/simple_animal/hostile/retaliate,
	/mob/living/simple_animal/hostile,
	/mob/living/simple_animal/pet,
	/mob/living/simple_animal/soulscythe, // As mimic, can't exist if spawned outside an item
	/mob/living/simple_animal,
))


//Since it didn't really belong in any other category, I'm putting this here
//This is for procs to replace all the goddamn 'in world's that are chilling around the code

GLOBAL_LIST_EMPTY(player_list) //all mobs **with clients attached**.
GLOBAL_LIST_EMPTY(keyloop_list) //as above but can be limited to boost performance
GLOBAL_LIST_EMPTY(mob_list) //all mobs, including clientless
GLOBAL_LIST_EMPTY(mob_directory) //mob_id -> mob
GLOBAL_LIST_EMPTY(alive_mob_list) //all alive mobs, including clientless. Excludes /mob/dead/new_player
GLOBAL_LIST_EMPTY(suicided_mob_list) //contains a list of all mobs that suicided, including their associated ghosts.
GLOBAL_LIST_EMPTY(drones_list)
GLOBAL_LIST_EMPTY(dead_mob_list) //all dead mobs, including clientless. Excludes /mob/dead/new_player
GLOBAL_LIST_EMPTY(joined_player_list) //all ckeys that have joined the game at round-start or as a latejoin.
GLOBAL_LIST_EMPTY(new_player_list) //all /mob/dead/new_player, in theory all should have clients and those that don't are in the process of spawning and get deleted when done.
GLOBAL_LIST_EMPTY(pre_setup_antags) //minds that have been picked as antag by the gamemode. removed as antag datums are set.
GLOBAL_LIST_EMPTY(silicon_mobs) //all silicon mobs
GLOBAL_LIST_EMPTY(mob_living_list) //all instances of /mob/living and subtypes
GLOBAL_LIST_EMPTY(carbon_list) //all instances of /mob/living/carbon and subtypes, notably does not contain brains or simple animals
GLOBAL_LIST_EMPTY(human_list) //all instances of /mob/living/carbon/human and subtypes
GLOBAL_LIST_EMPTY(ai_list)
GLOBAL_LIST_EMPTY(pai_list)
GLOBAL_LIST_EMPTY(available_ai_shells)
GLOBAL_LIST_INIT(simple_animals, list(list(),list(),list(),list())) // One for each AI_* status define
GLOBAL_LIST_EMPTY(spidermobs) //all sentient spider mobs
GLOBAL_LIST_EMPTY(bots_list)
GLOBAL_LIST_EMPTY(aiEyes)
GLOBAL_LIST_EMPTY(suit_sensors_list) //all people with suit sensors on

/// All alive mobs with clients.
GLOBAL_LIST_EMPTY(alive_player_list)

/// All dead mobs with clients. Does not include observers.
GLOBAL_LIST_EMPTY(dead_player_list)

/// All alive antags with clients.
GLOBAL_LIST_EMPTY(current_living_antags)

/// All observers with clients that joined as observers.
GLOBAL_LIST_EMPTY(current_observers_list)

/// All living mobs which can hear blob telepathy
GLOBAL_LIST_EMPTY(blob_telepathy_mobs)

/// All "living" (because revenants are in between mortal planes or whatever) mobs that can hear revenants
GLOBAL_LIST_EMPTY(revenant_relay_mobs)

///underages who have been reported to security for trying to buy things they shouldn't, so they can't spam
GLOBAL_LIST_EMPTY(narcd_underages)

GLOBAL_LIST_EMPTY(language_datum_instances)
GLOBAL_LIST_EMPTY(all_languages)
///List of all languages ("name" = type)
GLOBAL_LIST_EMPTY(language_types_by_name)

GLOBAL_LIST_EMPTY(sentient_disease_instances)

GLOBAL_LIST_EMPTY(latejoin_ai_cores)

GLOBAL_LIST_EMPTY(mob_config_movespeed_type_lookup)

GLOBAL_LIST_EMPTY(emote_list)

GLOBAL_LIST_INIT(construct_radial_images, list(
	CONSTRUCT_JUGGERNAUT = image(icon = 'icons/mob/nonhuman-player/cult.dmi', icon_state = "juggernaut"),
	CONSTRUCT_WRAITH = image(icon = 'icons/mob/nonhuman-player/cult.dmi', icon_state = "wraith"),
	CONSTRUCT_ARTIFICER = image(icon = 'icons/mob/nonhuman-player/cult.dmi', icon_state = "artificer")
))

/proc/update_config_movespeed_type_lookup(update_mobs = TRUE)
	var/list/mob_types = list()
	var/list/entry_value = CONFIG_GET(keyed_list/multiplicative_movespeed)
	for(var/path in entry_value)
		var/value = entry_value[path]
		if(!value)
			continue
		for(var/subpath in typesof(path))
			mob_types[subpath] = value
	GLOB.mob_config_movespeed_type_lookup = mob_types
	if(update_mobs)
		update_mob_config_movespeeds()

/proc/update_mob_config_movespeeds()
	for(var/i in GLOB.mob_list)
		var/mob/M = i
		M.update_config_movespeed()

/proc/init_emote_list()
	. = list()
	for(var/path in subtypesof(/datum/emote))
		var/datum/emote/E = new path()
		if(E.key)
			if(!.[E.key])
				.[E.key] = list(E)
			else
				.[E.key] += E
		else if(E.message) //Assuming all non-base emotes have this
			stack_trace("Keyless emote: [E.type]")

		if(E.key_third_person) //This one is optional
			if(!.[E.key_third_person])
				.[E.key_third_person] = list(E)
			else
				.[E.key_third_person] |= E

/proc/get_crewmember_minds()
	var/list/minds = list()
	for(var/datum/record/locked/target in GLOB.manifest.locked)
		var/datum/mind/mind = target.mind_ref.resolve()
		if(mind)
			minds += mind
	return minds
