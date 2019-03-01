/obj/item/kitchen/knife/combat/jade
	name = "Jade Dagger"

/obj/item/kitchen/knife/combat/jade/Initialize()
	. = ..()
	add_trait(TRAIT_NODROP)

/datum/action/innate/call_weapon/jadedagger
	name = "Summon Dagger"
	desc = "Your opponents will certainly feel Jaded after you're done with them."
	isclockcult = FALSE
	weapon_type = /obj/item/kitchen/knife/combat/jade

