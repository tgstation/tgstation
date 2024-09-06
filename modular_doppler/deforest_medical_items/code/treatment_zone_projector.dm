// Giant 3x3 tile warning hologram that tells people they should probably stand outside of it

/obj/structure/holosign/treatment_zone_warning
	name = "treatment zone indicator"
	desc = "A massive glowing holosign warning you to keep out of it, there's probably some important stuff happening in there!"
	icon = 'modular_doppler/deforest_medical_items/icons/telegraph_96x96.dmi'
	icon_state = "treatment_zone"
	layer = BELOW_OBJ_LAYER
	pixel_x = -32
	pixel_y = -32
	use_vis_overlay = FALSE

// Projector for the above mentioned treatment zone signs

/obj/item/holosign_creator/medical/treatment_zone
	name = "emergency treatment zone projector"
	desc = "A holographic projector that creates a large, clearly marked treatment zone hologram, which warns outsiders that they ought to stay out of it."
	holosign_type = /obj/structure/holosign/treatment_zone_warning
	creation_time = 1 SECONDS
	max_signs = 1

// Tech design for printing the projectors

/datum/design/treatment_zone_projector
	name = "Emergency Treatment Zone Projector"
	desc = "A holographic projector that creates a large, clearly marked treatment zone hologram, which warns outsiders that they ought to stay out of it."
	build_type = PROTOLATHE | AWAY_LATHE
	build_path = /obj/item/holosign_creator/medical/treatment_zone
	materials = list(
		/datum/material/iron = SMALL_MATERIAL_AMOUNT * 5,
		/datum/material/glass = SMALL_MATERIAL_AMOUNT * 5,
		/datum/material/silver = SMALL_MATERIAL_AMOUNT,
	)
	id = "treatment_zone_projector"
	category = list(
		RND_CATEGORY_TOOLS + RND_SUBCATEGORY_TOOLS_MEDICAL
	)
	departmental_flags = DEPARTMENT_BITFLAG_MEDICAL

/datum/techweb_node/holographics/New()
	. = ..()
	design_ids.Add("treatment_zone_projector")

// Adds the funny projector to medical borgs

/obj/item/robot_model/medical/New(loc, ...)
	. = ..()
	var/obj/item/holosign_creator/medical/treatment_zone/new_holosign = new(src)
	basic_modules.Add(new_holosign)
