GLOBAL_LIST_EMPTY(doom_event_mobs)

/datum/round_event_control/infection
	name = "Doom Clock Event"
	weight = 1
	max_occurrences = 3
	earliest_start = 0 MINUTES
	infectionevent = TRUE

/datum/round_event_control/infection/preRunEvent()
	// ok time to go old event mobs you had your fun
	for(var/mob/living/oldmob in GLOB.doom_event_mobs)
		GLOB.doom_event_mobs -= oldmob
		oldmob.visible_message("<span class='notice'>[oldmob] fades away as all of it's energy leaves it's body...</span>",
							   "<span class='notice'>Your consciousness fades away as the last remnants of the energy that brought you back into this world dissipate...</span>")
		oldmob.health = 0 // need to snowflake this for mobs like megafauna that refuse to die
		oldmob.death()
	var/doom_delay = 300 // 30 seconds
	INVOKE_ASYNC(src, .proc/doom_smash_sounds, doom_delay)
	sleep(doom_delay - 90)
	. = ..()

/datum/round_event_control/infection/proc/doom_smash_sounds(var/total_delay = 300)
	var/sound_delay = 14
	var/sounds_played = FLOOR(total_delay / sound_delay, 1)
	var/list/smashsounds = list('sound/weapons/wpnMonsterSmashBig.ogg', 'sound/weapons/wpnMonsterSmashBig2.ogg', 'sound/weapons/wpnMonsterSmashBig3.ogg')
	var/list/tempsounds = smashsounds.Copy()
	for(var/i = 1 to sounds_played)
		if(!tempsounds.len)
			tempsounds = smashsounds.Copy()
		var/s = sound(pick_n_take(tempsounds))
		for(var/mob/M in GLOB.player_list)
			if(!isnewplayer(M) && M.can_hear())
				if(M.client.prefs.toggles & SOUND_ANNOUNCEMENTS)
					SEND_SOUND(M, s)
		sleep(sound_delay)

/datum/round_event/infection
	var/boss_type // boss mob type (one lucky spore)
	var/list/boss_drop_list // overrides normal mob drops
	var/list/minion_types // minion mob type (everyone else)
	var/list/minion_drop_list // overrides normal mob drops
	var/warning_message // announcement message when the event occurs
	var/warning_jingle // jingle sound when the event occurs
	fakeable = FALSE

/datum/round_event/infection/start()
	var/mob/camera/commander/C = GLOB.infection_commander
	var/turf/start = get_turf(GLOB.infection_core)
	// one lucky nerd
	var/mob/living/simple_animal/hostile/infection/infectionspore/sentient/boss_spore
	if(boss_type)
		boss_spore = locate(/mob/living/simple_animal/hostile/infection/infectionspore/sentient) in C.infection_mobs
		if(!boss_spore)
			message_admins("Error! Failed to get spore for infection event. Consider spawning spores or giving legendary weapons to make victory possible.")
			return FALSE
		boss_spore.forceMove(GLOB.infection_core)
		var/mob/living/simple_animal/boss = new boss_type(start)
		boss.add_atom_colour(C.color, FIXED_COLOUR_PRIORITY)
		boss.AddComponent(/datum/component/spore_controlled, boss_spore)
		boss.loot = boss_drop_list
		boss.faction += ROLE_INFECTION
		boss.pass_flags |= PASSBLOB
		GLOB.doom_event_mobs += boss
	// everyone else gets minions
	if(minion_types.len)
		for(var/mob/living/simple_animal/hostile/infection/infectionspore/sentient/spore in (C.infection_mobs - boss_spore))
			spore.forceMove(GLOB.infection_core)
			var/minion_type = pickweight(minion_types)
			var/mob/living/simple_animal/minion = new minion_type(start)
			minion.add_atom_colour(C.color, FIXED_COLOUR_PRIORITY)
			minion.AddComponent(/datum/component/spore_controlled, spore)
			minion.loot = minion_drop_list
			minion.faction += ROLE_INFECTION
			minion.pass_flags |= PASSBLOB
			GLOB.doom_event_mobs += minion
	if(warning_message && warning_jingle)
		priority_announce("[warning_message]","CentCom Biohazard Division", warning_jingle)

