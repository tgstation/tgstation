/obj/item/food/deadmouse/Initialize(mapload, mob/living/basic/mouse/dead_critter)
	. = ..()
	ADD_TRAIT(src, TRAIT_TRASH_ITEM, INNATE_TRAIT)

/obj/item/food/deadmouse/extrapolator_act(mob/user, obj/item/extrapolator/E, scan = TRUE)
	if(!ratdisease.len)
		return FALSE
	if(scan)
		E.scan(src, ratdisease, user)
	else
		E.extrapolate(src, ratdisease, user)
	return TRUE

/mob/living/basic/mouse/extrapolator_act(mob/user, obj/item/extrapolator/E, scan = TRUE)
	if(!ratdisease.len)
		return FALSE
	if(scan)
		E.scan(src, ratdisease, user)
	else
		E.extrapolate(src, ratdisease, user)
	return TRUE
