/obj/structure/extinguisher_cabinet
	icon = 'modular_skyrat/modules/aesthetics/extinguisher/icons/extinguisher.dmi'
	icon_state = "extinguisher_standard_closed"

/obj/item/wallframe/extinguisher_cabinet
	icon = 'modular_skyrat/modules/aesthetics/extinguisher/icons/extinguisher.dmi'

/obj/item/extinguisher
	icon = 'modular_skyrat/modules/aesthetics/extinguisher/icons/extinguisher.dmi'
	var/random_overlay = 0

/obj/structure/extinguisher_cabinet/Initialize(mapload, ndir, building)
	. = ..()
	update_icon()


/obj/structure/extinguisher_cabinet/update_icon_state()
	if(!opened)
		if(stored_extinguisher)
			if(istype(stored_extinguisher, /obj/item/extinguisher/mini))
				icon_state = "extinguisher_mini_closed"
			else if(istype(stored_extinguisher, /obj/item/extinguisher/advanced))
				icon_state = "extinguisher_advanced_closed"
			else
				icon_state = "extinguisher_standard_closed"
		else
			icon_state = "extinguisher_empty_closed"
	else if(stored_extinguisher)
		if(istype(stored_extinguisher, /obj/item/extinguisher/mini))
			icon_state = "extinguisher_mini_open"
		else if(istype(stored_extinguisher, /obj/item/extinguisher/advanced))
			icon_state = "extinguisher_advanced_open"
		else
			icon_state = "extinguisher_standard_open"
	else
		icon_state = "extinguisher_empty_open"

/obj/item/extinguisher/Initialize()
	. = ..()
	random_overlay = rand(1, 6)
	update_icon()

/obj/item/extinguisher/update_overlays()
	. = ..()
	if(!istype(src, /obj/item/extinguisher/mini) && !istype(src, /obj/item/extinguisher/advanced))
		. += "ex_overlay_[random_overlay]"
