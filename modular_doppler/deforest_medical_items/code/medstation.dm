/obj/machinery/biogenerator/medstation
	name = "wall med-station"
	desc = "An advanced machine seen in frontier outposts and colonies capable of turning organic plant matter into \
		various emergency medical supplies and injectors. You can find one of these in the medical sections of just about \
		any frontier installation."
	icon = 'modular_doppler/deforest_medical_items/icons/medstation.dmi'
	circuit = null
	anchored = TRUE
	density = FALSE
	efficiency = 1
	productivity = 1
	show_categories = list(
		RND_CATEGORY_DEFOREST_MEDICAL,
		RND_CATEGORY_DEFOREST_BLOOD,
	)
	/// The item we turn into when repacked
	var/repacked_type = /obj/item/wallframe/frontier_medstation

MAPPING_DIRECTIONAL_HELPERS(/obj/machinery/biogenerator/medstation, 29)

/obj/machinery/biogenerator/medstation/RefreshParts()
	. = ..()
	efficiency = 1
	productivity = 1

/obj/machinery/biogenerator/medstation/default_unfasten_wrench(mob/user, obj/item/wrench/tool, time)
	user.balloon_alert(user, "deconstructing...")
	tool.play_tool_sound(src)
	if(tool.use_tool(src, user, 1 SECONDS))
		playsound(loc, 'sound/items/deconstruct.ogg', 50, TRUE)
		deconstruct(TRUE)
		return

/obj/machinery/biogenerator/medstation/on_deconstruction(disassembled)
	if(disassembled)
		new repacked_type(drop_location())

/obj/machinery/biogenerator/medstation/default_deconstruction_crowbar()
	return

// Deployable item for cargo for the medstation

/obj/item/wallframe/frontier_medstation
	name = "unmounted wall med-station"
	desc = "The innovative technology of a biogenerator to print medical supplies, but able to be mounted neatly on a wall out of the way."
	icon = 'modular_doppler/deforest_medical_items/icons/medstation.dmi'
	icon_state = "biogenerator_parts"
	w_class = WEIGHT_CLASS_NORMAL
	result_path = /obj/machinery/biogenerator/medstation
	pixel_shift = 29
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5,
		/datum/material/silver = SHEET_MATERIAL_AMOUNT * 3,
		/datum/material/gold = SHEET_MATERIAL_AMOUNT,
	)
