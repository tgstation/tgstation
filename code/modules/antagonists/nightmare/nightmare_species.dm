/**
 * A highly aggressive subset of shadowlings
 */
/datum/species/shadow/nightmare
	name = "Nightmare"
	id = SPECIES_NIGHTMARE
	examine_limb_id = SPECIES_SHADOW
	burnmod = 1.5
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE
	no_equip_flags = ITEM_SLOT_MASK | ITEM_SLOT_OCLOTHING | ITEM_SLOT_GLOVES | ITEM_SLOT_FEET | ITEM_SLOT_ICLOTHING | ITEM_SLOT_SUITSTORE
	species_traits = list(NO_UNDERWEAR,NO_DNA_COPY,NOTRANSSTING,NOEYESPRITES)
	inherent_traits = list(
		TRAIT_ADVANCEDTOOLUSER,
		TRAIT_CAN_STRIP,
		TRAIT_RESISTCOLD,
		TRAIT_NOBREATH,
		TRAIT_RESISTHIGHPRESSURE,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_RADIMMUNE,
		TRAIT_VIRUSIMMUNE,
		TRAIT_PIERCEIMMUNE,
		TRAIT_NODISMEMBER,
		TRAIT_NOHUNGER,
		TRAIT_NOBLOOD,
	)
	internal_organs = list(
		ORGAN_SLOT_BRAIN = /obj/item/organ/internal/brain/shadow/nightmare,
		ORGAN_SLOT_EARS = /obj/item/organ/internal/ears,
		ORGAN_SLOT_EYES = /obj/item/organ/internal/eyes/night_vision/shadow,
		ORGAN_SLOT_TONGUE = /obj/item/organ/internal/tongue,
		ORGAN_SLOT_HEART = /obj/item/organ/internal/heart/nightmare,
		ORGAN_SLOT_LUNGS = NO_ORGAN,
		ORGAN_SLOT_STOMACH = /obj/item/organ/internal/stomach,
		ORGAN_SLOT_LIVER = /obj/item/organ/internal/liver,
		ORGAN_SLOT_APPENDIX = NO_ORGAN,

		ORGAN_SLOT_BRAIN_ANTIDROP = NO_ORGAN,
		ORGAN_SLOT_BRAIN_ANTISTUN = NO_ORGAN,
		ORGAN_SLOT_HUD = NO_ORGAN,
		ORGAN_SLOT_BREATHING_TUBE = NO_ORGAN,
		ORGAN_SLOT_HEART_AID = NO_ORGAN,
		ORGAN_SLOT_STOMACH_AID = NO_ORGAN,
		ORGAN_SLOT_THRUSTERS = NO_ORGAN,
		ORGAN_SLOT_RIGHT_ARM_AUG = NO_ORGAN,
		ORGAN_SLOT_LEFT_ARM_AUG = NO_ORGAN,

		ORGAN_SLOT_ADAMANTINE_RESONATOR = NO_ORGAN,
		ORGAN_SLOT_VOICE = NO_ORGAN,
		ORGAN_SLOT_MONSTER_CORE = NO_ORGAN,
		ORGAN_SLOT_CHEST_BONUS = NO_ORGAN,
		ORGAN_SLOT_GROIN_BONUS = NO_ORGAN,

		ORGAN_SLOT_ZOMBIE = NO_ORGAN,
		ORGAN_SLOT_PARASITE_EGG = NO_ORGAN,

		ORGAN_SLOT_XENO_HIVENODE = NO_ORGAN,
		ORGAN_SLOT_XENO_ACIDGLAND = NO_ORGAN,
		ORGAN_SLOT_XENO_NEUROTOXINGLAND = NO_ORGAN,
		ORGAN_SLOT_XENO_RESINSPINNER = NO_ORGAN,
		ORGAN_SLOT_XENO_PLASMAVESSEL = NO_ORGAN,
		ORGAN_SLOT_XENO_EGGSAC = NO_ORGAN,
	)
	bodypart_overrides = list(
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/shadow/nightmare,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/shadow/nightmare,
		BODY_ZONE_HEAD = /obj/item/bodypart/head/shadow,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/shadow,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/shadow,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/shadow,
	)

/datum/species/shadow/nightmare/on_species_gain(mob/living/carbon/C, datum/species/old_species)
	. = ..()

	C.fully_replace_character_name(null, pick(GLOB.nightmare_names))
	C.set_safe_hunger_level()

/datum/species/shadow/nightmare/bullet_act(obj/projectile/P, mob/living/carbon/human/H)
	var/turf/T = H.loc
	if(istype(T))
		var/light_amount = T.get_lumcount()
		if(light_amount < SHADOW_SPECIES_LIGHT_THRESHOLD)
			H.visible_message(span_danger("[H] dances in the shadows, evading [P]!"))
			playsound(T, SFX_BULLET_MISS, 75, TRUE)
			return BULLET_ACT_FORCE_PIERCE
	return ..()

/datum/species/shadow/nightmare/check_roundstart_eligible()
	return FALSE
