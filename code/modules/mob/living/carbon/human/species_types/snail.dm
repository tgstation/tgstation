/datum/species/snail
	name = "Snailperson"
	id = SPECIES_SNAIL
	species_traits = list(
		MUTCOLORS,
		NO_UNDERWEAR,
	)
	inherent_traits = list(
		TRAIT_NOSLIPALL,
	)

	coldmod = 0.5 //snails only come out when its cold and wet
	burnmod = 2
	speedmod = 6
	siemens_coeff = 2 //snails are mostly water
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | RACE_SWAP
	sexes = FALSE //snails are hermaphrodites

	exotic_blood = /datum/reagent/lube
	internal_organs = list(
		ORGAN_SLOT_BRAIN = /obj/item/organ/internal/brain,
		ORGAN_SLOT_EARS = /obj/item/organ/internal/ears,
		ORGAN_SLOT_EYES = /obj/item/organ/internal/eyes/snail,
		ORGAN_SLOT_TONGUE = /obj/item/organ/internal/tongue/snail,
		ORGAN_SLOT_HEART = /obj/item/organ/internal/heart,
		ORGAN_SLOT_LUNGS = /obj/item/organ/internal/lungs,
		ORGAN_SLOT_STOMACH = /obj/item/organ/internal/stomach,
		ORGAN_SLOT_LIVER = /obj/item/organ/internal/liver,
		ORGAN_SLOT_APPENDIX = /obj/item/organ/internal/appendix,

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
		BODY_ZONE_HEAD = /obj/item/bodypart/head/snail,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/snail,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/snail,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/snail,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/snail,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/snail
	)

/datum/species/snail/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H, delta_time, times_fired)
	if(istype(chem,/datum/reagent/consumable/salt))
		H.adjustFireLoss(2 * REAGENTS_EFFECT_MULTIPLIER * delta_time)
		playsound(H, 'sound/weapons/sear.ogg', 30, TRUE)
		H.reagents.remove_reagent(chem.type, REAGENTS_METABOLISM * delta_time)
		return TRUE

/datum/species/snail/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	. = ..()
	var/obj/item/storage/backpack/bag = C.get_item_by_slot(ITEM_SLOT_BACK)
	if(!istype(bag, /obj/item/storage/backpack/snail))
		if(C.dropItemToGround(bag)) //returns TRUE even if its null
			C.equip_to_slot_or_del(new /obj/item/storage/backpack/snail(C), ITEM_SLOT_BACK)
	C.AddElement(/datum/element/snailcrawl)

/datum/species/snail/on_species_loss(mob/living/carbon/C)
	. = ..()
	C.RemoveElement(/datum/element/snailcrawl)
	var/obj/item/storage/backpack/bag = C.get_item_by_slot(ITEM_SLOT_BACK)
	if(istype(bag, /obj/item/storage/backpack/snail))
		bag.emptyStorage()
		C.temporarilyRemoveItemFromInventory(bag, TRUE)
		qdel(bag)

/obj/item/storage/backpack/snail
	name = "snail shell"
	desc = "Worn by snails as armor and storage compartment."
	icon_state = "snailshell"
	inhand_icon_state = null
	lefthand_file = 'icons/mob/inhands/equipment/backpack_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/backpack_righthand.dmi'
	armor_type = /datum/armor/backpack_snail
	max_integrity = 200
	resistance_flags = FIRE_PROOF | ACID_PROOF

/datum/armor/backpack_snail
	melee = 40
	bullet = 30
	laser = 30
	energy = 10
	bomb = 25
	acid = 50

/obj/item/storage/backpack/snail/dropped(mob/user, silent)
	. = ..()
	emptyStorage()
	if(!QDELETED(src))
		qdel(src)

/obj/item/storage/backpack/snail/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, "snailshell")
