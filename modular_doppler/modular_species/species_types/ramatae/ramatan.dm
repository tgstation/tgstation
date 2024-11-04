/// Ramatan language holder - they are adept in understanding machines, though unable to speak the tongue themselves.
/datum/language_holder/ramatan
	understood_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/movespeak = list(LANGUAGE_ATOM),
		/datum/language/machine = list(LANGUAGE_ATOM),
		/datum/language/drone = list(LANGUAGE_ATOM),
	)
	spoken_languages = list(
		/datum/language/common = list(LANGUAGE_ATOM),
		/datum/language/movespeak = list(LANGUAGE_ATOM),
	)

/mob/living/carbon/human/species/ramatan
	race = /datum/species/ramatan

/datum/species/ramatan
	// The Ramatae of Aadia III - The Origin
	name = "\improper Ramatan"
	plural_form = "Ramatae"
	id = SPECIES_RAMATAN
	preview_outfit = /datum/outfit/ramatan_preview
	inherent_traits = list(
		TRAIT_MUTANT_COLORS,
		TRAIT_EXPERT_FISHER,
		TRAIT_BEAST_EMPATHY,
	)
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID
	body_markings = list(/datum/bodypart_overlay/simple/body_marking/lizard = "None")
	mutant_organs = list(
		/obj/item/organ/ears = "Ramatan",
		/obj/item/organ/frills = "None",
		/obj/item/organ/snout = "Ramatan",
		/obj/item/organ/tail/alien = "Ramatan",
	)
	payday_modifier = 1.0
	mutanttongue = /obj/item/organ/tongue/ramatan
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	death_sound = 'modular_doppler/modular_species/species_types/ramatae/sounds/scugdeath.ogg'
	species_language_holder = /datum/language_holder/ramatan
	digitigrade_customization = DIGITIGRADE_OPTIONAL

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/ramatan,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/ramatan,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/lizard/ramatan,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/lizard/ramatan,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/lizard/ramatan,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/lizard/ramatan,
	)
	digi_leg_overrides = list(
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/digitigrade/ramatan,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/digitigrade/ramatan,
	)

/datum/species/ramatan/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "bone",
			SPECIES_PERK_NAME = "50% Boneless",
			SPECIES_PERK_DESC = "Ramatae have cartilage skeletons, making bone wounds barely a concern.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "fa-volume-xmark",
			SPECIES_PERK_NAME = "Keep Quiet",
			SPECIES_PERK_DESC = "Ramatae, while adept at sign language and making /noises,/ have underdeveloped larynxes incapable of verbal speech.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "fa-fish",
			SPECIES_PERK_NAME = "Survivalist",
			SPECIES_PERK_DESC = "Ramatae are naturally adept at living off the land; catching fish and taming beasts better than others."
		),
	)

	return to_add

/datum/outfit/ramatan_preview
	name = "Ramatan (Species Preview)"
	head = /obj/item/clothing/head/beret/doppler_command/science
	neck = /obj/item/clothing/neck/doppler_mantle/science

/datum/species/ramatan/on_species_gain(mob/living/carbon/human/new_ramatan, datum/species/old_species, pref_load)
	. = ..()
	new_ramatan.AddComponent(/datum/component/sign_language)

/datum/species/ramatan/prepare_human_for_preview(mob/living/carbon/human/ramatan_for_preview)
	ramatan_for_preview.dna.features["lizard_markings"] = "Ramatan Underbelly"
	ramatan_for_preview.dna.features["body_markings_color_1"] = "#ccecff"
	ramatan_for_preview.dna.features["mcolor"] = "#FFFFFF"
	ramatan_for_preview.dna.ear_type = ALIEN
	ramatan_for_preview.dna.features["ears"] = "Ramatan"
	ramatan_for_preview.dna.features["ears_color_1"] = "#ffffff"
	ramatan_for_preview.dna.features["ears_color_2"] = "#dddddd"
	ramatan_for_preview.dna.features["frills"] = "Ramatan"
	ramatan_for_preview.dna.features["frills_color_1"] = "#ccecff"
	ramatan_for_preview.dna.features["snout"] = "Ramatan"
	ramatan_for_preview.dna.features["snout_color_1"] = "#ffffff"
	ramatan_for_preview.dna.features["snout_color_2"] = "#dddddd"
	ramatan_for_preview.dna.features["snout_color_3"] = "#9a9b9e"
	ramatan_for_preview.eye_color_left = "#CCECFF"
	ramatan_for_preview.eye_color_right = "#CCECFF"
	regenerate_organs(ramatan_for_preview)
	ramatan_for_preview.update_body(is_creating = TRUE)

