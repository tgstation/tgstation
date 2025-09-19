///Spirit mob that lacks legs but still roams the station as part of the unliving.
/datum/species/ghost
	name = "Ghost"
	id = SPECIES_GHOST
	inherent_traits = list(
		TRAIT_GENELESS,
		TRAIT_MOVE_FLYING,
		TRAIT_NEVER_WOUNDED,
		TRAIT_NOBLOOD,
		TRAIT_NODISMEMBER,
		TRAIT_NO_DNA_COPY,
		TRAIT_NO_FLOATING_ANIM,
		TRAIT_NO_PLASMA_TRANSFORM,
		TRAIT_NO_UNDERWEAR,
		TRAIT_RESISTLOWPRESSURE,
		TRAIT_UNHUSKABLE,
	)
	inherent_biotypes = MOB_HUMANOID | MOB_SPIRIT | MOB_UNDEAD
	no_equip_flags = ITEM_SLOT_FEET
	changesource_flags = MIRROR_BADMIN | WABBAJACK | SLIME_EXTRACT | MIRROR_PRIDE | MIRROR_MAGIC
	sexes = FALSE
	meat = /obj/item/ectoplasm

	mutantheart = null
	mutantappendix = null
	mutantears = /obj/item/organ/ears/ghost
	mutantstomach = /obj/item/organ/stomach/ghost
	mutantliver = /obj/item/organ/liver/ghost
	mutantlungs = /obj/item/organ/lungs/ghost
	mutanteyes = /obj/item/organ/eyes/ghost
	mutantbrain = /obj/item/organ/brain/ghost
	mutanttongue = /obj/item/organ/tongue/ghost

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/ghost,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/ghost,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/ghost,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/ghost,
	)

	///Innate passthrough ability given to ghosts that allows them to phase but drops their stuff.
	var/datum/action/innate/toggle_passthrough/passthrough_ability

/datum/species/ghost/check_roundstart_eligible()
	if(check_holidays(HALLOWEEN))
		return TRUE
	return ..()

/datum/species/ghost/on_species_gain(mob/living/carbon/human/new_ghost, datum/species/old_species, pref_load, regenerate_icons)
	. = ..()
	passthrough_ability = new(src)
	passthrough_ability.Grant(new_ghost)

/datum/species/ghost/on_species_loss(mob/living/carbon/human/former_ghost, datum/species/new_species, pref_load)
	QDEL_NULL(passthrough_ability)
	return ..()

/datum/species/ghost/get_physical_attributes()
	return "Ghosts are the spiritual remains of long-passed entities. They lack legs, can fly, and phase through walls, \
		but still eat, breathe, hear and see."

/datum/species/ghost/get_species_description()
	return "Spirits are spirits of long-dead creatures whom, for one reason or another, still roam around."

/datum/species/ghost/get_species_lore()
	return list(
		"Ghosts are one of the spookiest creatures known in the galaxy. \
		While they still need their protein to sustain themselves, they are able to control their own bodies, \
		going through walls and getting rid of all their posessions at will. \
		Most knowledge known about them is kept secret by Nanotrasen's top Chaplains, who are keen \
		to keep it private.",
	)

/datum/species/ghost/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = "body",
		SPECIES_PERK_NAME = "Leg-less",
		SPECIES_PERK_DESC = "Ghosts lack legs and float, preventing you from falling into holes in the ground.",
	))

	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEUTRAL_PERK,
		SPECIES_PERK_ICON = "ghost",
		SPECIES_PERK_NAME = "Incorporeal",
		SPECIES_PERK_DESC = "Ghost carry their tombstones with them and are directly tied to it. \
			dropping the tombstone will allow you to phase through solid matter, but leaves you vulnerable.",
	))

	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
		SPECIES_PERK_ICON = "shoe-prints",
		SPECIES_PERK_NAME = "No Feet",
		SPECIES_PERK_DESC = "You lack feet, therefore the ability to wear any shoes!",
	))

	return to_add

/**
 * Passthrough ability
 *
 * Ghost innate ability that allows them to enter ghost mode,
 * which gives them the phasing ability, but makes them unable to use anything,
 * and they will be tied to a tombstone that, if dug up, will kill them and turn them
 * into a skeleton.
 */
