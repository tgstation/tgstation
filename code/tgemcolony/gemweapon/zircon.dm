/obj/item/kitchen/knife/combat/jade
	name = "Jade Dagger"

/obj/item/kitchen/knife/combat/jade/Initialize()
	. = ..()
	add_trait(TRAIT_NODROP)

/datum/action/innate/call_weapon/zircon
	name = "Summon Law Book"
	desc = "Not a weapon, but it'll do."
	isclockcult = FALSE
	weapon_type = /obj/item/kitchen/knife/combat/jade