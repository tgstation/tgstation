/**
 * curse of polymorph component;
 *
 * Used as a rpgloot suffix and wizard spell!
 */
/datum/component/curse_of_polymorph
	var/polymorph_type

/datum/component/curse_of_polymorph/Initialize(polymorph_type)
	. = ..()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	src.polymorph_type = polymorph_type

/datum/component/curse_of_polymorph/RegisterWithParent()
	. = ..()
	var/obj/item/cursed_item = parent
	RegisterSignal(cursed_item, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))

/datum/component/curse_of_polymorph/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, list(
		COMSIG_ITEM_EQUIPPED,
	))

///signal called from equipping parent
/datum/component/curse_of_polymorph/proc/on_equip(datum/source, mob/living/equipper, slot)
	SIGNAL_HANDLER
	var/obj/item/polymorpher_item = parent
	// Items with no slot flags curse on pickup (because hand slot)
	if(polymorpher_item.slot_flags && !(polymorpher_item.slot_flags & slot))
		return
	ASYNC
		equipper.dropItemToGround(polymorpher_item, TRUE)
		equipper.wabbajack(polymorph_type)