/datum/action/innate/toggle_passthrough
	name = "Toggle passthrough"
	desc = "Toggles phasing through everything, including your hands. You are tied to your tombstone while this is active. \
		At least you know how to keep your clothes on."
	button_icon = 'icons/hud/actions.dmi'
	button_icon_state = "ghost"

	///Grave that appears when we're passing through, which we are also tied to.
	var/obj/structure/closet/crate/grave/skeleton/grave

/datum/action/innate/toggle_passthrough/Grant(mob/grant_to)
	. = ..()
	grave = new()
	//contents are initialized when the grave is robbed as that's when the crate is opened for the first time.
	RegisterSignal(grave, COMSIG_CLOSET_CONTENTS_INITIALIZED, PROC_REF(on_grave_robbed))
	RegisterSignal(grave, COMSIG_CLOSET_POST_OPEN, PROC_REF(post_grave_robbed))

/datum/action/innate/toggle_passthrough/Remove(mob/remove_from)
	if(!QDELING(remove_from))
		swap_mode(force_off = TRUE)
	QDEL_NULL(grave)
	return ..()

/datum/action/innate/toggle_passthrough/Activate()
	. = ..()
	if(!iscarbon(owner))
		return
	swap_mode()

///Swaps the mode, allowing us to phase through stuff but drops everything. Optional 'force_off' arg to prevent being able to turn it on.
/datum/action/innate/toggle_passthrough/proc/swap_mode(force_off)
	//we can only turn off, early return if we're trying to turn it on instead.
	if(force_off && HAS_TRAIT_FROM(owner, TRAIT_NO_FLOATING_ANIM, SPECIES_TRAIT))
		return

	var/mob/living/carbon/carbon_owner = owner
	if(HAS_TRAIT_FROM(carbon_owner, TRAIT_NO_FLOATING_ANIM, SPECIES_TRAIT))
		grave.forceMove(get_turf(carbon_owner))
		carbon_owner.AddComponent(/datum/component/leash, grave, distance = 7)
		REMOVE_TRAIT(carbon_owner, TRAIT_NO_FLOATING_ANIM, SPECIES_TRAIT)
		carbon_owner.add_traits(list(
			TRAIT_MOVE_PHASING,
			TRAIT_PIERCEIMMUNE,
			TRAIT_INVISIBLE_TO_CAMERA,
			TRAIT_HANDS_BLOCKED, //MOBILITY_USE | MOBILITY_PICKUP | MOBILITY_STORAGE
			TRAIT_PULL_BLOCKED, //MOBILITY_PULL
			TRAIT_UI_BLOCKED, //MOBILITY_UI
		), SPECIES_TRAIT)
	else
		qdel(carbon_owner.GetComponent(/datum/component/leash))
		carbon_owner.forceMove(get_turf(grave))
		grave.moveToNullspace()
		ADD_TRAIT(carbon_owner, TRAIT_NO_FLOATING_ANIM, SPECIES_TRAIT)
		carbon_owner.remove_traits(list(
			TRAIT_MOVE_PHASING,
			TRAIT_PIERCEIMMUNE,
			TRAIT_INVISIBLE_TO_CAMERA,
			TRAIT_HANDS_BLOCKED,
			TRAIT_PULL_BLOCKED,
			TRAIT_UI_BLOCKED,
		), SPECIES_TRAIT)

///Called when the contents are made, which means the grave has been 'opened', therefore robbed.
/datum/action/innate/toggle_passthrough/proc/on_grave_robbed(obj/structure/closet/crate/grave/skeleton/source)
	SIGNAL_HANDLER
	var/mob/living/carbon/human/species/skeleton/skeletons_in_the_closet = locate() in source.contents
	owner.mind.transfer_to(skeletons_in_the_closet, force_key_move = TRUE)
	skeletons_in_the_closet.death(gibbed = FALSE)

///Called AFTER the contents have been spit out, which means the owner is now in the skeleton. Let's clean up.
/datum/action/innate/toggle_passthrough/proc/post_grave_robbed(obj/structure/closet/crate/grave/skeleton/source)
	SIGNAL_HANDLER
	qdel(owner)
