
// Overrides such that examining a held undersized character shows their proper examine rather than the item examine

/obj/item/clothing/head/mob_holder/get_examine_name(mob/user)
	if(iscarbon(held_mob))
		return held_mob.get_examine_name(user)
	return ..()

/obj/item/clothing/head/mob_holder/get_examine_icon(mob/user)
	if(iscarbon(held_mob))
		return held_mob.get_examine_icon(user)
	return ..()

/obj/item/clothing/head/mob_holder/examine(mob/user)
	if(iscarbon(held_mob))
		return held_mob.examine(user)
	return ..()

/obj/item/clothing/head/mob_holder/examine_more(mob/user)
	if(iscarbon(held_mob))
		return held_mob.examine_more(user)
	return ..()
