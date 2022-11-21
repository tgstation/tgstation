/**
 * ## basic eating element!
 *
 * Small behavior for non-carbons to eat certain stuff they interact with
 */
/datum/element/basic_eating
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// Types the animal can eat.
	var/list/food_types

/datum/element/basic_eating/Attach(datum/target, food_types = list())
	. = ..()

	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE

	src.food_types = food_types

	//this lets players eat
	RegisterSignal(target, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(on_unarm_attack))
	//this lets ai eat. yes, i'm serious
	RegisterSignal(target, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(on_pre_attackingtarget))

/datum/element/basic_eating/Detach(datum/target)
	UnregisterSignal(target, list(COMSIG_LIVING_UNARMED_ATTACK, COMSIG_HOSTILE_PRE_ATTACKINGTARGET))
	return ..()

/datum/element/basic_eating/proc/on_unarm_attack(mob/living/eater, atom/target, proximity, modifiers)
	SIGNAL_HANDLER
	try_eating(eater, target)

/datum/element/basic_eating/proc/on_pre_attackingtarget(mob/living/eater, atom/target)
	SIGNAL_HANDLER
	try_eating(eater, target)

/datum/element/basic_eating/proc/try_eating(mob/living/eater, atom/target)
	if(!is_type_in_list(target, food_types))
		return
	on_eaten(eater, target)
	playsound(eater.loc,'sound/items/eatfood.ogg', rand(10,50), TRUE)
	qdel(target)

/// Do something in response to eating food
/datum/element/basic_eating/proc/on_eaten(mob/living/eater, atom/target)
	return

/// Eating desired foods will heal you
/datum/element/basic_eating/heal
	/// Amount of healing to do
	var/heal_amt

/datum/element/basic_eating/heal/Attach(datum/target, food_types = list(), heal_amt = 0)
	. = ..()
	if (. == ELEMENT_INCOMPATIBLE)
		return

	src.heal_amt = heal_amt

/datum/element/basic_eating/heal/on_eaten(mob/living/eater, atom/target)
	var/eat_verb = pick("bite","chew","nibble","gnaw","gobble","chomp")
	var/healed = heal_amt && eater.health < eater.maxHealth
	if(heal_amt)
		eater.heal_overall_damage(heal_amt)
	eater.visible_message(span_notice("[eater] [eat_verb]s [target]."), span_notice("You [eat_verb] [target][healed ? ", restoring some health" : ""]."))

/// Eating desired foods will hurt you
/datum/element/basic_eating/harm
	/// Amount of damage to do
	var/damage_amount
	/// Type of damage
	var/damage_type

/datum/element/basic_eating/harm/Attach(datum/target, food_types = list(), damage_amount = 0, damage_type = BRUTE)
	. = ..()
	if (. == ELEMENT_INCOMPATIBLE)
		return

	src.damage_amount = damage_amount
	src.damage_type =damage_type


/datum/element/basic_eating/harm/on_eaten(mob/living/eater, atom/target)
	var/eat_verb = pick("bite","chew","nibble","gnaw","gobble","chomp")
	if(damage_amount)
		eater.apply_damage(damage_amount, damage_type)
	eater.visible_message(span_notice("[eater] [eat_verb]s [target], and seems to hurt itself."), span_notice("You [eat_verb] [target][damage_amount ? ", hurting yourself in the process" : ""]."))
