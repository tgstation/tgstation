/datum/species/moth/talonmoth
	// Slugcats from Rain World, revamped to fit into
	name = "\improper Talon IV Moth"
	plural_form = "\improper Tal4 Moths"
	id = SPECIES_TALONMOTH
	inherent_traits = list(
		TRAIT_MUTANT_COLORS,
		TRAIT_CAN_USE_FLIGHT_POTION,
		TRAIT_TACKLING_WINGED_ATTACKER,
		TRAIT_TACKLING_TAILED_DEFENDER,
		TRAIT_ANTENNAE,
		USE_TRICOLOR_ALPHA,
		USE_TRICOLOR_BETA,
	)
	inherent_biotypes = MOB_ORGANIC|MOB_HUMANOID
	species_language_holder = /datum/language_holder/moth

	mutant_bodyparts = list("bodymarks_talonmoth" = "None")
	external_organs = list(
		/obj/item/organ/external/wings/moth = "Jungle",
		/obj/item/organ/external/snout/talonmoth = "Full Snout",
		/obj/item/organ/external/horns/slugcat = "Standard",
	)

	//UGH WE NEED TO SUBTYPE THIS
	mutanttongue = /obj/item/organ/internal/tongue/moth
	mutanteyes = /obj/item/organ/internal/eyes/talonmoth
	wing_types = list(/obj/item/organ/external/wings/functional/moth/megamoth, /obj/item/organ/external/wings/functional/moth/mothra)

	payday_modifier = 1 //we're going to be doing a master_files override to universally set payday mod to 1 bcuz it's still some serious wtfery

	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT
	//liked_food = VEGETABLES | DAIRY | CLOTH | MEAT
	//disliked_food = GROSS | BUGS | GORE
	//toxic_food = FRUIT | RAW | SEAFOOD
	//scugs have forced digi thru custom legs, this is necessary until we rework the digi_customization setting to allow for other digileg types
	//digitigrade_customization = DIGITIGRADE_FORCED

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/talonmoth,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/talonmoth,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/talonmoth,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/talonmoth,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/digitigrade/talonmoth,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/digitigrade/talonmoth,
	)

/datum/species/talonmoth/random_name(gender,unique,lastname)
	if(unique)
		return random_unique_moth_name()

	var/randname = moth_name()

	if(lastname)
		randname += " [lastname]"

	return randname

/datum/species/talonmoth/randomize_features(mob/living/carbon/human/human_mob)
	human_mob.undershirt = random_undershirt(human_mob.gender)
	human_mob.underwear = random_underwear(human_mob.gender)
	human_mob.socks = random_socks(human_mob.gender)
	human_mob.hairstyle = random_hairstyle(human_mob.gender)
	randomize_external_organs(human_mob)

/datum/species/talonmoth/get_scream_sound(mob/living/carbon/human/lizard)
	return pick(
		'sound/voice/moth/scream_moth.ogg',
	)

/datum/species/talonmoth/on_species_gain(mob/living/carbon/carbon_being, datum/species/old_species, pref_load)
	// so far i don't think they need any special abilities here
	return ..()


/// Pretty UI stuff goes here.
/datum/species/talonmoth/prepare_human_for_preview(mob/living/carbon/human/human_for_preview)
	/*human_for_preview.hairstyle = "Messy"
	human_for_preview.hair_color = "#365904"
	human_for_preview.dna.features["mcolor"] = "#87a629"
	human_for_preview.eye_color_left = "#39c9e6"
	human_for_preview.eye_color_right = "#ffd659"*/
	var/obj/item/organ/external/snout_tmp = human_for_preview.get_organ_by_type(/obj/item/organ/external/snout/talonmoth)
	if(snout_tmp)
		snout_tmp.bodypart_overlay.set_appearance(/datum/sprite_accessory/snouts/talonmoth/long)
		snout_tmp.bodypart_overlay.sprite_datum = new /datum/sprite_accessory/snouts/talonmoth/long() //do NOT do this this is bad and ugly

/datum/species/talonmoth/get_species_description()
	return "Old explorers from a forgotten part of the Moffic Fleet, abandoned on Talon IV and left to evolve and mutate over generations, \
		the Tal4 Moths are sturdier and more beastlike in appearance than their ship-dwelling kin, while still retaining their vibrant wings and \
		all-enveloping fluffiness that standard moths have long been known for."

/datum/species/talonmoth/get_species_lore()
	return list(
		"Long ago, the Moffic Fleet passed through the Talon system, and set about exploring the jungle world of Talon IV, whilst choosing to keep a \
			safe distance from Talon III and its developing civilizations.  Talon IV is a varied world, with just about every kind of biome and lifeform \
			imaginable on its surface, and it was a boon to the early nomadic fleet for its rich resources and scientific wealth.",

		"However, this good fortune was not to last - extrasolar asteroids rich in an unknown radioactive material were soon detected on a collision course with the system.  \
			Most of the explorers were able to escape in time, but those lost deep within the volcanic caverns & icy peaks were inaccessible in time, oblivious to the danger \
			they would soon face as a consequence of their scientific explorations.  These same locales kept them safe from the brunt of the impact when the asteroids hit...\
			but it mattered little when they were now stranded on this alien world, their kin having fled to save what lives they could.",

		"Left to their own devices, these remaining scientists and explorers set to work trying to eke out a new life on the planet, but soon found new issues arising - \
			the asteroids carried with them an unknown material, both toxic and empowering to life at once, increasing its rate of mutation and NEED to survive.  \
			As the environment grew more hostile, more desparate to fend for itself, their once lush home became dangerous, and as generations passed, they too began \
			to change - even as unbeknownst to them, the same sickness had taken place on their sister world of Talon III.",

		"Space travel began to fall into distant memory, as every effort was being taken just to survive and to repair this once vibrant ecosystem.  It was only when the Iterators \
			of Talon III were able to recover the old infrastructure of the Ancients with the help of their Slugcat companions that these tired moths found hope once more - \
			others to talk to, to communicate with and work togther alongside to solve the problems both their worlds faced.  By the time the Solar Federation's explorers found the Talon system, \
			the moths of Talon IV and combined civilization of Talon III's Iterators and Slugcats had formed an alliance, sharing data from the different impacts & mutations as the best minds \
			of both worlds worked together to find a solution to the problems they faced.",
	)

/datum/species/talonmoth/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "feather-alt",
			SPECIES_PERK_NAME = "Precious Wings",
			SPECIES_PERK_DESC = "Moths can fly in pressurized, zero-g environments and safely land short falls using their wings.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "tshirt",
			SPECIES_PERK_NAME = "Meal Plan",
			SPECIES_PERK_DESC = "Moths can eat clothes for temporary nourishment.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "fire",
			SPECIES_PERK_NAME = "Ablazed Wings",
			SPECIES_PERK_DESC = "Moth wings are fragile, and can be easily burnt off.",
		),
	)

	return to_add
