///Tool capable of taking biological samples from mobs
/obj/item/biopsy_tool
	name = "biopsy tool"
	desc = "Used to retrieve cell lines from organisms. Don't worry, it won't sting."
	icon = 'icons/obj/science/vatgrowing.dmi'
	icon_state = "biopsy"
	worn_icon_state = "biopsy"

///Adds the swabbing component to the biopsy tool
/obj/item/biopsy_tool/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/swabbing, FALSE, FALSE, TRUE, CALLBACK(src, PROC_REF(update_swab_icon)), max_items = 1)


/obj/item/biopsy_tool/proc/update_swab_icon(list/swabbed_items)
	if(LAZYLEN(swabbed_items))
		icon_state = "biopsy_full"
	else
		icon_state = "biopsy"
