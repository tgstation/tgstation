///This file contains station traits that typically roll on every other round during april fools.
/datum/station_trait/april_fools
	weight = 0 //Prevent the station traits from being picked by SSstation.SetupTraits.
	abstract_type = /datum/station_trait/april_fools
	trait_type = STATION_TRAIT_NEUTRAL //They should all be treated as neutral traits, it's easier to pick them that way.
	//By default, they don't. Some of them just add more station traits, while it doesn't take much to understand others are pranks.
	show_in_report = FALSE
	can_revert = FALSE //I'm pretty sure these won't be easy to revert a trait that adds more unrevertable traits.

///Enables all job traits
/datum/station_trait/april_fools/all_jobs
	name = "All Job Traits Enabled (April Fools)"

/datum/station_trait/april_fools/all_jobs/New()
	. = ..()
	for(var/datum/station_trait/job/job_trait as anything in subtypesof(/datum/station_trait/job))
		if(job_trait in SSstation.selectable_traits_by_types[job_trait::trait_type]) //Not blacklisted or abstract
			SSstation.setup_trait(job_trait)

///Enable a bunch of traits regardless of weight. Yes, it can pick other april fools trait as well.
/datum/station_trait/april_fools/random_traits
	name = "A Bunch Of Random Traits (April Fools)"

/datum/station_trait/april_fools/random_traits/New()
	. = ..()
	var/traits_left = rand(10, 20)
	var/list/available_types = SSstation.selectable_traits_by_types.Copy()
	while(traits_left > 0)
		if(!length(available_types))
			break
		var/picked_type = pick(available_types)
		var/list_to_pick_from = SSstation.selectable_traits_by_types[picked_type]
		if(!length(list_to_pick_from))
			available_types -= picked_type
			continue
		SSstation.setup_trait(pick(list_to_pick_from))
		traits_left--

///Shuffle job landmarks around. Might get some people stuck, which is why we also give them a mini welding tool.
/datum/station_trait/april_fools/shuffe_job_landmarks
	name = "Shuffle Job Landmarks (April Fools)"
	blacklist = list(/datum/station_trait/late_arrivals, /datum/station_trait/random_spawns, /datum/station_trait/hangover)

/datum/station_trait/april_fools/shuffe_job_landmarks/New()
	. = ..()
	RegisterSignal(SSminor_mapping, , PROC_REF(shuffe_job_landmarks))
	RegisterSignal(SSdcs, COMSIG_GLOB_JOB_AFTER_SPAWN, PROC_REF(give_emergency_welding_tool))

/datum/station_trait/april_fools/proc/shuffe_job_landmarks()
	SIGNAL_HANDLER
	var/list/stored_locations = list()
	var/list/stored_landmarks = list()
	//While it'll be hella funny, I'm sure we should leave non-crew landmarks untouched.
	var/list/skipped_landmark_types = typecacheof(list(
		/obj/effect/landmark/start/nukeop,
		/obj/effect/landmark/start/nukeop_leader,
		/obj/effect/landmark/start/nukeop_overwatch,
		/obj/effect/landmark/start/new_player,
		/obj/effect/landmark/start/hangover,
	))
	for(var/obj/effect/landmark/start/landmark as anything in GLOB.start_landmarks_list)
		if(is_type_in_typecache(landmark, skipped_landmark_types))
			continue
		stored_locations += landmark.loc
		stored_landmarks += landmark

	stored_landmarks = shuffle(stored_landmarks)
	for(var/obj/effect/landmark/start/landmark as anything in stored_landmarks)
		var/picked_location = pick_n_take(stored_locations)
		landmark.forceMove(picked_location)

//Make it a little harder to be completely stuck in a room with no other way out. I'm that kind...
/datum/station_trait/april_fools/proc/give_emergency_welding_tool(datum/source, datum/job/job, mob/living/spawned, joined_late)
	SIGNAL_HANDLER
	if(joined_late || issilicon(spawned)) //You already have all access, borgos.
		return
	var/obj/item/weldingtool/mini/i_may_be_stuck = new(get_turf(spawned))
	var/list/slot_list = list(ITEM_SLOT_HANDS, ITEM_SLOT_LPOCKET, ITEM_SLOT_RPOCKET, ITEM_SLOT_BACKPACK)
	spawned.equip_in_one_of_slots(i_may_be_stuck, slot_list, qdel_on_fail = FALSE, indirect_action = TRUE)

/datum/station_trait/april_fools/another_holiday
	name = "Pick Random Holiday (April Fools)"

/datum/station_trait/april_fools/another_holiday/New()
	. = ..()
	var/holiday_type = pick(subtypesof(/datum/holiday))
	var/datum/holiday/holiday = new holiday_type()
	holiday.celebrate()
	if(!holiday.holiday_colors)
		return
	var/datum/holiday/april_fools/fools = GLOB.holidays[APRIL_FOOLS]
	fools.holiday_colors = FALSE

/datum/station_trait/april_fools/super_maintenance_loot
	name = "Super Maintenance Loot (April Fools)"
	can_revert = TRUE

/datum/station_trait/aprol_fools/super_maintenance_loot/New()
	. = ..()
	GLOB.maintenance_loot -= GLOB.trash_loot
	GLOB.maintenance_loot -= GLOB.common_loot
	GLOB.maintenance_loot[GLOB.uncommon_loot] /= 5
	GLOB.maintenance_loot[GLOB.oddity_loot] *= 2

/datum/station_trait/aprol_fools/super_maintenance_loot/revert()
	GLOB.maintenance_loot[GLOB.trash_loot] = maint_trash_weight
	GLOB.maintenance_loot[GLOB.common_loot] = maint_common_weight
	GLOB.maintenance_loot[GLOB.uncommon_loot] *= 5
	GLOB.maintenance_loot[GLOB.oddity_loot] /= 2
	return ..()
