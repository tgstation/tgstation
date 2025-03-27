/// Candidates for the petsplosion wizard event
GLOBAL_LIST_INIT(petsplosion_candidates, typecacheof(list(
	/mob/living/basic/bat,
	/mob/living/basic/butterfly,
	/mob/living/basic/carp/pet/cayenne,
	/mob/living/basic/chicken,
	/mob/living/basic/cow,
	/mob/living/basic/goat,
	/mob/living/basic/goose/vomit,
	/mob/living/basic/lizard,
	/mob/living/basic/mothroach,
	/mob/living/basic/mouse/brown/tom,
	/mob/living/basic/parrot,
	/mob/living/basic/pet,
	/mob/living/basic/pig,
	/mob/living/basic/rabbit,
	/mob/living/basic/sheep,
	/mob/living/basic/sloth,
	/mob/living/basic/snake,
	/mob/living/basic/spider/giant/sgt_araneus,
)))

/datum/round_event_control/wizard/petsplosion //the horror
	name = "Petsplosion"
	weight = 2
	typepath = /datum/round_event/wizard/petsplosion
	max_occurrences = 1 //Exponential growth is nothing to sneeze at!
	earliest_start = 0 MINUTES
	description = "Rapidly multiplies the animals on the station."
	min_wizard_trigger_potency = 0
	max_wizard_trigger_potency = 4
	/// Number of mobs we're going to duplicate
	var/mobs_to_dupe = 0

/datum/round_event_control/wizard/petsplosion/preRunEvent()
	for(var/mob/living/basic/dupe_animal in GLOB.alive_mob_list)
		count_mob(dupe_animal)
	for(var/mob/living/simple_animal/dupe_animal in GLOB.alive_mob_list)
		count_mob(dupe_animal)
	if(mobs_to_dupe > 100 || !mobs_to_dupe)
		return EVENT_CANT_RUN

	return ..()

/// Counts whether we found some kind of valid living mob
/datum/round_event_control/wizard/petsplosion/proc/count_mob(mob/living/dupe_animal)
	if(is_type_in_typecache(dupe_animal, GLOB.petsplosion_candidates) && is_station_level(dupe_animal.z))
		mobs_to_dupe++

/datum/round_event/wizard/petsplosion
	end_when = 61 //1 minute (+1 tick for endWhen not to interfere with tick)
	var/countdown = 0
	var/mobs_duped = 0

/datum/round_event/wizard/petsplosion/tick()
	if(activeFor < 30 * countdown) // 0 seconds : 2 animals | 30 seconds : 4 animals | 1 minute : 8 animals
		return
	countdown += 1

	//If you cull the herd before the next replication, things will be easier for you
	for(var/mob/living/basic/dupe_animal in GLOB.alive_mob_list)
		duplicate_mob(dupe_animal)
	for(var/mob/living/simple_animal/dupe_animal in GLOB.alive_mob_list)
		duplicate_mob(dupe_animal)

/// Makes a duplicate of a valid mob and increments our "too many mobs" counter
/datum/round_event/wizard/petsplosion/proc/duplicate_mob(mob/living/dupe_animal)
	if(!is_type_in_typecache(dupe_animal, GLOB.petsplosion_candidates) || !is_station_level(dupe_animal.z))
		return
	new dupe_animal.type(dupe_animal.loc)
	mobs_duped++
	if(mobs_duped > 400)
		kill()
