/obj/item/mounted/frame/fireaxe_cabinet_frame
	name = "fireaxe cabinet frame"
	desc = "Used for building fireaxe cabinets"
	icon = 'icons/obj/closet.dmi'
	icon_state = "fireaxe_assembly"
	flags = FPRINT
	//m_amt = 2*CC_PER_SHEET_METAL //It's plasteel
	melt_temperature = MELTPOINT_STEEL
	w_type = NOT_RECYCLABLE //Plasteel recycling doesn't exist, to my knowledge.
	mount_reqs = list("simfloor", "nospace")

/obj/item/mounted/frame/fireaxe_cabinet_frame/do_build(turf/on_wall, mob/user)
	new /obj/structure/closet/fireaxecabinet/empty(get_turf(src), get_dir(user, on_wall), 1)
	qdel(src)