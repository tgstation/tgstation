/datum/species/floran
	name = "\improper Floran"
	plural_form = "Florans"
	id = SPECIES_FLORAN
	sexes = TRUE
	species_traits = list(
		MUTCOLORS,
		MUTCOLORS_SECONDARY,
		NO_UNDERWEAR,
	)
	inherent_traits = list(
		TRAIT_PLANT_SAFE,
		TRAIT_NO_JUMPSUIT,
		TRAIT_LIMBATTACHMENT,
		TRAIT_EASYDISMEMBER
	)
	external_organs = list(
		/obj/item/organ/external/pod_hair = "None",
		/obj/item/organ/external/floran_leaves = "Furnivour",
	)
	inherent_biotypes = MOB_ORGANIC | MOB_HUMANOID | MOB_PLANT
	inherent_factions = list(FACTION_PLANTS, FACTION_VINES)
	burnmod = 1.8
	heatmod = 0.67 //Same as lizard people
	coldmod = 1.5 //Same as lizard people
	speedmod = -0.1 //Same as arachnids
	meat = /obj/item/food/meat/slab/human/mutant/plant
	exotic_blood = /datum/reagent/water
	// disliked_food = VEGETABLES | FRUIT | GRAIN
	liked_food = MEAT | BUGS | GORE
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	species_language_holder = /datum/language_holder/plant

	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/floran,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/floran,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/floran,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/floran,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/floran,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/floran,
	)
	mutanttongue = /obj/item/organ/internal/tongue/lizard
	mutanteyes = /obj/item/organ/internal/eyes/floran

	ass_image = 'icons/ass/asspodperson.png'

/datum/species/floran/spec_life(mob/living/carbon/human/H, seconds_per_tick, times_fired)
	if(H.stat == DEAD)
		return

	var/light_amount = 0
	if(isturf(H.loc))
		var/turf/T = H.loc
		light_amount = min(1, T.get_lumcount()) - 0.5
		if(light_amount > 0.3)
			H.heal_overall_damage(brute = 0.25 * seconds_per_tick, burn = 0.25 * seconds_per_tick, required_bodytype = BODYTYPE_ORGANIC) //Lowered to 0.25
			H.adjustToxLoss(-0.25 * seconds_per_tick)
			H.adjustOxyLoss(-0.25 * seconds_per_tick)

/datum/species/floran/on_species_gain(mob/living/carbon/new_floran, datum/species/old_species, pref_load)
	. = ..()
	if(ishuman(new_floran))
		update_mail_goodies(new_floran)

/datum/species/floran/update_quirk_mail_goodies(mob/living/carbon/human/recipient, datum/quirk/quirk, list/mail_goodies = list())
	if(istype(quirk, /datum/quirk/blooddeficiency))
		mail_goodies += list(
			/obj/item/reagent_containers/blood/podperson
		)
	return ..()

/datum/species/floran/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H, seconds_per_tick, times_fired)
	if(chem.type == /datum/reagent/toxin/plantbgone)
		H.adjustToxLoss(3 * REM * seconds_per_tick)
		H.reagents.remove_reagent(chem.type, REAGENTS_METABOLISM * seconds_per_tick)
		return TRUE
	if(chem.type == /datum/reagent/potassium) //Floran "blood" is water, water does not like potassium
		to_chat(H, span_danger("You feel your skin bubble and pop painfully!"))
		H.adjustBruteLoss(10*REM, FALSE)
		return TRUE
	return ..()

/datum/species/floran/randomize_features(mob/living/carbon/human_mob)
	randomize_external_organs(human_mob)

/datum/species/floran/get_scream_sound(mob/living/carbon/human/human)
	return pick(
		'sound/voice/lizard/lizard_scream_1.ogg',
		'sound/voice/lizard/lizard_scream_2.ogg',
		'sound/voice/lizard/lizard_scream_3.ogg',
		'monkestation/sound/voice/screams/lizard/lizard_scream_5.ogg',
	)

/datum/species/floran/get_laugh_sound(mob/living/carbon/human/human)
	return 'monkestation/sound/voice/laugh/lizard/lizard_laugh.ogg'

/datum/species/floran/get_species_description()
	return "Plant-based humanoids, they are extremely violent carnivores with no central government or power structure, \
	split into numerous tribes spread across the universe, each led by a Greenfinger. \
	Though they are biologically a single-sex race, they may adapt sexually dimorphic physical traits and male/female identities if they so choose. \
	Their speech is often simplistic, and they tend to hisss their sibilantsss. \
	Their primary drives are hunting, acquiring trophies, fighting, eating meat, and more hunting. \
	It is speculated that their general casual view towards killing and consuming other intelligent species stems from not viewing \"meat\" as \"alive\" in \
	the same sense they are. However, as the Floran spread throughout the galaxy, more and more individuals are recognizing a need to integrate, \
	make friends, and maybe not stab anyone that slightly inconveniences them. (E.I. THIS IS NOT AN EXCUSE TO RDM)"

/datum/species/floran/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "fist-raised",
			SPECIES_PERK_NAME = "Carnivore",
			SPECIES_PERK_DESC = "As a vicious carnivore, your claws do more damage to your prey.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "sun",
			SPECIES_PERK_NAME = "Photosynthesis",
			SPECIES_PERK_DESC = "Your green skin slowly heals itself while it is illuminated.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "bolt",
			SPECIES_PERK_NAME = "Agile",
			SPECIES_PERK_DESC = "Florans run slightly faster than other species, but are still outpaced by Goblins.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "fire",
			SPECIES_PERK_NAME = "Flammable Skin",
			SPECIES_PERK_DESC = "Your flammable skin is highly susceptible to burn damage.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "skull",
			SPECIES_PERK_NAME = "Plant Biology",
			SPECIES_PERK_DESC = "PlantbGone and potassium will do large amounts of damage to a Floran."
		),
		)

	return to_add


/obj/item/organ/external/floran_leaves
	name = "floran leaves"
	desc = "you shouldn't see this"
	organ_flags = ORGAN_UNREMOVABLE | ORGAN_HIDDEN
	icon_state = "floran_leaves"
	icon = 'monkestation/icons/obj/medical/organs/organs.dmi'

	preference = "feature_floran_leaves"
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_EXTERNAL_FLORAN_LEAVES

	use_mob_sprite_as_obj_sprite = TRUE
	bodypart_overlay = /datum/bodypart_overlay/mutant/floran_leaves

/datum/bodypart_overlay/mutant/floran_leaves
	layers = EXTERNAL_ADJACENT
	feature_key = "floran_leaves"
