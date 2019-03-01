/obj/item/melee/curator_whip/amethystwhip
	name = "Amethyst Whip"
	desc = "A tool used by great gems to placate the frothing clods"
	force = 10

/obj/item/melee/curator_whip/amethystwhip/Initialize()
	. = ..()
	add_trait(TRAIT_NODROP)

/datum/action/innate/call_weapon/amethystwhip
	name = "Summon Whip"
	desc = "Whenever you need to summon your weapon, it just happens."
	isclockcult = FALSE
	weapon_type = /obj/item/melee/curator_whip/amethystwhip

