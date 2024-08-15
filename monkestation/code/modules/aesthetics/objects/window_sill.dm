/obj/structure/window_sill
	icon = 'monkestation/icons/obj/structures/window/window_sill.dmi'
	base_icon_state = "window_sill"
	icon_state = "window_sill-0"
	layer = ABOVE_OBJ_LAYER - 0.02
	canSmoothWith =  SMOOTH_GROUP_WINDOW_SILL + SMOOTH_GROUP_AIRLOCK + SMOOTH_GROUP_WALLS
	smoothing_flags = SMOOTH_BITMASK | SMOOTH_OBJ
	smoothing_groups = SMOOTH_GROUP_WINDOW_SILL
	smooth_adapters = SMOOTH_ADAPTERS_WALLS
	pass_flags_self = PASSTABLE | LETPASSTHROW
	density = TRUE
	anchored = TRUE

/obj/structure/window_sill/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/climbable)

/obj/structure/window_sill/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	deconstruct()

/obj/structure/window_sill/deconstruct(disassembled = TRUE, wrench_disassembly = 0)
	new /obj/item/stack/sheet/iron(get_turf(src))
	qdel(src)

/obj/structure/window_sill/attackby(obj/item/attacking_item, mob/user, params)
	. = ..()
	if(!isstack(attacking_item))
		return FALSE
	var/obj/item/stack/stack_item = attacking_item
	if(istype(attacking_item, /obj/item/stack/sheet/glass))
		if(stack_item.amount < 2)
			return FALSE
		if(do_after(user, 2 SECONDS, src))
			new /obj/structure/window/fulltile(get_turf(src))
			stack_item.amount -= 2
			return TRUE

	if(istype(attacking_item, /obj/item/stack/sheet/rglass))
		if(stack_item.amount < 2)
			return FALSE
		if(do_after(user, 2 SECONDS, src))
			new /obj/structure/window/reinforced/fulltile(get_turf(src))
			stack_item.amount -= 2
			return TRUE

	if(istype(attacking_item, /obj/item/stack/sheet/plasmarglass))
		if(stack_item.amount < 2)
			return FALSE
		if(do_after(user, 2 SECONDS, src))
			new /obj/structure/window/reinforced/plasma/fulltile(get_turf(src))
			stack_item.amount -= 2
			return TRUE

	if(istype(attacking_item, /obj/item/stack/sheet/plasmaglass))
		if(stack_item.amount < 2)
			return FALSE
		if(do_after(user, 2 SECONDS, src))
			new /obj/structure/window/fulltile(get_turf(src))
			stack_item.amount -= 2
			return TRUE

	if(istype(attacking_item, /obj/item/stack/rods))
		if(stack_item.amount < 2)
			return FALSE
		if(do_after(user, 2 SECONDS, src))
			new /obj/structure/grille/window_sill(get_turf(src))
			stack_item.amount -= 2
			return TRUE

//merges adjacent full-tile windows into one
/obj/structure/window_sill/update_overlays(updates=ALL)
	. = ..()
	if((updates & UPDATE_SMOOTHING) && (smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK)))
		QUEUE_SMOOTH(src)
