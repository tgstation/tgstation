/obj/item/melee/chainofcommand/agatewhip
	name = "Agate Whip"
	desc = "A tool used by great gems to placate the frothing clods"
	force = 30
	damtype = "fire"
	hitsound = 'sound/weapons/egloves.ogg'

/obj/item/melee/chainofcommand/agatewhip/Initialize()
	. = ..()
	add_trait(TRAIT_NODROP)

/datum/action/innate/call_weapon/agatewhip
	name = "Summon Whip"
	desc = "Whenever you summon your weapon, Amethysts hit the deck."
	isclockcult = FALSE
	weapon_type = /obj/item/melee/chainofcommand/agatewhip

