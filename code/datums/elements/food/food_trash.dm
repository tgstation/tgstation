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

/datum/element/dunkable/Detach(datum/target)
	. = ..()
	UnregisterSignal(target, COMSIG_FOOD_CONSUMED)

/datum/element/food_trash/proc/generate_trash(datum/source, mob/living/eater, mob/living/feeder)
	SIGNAL_HANDLER

	var/datum/component/edible/edible_component = source

	var/obj/item/trash_item = new trash()

	var/mob/living/mob_location = edible_component.parent.loc //The foods location

	if(istype(mob_location))
		mob_location.put_in_hands(trash_item)
	else
		trash_item.forceMove(get_turf(edible_component.parent))
