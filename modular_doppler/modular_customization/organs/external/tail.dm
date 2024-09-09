/// Monkey tail
//	now waggable!
/obj/item/organ/external/tail/monkey
	wag_flags = WAG_ABLE

/// Dog tail
//	Buffs people if they're closeby while you're wagging it!
/obj/item/organ/external/tail/dog
	preference = "feature_dog_tail"
	dna_block = null
	wag_flags = WAG_ABLE
	bodypart_overlay = /datum/bodypart_overlay/mutant/tail/canine
	/// monitor used for the moodbuff
	var/datum/proximity_monitor/advanced/dog_wag/mood_buff

/datum/bodypart_overlay/mutant/tail/canine
	feature_key = "tail_other"

/datum/bodypart_overlay/mutant/tail/canine/get_global_feature_list()
	return SSaccessories.tails_list_canine

// Create the proximity monitor when we start wagging, thanks TG for this proc!
/obj/item/organ/external/tail/dog/start_wag(mob/living/carbon/organ_owner, stop_after = INFINITY)
	. = ..()
	if(!mood_buff)
		mood_buff = new(organ_owner, 3, TRUE)

/obj/item/organ/external/tail/dog/stop_wag(mob/living/carbon/organ_owner)
	. = ..()
	if(mood_buff)
		QDEL_NULL(mood_buff)

/obj/item/organ/external/tail/dog/on_mob_remove(mob/living/carbon/organ_owner, special = FALSE, movement_flags)
	. = ..()
	if(mood_buff)
		QDEL_NULL(mood_buff)

/datum/proximity_monitor/advanced/dog_wag/field_turf_crossed(atom/movable/entered, turf/old_location, turf/new_location)
	if(!ishuman(entered) || !can_see(entered, host, current_range))
		return
	if(entered == host)
		return
	var/mob/living/carbon/human/empath = entered
	empath.add_mood_event("dog_wag", /datum/mood_event/dog_wag)

// The mood buff itself
/datum/mood_event/dog_wag
	description = "That wagging tail's excitement is infectious!"
	mood_change = 1
	timeout = 30 SECONDS
