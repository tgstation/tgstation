/datum/component/max_held_weight
	var/max_weight = WEIGHT_CLASS_NORMAL


/datum/component/max_held_weight/Initialize(max_weight)
	. = ..()
	src.max_weight = max_weight


/datum/component/max_held_weight/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_LIVING_PICKED_UP_ITEM, PROC_REF(see_if_can_hold))

/datum/component/max_held_weight/UnregisterFromParent()
	. = ..()
	UnregisterSignal(parent, COMSIG_LIVING_PICKED_UP_ITEM)

/datum/component/max_held_weight/proc/see_if_can_hold(mob/living/source, obj/item/picked_up)
	if(picked_up.w_class > max_weight)
		addtimer(CALLBACK(src, PROC_REF(drop_item), source, picked_up), 1 SECONDS)


/datum/component/max_held_weight/proc/drop_item(mob/living/source, obj/item/picked_up)
	source.dropItemToGround(picked_up, TRUE)
	to_chat(source, span_notice("You cannot seem to hold onto [picked_up], it's too heavy for you!"))
