/**
 * ## basic eating element!
 *
 * Small behavior for non-carbons to eat certain stuff they interact with. If applicable, sets up BB_BASIC_FOODS as well.
 */
/datum/element/basic_eating
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// Amount to heal
	var/heal_amt
	/// Amount to hurt
	var/damage_amount
	/// Type of hurt to apply
	var/damage_type
	/// Whether to flavor it as drinking rather than eating.
	var/drinking
	/// Types the animal can eat.
	var/list/food_types

/datum/element/basic_eating/Attach(datum/target, heal_amt = 0, damage_amount = 0, damage_type = null, drinking = FALSE, food_types = list())
	. = ..()

	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE
	var/mob/living/living_target = target

	src.heal_amt = heal_amt
	src.damage_amount = damage_amount
	src.damage_type = damage_type
	src.drinking = drinking
	src.food_types = food_types

	living_target.ai_controller?.blackboard[BB_BASIC_FOODS] = typecacheof(food_types)

	//this lets players eat
	RegisterSignal(target, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(on_unarm_attack))
	//this lets ai eat. yes, i'm serious
	RegisterSignal(target, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(on_pre_attackingtarget))
	//feeding to this mob
	RegisterSignal(target, COMSIG_ATOM_ATTACKBY, PROC_REF(on_atom_attackby))

/datum/element/basic_eating/Detach(datum/target)
	UnregisterSignal(target, list(COMSIG_LIVING_UNARMED_ATTACK, COMSIG_HOSTILE_PRE_ATTACKINGTARGET))
	return ..()

/datum/element/basic_eating/proc/on_atom_attackby(mob/living/eater, obj/item/food, mob/living/feeder, params)
	SIGNAL_HANDLER
	if(!is_type_in_list(food, food_types))
		return
	if(eater.stat == DEAD)
		to_chat(feeder, span_warning("[eater] is dead!"))
		return COMPONENT_CANCEL_ATTACK_CHAIN

	if(try_eating(eater, food, feeder))
		return COMPONENT_CANCEL_ATTACK_CHAIN
	return NONE

/datum/element/basic_eating/proc/on_unarm_attack(mob/living/eater, atom/target, proximity, modifiers)
	SIGNAL_HANDLER
	if(!proximity)
		return NONE

	if(try_eating(eater, target))
		return COMPONENT_CANCEL_ATTACK_CHAIN
	return NONE

/datum/element/basic_eating/proc/on_pre_attackingtarget(mob/living/eater, atom/target)
	SIGNAL_HANDLER
	try_eating(eater, target)

/datum/element/basic_eating/proc/try_eating(mob/living/eater, atom/target, mob/living/feeder)
	if(!is_type_in_list(target, food_types))
		return FALSE
	if(SEND_SIGNAL(eater, COMSIG_MOB_PRE_EAT, target) & COMSIG_MOB_CANCEL_EAT)
		return FALSE
	var/eat_verb
	if(drinking)
		eat_verb = pick("slurp","sip","guzzle","drink","quaff","suck")
	else
		eat_verb = pick("bite","chew","nibble","gnaw","gobble","chomp")

	if (heal_amt > 0)
		var/healed = heal_amt && eater.health < eater.maxHealth
		if(heal_amt)
			eater.heal_overall_damage(heal_amt)
		eater.visible_message(span_notice("[eater] [eat_verb]s [target]."), span_notice("You [eat_verb] [target][healed ? ", restoring some health" : ""]."))
		finish_eating(eater, target, feeder)
		return TRUE

	if (damage_amount > 0 && damage_type)
		eater.apply_damage(damage_amount, damage_type)
		eater.visible_message(span_notice("[eater] [eat_verb]s [target], and seems to hurt itself."), span_notice("You [eat_verb] [target], hurting yourself in the process."))
		finish_eating(eater, target, feeder)
		return TRUE

	eater.visible_message(span_notice("[eater] [eat_verb]s [target]."), span_notice("You [eat_verb] [target]."))
	finish_eating(eater, target, feeder)
	return TRUE

/datum/element/basic_eating/proc/finish_eating(mob/living/eater, atom/target, mob/living/feeder)
	SEND_SIGNAL(eater, COMSIG_MOB_ATE, target, feeder)
	if(drinking)
		playsound(eater.loc,'sound/items/drink.ogg', rand(10,50), TRUE)
	else
		playsound(eater.loc,'sound/items/eatfood.ogg', rand(10,50), TRUE)
	qdel(target)
