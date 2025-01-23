/atom/proc/examine_title_worn(mob/user)
	var/regular_examine = src.examine_title(user)
	if(HAS_TRAIT_FROM(src, TRAIT_WORN_EXAMINE, TRAIT_SUBTREE_REQUIRED_OPERATIONAL_DATUM)) // Uses /datum/element/examined_when_worn
		return "<a href='?src=[REF(src)];examine_loadout=1;'>[regular_examine]</a>"
	else
		return regular_examine
