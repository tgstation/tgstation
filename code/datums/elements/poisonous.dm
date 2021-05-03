/**
 * Poisonous component; which makes the attacks of the simplemob attached poison the enemy.
 *
 * Used for spiders and bees!
 */
/datum/component/poisonous
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS
	///Path of the reagent added
	var/poison_type
	///How much of the reagent added. if it's a list, it'll pick a range with the range being list(lower_value, upper_value)
	var/list/amount_added

/datum/component/poisonous/Initialize(poison_type, amount_added)
	src.poison_type = poison_type
	src.amount_added = amount_added

/datum/component/poisonous/RegisterWithParent()
	if(isgun(parent))
		RegisterSignal(parent, COMSIG_PROJECTILE_ON_HIT, .proc/projectile_hit)
	else if(isitem(parent))
		RegisterSignal(parent, COMSIG_ITEM_AFTERATTACK, .proc/item_afterattack)
	else if(ishostile(parent))
		RegisterSignal(parent, COMSIG_HOSTILE_ATTACKINGTARGET, .proc/hostile_attackingtarget)

/datum/component/poisonous/UnregisterFromParent()
	UnregisterSignal(parent, COMSIG_HOSTILE_ATTACKINGTARGET)

///if a new poisonous component is added lets just update what it's type and amount is
/datum/component/poisonous/InheritComponent(datum/component/C, poison_type, amount_added)
	src.poison_type = poison_type
	src.amount_added = amount_added

/datum/component/poisonous/proc/projectile_hit(atom/fired_from, atom/movable/firer, atom/target, Angle)
	SIGNAL_HANDLER

	poison_target(target)

/datum/component/poisonous/proc/item_afterattack(obj/item/source, atom/target, mob/user, proximity_flag, click_parameters)
	SIGNAL_HANDLER

	if(!proximity_flag)
		return
	poison_target(target)

/datum/component/poisonous/proc/hostile_attackingtarget(mob/living/simple_animal/hostile/attacker, atom/target, success)
	SIGNAL_HANDLER

	if(!success)
		return
	poison_target(target)

/datum/component/poisonous/proc/poison_target(mob/living/target)
	if(!istype(target))
		return
	var/final_amount_added
	if(islist(amount_added))
		final_amount_added = rand(amount_added[1], amount_added[2])
	else
		final_amount_added = amount_added
	target.reagents?.add_reagent(poison_type, final_amount_added)
