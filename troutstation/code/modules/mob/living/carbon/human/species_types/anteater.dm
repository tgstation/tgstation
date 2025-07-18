/datum/species/anteater
	name = "\improper Anteater"
	plural_form = "Anteaters"
	id = SPECIES_ANTEATER
	inherent_traits = list(
		TRAIT_MUTANT_COLORS,
	)
	inherent_biotypes = MOB_ORGANIC | MOB_HUMANOID
	body_markings = list(
		/datum/bodypart_overlay/simple/body_marking/anteater = SPRITE_ACCESSORY_NONE,
	)
	mutant_organs = list(
		/obj/item/organ/anteater_snout = "Big",
		/obj/item/organ/tail/anteater = "Giant"
	)
	mutanttongue = /obj/item/organ/tongue/anteater
	mutantstomach = /obj/item/organ/stomach/anteater
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	species_language_holder = /datum/language_holder/anteater
	payday_modifier = 1.0

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/anteater,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/anteater,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/anteater,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/anteater,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/anteater,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/anteater,
	)

	var/base_speed = 2.25
	var/speed_multiplier_multiplier = 0.5 // i am good at names

/datum/species/anteater/on_species_gain(mob/living/carbon/human/human, datum/species/old_species, pref_load, regenerate_icons)
	. = ..()
	RegisterSignal(human, COMSIG_MOB_MOVESPEED_UPDATED, PROC_REF(update_movespeed))
	human.cached_multiplicative_slowdown = base_speed

/datum/species/anteater/on_species_loss(mob/living/carbon/human/human, datum/species/new_species, pref_load)
	. = ..()
	UnregisterSignal(human, COMSIG_MOB_MOVESPEED_UPDATED)

/datum/species/anteater/proc/update_movespeed(mob/living/target)
	SIGNAL_HANDLER
	target.cached_multiplicative_slowdown = base_speed + (target.cached_multiplicative_slowdown * speed_multiplier_multiplier)

/datum/species/anteater/prepare_human_for_preview(mob/living/carbon/human/human)
	human.dna.features[FEATURE_MUTANT_COLOR] = COLOR_BROWNER_BROWN
	human.dna.features[FEATURE_ANTEATER_SNOUT] = "Big"
	human.dna.features[FEATURE_ANTEATER_TAIL] = "Giant"
	human.dna.features[FEATURE_ANTEATER_MARKINGS] = "Giant"
	human.update_body(is_creating = TRUE)

/datum/species/anteater/randomize_features()
	var/list/features = ..()
	features[FEATURE_ANTEATER_SNOUT] = pick(SSaccessories.anteater_snouts_list)
	features[FEATURE_ANTEATER_TAIL] = pick(SSaccessories.tails_list_anteater)
	features[FEATURE_ANTEATER_MARKINGS] = pick(SSaccessories.anteater_markings_list)
	return features

// sounds

/datum/species/anteater/get_scream_sound(mob/living/carbon/human/anteater)
	if(anteater.physique == MALE)
		if(prob(1))
			return 'sound/mobs/humanoids/human/scream/wilhelm_scream.ogg'
		return pick(
			'sound/mobs/humanoids/human/scream/malescream_1.ogg',
			'sound/mobs/humanoids/human/scream/malescream_2.ogg',
			'sound/mobs/humanoids/human/scream/malescream_3.ogg',
			'sound/mobs/humanoids/human/scream/malescream_4.ogg',
			'sound/mobs/humanoids/human/scream/malescream_5.ogg',
			'sound/mobs/humanoids/human/scream/malescream_6.ogg',
		)

	return pick(
		'sound/mobs/humanoids/human/scream/femalescream_1.ogg',
		'sound/mobs/humanoids/human/scream/femalescream_2.ogg',
		'sound/mobs/humanoids/human/scream/femalescream_3.ogg',
		'sound/mobs/humanoids/human/scream/femalescream_4.ogg',
		'sound/mobs/humanoids/human/scream/femalescream_5.ogg',
	)

