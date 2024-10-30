/datum/species/skeleton
	// 2spooky
	name = "Spooky Scary Skeleton"
	id = SPECIES_SKELETON
	sexes = FALSE
	meat = /obj/item/food/meat/slab/human/mutant/skeleton
	inherent_traits = list(
		TRAIT_EASYDISMEMBER,
		TRAIT_FAKEDEATH,
		TRAIT_GENELESS,
		TRAIT_LIMBATTACHMENT,
		TRAIT_NOBLOOD,
		TRAIT_NOBREATH,
		TRAIT_NO_DNA_COPY,
		TRAIT_NO_UNDERWEAR,
		TRAIT_PIERCEIMMUNE,
		TRAIT_RADIMMUNE,
		TRAIT_RESISTCOLD,
		TRAIT_RESISTHEAT,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_TOXIMMUNE,
		TRAIT_UNHUSKABLE,
		TRAIT_XENO_IMMUNE,
	)
	inherent_biotypes = MOB_UNDEAD|MOB_HUMANOID
	mutanttongue = /obj/item/organ/tongue/bone
	mutantstomach = /obj/item/organ/stomach/bone
	mutantappendix = null
	mutantheart = null
	mutantliver = /obj/item/organ/liver/bone
	mutantlungs = null
	//They can technically be in an ERT
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | ERT_SPAWN
	species_cookie = /obj/item/reagent_containers/condiment/milk
	species_language_holder = /datum/language_holder/skeleton

	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/skeleton,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/skeleton,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/skeleton,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/skeleton,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/skeleton,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/skeleton,
	)

/datum/species/skeleton/check_roundstart_eligible()
	if(check_holidays(HALLOWEEN))
		return TRUE
	return ..()

/datum/species/skeleton/get_physical_attributes()
	return "These humerus folk lack any fleshy biology, which allows them to resist pressure, temperature, radiation, asphyxiation and even toxins. \
		However, due to that same fact, it is quite hard to heal them as well. The calcium found in common space milk is highly effective at treating their wounds. \
		Their limbs are easy to pop off their joints, but they can somehow just slot them back in."

/datum/species/skeleton/get_species_description()
	return "A rattling skeleton! They descend upon Space Station 13 \
		Every year to spook the crew! \"I've got a BONE to pick with you!\""

/datum/species/skeleton/get_species_lore()
	return list(
		"Skeletons want to be feared again! Their presence in media has been destroyed, \
		or at least that's what they firmly believe. They're always the first thing fought in an RPG, \
		they're Flanderized into pun rolling JOKES, and it's really starting to get to them. \
		You could say they're deeply RATTLED. Hah."
	)
