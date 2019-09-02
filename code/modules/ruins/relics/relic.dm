/obj/item/curio
	name = "relic"
	desc = "From a long gone civilization."
	icon = 'icons/obj/guns/projectile.dmi'
	icon_state = "detective"
	item_state = "gun"
	w_class = WEIGHT_CLASS_NORMAL
	throwforce = 5
	throw_speed = 3
	throw_range = 5
	force = 5
	attack_verb = list("struck", "hit", "bashed")

	var/rarity

/obj/item/curio/Initialize()

/obj/item/curio/Destroy()
