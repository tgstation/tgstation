/obj/item/stack/rail_track
	name = "railroad tracks"
	singular_name = "railroad track"
	desc = "A primitive form of transportation. Place on any floor to start building a railroad."
	icon = 'modular_doppler/hearthkin/primitive_structures/icons/railroad.dmi'
	icon_state = "rail_item"
	merge_type = /obj/item/stack/rail_track

/obj/item/stack/rail_track/ten
	amount = 10

/obj/item/stack/rail_track/fifty
	amount = 50

/obj/item/stack/rail_track/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!isopenturf(interacting_with))
		return NONE
	var/turf/open/target_turf = get_turf(interacting_with)
	var/obj/structure/railroad/check_rail = locate() in target_turf
	if(check_rail || !use(1))
		return NONE
	to_chat(user, span_notice("You place [src] on [target_turf]."))
	new /obj/structure/railroad(target_turf)
	return ITEM_INTERACT_SUCCESS

/obj/structure/railroad
	name = "railroad track"
	desc = "A primitive form of transportation. You may see some rail carts on it."
	icon = 'modular_doppler/hearthkin/primitive_structures/icons/railroad.dmi'
	icon_state = "rail"
	anchored = TRUE

/obj/structure/railroad/Initialize(mapload)
	. = ..()
	for(var/obj/structure/railroad/rail in range(1))
		addtimer(CALLBACK(rail, /atom/proc/update_appearance), 5)

/obj/structure/railroad/Destroy()
	. = ..()
	for(var/obj/structure/railroad/rail in range(1))
		if(rail == src)
			continue
		addtimer(CALLBACK(rail, /atom/proc/update_appearance), 5)

/obj/structure/railroad/update_appearance(updates)
	icon_state = "rail"
	var/turf/src_turf = get_turf(src)
	for(var/direction in GLOB.cardinals)
		var/obj/structure/railroad/locate_rail = locate() in get_step(src_turf, direction)
		if(!locate_rail)
			continue
		icon_state = "[icon_state][direction]"
	return ..()

/obj/structure/railroad/crowbar_act(mob/living/user, obj/item/tool)
	tool.play_tool_sound(src)
	if(!do_after(user, 2 SECONDS, src))
		return
	tool.play_tool_sound(src)
	new /obj/item/stack/rail_track(get_turf(src))
	qdel(src)

/obj/vehicle/ridden/rail_cart
	name = "rail cart"
	desc = "A wonderful form of locomotion. It will only ride while on tracks. It does have storage"
	icon = 'modular_doppler/hearthkin/primitive_structures/icons/railroad.dmi'
	icon_state = "railcart"
	material_flags = MATERIAL_EFFECTS | MATERIAL_ADD_PREFIX | MATERIAL_GREYSCALE | MATERIAL_COLOR
	/// The mutable appearance used for the overlay over buckled mobs.
	var/mutable_appearance/railoverlay
	/// whether there is sand in the cart
	var/has_sand = FALSE

/obj/vehicle/ridden/rail_cart/examine(mob/user)
	. = ..()
	. += span_notice("<br><b>Alt-Click</b> to attach a rail cart to this cart.")
	. += span_notice("<br>Filling it with <b>10 sand</b> will allow it to be used as a planter!")

/obj/vehicle/ridden/rail_cart/Initialize(mapload)
	. = ..()
	attach_trailer()
	railoverlay = mutable_appearance(icon, "railoverlay", ABOVE_MOB_LAYER, src)
	AddElement(/datum/element/ridable, /datum/component/riding/vehicle/rail_cart)

	create_storage(max_total_storage = 21, max_slots = 21)

/obj/vehicle/ridden/rail_cart/post_buckle_mob(mob/living/M)
	. = ..()
	update_overlays()

/obj/vehicle/ridden/rail_cart/post_unbuckle_mob(mob/living/M)
	. = ..()
	update_overlays()

/obj/vehicle/ridden/rail_cart/update_overlays()
	. = ..()
	if(has_buckled_mobs())
		add_overlay(railoverlay)
	else
		cut_overlay(railoverlay)

/obj/vehicle/ridden/rail_cart/relaymove(mob/living/user, direction)
	var/obj/structure/railroad/locate_rail = locate() in get_step(src, direction)
	if(!canmove || !locate_rail)
		return FALSE
	if(is_driver(user))
		return relaydrive(user, direction)
	return FALSE

/obj/vehicle/ridden/rail_cart/click_alt(mob/user)
	attach_trailer()
	return CLICK_ACTION_SUCCESS

/obj/vehicle/ridden/rail_cart/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	atom_storage?.show_contents(user)

/obj/vehicle/ridden/rail_cart/attackby(obj/item/attacking_item, mob/user, params)
	if(istype(attacking_item, /obj/item/stack/ore/glass))
		var/obj/item/stack/ore/glass/use_item = attacking_item
		if(has_sand || !use_item.use(10))
			return ..()
		AddComponent(/datum/component/simple_farm, TRUE, TRUE, list(0, 16))
		has_sand = TRUE
		RemoveElement(/datum/element/ridable)
		return

	if(attacking_item.tool_behaviour == TOOL_SHOVEL)
		var/datum/component/remove_component = GetComponent(/datum/component/simple_farm)
		if(!remove_component)
			return ..()
		qdel(remove_component)
		has_sand = FALSE
		AddElement(/datum/element/ridable, /datum/component/riding/vehicle/rail_cart)
		return

	return ..()

/// searches the cardinal directions to add this cart to another cart's trailer
/obj/vehicle/ridden/rail_cart/proc/attach_trailer()
	if(trailer)
		remove_trailer()
		return
	for(var/direction in GLOB.cardinals)
		var/obj/vehicle/ridden/rail_cart/locate_cart = locate() in get_step(src, direction)
		if(!locate_cart || locate_cart.trailer == src)
			continue
		add_trailer(locate_cart)
		break

/datum/component/riding/vehicle/rail_cart
	vehicle_move_delay = 0.5
	ride_check_flags = RIDER_NEEDS_LEGS | RIDER_NEEDS_ARMS | UNBUCKLE_DISABLED_RIDER

/datum/component/riding/vehicle/rail_cart/handle_specials()
	. = ..()
	set_riding_offsets(RIDING_OFFSET_ALL, list(TEXT_NORTH = list(0, 13), TEXT_SOUTH = list(0, 13), TEXT_EAST = list(0, 13), TEXT_WEST = list(0, 13)))
	set_vehicle_dir_layer(SOUTH, OBJ_LAYER)
	set_vehicle_dir_layer(NORTH, OBJ_LAYER)
	set_vehicle_dir_layer(EAST, OBJ_LAYER)
	set_vehicle_dir_layer(WEST, OBJ_LAYER)