/// SOUNDS BREAKER
/datum/species/ramatan/get_scream_sound(mob/living/carbon/human/ramatan)
	return pick(
		'modular_doppler/modular_species/species_types/ramatae/sounds/scugscream_1.ogg',
	)

/datum/species/ramatan/get_cough_sound(mob/living/carbon/human/ramatan)
	if(ramatan.physique == FEMALE)
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

/datum/species/ramatan/get_cry_sound(mob/living/carbon/human/ramatan)
	if(ramatan.physique == FEMALE)
		return pick(
			'sound/mobs/humanoids/human/cry/female_cry1.ogg',
			'sound/mobs/humanoids/human/cry/female_cry2.ogg',
		)
	return pick(
		'sound/mobs/humanoids/human/cry/male_cry1.ogg',
		'sound/mobs/humanoids/human/cry/male_cry2.ogg',
		'sound/mobs/humanoids/human/cry/male_cry3.ogg',
	)

/datum/species/ramatan/get_sneeze_sound(mob/living/carbon/human/ramatan)
	if(ramatan.physique == FEMALE)
		return 'sound/mobs/humanoids/human/sneeze/female_sneeze1.ogg'
	return 'sound/mobs/humanoids/human/sneeze/male_sneeze1.ogg'

/datum/species/ramatan/get_laugh_sound(mob/living/carbon/human/ramatan)
	return 'modular_doppler/modular_species/species_types/ramatae/sounds/scuglaugh_1.ogg'

/datum/species/ramatan/get_sigh_sound(mob/living/carbon/human/ramatan)
	if(ramatan.physique == FEMALE)
		return SFX_FEMALE_SIGH
	return SFX_MALE_SIGH

/datum/species/ramatan/get_sniff_sound(mob/living/carbon/human/ramatan)
	if(ramatan.physique == FEMALE)
		return 'sound/mobs/humanoids/human/sniff/female_sniff.ogg'
	return 'sound/mobs/humanoids/human/sniff/male_sniff.ogg'
/// SOUNDS BREAKER END

/datum/species/ramatan/get_species_description()
	return "Nimble, silent, omnivores with a natural aptitude for talking to machines, the Ramatae and their many tribes are a rare sight in systems far from their homeworld of Aadia III.  \
		Ramatae are known for being crafty and intelligent, but equally deeply spiritual, firmly believing in their roles as reincarnated embodiments of their own, distant soul. \
		They have been in friendly contact with a machine intelligence of a long-gone culture, VISHVA, for twenty thousand years, owing their capacity for spaceflight to their symbiosis with it."

/datum/species/ramatan/get_species_lore()
	return list(
		"Ramatae, individually Ramatan, are a species of opportunistic humanoid omnivores, native to Aadia III. A species of simultaneous hermaphrodites, Ramatae stand at around four to five feet tall, known for their strange morphology.  \
			Their skeletons are made of cartilage, able to flex and bend in almost any way they need. Their bodies are highly adapted for 'arboreal' three-dimensional movement-- three long and flexible digits paired with semi-retractile claws on both hand and foot, mostly good for climbing.  \
			However, while Ramatae have been shown to be in every way as cognitively capable as other races of the Orion Spur, their larynxes are heavily underdeveloped, only good for a few cries or trilling sounds; leaving them incapable of verbal communication.",

		"They're typically rather slender, with the exception of their tails; fat and heavy, nearly as long as they are tall, and where the vast majority of their fat is stored. \
			Ramataen bodies constantly produce a slick mucus, predominantly serving to prevent them from being snatched by predators. \
			Some develop an extra fine coat of fur similar to a viverrid, others a double layer giving them a very oily and fluffed-up appearance.",

		"Ramatae are a heavily spiritual people, having a belief system focused around the concept of reincarnation. Tying in with their natural nomadic instincts, their culture holds that their bodies are a vessel for their soul to wander; \
			their soul remembering what their bodies do not. They believe themselves to be sent to the material world to gain particular experiences, to gain particular viewpoints, and to live particular lives-- \
			all in the service of their eventual 'ascension' as they become 'complete people.' Plural Ramatae are particularly revered, thought of as multiple sharing one experience together.",

		"While they hold traditional names amongst their tribes, a Ramatan is particularly known by their self-sought epithet; examples such as The Sage, The Archivist, The Justice, The Kind, The Magician, The Digger, The Reclaimer, The Vessel... \
			These epithets are typically carried throughout a Ramatan's life, the personal meaning of these titles shifting over time, and it being their job to find out what their name and role means to them. \
			They embody what an individual Ramatan aspires to be and do in the world, and only in response to major life events will they ever change.",
	)
