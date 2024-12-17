/// Changes a food item's food buff to something else when it has "love" reagent within
/datum/element/love_food_buff
	element_flags = ELEMENT_BESPOKE
	argument_hash_start_idx = 2
	/// Buff typepath to add when our food has love within
	var/love_buff_type

/datum/element/love_food_buff/Attach(datum/target, love_buff_type)
	. = ..()
	if(!istype(target, /obj/item/food))
		return ELEMENT_INCOMPATIBLE
	var/obj/item/food/food = target
	if(isnull(food.reagents))
		return ELEMENT_INCOMPATIBLE

	src.love_buff_type = love_buff_type
	RegisterSignals(food.reagents, list(
		COMSIG_REAGENTS_ADD_REAGENT,
		COMSIG_REAGENTS_CLEAR_REAGENTS,
		COMSIG_REAGENTS_DEL_REAGENT,
		COMSIG_REAGENTS_NEW_REAGENT,
		COMSIG_REAGENTS_REM_REAGENT,
	), PROC_REF(on_reagents_changed))

/datum/element/love_food_buff/Detach(datum/source, ...)
	var/obj/item/food/food = source
	if(istype(food) && !isnull(food.reagents))
		UnregisterSignal(food.reagents, list(
			COMSIG_REAGENTS_ADD_REAGENT,
			COMSIG_REAGENTS_CLEAR_REAGENTS,
			COMSIG_REAGENTS_DEL_REAGENT,
			COMSIG_REAGENTS_NEW_REAGENT,
			COMSIG_REAGENTS_REM_REAGENT,
		))
	return ..()

/datum/element/love_food_buff/proc/on_reagents_changed(datum/reagents/source, ...)
	SIGNAL_HANDLER

	var/obj/item/food/food = source.my_atom
	if(!istype(food))
		return

	if(source.has_reagent(/datum/reagent/love))
		food.crafted_food_buff = love_buff_type
	else
		food.crafted_food_buff = initial(food.crafted_food_buff)
