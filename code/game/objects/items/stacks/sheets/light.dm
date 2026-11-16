/obj/item/stack/light_w
	name = "wired glass tile"
	singular_name = "wired glass floor tile"
	desc = "A glass tile, which is wired, somehow."
	icon = 'icons/obj/tiles.dmi'
	icon_state = "glass_wire"
	w_class = WEIGHT_CLASS_NORMAL
	force = 3
	throwforce = 5
	throw_speed = 3
	throw_range = 7
	obj_flags = CONDUCTS_ELECTRICITY
	max_amount = 60
	mats_per_unit = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 1.05, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 1.05)
	merge_type = /obj/item/stack/light_w

/obj/item/stack/light_w/grind_results()
	return list(/datum/reagent/silicon = 20, /datum/reagent/copper = 5)

/obj/item/stack/light_w/examine(mob/user)
	. = ..()
	. += span_warning("\The [src] looks unfinished, add <b>iron</b> to complete it.")

/obj/item/stack/light_w/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/stack/sheet/iron))
		return ..()
	var/obj/item/stack/sheet/iron/steel = tool
	if(!steel.use(1))
		to_chat(user, span_warning("You need one iron sheet to finish the light tile!"))
		return ITEM_INTERACT_BLOCKING

	var/obj/item/stack/tile/light/finished_tiles = new(user.drop_location())
	to_chat(user, span_notice("You make a light tile."))
	if(!QDELETED(finished_tiles))
		finished_tiles.add_fingerprint(user)
	use(1)
	return ITEM_INTERACT_SUCCESS

/obj/item/stack/light_w/wirecutter_act(mob/living/user, obj/item/I)
	. = ..()
	var/atom/Tsec = user.drop_location()
	var/obj/item/stack/cable_coil/CC = new (Tsec, 5)
	if (!QDELETED(CC))
		CC.add_fingerprint(user)
	var/obj/item/stack/sheet/glass/G = new (Tsec)
	if (!QDELETED(G))
		G.add_fingerprint(user)
	use(1)
