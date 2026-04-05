/datum/material/hauntium
	name = "hauntium"
	desc = "very scary!"
	color = list(460/255, 464/255, 460/255, 0, 0,0,0,0, 0,0,0,0, 0,0,0,1, 0,0,0,0)
	greyscale_color = "#FFFFFF"
	alpha = 100
	starlight_color = COLOR_ALMOST_BLACK
	mat_flags = MATERIAL_BASIC_RECIPES | MATERIAL_CLASS_METAL | MATERIAL_CLASS_FABRIC // Metal for crafting, and fabric because bedsheets and ghosts... you get it.
	mat_properties = list(
		MATERIAL_DENSITY = 2,
		MATERIAL_HARDNESS = 6,
		MATERIAL_FLEXIBILITY = 8, // Fabric
		MATERIAL_REFLECTIVITY = 4,
		MATERIAL_ELECTRICAL = 4,
		MATERIAL_THERMAL = 4,
		MATERIAL_CHEMICAL = 2,
		MATERIAL_FLAMMABILITY = 6,
	)
	sheet_type = /obj/item/stack/sheet/hauntium
	material_reagent = /datum/reagent/hauntium
	value_per_unit = 0.05

/datum/material/hauntium/on_main_applied(atom/source, mat_amount, multiplier)
	. = ..()
	if(!isitem(source))
		return
	var/obj/item/source_item = source
	source_item.make_haunted(INNATE_TRAIT, "#f8f8ff")
	if(isbodypart(source))
		var/obj/item/bodypart/bodypart = source
		if(!(bodypart::bodytype & BODYTYPE_GHOST))
			bodypart.bodytype |= BODYTYPE_GHOST
	if(isorgan(source))
		var/obj/item/organ/organ = source
		if(!(organ::organ_flags & ORGAN_GHOST))
			organ.organ_flags |= ORGAN_GHOST

/datum/material/hauntium/on_main_removed(atom/source, mat_amount, multiplier)
	. = ..()
	if(!isitem(source))
		return
	var/obj/item/source_item = source
	source_item.remove_haunted(INNATE_TRAIT)
	if(isbodypart(source))
		var/obj/item/bodypart/bodypart = source
		if(!(bodypart::bodytype & BODYTYPE_GHOST))
			bodypart.bodytype &= ~BODYTYPE_GHOST
	if(isorgan(source))
		var/obj/item/organ/organ = source
		if(!(organ::organ_flags & ORGAN_GHOST))
			organ.organ_flags &= ~ORGAN_GHOST
