/obj/item/reagent_containers/cooler_jug
	name = "cooler jug"
	desc = "A huge, unwieldy jug. Serves as the life force for liquid coolers. It smells like freshly cooled plastic."
	icon = 'icons/obj/medical/chemical_tanks.dmi'
	icon_state = "cooler_jug"
	volume = 200
	custom_materials = list(/datum/material/plastic = SHEET_MATERIAL_AMOUNT * 4)
	initial_reagent_flags = REFILLABLE | DRAINABLE | INJECTABLE | DRAWABLE | TRANSPARENT | NO_SPLASH
	spillable = TRUE
	has_variable_transfer_amount = FALSE
	interaction_flags_click = NEED_DEXTERITY
	fill_icon_state = "cooler_jug_overlay"
	fill_icon_thresholds = list(25, 50, 75, 100)
	obj_flags = UNIQUE_RENAME
	w_class = WEIGHT_CLASS_BULKY

/obj/item/reagent_containers/cooler_jug/water
	name = "water jug"
	desc = "An elegant-looking water cooler jug. There's a water cooler out there, somewhere, waiting to be reunited with this. The jug's mouth smells intoxicatingly stale and metallic."
	list_reagents = list(/datum/reagent/water = 200)

/obj/item/reagent_containers/cooler_jug/punch
	name = "punch jug"
	desc = "A jug meant for storing fruit punch. It's covered in dozens of warning labels and scary-looking symbols you don't recognize. The smell of sweet punch sticks to the mouth of the jug."
	list_reagents = list(/datum/reagent/consumable/fruit_punch = 200)
