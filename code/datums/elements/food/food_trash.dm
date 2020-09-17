// If an item has the food_trash element it will drop an item when it is consumed.
/datum/element/food_trash
	element_flags = ELEMENT_BESPOKE
	id_arg_index = 2
	/// The type of trash that is spawned by this element
	var/trash

/datum/element/food_trash/Attach(datum/target, atom/trash)
	. = ..()
	if(!isatom(target))
		return ELEMENT_INCOMPATIBLE
	src.trash = trash
	RegisterSignal(target, COMSIG_FOOD_CONSUMED, .proc/generate_trash)

/datum/element/food_trash/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_FOOD_CONSUMED)

/datum/element/food_trash/proc/generate_trash(datum/source, mob/living/eater, mob/living/feeder)
	SIGNAL_HANDLER

	///cringy signal_handler shouldnt be needed if you dont want to return but oh well
	INVOKE_ASYNC(src, .proc/async_generate_trash, source)

/datum/element/food_trash/proc/async_generate_trash(datum/source)

	var/obj/item/trash_item = new trash()

	var/atom/edible_object = source

	var/mob/living/mob_location = edible_object.loc //The foods location

	if(istype(mob_location))
		mob_location.put_in_hands(trash_item)
	else
		trash_item.forceMove(get_turf(edible_object))
