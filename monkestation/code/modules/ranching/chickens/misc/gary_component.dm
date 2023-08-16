/datum/component/garys_item
	///the gary that created us
	var/mob/living/basic/chicken/gary/attached_gary
	///the source of this
	var/obj/item/source_item

/datum/component/garys_item/Initialize(mob/living/basic/chicken/gary/attached_gary)
	. = ..()

	src.attached_gary = attached_gary
	source_item = parent

	RegisterSignal(source_item, COMSIG_ITEM_PICKUP, PROC_REF(looter))


/datum/component/garys_item/UnregisterFromParent()
	. = ..()
	UnregisterSignal(source_item, COMSIG_ITEM_PICKUP)

/datum/component/garys_item/proc/looter()
	attached_gary.held_shinies -= source_item.type
	attached_gary.adjust_happiness(-5)
