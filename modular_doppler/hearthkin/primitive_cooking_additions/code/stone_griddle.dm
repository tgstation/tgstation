/obj/machinery/griddle/stone
	name = "stone griddle"
	desc = "You could probably cook an egg on this... the griddle slab looks very unsanitary."
	icon = 'modular_doppler/hearthkin/primitive_cooking_additions/icons/stone_kitchen_machines.dmi'
	icon_state = "griddle1_off"
	density = TRUE
	pass_flags_self = PASSMACHINE | PASSTABLE| LETPASSTHROW // It's roughly the height of a table.
	layer = BELOW_OBJ_LAYER
	use_power = FALSE
	circuit = null
	resistance_flags = FIRE_PROOF
	processing_flags = START_PROCESSING_MANUALLY
	variant = 1

/obj/machinery/griddle/Initialize(mapload)
	. = ..()
	grill_loop = new(src, FALSE)
	if(isnum(variant))
		variant = 1

/obj/machinery/griddle/stone/examine(mob/user)
	. = ..()

	. += span_notice("It can be taken apart with a <b>crowbar</b>.")

/obj/machinery/griddle/stone/crowbar_act(mob/living/user, obj/item/tool)
	user.balloon_alert_to_viewers("disassembling...")
	if(!tool.use_tool(src, user, 2 SECONDS, volume = 100))
		return
	new /obj/item/stack/sheet/mineral/stone(drop_location(), 5)
	deconstruct(TRUE)
	return ITEM_INTERACT_SUCCESS
