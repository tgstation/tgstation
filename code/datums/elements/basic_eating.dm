/**
 * ## basic eating element!
 *
 * Small behavior for non-carbons to eat certain stuff they interact with
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
	/// If true, we put food in our tummy instead of deleting it
	var/add_to_contents
	/// If true, when add_to_contents would put the item into contents but when used for healing, the item is consumed instead
	var/consume_healing
	/// Types the animal can eat. Can be an assoc list with amount to heal/damage the mob by
	var/list/food_types

/datum/element/basic_eating/Attach(datum/target, heal_amt = 0, damage_amount = 0, damage_type = null, drinking = FALSE, add_to_contents = FALSE, consume_healing = TRUE, food_types = list())
	. = ..()

	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE

	ADD_TRAIT(target, TRAIT_MOB_EATER, REF(src))
	src.heal_amt = heal_amt
	src.damage_amount = damage_amount
	src.damage_type = damage_type
	src.drinking = drinking
	src.add_to_contents = add_to_contents
	src.consume_healing = consume_healing
	src.food_types = food_types

	RegisterSignal(target, COMSIG_ATOM_ITEM_INTERACTION, PROC_REF(try_feed))
	RegisterSignal(target, COMSIG_LIVING_UNARMED_ATTACK, PROC_REF(on_unarm_attack))

/datum/element/basic_eating/Detach(datum/target)
	REMOVE_TRAIT(target, TRAIT_MOB_EATER, REF(src))

	UnregisterSignal(target, list(
		COMSIG_LIVING_UNARMED_ATTACK,
		COMSIG_ATOM_ITEM_INTERACTION,
	))
	return ..()

/datum/element/basic_eating/proc/try_feed(atom/source, mob/living/user, atom/possible_food)
	SIGNAL_HANDLER
	if(user.combat_mode || !is_type_in_list(possible_food, food_types))
		return NONE
	var/mob/living/living_source = source
	if(living_source.stat != CONSCIOUS)
		return NONE
	return try_eating(source, possible_food, user) ? ITEM_INTERACT_SUCCESS : NONE

/datum/element/basic_eating/proc/on_unarm_attack(mob/living/eater, atom/target, proximity, modifiers)
	SIGNAL_HANDLER
	if(!proximity)
		return NONE

	if(try_eating(eater, target))
		return COMPONENT_CANCEL_ATTACK_CHAIN
	return NONE

/datum/element/basic_eating/proc/try_eating(mob/living/eater, atom/target, mob/living/feeder)
	if(!is_type_in_list(target, food_types))
		return FALSE
	var/list/effect_mult = list()
	if(SEND_SIGNAL(eater, COMSIG_MOB_PRE_EAT, target, feeder, effect_mult) & COMSIG_MOB_CANCEL_EAT)
		return FALSE
	if(add_to_contents && !ismovable(target))
		return FALSE
	var/eat_verb
	if(drinking)
		eat_verb = pick("slurp","sip","guzzle","drink","quaff","suck")
	else
		eat_verb = pick("bite","chew","nibble","gnaw","gobble","chomp")

	var/best_match = null
	var/best_value = 0
	for (var/food_path in food_types)
		// Not an assoc list
		if (isnull(food_types[food_path]))
			break
		if (istype(target, food_path) && (!best_match || ispath(food_path, best_match)))
			best_match = food_path
			best_value = food_types[food_path]

	var/to_heal = heal_amt
	var/to_damage = damage_amount

	if (best_match)
		to_heal = 0
		to_damage = 0
		if (best_value > 0)
			to_heal = best_value
		else if (best_value < 0)
			to_damage = -best_value

		for (var/mult in effect_mult)
			to_heal *= mult
			to_damage *= mult

	if (to_heal > 0)
		var/healed = eater.heal_overall_damage(to_heal)
		eater.visible_message(span_notice("[eater] [eat_verb]s [target]."), span_notice("You [eat_verb] [target][healed ? ", restoring some health" : ""]."))
	else if (to_damage > 0 && damage_type)
		var/damaged = eater.apply_damage(to_damage, damage_type)
		eater.visible_message(span_notice("[eater] [eat_verb]s [target][damaged ? ", and seems to hurt [eater.p_themselves()]!" : "."]"), span_notice("You [eat_verb] [target][damaged ? ", hurting yourself in the process" : ""]."))
	else
		eater.visible_message(span_notice("[eater] [eat_verb]s [target]."), span_notice("You [eat_verb] [target]."))

	finish_eating(eater, target, feeder, to_heal)
	return TRUE

/datum/element/basic_eating/proc/finish_eating(mob/living/eater, atom/target, mob/living/feeder, to_heal)
	set waitfor = FALSE
	if(drinking)
		playsound(eater.loc,'sound/items/drink.ogg', rand(10,50), TRUE)
	else
		playsound(eater.loc,'sound/items/eatfood.ogg', rand(10,50), TRUE)
	var/atom/final_target = target
	if(SEND_SIGNAL(eater, COMSIG_MOB_ATE, final_target, feeder) & COMSIG_MOB_TERMINATE_EAT)
		return
	if(isstack(target)) //if stack, only consume 1
		var/obj/item/stack/food_stack = target
		final_target = food_stack.split_stack(1)

	var/devour = add_to_contents && !to_heal
	eater.log_message("has eaten [target], [devour ? "swallowing it" : "destroying it"]!", LOG_ATTACK)

	if (devour)
		var/atom/movable/movable_target = final_target
		movable_target.forceMove(eater)
	else
		qdel(final_target)

