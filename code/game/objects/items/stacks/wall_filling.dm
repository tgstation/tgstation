// Wall-fillings; items you can re-skin in hand and place onto griders to create different wall types.

/obj/item/stack/wall_filling
	name = "wall filling"
	singular_name = "wall filler"
	desc = "An empty wall filling. This should not exist."
	//wall-fillings will generaly use the inhands of the sheet they are made from.
	lefthand_file = 'icons/mob/inhands/items/sheets_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items/sheets_righthand.dmi'
	icon = 'icons/obj/stack_objects.dmi'
	w_class = WEIGHT_CLASS_NORMAL
	force = 2
	throwforce = 2
	throw_speed = 2
	throw_range = 5
	max_amount = 60
	novariants = TRUE
	material_flags = MATERIAL_EFFECTS
	usable_for_construction = TRUE
	merge_type = /obj/item/stack/wall_filling
	/// the main thing it exists for, list of fillings to reskin into.
	var/list/wall_reskin_types
	/// what it should be broken down back into when using a welder. Provided as a path.
	var/made_from

/obj/item/stack/wall_filling/examine(mob/user)
	. = ..()
	. += span_notice("Use while in your hand to change what type of [src] you want.")
	if(throwforce && !is_cyborg) //do not want to divide by zero or show the message to borgs who can't throw
		var/damage_value
		switch(ceil(MAX_LIVING_HEALTH / throwforce)) //throws to crit a human
			if(1 to 3)
				damage_value = "superb"
			if(4 to 6)
				damage_value = "great"
			if(7 to 9)
				damage_value = "good"
			if(10 to 12)
				damage_value = "fairly decent"
			if(13 to 15)
				damage_value = "mediocre"
		if(!damage_value)
			return
		. += span_notice("Those could work as a [damage_value] throwing weapon.")

/obj/item/stack/wall_filling/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if (tool.tool_behaviour != TOOL_WELDER)
		return ..()

	if(!made_from)
		to_chat(user, span_warning("You can not reform this!"))
		stack_trace("A wall filling of type [type] doesn't have its made_from set.")
		return
	if(!tool.use_tool(src, user, 0, volume=40))
		return
	var/obj/item/new_item = new made_from(user.drop_location(), 2)
	user.visible_message(span_notice("[user] shaped [src] into [new_item] with [tool]."), \
		span_notice("You shaped [src] into [new_item] with [tool]."), \
		span_hear("You hear welding."))
	var/holding = user.is_holding(src)
	use(1)
	if(holding && QDELETED(src))
		user.put_in_hands(new_item)
	return ITEM_INTERACT_SUCCESS

GLOBAL_LIST_EMPTY(wall_reskin_lists)

/**
 * Yup, literally copied over from tile reskinning, except we don't need a dir as walls don't rotate, so, that much simpler.
 */
/obj/item/stack/wall_filling/proc/wall_reskin_list(list/values)
	var/string_id = values.Join("-")
	. = GLOB.wall_reskin_lists[string_id]
	if(.)
		return
	for(var/path in values)
		var/obj/item/stack/wall_filling/type_cast_path = path
		values[path] = image(icon = initial(type_cast_path.icon), icon_state = initial(type_cast_path.icon_state))
	return GLOB.wall_reskin_lists[string_id] = values

/obj/item/stack/wall_filling/attack_self(mob/user)
	var/obj/item/stack/wall_filling/choice = show_radial_menu(user, src, wall_reskin_types, radius = 48, require_near = TRUE)
	if(!choice || choice == type)
		return
	choice = new choice(user.drop_location(), amount)
	moveToNullspace()
	if(!QDELETED(choice))
		user.put_in_active_hand(choice)
	qdel(src)

/obj/item/stack/wall_filling/Initialize(mapload, new_amount, merge = TRUE, list/mat_override=null, mat_amt=1)
	. = ..()
	if(wall_reskin_types)
		wall_reskin_types = wall_reskin_list(wall_reskin_types)

/obj/item/stack/wall_filling/plastitanium
	name = "plastitanium wall filling"
	singular_name = "plastitanium wall filler"
	desc = "A filling for a standard plastitanium wall."
	icon_state = "plastitanium-wall-fill"
	inhand_icon_state = "sheet-plastitanium"
	mats_per_unit = list(/datum/material/alloy/plastitanium=SHEET_MATERIAL_AMOUNT*2)
	merge_type = /obj/item/stack/wall_filling/plastitanium
	made_from = /obj/item/stack/sheet/mineral/plastitanium
	wall_reskin_types = list(
		/obj/item/stack/wall_filling/plastitanium/basic,
		/obj/item/stack/wall_filling/plastitanium/survivalpod,
		/obj/item/stack/wall_filling/plastitanium/pod,
		/obj/item/stack/wall_filling/plastitanium/redpod,
	)

/obj/item/stack/wall_filling/plastitanium/basic
	merge_type = /obj/item/stack/wall_filling/plastitanium/basic

/obj/item/stack/wall_filling/plastitanium/survivalpod
	name = "survival pod wall filling"
	singular_name = "survival pod wall filler"
	icon_state = "survivalpod-wall-fill"
	desc = "A filling for a survival pod wall, often usen for mining in hostile enviroments."
	merge_type = /obj/item/stack/wall_filling/plastitanium/survivalpod

/obj/item/stack/wall_filling/plastitanium/pod
	name = "dark shuttle wall filling"
	singular_name = "dark shuttle wall filler"
	icon_state = "pod-wall-fill"
	desc = "A filling for a dark shuttle wall. Dark mode on."
	merge_type = /obj/item/stack/wall_filling/plastitanium/pod

/obj/item/stack/wall_filling/plastitanium/redpod
	name = "red dark shuttle wall filling"
	singular_name = "red dark shuttle wall filler"
	icon_state = "redpod-wall-fill"
	desc = "A filling for a red dark shuttle wall. Quite the menacing vibe."
	merge_type = /obj/item/stack/wall_filling/plastitanium/redpod
