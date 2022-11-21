/**
 * ## basic eating element!
 *
 * Small behavior for non-carbons to eat certain stuff they interact with
 */
/datum/element/basic_eating
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	///Path of the reagent added
	var/heal_amt
	/// Types the animal can eat.
	var/list/food_types

/datum/element/basic_eating/Attach(datum/target, heal_amt = 0, food_types = list())
	. = ..()

	if(!isliving(target))
		return ELEMENT_INCOMPATIBLE

	src.heal_amt = heal_amt
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
	if(eater.combat_mode)
		return
	if(!is_type_in_list(target, food_types))
		return
	var/eat_verb = pick("bite","chew","nibble","gnaw","gobble","chomp")
	var/healed = heal_amt && eater.health < eater.maxHealth
	if(heal_amt)
		eater.heal_overall_damage(heal_amt)
	eater.visible_message(span_notice("[eater] [eat_verb]s [target]."), span_notice("You [eat_verb] [target][healed ? ", restoring some health" : ""]."))
	playsound(eater.loc,'sound/items/eatfood.ogg', rand(10,50), TRUE)
	qdel(target)
