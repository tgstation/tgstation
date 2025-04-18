/// Animated beings of stone. They have increased defenses, and do not need to breathe. They must eat minerals to live, which give additional buffs.
/datum/species/ghost
	name = "Ghost"
	id = SPECIES_GHOST
	inherent_traits = list(
		TRAIT_GENELESS,
		TRAIT_NEVER_WOUNDED,
		TRAIT_NOBLOOD,
		TRAIT_NODISMEMBER,
		TRAIT_NO_DNA_COPY,
		TRAIT_NO_PLASMA_TRANSFORM,
		TRAIT_NO_UNDERWEAR,
		TRAIT_UNHUSKABLE,
		TRAIT_NO_FLOATING_ANIM,
		TRAIT_MOVE_FLYING,
	)
	inherent_biotypes = MOB_SPIRIT
	no_equip_flags = ITEM_SLOT_FEET
	changesource_flags = MIRROR_BADMIN | MIRROR_PRIDE | MIRROR_MAGIC
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
	return "Ghosts are the spiritual remains of long-passed entities. They lack legs, can fly, can choose at will to become opaque, \
		but still eat, breathe, hear and see."

/datum/species/ghost/get_species_description()
	return "Ghosts are spirits of long-dead creatures whom, for one reason or another, still roam around."

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
		SPECIES_PERK_ICON = "ghost",
		SPECIES_PERK_NAME = "Incorporeal",
		SPECIES_PERK_DESC = "Ghost are able to control their body to the extent where you can willingly make yourself able \
			to phase through anything, including your own equipment.",
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
 * which gives them the phasing ability, but makes them drop everything
 * and completely unable to wear anything.
 */
/datum/action/innate/toggle_passthrough
	name = "Toggle passthrough"
	desc = "Toggles your ability to phase through everything, including your gear and any incompatible organs/limbs."
	button_icon = 'icons/hud/actions.dmi'
	button_icon_state = "ghost"

/datum/action/innate/toggle_passthrough/Grant(mob/grant_to)
	. = ..()
	RegisterSignal(grant_to, COMSIG_CARBON_POST_ATTACH_LIMB, PROC_REF(on_new_limb))

/datum/action/innate/toggle_passthrough/Remove(mob/remove_from)
	swap_mode(force_off = TRUE)
	UnregisterSignal(remove_from, COMSIG_CARBON_POST_ATTACH_LIMB)
	return ..()

/datum/action/innate/toggle_passthrough/Activate()
	. = ..()
	if(!iscarbon(owner))
		return
	swap_mode()

/datum/action/innate/toggle_passthrough/IsAvailable(feedback)
	if(LAZYLEN(owner.reagents))
		if(locate(/datum/reagent/water/holywater) in owner.reagents)
			return FALSE
	return ..()

///Called when the owner of this action gets a new limb, if it isn't a ghost-limb
///the action will turn itself off, and you'll lose said limb if you try using this action again.
/datum/action/innate/toggle_passthrough/proc/on_new_limb(mob/source, obj/item/bodypart/new_part, special)
	SIGNAL_HANDLER
	if(!iscarbon(owner))
		return
	if(!(new_part.bodytype & BODYTYPE_GHOST))
		swap_mode(force_off = TRUE)

///Swaps the mode, allowing us to phase through stuff but drops everything. Optional 'force_off' arg to prevent being able to turn it on.
/datum/action/innate/toggle_passthrough/proc/swap_mode(force_off)
	//we can only turn off, early return if we're trying to turn it on instead.
	if(force_off && HAS_TRAIT(owner, TRAIT_NO_FLOATING_ANIM))
		return

	var/mob/living/carbon/carbon_owner = owner
	var/datum/species/carbon_species = carbon_owner.dna.species

	//drop any limbs & organs that can't phase, now that you're phasing.
	for(var/obj/item/bodypart/bodypart as anything in carbon_owner.bodyparts)
		if(!(bodypart.bodytype & BODYTYPE_GHOST))
			bodypart.drop_limb(special = FALSE, dismembered = FALSE, move_to_floor = TRUE)
	for(var/obj/item/organ/organ as anything in carbon_owner.organs)
		if(!(organ.organ_flags & ORGAN_GHOST))
			organ.Remove(owner, special = FALSE)

	if(HAS_TRAIT(carbon_owner, TRAIT_NO_FLOATING_ANIM))
		REMOVE_TRAIT(carbon_owner, TRAIT_NO_FLOATING_ANIM, SPECIES_TRAIT)
		carbon_owner.add_traits(list(TRAIT_MOVE_PHASING, TRAIT_PIERCEIMMUNE), SPECIES_TRAIT)
		carbon_owner.mobility_flags = MOBILITY_FLAGS_CARBON_PHASING
		carbon_species.update_no_equip_flags(carbon_owner, ALL)
		RegisterSignal(carbon_owner, COMSIG_MOB_CLIENT_PRE_LIVING_MOVE, PROC_REF(attempt_move))
	else
		ADD_TRAIT(carbon_owner, TRAIT_NO_FLOATING_ANIM, SPECIES_TRAIT)
		carbon_owner.remove_traits(list(TRAIT_MOVE_PHASING, TRAIT_PIERCEIMMUNE), SPECIES_TRAIT)
		carbon_owner.mobility_flags = initial(carbon_owner.mobility_flags)
		carbon_species.update_no_equip_flags(carbon_owner, initial(carbon_species.no_equip_flags))
		UnregisterSignal(carbon_owner, COMSIG_MOB_CLIENT_PRE_LIVING_MOVE)

///Called when attempting to move to a new tile while the action is active, returns to cancel moving.
/datum/action/innate/toggle_passthrough/proc/attempt_move(mob/source, new_loc, direct)
	SIGNAL_HANDLER
	if(locate(/obj/effect/blessing) in new_loc)
		to_chat(source, span_warning("Holy energies block your path!"))
		return COMSIG_MOB_CLIENT_BLOCK_PRE_LIVING_MOVE
