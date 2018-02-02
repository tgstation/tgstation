/obj/item/gun/magic/staff
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/gun/magic/staff/Initialize()
	. = ..()
	AddComponent(/datum/component/spell_catalyst)

/obj/item/twohanded/mjollnir/Initialize()
	. = ..()
	AddComponent(/datum/component/spell_catalyst)
	
/obj/item/twohanded/singularityhammer/Initialize()
	. = ..()
	AddComponent(/datum/component/spell_catalyst)
