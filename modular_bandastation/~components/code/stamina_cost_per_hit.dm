/**
 * # Stamina Cost Per Hit Component
 *
 * A component that adds stamina cost to item attacks.
 *
 * This component allows items to consume stamina when used to attack,
 * with different costs for attacking living beings vs other atoms,
 * and separate costs for wielded vs one-handed use.
 */
/datum/component/stamina_cost_per_hit
	/// Base stamina cost for attacking living beings
	var/stamina_cost = 10
	/// Stamina cost for attacking living beings when wielded
	var/stamina_cost_wielded
	/// Stamina cost for attacking non-living atoms
	var/stamina_cost_on_atom
	/// Stamina cost for attacking non-living atoms when wielded
	var/stamina_cost_wielded_on_atom
	/// Whether to ignore stamina exhaustion checks
	var/ignore_exhaustion = FALSE

	/// Calculated stamina cost for the current attack
	var/attack_cost

/**
 * Initialize the stamina cost per hit component
 *
 * Sets up the component parameters for stamina consumption on attacks
 * Arguments:
 * * stamina_cost - Base stamina cost for attacking living beings
 * * stamina_cost_wielded - Stamina cost for attacking living beings when wielded (uses stamina_cost if null)
 * * stamina_cost_on_atom - Stamina cost for attacking non-living atoms (uses stamina_cost if null)
 * * stamina_cost_wielded_on_atom - Stamina cost for attacking non-living atoms when wielded (uses stamina_cost_wielded if null)
 * * ignore_exhaustion - Whether to ignore stamina exhaustion checks
 */
/datum/component/stamina_cost_per_hit/Initialize(
	stamina_cost = 10,
	stamina_cost_wielded,
	stamina_cost_on_atom,
	stamina_cost_wielded_on_atom,
	ignore_exhaustion = FALSE,
)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	src.stamina_cost = stamina_cost
	src.stamina_cost_wielded = is_more_or_equal_0(stamina_cost_wielded) ? stamina_cost_wielded : stamina_cost
	src.stamina_cost_on_atom = is_more_or_equal_0(stamina_cost_on_atom) ? stamina_cost_on_atom : stamina_cost
	src.stamina_cost_wielded_on_atom = is_more_or_equal_0(stamina_cost_wielded_on_atom) ? stamina_cost_wielded_on_atom : src.stamina_cost_wielded
	src.ignore_exhaustion = ignore_exhaustion

/datum/component/stamina_cost_per_hit/RegisterWithParent()
	RegisterSignals(parent, list(
		COMSIG_ITEM_ATTACK,
		COMSIG_ITEM_ATTACK_ATOM
		), PROC_REF(on_attack))
	RegisterSignal(parent, COMSIG_ITEM_AFTERATTACK, PROC_REF(on_afterattack))

/datum/component/stamina_cost_per_hit/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_ITEM_ATTACK,
		COMSIG_ITEM_ATTACK_ATOM,
		COMSIG_ITEM_AFTERATTACK,
	))

/**
 * Handle attack validation and stamina cost calculation
 *
 * Calculates the appropriate stamina cost based on target type and wield status,
 * and cancels the attack if the user would be exhausted by the cost
 * Returns: [COMPONENT_CANCEL_ATTACK_CHAIN] if attack should be canceled due to exhaustion, otherwise NONE
 */
/datum/component/stamina_cost_per_hit/proc/on_attack(obj/item/attaking_item, atom/target, mob/living/user, list/modifiers, list/attack_modifiers)
	SIGNAL_HANDLER // COMSIG_ITEM_ATTACK + COMSIG_ITEM_ATTACK_ATOM

	if(isliving(target))
		attack_cost = HAS_TRAIT(parent, TRAIT_WIELDED) ? stamina_cost_wielded : stamina_cost
	else
		attack_cost = HAS_TRAIT(parent, TRAIT_WIELDED) ? stamina_cost_wielded_on_atom : stamina_cost_on_atom

	if(!ignore_exhaustion && ((user.maxHealth - (user.get_stamina_loss() + attack_cost)) <= user.crit_threshold))
		user.balloon_alert(user, "нет сил!")
		return COMPONENT_CANCEL_ATTACK_CHAIN

/**
 * Apply stamina cost after a successful attack
 *
 * Deducts the calculated stamina cost from the user after an attack completes
 */
/datum/component/stamina_cost_per_hit/proc/on_afterattack(obj/item/attaking_item, atom/target, mob/living/user, list/modifiers, list/attack_modifiers)
	SIGNAL_HANDLER // COMSIG_ITEM_AFTERATTACK

	user.adjust_stamina_loss(attack_cost)
