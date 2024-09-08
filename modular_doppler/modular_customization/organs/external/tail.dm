/// Monkey tail
//	now waggable!
/obj/item/organ/external/tail/monkey
	wag_flags = WAG_ABLE

#define DOG_WAG_MOOD "dog_wag"

/// Dog tail
//	Buffs people if they're closeby while you're wagging it!
/obj/item/organ/external/tail/dog
	preference = "feature_dog_tail"
	dna_block = null
	wag_flags = WAG_ABLE
	bodypart_overlay = /datum/bodypart_overlay/mutant/tail/canine
	// monitor used for the moodbuff
	var/datum/proximity_monitor/advanced/dog_wag/mood_buff
	// cooldown timer for the moodbuff
	var/timer

/datum/bodypart_overlay/mutant/tail/canine
	feature_key = "tail_other"

/datum/bodypart_overlay/mutant/tail/canine/get_global_feature_list()
	return SSaccessories.tails_list_canine

// Create the proximity monitor when we start wagging, thanks TG for this proc!
/obj/item/organ/external/tail/dog/start_wag(mob/living/carbon/organ_owner, stop_after = INFINITY)
	. = ..()
	if(!timer)
		mood_buff = new(_host = src, range = 4)
		timer = addtimer(CALLBACK(src, PROC_REF(reset_timer), organ_owner), 1 MINUTES, TIMER_UNIQUE|TIMER_DELETE_ME)

// Timer ran out, that means the buff is off cooldown and can be created!
/obj/item/organ/external/tail/dog/proc/reset_timer()
	deltimer(timer)

// No buff if not wagging!
/obj/item/organ/external/tail/dog/stop_wag(mob/living/carbon/organ_owner)
	. = ..()
	if(mood_buff)
		QDEL_NULL(mood_buff)

// Nor if you lose the tail...
/obj/item/organ/external/tail/dog/on_mob_remove(mob/living/carbon/organ_owner, special = FALSE, movement_flags)
	. = ..()
	if(mood_buff)
		QDEL_NULL(mood_buff)

// Proximity monitor stuff
/datum/proximity_monitor/advanced/dog_wag/field_turf_crossed(atom/movable/crossed, turf/old_location, turf/new_location)
	if (!isliving(crossed) || !can_see(crossed, host, current_range))
		return
	on_enter(crossed)

/datum/proximity_monitor/advanced/dog_wag/field_turf_uncrossed(atom/movable/crossed, turf/old_location, turf/new_location)
	if (!isliving(crossed) || !can_see(crossed, host, current_range))
		return
	on_exit(crossed)

/datum/proximity_monitor/advanced/dog_wag/proc/on_enter(mob/living/viewer)
	if (!viewer.mind || !viewer.mob_mood || (viewer.stat != CONSCIOUS) || viewer.is_blind())
		return
	viewer.add_mood_event(DOG_WAG_MOOD, /datum/mood_event/dog_wag)

/datum/proximity_monitor/advanced/dog_wag/proc/on_exit(mob/living/viewer)
	if (!viewer.mind || !viewer.mob_mood || (viewer.stat != CONSCIOUS) || viewer.is_blind())
		return
	viewer.clear_mood_event(DOG_WAG_MOOD)

// The mood buff itself
/datum/mood_event/dog_wag
	description = "The excitement is infectious!"
	mood_change = 0.5
	category = DOG_WAG_MOOD

#undef DOG_WAG_MOOD
