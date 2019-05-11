/datum/round_event_control/infection
	name = "Doom Clock Event"
	weight = 1
	max_occurrences = 1
	earliest_start = 0 MINUTES
	infectionevent = TRUE

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
	var/mob/living/simple_animal/hostile/infection/infectionspore/sentient/boss_spore = locate(/mob/living/simple_animal/hostile/infection/infectionspore/sentient) in C.infection_mobs
	boss_spore.forceMove(GLOB.infection_core)
	var/mob/living/simple_animal/boss = new boss_type(start)
	boss.add_atom_colour(C.color, FIXED_COLOUR_PRIORITY)
	boss.AddComponent(/datum/component/spore_controlled, boss_spore)
	boss.loot = boss_drop_list
	boss.faction += ROLE_INFECTION
	boss.pass_flags |= PASSBLOB
	// everyone else gets minions
	for(var/mob/living/simple_animal/hostile/infection/infectionspore/sentient/spore in (C.infection_mobs - boss_spore))
		spore.forceMove(GLOB.infection_core)
		var/minion_type = pick(minion_types)
		var/mob/living/simple_animal/minion = new minion_type(start)
		minion.add_atom_colour(C.color, FIXED_COLOUR_PRIORITY)
		minion.AddComponent(/datum/component/spore_controlled, spore)
		minion.loot = minion_drop_list
		minion.faction += ROLE_INFECTION
		minion.pass_flags |= PASSBLOB
	if(warning_message)
		priority_announce("[warning_message]","Biohazard Containment Commander", 'sound/misc/notice1.ogg')
	if(warning_jingle)
		var/s = sound(warning_jingle)
		for(var/mob/M in GLOB.player_list)
			if(!isnewplayer(M) && M.can_hear())
				if(M.client.prefs.toggles & SOUND_ANNOUNCEMENTS)
					SEND_SOUND(M, s)


/datum/component/spore_controlled
	var/mob/parentmob
	var/mob/living/simple_animal/hostile/infection/infectionspore/sentient/realmob

/datum/component/spore_controlled/Initialize(var/mob/real)
	RegisterSignal(parent, COMSIG_MOB_DEATH, .proc/return_to_spore)
	parentmob = parent
	realmob = real
	// transfer spore mind to temp body
	realmob.mind.transfer_to(parentmob, TRUE)

/datum/component/spore_controlled/proc/return_to_spore()
	parentmob.mind.transfer_to(realmob, TRUE)
	realmob.death()

/*
//
// Actual Events
//
*/

/datum/round_event_control/infection/carp
	name = "Doom Event: Magical Carp Creatures"
	typepath = /datum/round_event/infection/carp

/datum/round_event/infection/carp
	boss_type = /mob/living/simple_animal/hostile/megafauna/dragon/space_dragon
	boss_drop_list = list(/obj/item/infectionkiller/excaliju)
	minion_types = list(/mob/living/simple_animal/hostile/carp/ranged, /mob/living/simple_animal/hostile/carp/ranged/chaos)
	minion_drop_list = list()
	warning_message = "Magical Carp Creatures are invading the station!"
	warning_jingle = 'sound/ambience/doomevent4.ogg'