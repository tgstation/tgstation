/// -- Plant backfire element --
/// Certain high-danger plants, like death-nettles, will backfire and harm the holder if they're not properly protected.
/// If a user is protected with something like leather gloves, they can handle them normally.
/// If they're not protected properly, we invoke a callback on the user, harming or inconveniencing them.
/datum/element/plant_backfire
	element_flags = ELEMENT_BESPOKE | ELEMENT_DETACH
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

/*
 * Checks before we attack if we're okay to continue.
 *
 * source - our plant
 * user - the mob wielding our [source]
 */
/datum/element/plant_backfire/proc/attack_safety_check(datum/source, atom/target, mob/user)
	SIGNAL_HANDLER

	if(plant_safety_check(source, user))
		return
	SEND_SIGNAL(source, COMSIG_PLANT_ON_BACKFIRE, user)
	if(cancel_action)
		return COMPONENT_CANCEL_ATTACK_CHAIN

/*
 * Checks before we pick up the plant if we're okay to continue.
 *
 * source - our plant
 * user - the mob picking our [source]
 */
/datum/element/plant_backfire/proc/pickup_safety_check(datum/source, mob/user)
	SIGNAL_HANDLER

	if(plant_safety_check(source, user))
		return
	SEND_SIGNAL(source, COMSIG_PLANT_ON_BACKFIRE, user)

/*
 * Checks before we throw the plant if we're okay to continue.
 *
 * source - our plant
 * thrower - the mob throwing our [source]
 */
/datum/element/plant_backfire/proc/throw_safety_check(datum/source, list/arguments)
	SIGNAL_HANDLER

	var/mob/living/thrower = arguments[4] // 4th arg = mob/thrower
	if(plant_safety_check(source, thrower))
		return
	SEND_SIGNAL(source, COMSIG_PLANT_ON_BACKFIRE, thrower)
	if(cancel_action)
		return COMPONENT_CANCEL_THROW

/*
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
/datum/element/plant_backfire/proc/plant_safety_check(datum/source, mob/living/carbon/user)
	if(!istype(user))
		return TRUE

	if(HAS_TRAIT(user, TRAIT_PLANT_SAFE))
		return TRUE

	for(var/checked_trait in extra_traits)
		if(HAS_TRAIT(user, checked_trait))
			return TRUE

	var/obj/item/parent_item = source
	var/obj/item/seeds/our_seed = parent_item.get_plant_seed()
	if(our_seed)
		for(var/checked_gene in extra_genes)
			if(!our_seed.get_gene(checked_gene))
				return TRUE

	for(var/obj/item/clothing/worn_item in user.get_equipped_items())
		if((worn_item.body_parts_covered & HANDS) && (worn_item.clothing_flags & THICKMATERIAL))
			return TRUE

	return FALSE
