/// Return values for wall tearing validation
#define WALL_TEAR_ALLOWED 1 ///< Tearing is allowed and should proceed
#define WALL_TEAR_INVALID 0 ///< Target is not valid for tearing
#define WALL_TEAR_CANCEL_CHAIN -1 ///< Tearing is invalid and attack chain should be canceled

/**
 * # Rip and Tear Component
 *
 * A component that allows items to tear down walls with sustained attacks.
 *
 * This component handles the validation and execution of wall-tearing actions,
 * including stamina costs, wield requirements, and handling of reinforced walls.
 * It provides visual feedback and sound effects during the tearing process.
 */
/datum/component/rip_and_tear
	/// Base stamina cost for tearing actions
	var/stamina_cost = 30
	/// Stamina cost when wielded (if different from base)
	var/stamina_cost_wielded
	/// Whether the item must be wielded to tear walls
	var/require_wielded = TRUE
	/// Multiplier for tear time on reinforced walls (null means cannot tear reinforced walls)
	var/reinforced_multiplier
	/// Base time required to tear a standard wall
	var/tear_time = 5 SECONDS
	/// Whether to ignore stamina exhaustion checks
	var/ignore_exhaustion = FALSE
	/// Unique key for do_after actions to prevent overlapping interactions
	var/do_after_key = "rip_and_tear"

/**
 * Initialize the rip and tear component
 *
 * Sets up the component parameters for wall tearing behavior
 * Arguments:
 * * stamina_cost - Base stamina cost for tearing actions
 * * stamina_cost_wielded - Stamina cost when wielded (uses stamina_cost if null)
 * * require_wielded - Whether wielding is required for tearing
 * * reinforced_multiplier - Time multiplier for reinforced walls (null prevents tearing reinforced walls)
 * * tear_time - Base time required to tear standard walls
 * * ignore_exhaustion - Whether to ignore stamina exhaustion checks
 */
/datum/component/rip_and_tear/Initialize(
	stamina_cost = 30,
	stamina_cost_wielded,
	require_wielded = TRUE,
	reinforced_multiplier,
	tear_time = 5 SECONDS,
	ignore_exhaustion = FALSE,
)
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE

	src.stamina_cost = stamina_cost
	src.stamina_cost_wielded = is_more_or_equal_0(stamina_cost_wielded) ? stamina_cost_wielded : stamina_cost
	src.require_wielded = require_wielded
	src.reinforced_multiplier = reinforced_multiplier
	src.tear_time = tear_time
	src.ignore_exhaustion = ignore_exhaustion

/datum/component/rip_and_tear/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_PRE_ATTACK, PROC_REF(on_pre_attack))

/datum/component/rip_and_tear/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_ITEM_PRE_ATTACK,
	))

/**
 * Handle pre-attack validation for wall tearing
 *
 * Checks if the target is a valid wall for tearing and initiates the tearing process
 * Returns: [COMPONENT_CANCEL_ATTACK_CHAIN] if tearing is initiated or invalid, otherwise NONE
 */
/datum/component/rip_and_tear/proc/on_pre_attack(obj/item/source, atom/target, mob/living/user, list/modifiers)
	SIGNAL_HANDLER // COMSIG_ITEM_PRE_ATTACK

	if(!iswallturf(target))
		return

	var/is_valid = validate_target(target, user)
	if(is_valid != WALL_TEAR_ALLOWED)
		return is_valid == WALL_TEAR_CANCEL_CHAIN ? COMPONENT_CANCEL_ATTACK_CHAIN : .

	INVOKE_ASYNC(src, PROC_REF(rip_and_tear), user, target)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/**
 * Validate if target can be torn
 *
 * Checks various conditions for wall tearing validity
 * Returns: [WALL_TEAR_ALLOWED] if valid, [WALL_TEAR_INVALID] if invalid but should continue chain,
 *          [WALL_TEAR_CANCEL_CHAIN] if invalid and should cancel attack chain
 */
/datum/component/rip_and_tear/proc/validate_target(atom/target, mob/living/user)
	if(!isclosedturf(target) || isindestructiblewall(target))
		return WALL_TEAR_INVALID

	if(require_wielded && !HAS_TRAIT(parent, TRAIT_WIELDED))
		user.balloon_alert(user, "нужно держать двумя руками!")
		return WALL_TEAR_CANCEL_CHAIN

	var/reinforced = istype(target, /turf/closed/wall/r_wall)
	if(!reinforced_multiplier && reinforced)
		target.balloon_alert(user, "слишком крепкая!")
		return WALL_TEAR_CANCEL_CHAIN

	return WALL_TEAR_ALLOWED

/**
 * Execute the wall tearing process
 *
 * Handles the actual wall tearing sequence including do_after, stamina costs,
 * and visual/audio feedback. Recursively continues tearing until wall is destroyed
 * or interrupted.
 */
/datum/component/rip_and_tear/proc/rip_and_tear(mob/living/user, atom/target)
	if(QDELETED(target))
		return

	var/reinforced = istype(target, /turf/closed/wall/r_wall)
	if(reinforced && !reinforced_multiplier)
		return

	var/rip_time = (reinforced ? tear_time * reinforced_multiplier : tear_time) / 3
	if(rip_time > 0)
		if(DOING_INTERACTION_WITH_TARGET(user, target) || DOING_INTERACTION(user, do_after_key))
			user.balloon_alert(user, "заняты!")
			return

		if(!ignore_exhaustion && ((user.maxHealth - (user.get_stamina_loss() + get_stamina_cost())) <= user.crit_threshold))
			user.balloon_alert(user, "вы слишком устали!")
			return

		user.visible_message(span_warning("[capitalize(user.declent_ru(NOMINATIVE))] начинает выламывать [target.declent_ru(ACCUSATIVE)] при помощи [parent.declent_ru(GENITIVE)]!"))
		playsound(user, 'sound/machines/airlock/airlock_alien_prying.ogg', vol = 100, vary = TRUE)
		target.balloon_alert(user, "выламываем...")
		if(!do_after(user, delay = rip_time, target = target, interaction_key = do_after_key))
			user.balloon_alert(user, "прервано!")
			return

	var/is_valid = validate_target(target, user)
	if(is_valid != WALL_TEAR_ALLOWED)
		return

	user.do_attack_animation(target)
	target.AddComponent(/datum/component/torn_wall)
	user.adjust_stamina_loss(get_stamina_cost())
	playsound(target, 'sound/effects/meteorimpact.ogg', 100, TRUE)

	is_valid = validate_target(target, user)
	if(is_valid == WALL_TEAR_ALLOWED)
		rip_and_tear(user, target)

/**
 * Get current stamina cost based on wield status
 *
 * Returns the appropriate stamina cost based on whether the item is wielded
 * Returns: Stamina cost value
 */
/datum/component/rip_and_tear/proc/get_stamina_cost()
	return HAS_TRAIT(parent, TRAIT_WIELDED) ? stamina_cost_wielded : stamina_cost

#undef WALL_TEAR_ALLOWED
#undef WALL_TEAR_INVALID
#undef WALL_TEAR_CANCEL_CHAIN