/datum/species/anteater/get_cough_sound(mob/living/carbon/human/anteater)
	if(anteater.physique == FEMALE)
		return pick(
			'sound/mobs/humanoids/human/cough/female_cough1.ogg',
			'sound/mobs/humanoids/human/cough/female_cough2.ogg',
			'sound/mobs/humanoids/human/cough/female_cough3.ogg',
			'sound/mobs/humanoids/human/cough/female_cough4.ogg',
			'sound/mobs/humanoids/human/cough/female_cough5.ogg',
			'sound/mobs/humanoids/human/cough/female_cough6.ogg',
		)
	return pick(
		'sound/mobs/humanoids/human/cough/male_cough1.ogg',
		'sound/mobs/humanoids/human/cough/male_cough2.ogg',
		'sound/mobs/humanoids/human/cough/male_cough3.ogg',
		'sound/mobs/humanoids/human/cough/male_cough4.ogg',
		'sound/mobs/humanoids/human/cough/male_cough5.ogg',
		'sound/mobs/humanoids/human/cough/male_cough6.ogg',
	)

/datum/species/anteater/get_cry_sound(mob/living/carbon/human/anteater)
	if(anteater.physique == FEMALE)
		return pick(
			'sound/mobs/humanoids/human/cry/female_cry1.ogg',
			'sound/mobs/humanoids/human/cry/female_cry2.ogg',
		)
	return pick(
		'sound/mobs/humanoids/human/cry/male_cry1.ogg',
		'sound/mobs/humanoids/human/cry/male_cry2.ogg',
		'sound/mobs/humanoids/human/cry/male_cry3.ogg',
	)


/datum/species/anteater/get_sneeze_sound(mob/living/carbon/human/anteater)
	if(anteater.physique == FEMALE)
		return 'sound/mobs/humanoids/human/sneeze/female_sneeze1.ogg'
	return 'sound/mobs/humanoids/human/sneeze/male_sneeze1.ogg'

/datum/species/anteater/get_laugh_sound(mob/living/carbon/human/anteater)
	if(anteater.physique == FEMALE)
		return 'sound/mobs/humanoids/human/laugh/womanlaugh.ogg'
	return pick(
		'sound/mobs/humanoids/human/laugh/manlaugh1.ogg',
		'sound/mobs/humanoids/human/laugh/manlaugh2.ogg',
	)

/datum/species/anteater/get_sigh_sound(mob/living/carbon/human/anteater)
	if(anteater.physique == FEMALE)
		return SFX_FEMALE_SIGH
	return SFX_MALE_SIGH

/datum/species/anteater/get_sniff_sound(mob/living/carbon/human/anteater)
	if(anteater.physique == FEMALE)
		return 'sound/mobs/humanoids/human/sniff/female_sniff.ogg'
	return 'sound/mobs/humanoids/human/sniff/male_sniff.ogg'

/datum/species/anteater/get_snore_sound(mob/living/carbon/human/anteater)
	if(anteater.physique == FEMALE)
		return SFX_SNORE_FEMALE
	return SFX_SNORE_MALE

/datum/species/anteater/get_hiss_sound(mob/living/carbon/human/anteater)
	return 'sound/mobs/humanoids/human/hiss/human_hiss.ogg'

// descriptions

/datum/species/anteater/get_physical_attributes()
	return "Anteaters are a slow but resilient species resembling the Earth animal of the same name. \
		They have a long snout and a large tail, and are known for their ability to eat space ants."

/datum/species/anteater/get_species_description()
	return "(EARLY ACCESS PREVIEW) \n\
		Local to this sector of space, the anteaters helped with the financing of the \
		construction of the station in exchange for a presence in NT operations here."

/datum/species/anteater/get_species_lore()
	return list(
		"(no lore here yet :C)",

		"Allen please add details."
	)

/datum/species/anteater/create_pref_unique_perks()
	var/list/to_add = list()
	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = FA_ICON_BUG,
			SPECIES_PERK_NAME = "Ant Eater",
			SPECIES_PERK_DESC = "You can eat space ants with no ill effect. Using an empty hand on space ants will let you eat them.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
			SPECIES_PERK_ICON = FA_ICON_SCALE_BALANCED,
			SPECIES_PERK_NAME = "Stoic Speed",
			SPECIES_PERK_DESC = "Your speed is less affected by speed buffs or debuffs. You're slower than others, but you'll lose less speed overall.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = FA_ICON_FACE_TIRED,
			SPECIES_PERK_NAME = "Tiny Mouth",
			SPECIES_PERK_DESC = "If you can't squeeze it into your snout, you aren't eating it.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = FA_ICON_HOURGLASS_HALF,
			SPECIES_PERK_NAME = "Slow Metabolism",
			SPECIES_PERK_DESC = "You don't process reagents quite as fast as other species.",
		)
	)
	return to_add
