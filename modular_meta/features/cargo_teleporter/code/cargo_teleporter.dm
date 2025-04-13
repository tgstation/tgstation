GLOBAL_LIST_EMPTY(cargo_marks)
#define MAX_CARGO_MARKER 3

/obj/item/cargo_teleporter
	name = "cargo teleporter"
	desc = "A device that can set a certain number of markers, allowing items to be teleported to the set markers."
	icon = 'modular_meta/features/cargo_teleporter/icons/cargo_teleporter.dmi'
	icon_state = "cargo-off"
	///the list of markers spawned by this item
	var/list/marker_children = list()

	COOLDOWN_DECLARE(use_cooldown)

/obj/item/cargo_teleporter/examine(mob/user)
	. = ..()
	. += span_notice("<hr>Use in-hand to place marker.")
	. += span_notice("<hr>Other empty hand pressing to remove all markers!")

/obj/item/cargo_teleporter/Destroy()
	if(length(marker_children))
		for(var/obj/effect/decal/cleanable/cargo_mark/destroy_children in marker_children)
			destroy_children.parent_item = null
			qdel(destroy_children)
	return ..()

/obj/item/cargo_teleporter/attack_self(mob/user, modifiers)
	if(length(marker_children) >= MAX_CARGO_MARKER)
		to_chat(user, span_warning("Marker limit reached."))
		return
	to_chat(user, span_notice("Installing a marker."))
	var/obj/effect/decal/cleanable/cargo_mark/spawned_marker = new /obj/effect/decal/cleanable/cargo_mark(get_turf(src))
	playsound(src, 'sound/machines/click.ogg', 50)
	spawned_marker.parent_item = src
	marker_children += spawned_marker

/obj/item/cargo_teleporter/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(length(marker_children))
		for(var/obj/effect/decal/cleanable/cargo_mark/destroy_children in marker_children)
			qdel(destroy_children)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/cargo_teleporter/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(!proximity_flag)
		return ..()
	if(target == src)
		return ..()
	if(!COOLDOWN_FINISHED(src, use_cooldown))
		to_chat(user, span_warning("[capitalize(src.name)] recharges!"))
		return
	var/choice = tgui_input_list(user, "To which mark will we teleport this?", "Selecting a marker", GLOB.cargo_marks)
	if(!choice)
		return ..()
	if(get_dist(user, target) > 1)
		return
	var/turf/moving_turf = get_turf(choice)
	var/turf/target_turf = get_turf(target)
	for(var/check_content in target_turf.contents)
		icon_state = "cargo-on"
		if(isobserver(check_content))
			continue
		if(!ismovable(check_content))
			continue
		var/atom/movable/movable_content = check_content
		if(isliving(movable_content))
			to_chat(user, span_warning("Teleport displays an error: This is a creature!"))
			continue
		if(length(movable_content.get_all_contents_type(/mob/living)))
			to_chat(user, span_warning("Teleport displays an error: There is a creature inside!"))
			continue
		if(movable_content.anchored)
			to_chat(user, span_warning("Teleport displays an error: This is bolted to the floor!"))
			continue
		do_teleport(movable_content, moving_turf, asoundout = 'sound/items/modsuit/tem_shot.ogg')
		icon_state = "cargo-off"
	new /obj/effect/decal/cleanable/ash(target_turf)
	COOLDOWN_START(src, use_cooldown, 1 SECONDS)

/datum/design/cargo_teleporter
	name = "сargo teleporter"
	desc = "A device that can place markers and teleport items to those markers."
	id = "cargotele"
	build_type = PROTOLATHE
	materials = list(/datum/material/iron = HALF_SHEET_MATERIAL_AMOUNT*5, /datum/material/plastic = SMALL_MATERIAL_AMOUNT*5, /datum/material/bluespace = SHEET_MATERIAL_AMOUNT*3)
	build_path = /obj/item/cargo_teleporter
	category = list(
		RND_CATEGORY_COMPUTER + RND_SUBCATEGORY_COMPUTER_CARGO
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO

/obj/effect/decal/cleanable/cargo_mark
	name = "cargo mark"
	desc = "A mark left by a cargo teleporter that allows things to be teleported to their destination. Can be removed by a cargo teleporter."
	icon = 'icons/effects/effects.dmi'
	icon_state = "eating_zone"
	///the reference to the item that spawned the cargo mark
	var/obj/item/cargo_teleporter/parent_item

	light_range = 3
	light_color = COLOR_VIVID_YELLOW

/obj/effect/decal/cleanable/cargo_mark/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/cargo_teleporter))
		to_chat(user, span_notice("Remove [src] using [W]."))
		playsound(src, 'sound/machines/click.ogg', 50)
		qdel(src)
		return
	return ..()

/obj/effect/decal/cleanable/cargo_mark/Destroy()
	if(parent_item)
		parent_item.marker_children -= src
	GLOB.cargo_marks -= src
	return ..()

/obj/effect/decal/cleanable/cargo_mark/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	var/area/src_area = get_area(src)
	name = "[src_area.name] #[rand(100000,999999)]"
	GLOB.cargo_marks += src
