#define CLONER_FAILURE_COMMON 3
#define CLONER_FAILURE_RARE 1

/// Things we can do to mess up the clones
/datum/experimental_cloner_fuckup
	/// How likely is it?
	var/weight

/// Can we actually mutate this thing?
/datum/experimental_cloner_fuckup/proc/is_valid(species_type)
	return TRUE

/// What do we do to it
/datum/experimental_cloner_fuckup/proc/apply_to_mob(mob/living/carbon/human/victim)
	return

/// What do we do after someone has taken over the mob
/datum/experimental_cloner_fuckup/proc/post_emerged(mob/living/victim)
	return

/// Become cat
/datum/experimental_cloner_fuckup/felinise
	weight = CLONER_FAILURE_COMMON

/datum/experimental_cloner_fuckup/felinise/is_valid(species_type)
	return !ispath(species_type, /datum/species/human/felinid)

/datum/experimental_cloner_fuckup/felinise/apply_to_mob(mob/living/carbon/human/victim)
	if (is_species(victim, /datum/species/human))
		victim.set_species(/datum/species/human/felinid)
	else // I think this is funnier
		var/obj/item/organ/tail/cat/new_tail = new(victim)
		var/obj/item/organ/ears/cat/new_ears = new(victim)
		var/obj/item/organ/tongue/cat/new_tongue = new(victim)

		new_tail.replace_into(victim)
		new_ears.replace_into(victim)
		new_tongue.replace_into(victim)

/// Bald
/datum/experimental_cloner_fuckup/bald
	weight = CLONER_FAILURE_COMMON

/datum/experimental_cloner_fuckup/bald/apply_to_mob(mob/living/carbon/human/victim)
	victim.set_facial_hairstyle("Shaved", update = FALSE)
	victim.set_hairstyle("Bald", update = TRUE)

/datum/experimental_cloner_fuckup/bald/is_valid(species_type)
	return !is_path_in_list(/datum/species/human, /datum/species/ethereal)

/// Give a brain trauma or two
/datum/experimental_cloner_fuckup/brain_trauma
	weight = CLONER_FAILURE_COMMON

/datum/experimental_cloner_fuckup/brain_trauma/apply_to_mob(mob/living/carbon/human/victim)
	victim.gain_trauma_type()
	if (prob(50))
		return
	victim.gain_trauma_type()

/// Roll the limb and organ dice a couple times
/datum/experimental_cloner_fuckup/scramble
	weight = CLONER_FAILURE_COMMON

/datum/experimental_cloner_fuckup/scramble/apply_to_mob(mob/living/carbon/human/victim)
	victim.bioscramble("your fucked up genes")
	if (prob(50))
		return
	victim.bioscramble("your fucked up genes")
	if (prob(75))
		return
	victim.bioscramble("your fucked up genes")

/// Mess with the genes
/datum/experimental_cloner_fuckup/mutate
	weight = CLONER_FAILURE_COMMON

/datum/experimental_cloner_fuckup/mutate/apply_to_mob(mob/living/carbon/human/victim)
	victim.easy_random_mutate(NEGATIVE + MINOR_NEGATIVE)
	if (prob(50))
		return
	victim.easy_random_mutate(NEGATIVE + MINOR_NEGATIVE)
	if (prob(75))
		return
	victim.easy_random_mutate(NEGATIVE + MINOR_NEGATIVE)

/// Makes your limbs mad at you
/datum/experimental_cloner_fuckup/lively_flesh
	weight = CLONER_FAILURE_COMMON

/datum/experimental_cloner_fuckup/lively_flesh/apply_to_mob(mob/living/carbon/human/victim)
	var/list/valid_zones = GLOB.limb_zones.Copy()
	for (var/i in 1 to (rand(1, 3)))
		var/target_zone = pick_n_take(valid_zones)

		var/part_type
		switch(target_zone)
			if(BODY_ZONE_L_ARM)
				part_type = /obj/item/bodypart/arm/left/flesh
			if(BODY_ZONE_R_ARM)
				part_type = /obj/item/bodypart/arm/right/flesh
			if(BODY_ZONE_L_LEG)
				part_type = /obj/item/bodypart/leg/left/flesh
			if(BODY_ZONE_R_LEG)
				part_type = /obj/item/bodypart/leg/right/flesh

		var/obj/item/bodypart/old_bodypart = victim.get_bodypart(target_zone)
		var/obj/item/bodypart/new_bodypart = new part_type()
		new_bodypart.replace_limb(victim, TRUE)
		qdel(old_bodypart)

/// Contaminated sample
/datum/experimental_cloner_fuckup/fly_mishap
	weight = CLONER_FAILURE_COMMON

/datum/experimental_cloner_fuckup/fly_mishap/apply_to_mob(mob/living/carbon/human/victim)
	victim.set_species(/datum/species/fly)

/// Return to monkey
/datum/experimental_cloner_fuckup/monkey
	weight = CLONER_FAILURE_RARE

/datum/experimental_cloner_fuckup/monkey/post_emerged(mob/living/carbon/victim)
	victim.visible_message(\
		span_boldwarning("[victim]'s hair begins to grow rapidly!"),\
		span_boldwarning("As you emerge from the pod, all the hair on your body starts to grow!"))
	victim.monkeyize()

/// No skin
/datum/experimental_cloner_fuckup/skeletised
	weight = CLONER_FAILURE_RARE

/datum/experimental_cloner_fuckup/skeletised/post_emerged(mob/living/victim)
	victim.emote("scream")
	victim.visible_message(\
		span_boldwarning("[victim]'s flesh slithers off in a disgusting heap!"),\
		span_boldwarning("As you emerge from the pod, your skin slithers off onto the ground!"))
	victim.set_species(/datum/species/skeleton)
	new /obj/effect/gibspawner/human/bodypartless(victim.drop_location(), victim)

/// Become a psyker, possibly the worst fate on this list
/datum/experimental_cloner_fuckup/psykerize
	weight = CLONER_FAILURE_RARE

/datum/experimental_cloner_fuckup/total_failure/post_emerged(mob/living/carbon/human/victim)
	victim.slow_psykerize(blind_them = TRUE)

/// Just fuck me up
/datum/experimental_cloner_fuckup/total_failure
	weight = CLONER_FAILURE_RARE

/datum/experimental_cloner_fuckup/total_failure/post_emerged(mob/living/victim)
	victim.emote("scream")
	victim.visible_message(\
		span_boldwarning("[victim] collapses bonelessly into a writhing heap of flesh!"),\
		span_boldwarning("As you emerge from the pod, your boneless flesh collapses into a writhing heap!"))
	var/mob/living/basic/fleshblob/blob = new(victim.drop_location())
	blob.name = victim.real_name
	blob.real_name = victim.real_name
	victim.mind?.transfer_to(blob, TRUE)
	victim.gib()

#undef CLONER_FAILURE_COMMON
#undef CLONER_FAILURE_RARE
