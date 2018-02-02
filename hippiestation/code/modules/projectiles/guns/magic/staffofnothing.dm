/obj/item/gun/magic/staff
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/gun/magic/staff/Initialize()
	. = ..()
	AddComponent(/datum/component/spell_catalyst)