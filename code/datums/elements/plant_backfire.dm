/// -- Plant backfire element --
/// Certain high-danger plants, like death-nettles, will backfire and harm the holder if they're not properly protected.
/// If a user is protected with something like leather gloves, they can handle them normally.
/// If they're not protected properly, we call backfire proc on the user.
/datum/element/plant_backfire
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2
	/// Any extra traits we want to check in addition to TRAIT_PLANT_SAFE. Mobs with a trait in this list will be considered safe. List of traits.
	var/extra_traits
	/// Any plant genes we want to check that are required for our plant to be dangerous. Plants without a gene in this list will be considered safe. List of typepaths.
	var/extra_genes
	/// The proc path of the backfire effect of the plant.
	var/backfire_procpath

/datum/element/plant_backfire/Attach(datum/target, backfire_procpath, extra_traits, extra_genes)
	. = ..()
	if(!isitem(target))
		return ELEMENT_INCOMPATIBLE

	src.extra_traits = extra_traits
	src.extra_genes = extra_genes
	src.backfire_procpath = backfire_procpath

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
 * user - the mob wielding [source]
 */
/datum/element/plant_backfire/proc/attack_safety_check(datum/source, atom/target, mob/user)
	SIGNAL_HANDLER

	if(plant_safety_check(source, user))
		return
	call(source, backfire_procpath)(user)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/*
 * Checks before we pick up the plant if we're okay to continue.
 *
 * source - our plant
 * user - the mob picking up [source]
 */
/datum/element/plant_backfire/proc/pickup_safety_check(datum/source, mob/user)
	SIGNAL_HANDLER

	if(plant_safety_check(source, user))
		return
	call(source, backfire_procpath)(user)

/*
 * Checks before we throw the plant if we're okay to continue.
 *
 * source - our plant
 * thrower - the mob throwing up [source]
 */
/datum/element/plant_backfire/proc/throw_safety_check(datum/source, atom/target, range, speed, mob/thrower)
	SIGNAL_HANDLER

	if(plant_safety_check(source, thrower))
		return
	call(source, backfire_procpath)(thrower)
	return COMPONENT_CANCEL_THROW

/*
 * Actually checks if our user is safely handling our plant.
 *
 * source - our plant
 * user - the carbon handling [source]
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

	return FALSE
