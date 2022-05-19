/**
 * Venomous element; which makes the attacks of the simplemob attached poison the enemy.
 *
 * Used for spiders and bees!
 */
/datum/element/venomous
	element_flags = ELEMENT_BESPOKE|ELEMENT_DETACH
	id_arg_index = 2

	/// The reagents to add to the target on
	var/datum/reagents/venom
	/// The minimum amount of venom added to the target per strike.
	var/min_amount_added
	/// The maximum amount of venom added to the target per strike.
	var/max_amount_added
	/// How the venom gets into the target.
	var/methods

/datum/element/venomous/Attach(datum/target, list/datum/reagent/venom, amount_added, methods = TOUCH)
	. = ..()
	if (islist(amount_added))
		switch(length(amount_added))
			if(0)
				stack_trace("")
				return ELEMENT_INCOMPATIBLE
			if(1)
				min_amount_added = amount_added[1]
				max_amount_added = amount_added[1]
			if(2)
				min_amount_added = amount_added[1]
				max_amount_added = amount_added[2]
			else
				min_amount_added = amount_added[1]
				max_amount_added = amount_added[2]
				stack_trace("Excessively long amount-to-add list passed to venom element: [jointext(amount_added, ", ", "", ".")]")

	else if(isnum(amount_added))
		min_amount_added = amount_added
		max_amount_added = amount_added

	if(!(isnum(min_amount_added) && isnum(max_amount_added)))
		stack_trace("Attempted to")
		return ELEMENT_INCOMPATIBLE

	if (min_amount_added > max_amount_added)
		var/tmp_amt = min_amount_added
		min_amount_added = max_amount_added
		max_amount_added = tmp_amt

	if(!islist(venom))
		venom = list((venom) = max_amount_added)

	var/total_venom = 0
	for(var/datum/reagent/venom_path as anything in venom)
		var/venom_amt = venom[venom_path]
		if(!ispath(venom_path, /datum/reagent) || !isnum(venom_amt) || venom_amt <= 0)
			stack_trace("Attempted to make [target] venomous with [venom_amt]u of [venom_path] venom.")
			venom -= venom_path
			continue

		total_venom += venom_amt

	if (total_venom <= 0)
		stack_trace("Attempted to make [target] venomous with a total of [total_venom]u venom.")
		return ELEMENT_INCOMPATIBLE

	if(!isnum(methods))
		stack_trace("Attempted to make [target] venomous with invalid exposure methods [methods].")
		methods = NONE

	if(isgun(target))
		RegisterSignal(target, COMSIG_PROJECTILE_ON_HIT, .proc/projectile_hit)
	else if(isitem(target))
		RegisterSignal(target, COMSIG_ITEM_AFTERATTACK, .proc/item_afterattack)
	else if(ishostile(target) || isbasicmob(target))
		RegisterSignal(target, COMSIG_HOSTILE_POST_ATTACKINGTARGET, .proc/hostile_attackingtarget)
	else
		return ELEMENT_INCOMPATIBLE

	src.venom = new(INFINITY, NO_REACT)
	src.venom.add_reagent_list(venom)
	src.venom.multiply_reagents(max_amount_added / src.venom.total_volume)

	src.methods = methods

/datum/element/venomous/Detach(datum/target)
	UnregisterSignal(target, list(
		COMSIG_PROJECTILE_ON_HIT,
		COMSIG_ITEM_AFTERATTACK,
		COMSIG_HOSTILE_POST_ATTACKINGTARGET,
	))
	return ..()

/**
 * Handles a venomous gun hitting a target with a projectile.
 *
 * Adds venom to the targets bloodstream.
 *
 * Arguments:
 * * [fired_from][/atom]: The thing the projectile was fired from.
 * * [firer][/atom/movable]: The mob that fired the projectile.
 * * [target][/atom]: The atom that the projectile hit.
 * * Angle: The angle the projectile was moving at upon impact.
 */
/datum/element/venomous/proc/projectile_hit(atom/fired_from, atom/movable/firer, atom/target, Angle)
	SIGNAL_HANDLER

	add_reagent(target, fired_from)

/**
 * Handles a venomous weapon hitting a target/being used on a target.
 *
 * Adds venom to the targets bloodstream if the attack was in melee.
 *
 * Arguments:
 * * [source][/obj/item]: The venomous item being used on the target.
 * * [target][/atom]: The atom that the attacker is attacking.
 * * [user][/mob]: The mob wielding the source item.
 * * proximity_flag: Whether the interaction was in melee range.
 * * click_parameters: Various click-related parameters formatted as a string or assoc list.
 */
/datum/element/venomous/proc/item_afterattack(obj/item/source, atom/target, mob/user, proximity_flag, click_parameters)
	SIGNAL_HANDLER

	if(!proximity_flag)
		return
	add_reagent(target, source)

/**
 * Handles a hostile, venomous mob punching a target.
 *
 * Adds venom to the targets bloodstream if the attack was successful.
 *
 * Arguments:
 * * [attacker][/mob/living/simple_animal/hostile]: The venomous mob attacking a target.
 * * [target][/atom]: The atom that the attacker is attacking.
 * * success: Whether the attach successfully hit the target.
 */
/datum/element/venomous/proc/hostile_attackingtarget(mob/living/simple_animal/hostile/attacker, atom/target, success)
	SIGNAL_HANDLER

	if(!success)
		return
	add_reagent(target, attacker)

/**
 * Handles actually adding the venom reagent to the target
 *
 * Also handles exposing the target to the venom reagent.
 * Also handles any transfer-based effects of the venom reagent.
 *
 * Arguments:
 * - [target][/mob/living]: The mob that is getting venom added to its bloodstream.
 */
/datum/element/venomous/proc/add_reagent(mob/living/target, atom/source)
	if(!istype(target))
		return

	var/amount_added = rand(min_amount_added, max_amount_added)
	if(!amount_added)
		return

	var/datum/reagents/tmp_holder = new(INFINITY, NO_REACT)
	tmp_holder.my_atom = source
	venom.copy_to(tmp_holder, amount_added, no_react = TRUE)
	if (target.reagents)
		tmp_holder.trans_to(target, tmp_holder.total_volume, methods = methods, ignore_stomach = TRUE)
	else if(methods)
		tmp_holder.expose(target, methods)
	QDEL_NULL(tmp_holder)
