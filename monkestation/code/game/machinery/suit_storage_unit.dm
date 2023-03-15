// Mapping helper unit takes whatever lies on top of it
/obj/machinery/suit_storage_unit/inherit/Initialize(mapload)
	. = ..()
	if(mapload)
		return INITIALIZE_HINT_LATELOAD

/obj/machinery/suit_storage_unit/inherit/LateInitialize()
	. = ..()
	var/turf/our_turf = src.loc
	for(var/atom/movable/checked_atom in our_turf)
		if(istype(checked_atom, /obj/item/clothing/suit/space) && !suit)
			checked_atom.forceMove(src)
			suit = checked_atom
		else if(istype(checked_atom, /obj/item/clothing/head/helmet/space) && !helmet)
			checked_atom.forceMove(src)
			helmet = checked_atom
		else if(istype(checked_atom, /obj/item/clothing/mask) && !mask)
			checked_atom.forceMove(src)
			mask = checked_atom
		else if(istype(checked_atom, /obj/item) && !storage)
			checked_atom.forceMove(src)
			storage = checked_atom
	update_icon()
