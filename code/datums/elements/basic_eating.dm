/**
 * ## basic eating element!
 *
 * Small behavior for non-carbons to eat certain stuff they interact with
 */
/datum/element/basic_eating
	element_flags = ELEMENT_BESPOKE|ELEMENT_DETACH
	id_arg_index = 2
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

	RegisterSignal(target, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, .proc/pre_attackingtarget)

/datum/element/basic_eating/Detach(datum/target)
	UnregisterSignal(target, COMSIG_HOSTILE_PRE_ATTACKINGTARGET)
	return ..()

/datum/element/basic_eating/proc/pre_attackingtarget(mob/living/eater, atom/target)
	SIGNAL_HANDLER

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
