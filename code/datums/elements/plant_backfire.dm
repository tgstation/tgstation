/// -- Plant backfire element --
/// Certain high-danger plants, like death-nettles, will backfire and harm the holder if they're not properly protected.
/// If a user is protected with something like leather gloves, they can handle them normally.
/// If they're not protected properly, we invoke a callback on the user, harming or inconveniencing them.
/datum/element/plant_backfire
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2
	/// Whether we stop the current action if backfire is triggered (EX: returning CANCEL_ATTACK_CHAIN)
	var/cancel_action = FALSE
	/// Any extra traits we want to check in addition to TRAIT_PLANT_SAFE. Mobs with a trait in this list will be considered safe. List of traits.
	var/extra_traits
	/// Any plant genes we want to check that are required for our plant to be dangerous. Plants without a gene in this list will be considered safe. List of typepaths.
	var/extra_genes

/datum/element/plant_backfire/Attach(datum/target, cancel_action = FALSE, extra_traits, extra_genes)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE

	src.cancel_action = cancel_action
	src.extra_traits = extra_traits
	src.extra_genes = extra_genes

	RegisterSignal(target, COMSIG_ITEM_PRE_ATTACK, .proc/attack_safety_check)
	RegisterSignal(target, COMSIG_ITEM_PICKUP, .proc/pickup_safety_check)
	RegisterSignal(target, COMSIG_MOVABLE_PRE_THROW, .proc/throw_safety_check)

/datum/element/plant_backfire/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, list(COMSIG_ITEM_PRE_ATTACK, COMSIG_ITEM_PICKUP, COMSIG_MOVABLE_PRE_THROW))

/**
 * Checks before we attack if we're okay to continue.
 *
 * source - our plant
 * user - the mob wielding our [source]
 */
/datum/element/plant_backfire/proc/attack_safety_check(obj/item/source, atom/target, mob/user)
	SIGNAL_HANDLER

	// Covers stuff like tk, since we aren't actually touching the plant.
	if(!user.is_holding(source))
		return
	if(!backfire(source, user))
		return

	return cancel_action ? COMPONENT_CANCEL_ATTACK_CHAIN : NONE

/**
 * Checks before we pick up the plant if we're okay to continue.
 *
 * source - our plant
 * user - the mob picking our [source]
 */
/datum/element/plant_backfire/proc/pickup_safety_check(obj/item/source, mob/user)
	SIGNAL_HANDLER

	backfire(source, user)

/**
 * Checks before we throw the plant if we're okay to continue.
 *
 * source - our plant
 * thrower - the mob throwing our [source]
 */
/datum/element/plant_backfire/proc/throw_safety_check(obj/item/source, list/arguments)
	SIGNAL_HANDLER

	var/mob/living/thrower = arguments[4] // the 4th arg = the mob throwing our item
	if(!thrower.is_holding(source))
		return
	if(!backfire(source, thrower))
		return

	return cancel_action ? COMPONENT_CANCEL_ATTACK_CHAIN : NONE

/**
 * The actual backfire occurs here.
 * Checks if the user is able to safely handle the plant.
 * If not, sends the backfire signal (meaning backfire will occur and be handled by one or multiple genes).
 *
 * Returns FALSE if the user was safe and no backfire occured.
 * Returns TRUE if the user was not safe and a backfire actually happened.
 */
/datum/element/plant_backfire/proc/backfire(obj/item/plant, mob/user)
	if(plant_safety_check(plant, user))
		return FALSE

	SEND_SIGNAL(plant, COMSIG_PLANT_ON_BACKFIRE, user)
	return TRUE

/**
 * Actually checks if our user is safely handling our plant.
 *
 * Checks for TRAIT_PLANT_SAFE, and returns TRUE if we have it.
 * Then, any extra traits we need to check (Like TRAIT_PIERCEIMMUNE for nettles) and returns TRUE if we have one of them.
 * Then, any extra genes we need to check (Like liquid contents for bluespace tomatos) and returns TRUE if we don't have the gene.
 *
 * source - our plant
 * user - the carbon handling our [source]
 *
 * returns FALSE if none of the checks are successful.
 */
/datum/element/plant_backfire/proc/plant_safety_check(obj/item/plant, mob/living/carbon/user)
	if(!istype(user))
		return TRUE

	if(HAS_TRAIT(user, TRAIT_PLANT_SAFE))
		return TRUE

	for(var/checked_trait in extra_traits)
		if(HAS_TRAIT(user, checked_trait))
			return TRUE

	var/obj/item/seeds/our_seed = plant.get_plant_seed()
	if(our_seed)
		for(var/checked_gene in extra_genes)
			if(!our_seed.get_gene(checked_gene))
				return TRUE

	for(var/obj/item/clothing/worn_item in user.get_equipped_items())
		if((worn_item.body_parts_covered & HANDS) && (worn_item.clothing_flags & THICKMATERIAL))
			return TRUE

	return FALSE
