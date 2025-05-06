/obj/structure/window/green_glass_pane
	name = "green glass window"
	desc = "A handcrafted green glass window. At least you can still see through it."
	icon = 'modular_doppler/hearthkin/primitive_structures/icons/windows.dmi'
	icon_state = "green_glass"
	flags_1 = NONE
	obj_flags = parent_type::obj_flags | NO_DEBRIS_AFTER_DECONSTRUCTION
	fulltile = TRUE
	flags_1 = PREVENT_CLICK_UNDER_1

/datum/crafting_recipe/green_glass_pane
	name = "green glass window"
	result = /obj/structure/window/green_glass_pane
	time = 0.2 SECONDS
	reqs = list(
		/datum/reagent/iron = 5,
		/obj/item/stack/sheet/glass = 2,
	)
	category = CAT_STRUCTURE
