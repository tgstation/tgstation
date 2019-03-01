/obj/item/shield/riot/rosequartz
	name = "rose quartz shield"
	desc = "Might even be able to stand up to a direct attack from Three Diamonds... if you were one yourself."
	icon_state = "rosequartzshield"

/obj/item/shield/riot/rosequartz/Initialize()
	. = ..()
	add_trait(TRAIT_NODROP)

/datum/action/innate/call_weapon/roseshield
	name = "Summon Shield"
	desc = "May or may not require cookie cats to summon."
	isclockcult = FALSE
	weapon_type = /obj/item/shield/riot/rosequartz
