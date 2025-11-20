/obj/item/ammo_box/magazine/internal
	desc = "Oh god, this shouldn't be here"
	abstract_type = /obj/item/ammo_box/magazine/internal
	spawn_blacklisted = TRUE
	obj_flags = CONDUCTS_ELECTRICITY
	item_flags = ABSTRACT

//internals magazines are accessible, so replace spent ammo if full when trying to put a live one in
/obj/item/ammo_box/magazine/internal/give_round(obj/item/ammo_casing/R)
	return ..(R,1)
