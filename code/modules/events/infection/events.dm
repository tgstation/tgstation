GLOBAL_LIST_EMPTY(doom_event_mobs)

/datum/round_event_control/infection
	name = "Doom Clock Event"
	weight = 1
	max_occurrences = 1
	earliest_start = 0 MINUTES
	infectionevent = TRUE

/datum/round_event_control/infection/preRunEvent()
	// ok time to go old event mobs you had your fun
	for(var/mob/living/oldmob in GLOB.doom_event_mobs)
		GLOB.doom_event_mobs -= oldmob
		if(ismob(oldmob) && oldmob.stat != DEAD)
			oldmob.visible_message("<span class='notice'>[oldmob] fades away as all of it's energy leaves it's body...</span>",
								   "<span class='notice'>Your consciousness fades away as the last remnants of the energy that brought you back into this world dissipate...</span>")
			oldmob.health = 0 // need to snowflake this for mobs like megafauna that refuse to die
			oldmob.death()
	var/doom_delay = 300 // 30 seconds
	INVOKE_ASYNC(src, .proc/doom_smash_sounds, doom_delay)
	sleep(doom_delay - 90)
	. = ..()

/*
	Plays sounds to playing players before the event actually occurs
*/

/datum/round_event_control/infection/proc/doom_smash_sounds(var/total_delay = 300)
	var/sound_delay = 14
	var/sounds_played = FLOOR(total_delay / sound_delay, 1)
	var/list/smashsounds = list('sound/weapons/wpnMonsterSmashBig.ogg', 'sound/weapons/wpnMonsterSmashBig2.ogg', 'sound/weapons/wpnMonsterSmashBig3.ogg')
	var/list/tempsounds = smashsounds.Copy()
	for(var/i = 1 to sounds_played)
		if(!tempsounds.len)
			tempsounds = smashsounds.Copy()
		var/s = sound(pick_n_take(tempsounds))
		sound_to_playing_players(s)
		sleep(sound_delay)

/datum/round_event/infection
	// boss mob type, only one slime spawns as this, and they also drop the legendary weapon from boss_drop_list
	var/boss_type
	// overrides boss loot list, should always have at least one infectionkiller weapon, or the gamemode is obviously impossible to win
	var/list/boss_drop_list
	// list of minion types that can be a weighted list, picks from these to spawn in slime controlled mobs that are not the boss
	var/list/minion_types
	// overrides minion drop lists if you want to do something special
	var/list/minion_drop_list
	// announcement message sent to the whole station when the event occurs
	var/warning_message
	// sound that is sent when the event occurs
	var/warning_jingle
	fakeable = FALSE

/datum/round_event/infection/start()
	var/mob/camera/commander/C = GLOB.infection_commander
	var/turf/start = get_turf(GLOB.infection_core)
	// one lucky nerd
	var/mob/living/simple_animal/hostile/infection/infectionspore/sentient/boss_spore
	if(boss_type)
		boss_spore = locate(/mob/living/simple_animal/hostile/infection/infectionspore/sentient) in C.infection_mobs
		if(!boss_spore)
			message_admins("Error! Failed to get slime for infection event.")
			// spawn a random legendary weapon so the game isn't unbeatable
			var/list/legendaries = subtypesof(/obj/item/infectionkiller)
			for(var/i in 1 to legendaries.len)
				var/spawn_type = pick_n_take(legendaries)
				// don't bother specifying a position, they're stationloving so they'll come back anyways
				var/obj/item/infectionkiller/W = new spawn_type()
				// whoops it's not stationloving get rid of it
				if(!W.is_item)
					qdel(W)
					continue
				break
			return FALSE
		boss_spore.death()
		var/mob/living/simple_animal/boss = new boss_type(start)
		boss.add_atom_colour(C.color, FIXED_COLOUR_PRIORITY)
		boss.AddComponent(/datum/component/mindcontroller, boss_spore, list(ROLE_INFECTION))
		boss.AddComponent(/datum/component/no_beacon_crossing)
		boss.loot = boss_drop_list
		boss.pass_flags |= PASSBLOB
		GLOB.doom_event_mobs += boss
	// everyone else gets minions
	if(minion_types.len)
		for(var/mob/living/simple_animal/hostile/infection/infectionspore/sentient/spore in (C.infection_mobs - boss_spore))
			spore.death()
			var/minion_type = pickweight(minion_types)
			var/mob/living/simple_animal/minion = new minion_type(start)
			minion.add_atom_colour(C.color, FIXED_COLOUR_PRIORITY)
			minion.AddComponent(/datum/component/mindcontroller, spore, list(ROLE_INFECTION))
			minion.AddComponent(/datum/component/no_beacon_crossing)
			minion.loot = minion_drop_list
			minion.pass_flags |= PASSBLOB
			GLOB.doom_event_mobs += minion
	if(warning_message && warning_jingle)
		priority_announce("[warning_message]","CentCom Biohazard Division", warning_jingle)

