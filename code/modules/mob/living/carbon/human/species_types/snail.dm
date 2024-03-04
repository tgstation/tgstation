/datum/species/snail
	name = "Snailperson"
	id = SPECIES_SNAIL
	inherent_traits = list(
		TRAIT_MUTANT_COLORS,
		TRAIT_NO_UNDERWEAR,
		TRAIT_NO_SLIP_ALL,
	)

	coldmod = 0.5 //snails only come out when its cold and wet
	siemens_coeff = 2 //snails are mostly water
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | RACE_SWAP
	sexes = FALSE //snails are hermaphrodites

	mutanteyes = /obj/item/organ/internal/eyes/snail
	mutanttongue = /obj/item/organ/internal/tongue/snail
	exotic_blood = /datum/reagent/lube

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/snail,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/snail,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/snail,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/snail,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/snail,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/snail
	)


/datum/species/snail/get_physical_attributes()
	return "Snailpeople emit a viscous, slippery ooze when crawling along the ground, which they are somewhat faster at than other species. \
		They are almost purely made of water, making them extremely susceptible to shocks, and salt will scour them heavily."

/datum/species/snail/handle_chemical(datum/reagent/chem, mob/living/carbon/human/affected, seconds_per_tick, times_fired)
	. = ..()
	if(. & COMSIG_MOB_STOP_REAGENT_CHECK)
		return
	if(istype(chem,/datum/reagent/consumable/salt))
		playsound(affected, SFX_SEAR, 30, TRUE)
		affected.adjustFireLoss(2 * REM * seconds_per_tick)
		affected.reagents.remove_reagent(chem.type, REAGENTS_METABOLISM * seconds_per_tick)
		return COMSIG_MOB_STOP_REAGENT_CHECK

/datum/species/snail/on_species_gain(mob/living/carbon/new_snailperson, datum/species/old_species, pref_load)
	. = ..()
	var/obj/item/storage/backpack/bag = new_snailperson.get_item_by_slot(ITEM_SLOT_BACK)
	if(!istype(bag, /obj/item/storage/backpack/snail))
		if(new_snailperson.dropItemToGround(bag)) //returns TRUE even if its null
			new_snailperson.equip_to_slot_or_del(new /obj/item/storage/backpack/snail(new_snailperson), ITEM_SLOT_BACK)
	new_snailperson.AddElement(/datum/element/snailcrawl)
	if(ishuman(new_snailperson))
		update_mail_goodies(new_snailperson)

/datum/species/snail/on_species_loss(mob/living/carbon/former_snailperson, datum/species/new_species, pref_load)
	. = ..()
	former_snailperson.RemoveElement(/datum/element/snailcrawl)
	var/obj/item/storage/backpack/bag = former_snailperson.get_item_by_slot(ITEM_SLOT_BACK)
	if(istype(bag, /obj/item/storage/backpack/snail))
		bag.emptyStorage()
		former_snailperson.temporarilyRemoveItemFromInventory(bag, TRUE)
		qdel(bag)

/datum/species/snail/update_quirk_mail_goodies(mob/living/carbon/human/recipient, datum/quirk/quirk, list/mail_goodies = list())
	if(istype(quirk, /datum/quirk/blooddeficiency))
		mail_goodies += list(
			/obj/item/reagent_containers/blood/snail
		)
	return ..()

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