/datum/component/spore_controlled
	var/mob/living/simple_animal/hostile/infection/infectionspore/sentient/realmob

/datum/component/spore_controlled/Initialize(mob/real, mob/parentmob = parent)
	RegisterSignal(parent, COMSIG_MOB_DEATH, .proc/return_to_spore)
	realmob = real
	// transfer spore mind to temp body
	parentmob.key = realmob.key

/datum/component/spore_controlled/proc/return_to_spore(mob/parentmob = parent)
	realmob.key = parentmob.key
	realmob.death()
	qdel(src)

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
	minion_types = list(/mob/living/simple_animal/hostile/pirate/melee/space, /mob/living/simple_animal/hostile/bear, /mob/living/simple_animal/hostile/asteroid/goliath/beast/ancient)
	minion_drop_list = list()
	warning_message = "Space Creatures are invading the station!"
	warning_jingle = 'sound/weapons/bite.ogg'

/datum/round_event_control/infection/demon
	name = "Doom Event: Demons From Lavaland"
	typepath = /datum/round_event/infection/demon

/datum/round_event/infection/demon
	boss_type = /mob/living/simple_animal/slaughter
	boss_drop_list = list(/obj/item/infectionkiller/excaliju)
	minion_types = list(/mob/living/simple_animal/hostile/asteroid/goliath=1, /mob/living/simple_animal/hostile/asteroid/basilisk/watcher=2, /mob/living/simple_animal/hostile/asteroid/hivelord/legion=3)
	minion_drop_list = list()
	warning_message = "Demons From Lavaland are invading the station!"
	warning_jingle = 'sound/magic/enter_blood.ogg'

/datum/round_event_control/infection/paperwizard
	name = "Doom Event: Paper Wizard"
	typepath = /datum/round_event/infection/paperwizard

/datum/round_event/infection/paperwizard
	boss_type = /mob/living/simple_animal/hostile/boss/paper_wizard
	boss_drop_list = list(/obj/item/infectionkiller/excaliju)
	minion_types = list(/mob/living/simple_animal/hostile/stickman, /mob/living/simple_animal/hostile/stickman/ranged, /mob/living/simple_animal/hostile/stickman/dog)
	minion_drop_list = list()
	warning_message = "The Paper Wizard is invading the station!"
	warning_jingle = 'sound/weapons/emitter.ogg'

/datum/round_event_control/infection/syndicate
	name = "Doom Event: The Syndicate"
	typepath = /datum/round_event/infection/syndicate

/datum/round_event/infection/syndicate
	boss_type = /mob/living/simple_animal/hostile/syndicate/ranged/shotgun/space/stormtrooper
	boss_drop_list = list(/obj/item/infectionkiller/excaliju)
	minion_types = list(/mob/living/simple_animal/hostile/syndicate=1, /mob/living/simple_animal/hostile/syndicate/melee/sword/space=1, /mob/living/simple_animal/hostile/viscerator=5)
	minion_drop_list = list()
	warning_message = "Syndicate Operatives are invading the station!"
	warning_jingle = 'sound/machines/alarm.ogg'

/datum/round_event_control/infection/jungle
	name = "Doom Event: Jungle Madness"
	typepath = /datum/round_event/infection/jungle

/datum/round_event/infection/jungle
	boss_type = /mob/living/simple_animal/hostile/jungle/leaper
	boss_drop_list = list(/obj/item/infectionkiller/excaliju)
	minion_types = list(/mob/living/simple_animal/hostile/gorilla=1, /mob/living/simple_animal/hostile/poison/bees=2, /mob/living/simple_animal/hostile/killertomato=2, /mob/living/simple_animal/hostile/mushroom=2)
	minion_drop_list = list()
	warning_message = "Jungle Creatures are invading the station!"
	warning_jingle = 'sound/creatures/gorilla.ogg'