/*
//
// Actual Events
//
*/

/datum/round_event_control/infection/space
	name = "Doom Event: Space Creatures"
	typepath = /datum/round_event/infection/space

/datum/round_event/infection/space
	boss_type = /mob/living/simple_animal/hostile/megafauna/dragon/space_dragon
	boss_drop_list = list(/obj/item/infectionkiller/excaliju)
	minion_types = list(/mob/living/simple_animal/hostile/hivebot/strong=1,
						/mob/living/simple_animal/hostile/skeleton=2,
						/mob/living/simple_animal/hostile/hivebot/range=3)
	minion_drop_list = list()
	warning_message = "A space dragon and other space creatures have wandered into the station!"
	warning_jingle = 'sound/weapons/bite.ogg'

/datum/round_event_control/infection/lavaland
	name = "Doom Event: Monsters From Lavaland"
	typepath = /datum/round_event/infection/lavaland

/datum/round_event/infection/lavaland
	boss_type = /mob/living/simple_animal/hostile/megafauna/blood_drunk_miner
	boss_drop_list = list(/obj/item/infectionkiller/drill)
	minion_types = list(/mob/living/simple_animal/hostile/asteroid/basilisk/watcher=1,
						/mob/living/simple_animal/hostile/skeleton/plasmaminer=3,
						/mob/living/simple_animal/hostile/asteroid/hivelord/legion=1)
	minion_drop_list = list()
	warning_message = "Lavaland monsters appear to be attacking the station!"
	warning_jingle = 'sound/magic/enter_blood.ogg'

/datum/round_event_control/infection/clown
	name = "Doom Event: Clowns"
	typepath = /datum/round_event/infection/clown

/datum/round_event/infection/clown
	boss_type = /mob/living/simple_animal/hostile/retaliate/clown/clownhulk/destroyer
	boss_drop_list = list(/obj/item/infectionkiller/staff)
	minion_types = list(/mob/living/simple_animal/hostile/retaliate/clown/clownhulk=1,
						/mob/living/simple_animal/hostile/retaliate/clown/mutant=1,
						/mob/living/simple_animal/hostile/retaliate/clown/lube=2,
						/mob/living/simple_animal/hostile/retaliate/clown/fleshclown=2,
						/mob/living/simple_animal/hostile/retaliate/clown/banana=2)
	minion_drop_list = list()
	warning_message = "Clowns... oh god the clowns..."
	warning_jingle = 'sound/items/bikehorn.ogg'

/datum/round_event_control/infection/jungle
	name = "Doom Event: Jungle Madness"
	typepath = /datum/round_event/infection/jungle

/datum/round_event/infection/jungle
	boss_type = /mob/living/simple_animal/hostile/jungle/mega_arachnid
	boss_drop_list = list(/obj/item/infectionkiller/tonic)
	minion_types = list(/mob/living/simple_animal/hostile/poison/bees=1,
						/mob/living/simple_animal/hostile/killertomato=1,
						/mob/living/simple_animal/hostile/mushroom=1,
						/mob/living/simple_animal/hostile/jungle/seedling=1)
	minion_drop_list = list()
	warning_message = "Jungle Creatures are invading the station!"
	warning_jingle = 'sound/creatures/gorilla.ogg'