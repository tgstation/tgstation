
// Overrides such that a held undersized character counts as whatever their ID/access is

/obj/item/clothing/head/mob_holder/GetAccess()
	if(iscarbon(held_mob))
		return held_mob.get_access()
	return ..()

/obj/item/clothing/head/mob_holder/GetID()
	if(iscarbon(held_mob))
		return held_mob.get_idcard()
	return ..()
