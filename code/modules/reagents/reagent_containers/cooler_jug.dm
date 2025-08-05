/obj/item/reagent_containers/cooler_jug
	name = "cooler jug"
	desc = "A huge, unwieldy jug. Serves as the life force for liquid coolers. It smells like freshly cooled plastic."
	icon = 'icons/obj/medical/chemical_tanks.dmi'
	icon_state = "cooler_jug"
	volume = 200
	reagent_flags = REFILLABLE | DRAINABLE | INJECTABLE | DRAWABLE | TRANSPARENT
	spillable = TRUE
	has_variable_transfer_amount = FALSE
	interaction_flags_click = NEED_DEXTERITY
	fill_icon_state = "cooler_jug_overlay"
	fill_icon_thresholds = list(25, 50, 75, 100)
	obj_flags = UNIQUE_RENAME
