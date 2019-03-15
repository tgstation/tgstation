/datum/species/snail
	name = "Snailperson"
	id = "snail"
	default_color = "336600" //vomit green
	species_traits = list(MUTCOLORS, NO_UNDERWEAR)
	inherent_traits = list(TRAIT_ALWAYS_CLEAN)
	attack_verb = "slap"
	say_mod = "slurs"
	coldmod = 0.5 //snails only come out when its cold and wet
	burnmod = 2
	speedmod = 6
	punchdamagehigh = 0.5 //snails are soft and squishy
	siemens_coeff = 2 //snails are mostly water
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | RACE_SWAP
	sexes = FALSE //snails are hermaphrodites
	var/shell_type = /obj/item/storage/backpack/snail

	mutanteyes = /obj/item/organ/eyes/snail
	mutanttongue = /obj/item/organ/tongue/snail
	exotic_blood = "spacelube"

/datum/species/snail/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(chem.id == "sodiumchloride")
		H.adjustFireLoss(2)
		playsound(H, 'sound/weapons/sear.ogg', 30, 1)
		H.reagents.remove_reagent(chem.id, REAGENTS_METABOLISM)
		return 1

/datum/species/snail/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	. = ..()
	var/obj/item/storage/backpack/bag = C.get_item_by_slot(SLOT_BACK)
	if(!istype(bag, /obj/item/storage/backpack/snail))
		if(C.dropItemToGround(bag)) //returns TRUE even if its null
			C.equip_to_slot_or_del(new /obj/item/storage/backpack/snail(C), SLOT_BACK)
	C.AddComponent(/datum/component/snailcrawl)
	C.add_trait(TRAIT_NOSLIPALL, SPECIES_TRAIT)

/datum/species/snail/on_species_loss(mob/living/carbon/C)
	. = ..()
	var/datum/component/CP = C.GetComponent(/datum/component/snailcrawl)
	CP.RemoveComponent()
	C.remove_trait(TRAIT_NOSLIPALL, SPECIES_TRAIT)
	var/obj/item/storage/backpack/bag = C.get_item_by_slot(SLOT_BACK)
	if(istype(bag, /obj/item/storage/backpack/snail))
		bag.emptyStorage()
		C.doUnEquip(bag, TRUE, no_move = TRUE)
		qdel(bag)

/obj/item/storage/backpack/snail
	name = "snail shell"
	desc = "Worn by snails as armor and storage compartment."
	icon_state = "snail_green"
	item_state = "snail_green"
	lefthand_file = 'icons/mob/inhands/equipment/backpack_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/backpack_righthand.dmi'
	armor = list("melee" = 40, "bullet" = 30, "laser" = 30, "energy" = 10, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 0, "acid" = 50)
	max_integrity = 200
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/storage/backpack/snail/Initialize()
	. = ..()
	add_trait(TRAIT_NODROP)