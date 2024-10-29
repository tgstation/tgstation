///An element that adds extra food quality to any edible that was made from an atom with this attached.
/datum/element/quality_food_ingredient
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	///The increase of recipe complexity (basically hardcoded food quality) of edibles made with this.
	var/complexity_increase = 0

/datum/element/quality_food_ingredient/Attach(datum/target, complexity_increase)
	. = ..()
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE
	if(HAS_TRAIT_FROM(target, TRAIT_QUALITY_FOOD_INGREDIENT, REF(src))) //It already has this element attached.
		return

	src.complexity_increase = complexity_increase

	RegisterSignal(target, COMSIG_ATOM_USED_IN_CRAFT, PROC_REF(used_in_craft))
	RegisterSignal(target, COMSIG_ITEM_BAKED, PROC_REF(item_baked))
	RegisterSignal(target, COMSIG_ITEM_MICROWAVE_COOKED_FROM, PROC_REF(microwaved_from))
	RegisterSignal(target, COMSIG_ITEM_GRILLED, PROC_REF(item_grilled))
	RegisterSignals(target, list(COMSIG_ITEM_BARBEQUE_GRILLED, COMSIG_ITEM_FRIED), PROC_REF(simply_cooked))
	RegisterSignal(target, COMSIG_ITEM_USED_AS_INGREDIENT, PROC_REF(used_as_ingredient))

/datum/element/quality_food_ingredient/Detach(datum/source)
	UnregisterSignal(source, list(
		COMSIG_ATOM_USED_IN_CRAFT,
		COMSIG_ITEM_BAKED,
		COMSIG_ITEM_MICROWAVE_COOKED_FROM,
		COMSIG_ITEM_GRILLED,
		COMSIG_ITEM_BARBEQUE_GRILLED,
		COMSIG_ITEM_FRIED,
		COMSIG_ITEM_USED_AS_INGREDIENT,
		COMSIG_FOOD_GET_EXTRA_COMPLEXITY,
	))
	REMOVE_TRAIT(source, TRAIT_QUALITY_FOOD_INGREDIENT, REF(src))
	return ..()

/datum/element/quality_food_ingredient/proc/used_in_craft(datum/source, atom/result)
	SIGNAL_HANDLER
	add_quality(result)

/datum/element/quality_food_ingredient/proc/item_baked(datum/source, atom/baked_result)
	SIGNAL_HANDLER
	add_quality(baked_result)

/datum/element/quality_food_ingredient/proc/microwaved_from(datum/source, atom/result)
	SIGNAL_HANDLER
	add_quality(result)

/datum/element/quality_food_ingredient/proc/item_grilled(datum/source, atom/grill_result)
	SIGNAL_HANDLER
	add_quality(grill_result)

/datum/element/quality_food_ingredient/proc/simply_cooked(datum/source)
	SIGNAL_HANDLER
	//The target of the food quality and the source are the same, there's no need to re-add the whole element.
	RegisterSignal(source, COMSIG_FOOD_GET_EXTRA_COMPLEXITY, PROC_REF(add_complexity), TRUE)
	ADD_TRAIT(source, TRAIT_QUALITY_FOOD_INGREDIENT, REF(src))

/datum/element/quality_food_ingredient/proc/used_as_ingredient(datum/source, atom/container)
	SIGNAL_HANDLER
	add_quality(container)

/datum/element/quality_food_ingredient/proc/add_quality(atom/target)
	target.AddElement(/datum/element/quality_food_ingredient, complexity_increase)
	RegisterSignal(target, COMSIG_FOOD_GET_EXTRA_COMPLEXITY, PROC_REF(add_complexity), TRUE)
	ADD_TRAIT(target, TRAIT_QUALITY_FOOD_INGREDIENT, REF(src))

/datum/element/quality_food_ingredient/proc/add_complexity(datum/source, list/extra_complexity)
	SIGNAL_HANDLER
	extra_complexity[1] += complexity_increase
