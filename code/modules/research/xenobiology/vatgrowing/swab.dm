///Tool capable of taking biological samples from mobs
/obj/item/swab
	name = "swab"
	desc = "Some men use these for different reasons."
	icon = 'icons/obj/xenobiology/vatgrowing.dmi'
	icon_state = "swab"
	w_class = WEIGHT_CLASS_TINY

///Adds the swabbing component to the biopsy tool
/obj/item/swab/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/swabbing, TRUE, TRUE, FALSE, null, CALLBACK(src, .proc/update_swab_icon), max_items = 1)

/obj/item/swab/proc/update_swab_icon(overlays, list/swabbed_items)
	if(LAZYLEN(swabbed_items))
		var/datum/biological_sample/sample = LAZYACCESS(swabbed_items, 1) //Use the first one as our target
		var/mutable_appearance/swab_overlay = mutable_appearance(icon, "swab_[sample.sample_color]")
		swab_overlay.appearance_flags = RESET_COLOR
		overlays += swab_overlay
