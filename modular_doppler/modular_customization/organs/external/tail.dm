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
	bodypart_overlay = /datum/bodypart_overlay/mutant/tail/dog
	/// monitor used for the moodbuff
	var/datum/proximity_monitor/advanced/dog_wag/mood_buff

/datum/bodypart_overlay/mutant/tail/dog
	feature_key = "tail_other"

/datum/bodypart_overlay/mutant/tail/dog/get_global_feature_list()
	return SSaccessories.tails_list_dog

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

/// Fox tail
//
/obj/item/organ/external/tail/fox
	preference = "feature_fox_tail"
	dna_block = null
	wag_flags = WAG_ABLE
	bodypart_overlay = /datum/bodypart_overlay/mutant/tail/fox

/datum/bodypart_overlay/mutant/tail/fox
	feature_key = "tail_other"

/datum/bodypart_overlay/mutant/tail/fox/get_global_feature_list()
	return SSaccessories.tails_list_fox

/// Bunny tail
//
/obj/item/organ/external/tail/bunny
	preference = "feature_bunny_tail"
	dna_block = null
	wag_flags = WAG_ABLE
	bodypart_overlay = /datum/bodypart_overlay/mutant/tail/bunny

/datum/bodypart_overlay/mutant/tail/bunny
	feature_key = "tail_other"

/datum/bodypart_overlay/mutant/tail/bunny/get_global_feature_list()
	return SSaccessories.tails_list_bunny

/// Mouse tail
//
/obj/item/organ/external/tail/mouse
	preference = "feature_mouse_tail"
	dna_block = null
	wag_flags = WAG_ABLE
	bodypart_overlay = /datum/bodypart_overlay/mutant/tail/mouse

/datum/bodypart_overlay/mutant/tail/mouse
	feature_key = "tail_other"

/datum/bodypart_overlay/mutant/tail/mouse/get_global_feature_list()
	return SSaccessories.tails_list_mouse

/// Bird tail
//
/obj/item/organ/external/tail/bird
	preference = "feature_bird_tail"
	dna_block = null
	bodypart_overlay = /datum/bodypart_overlay/mutant/tail/bird

/datum/bodypart_overlay/mutant/tail/bird
	feature_key = "tail_other"

/datum/bodypart_overlay/mutant/tail/bird/get_global_feature_list()
	return SSaccessories.tails_list_bird

/// Bug tail
//
/obj/item/organ/external/tail/bug
	preference = "feature_bug_tail"
	dna_block = null
	bodypart_overlay = /datum/bodypart_overlay/mutant/tail/bug

/datum/bodypart_overlay/mutant/tail/bug
	feature_key = "tail_other"

/datum/bodypart_overlay/mutant/tail/bug/get_global_feature_list()
	return SSaccessories.tails_list_bug

/// Deer tail
//
/obj/item/organ/external/tail/deer
	preference = "feature_deer_tail"
	dna_block = null
	wag_flags = WAG_ABLE
	bodypart_overlay = /datum/bodypart_overlay/mutant/tail/deer

/datum/bodypart_overlay/mutant/tail/deer
	feature_key = "tail_other"

/datum/bodypart_overlay/mutant/tail/deer/get_global_feature_list()
	return SSaccessories.tails_list_deer

/// Fish tail
//
/obj/item/organ/external/tail/fish
	preference = "feature_fish_tail"
	dna_block = null
	wag_flags = WAG_ABLE
	bodypart_overlay = /datum/bodypart_overlay/mutant/tail/fish

/datum/bodypart_overlay/mutant/tail/fish
	feature_key = "tail_other"

/datum/bodypart_overlay/mutant/tail/fish/get_global_feature_list()
	return SSaccessories.tails_list_fish

/// Synth tail
//
/obj/item/organ/external/tail/synthetic
	preference = "feature_synth_tail"
	dna_block = null
	organ_flags = ORGAN_ROBOTIC
	bodypart_overlay = /datum/bodypart_overlay/mutant/tail/synthetic

/datum/bodypart_overlay/mutant/tail/synthetic
	feature_key = "tail_other"

/datum/bodypart_overlay/mutant/tail/synthetic/get_global_feature_list()
	return SSaccessories.tails_list_synth


/// Humanoid tail
//
/obj/item/organ/external/tail/humanoid
	preference = "feature_humanoid_tail"
	dna_block = null
	bodypart_overlay = /datum/bodypart_overlay/mutant/tail/humanoid

/datum/bodypart_overlay/mutant/tail/humanoid
	feature_key = "tail_other"

/datum/bodypart_overlay/mutant/tail/humanoid/get_global_feature_list()
	return SSaccessories.tails_list_humanoid
