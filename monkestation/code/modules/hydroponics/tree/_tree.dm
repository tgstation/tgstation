/obj/machinery/mother_tree
	name = "Strange Tree"
	desc = "A strange tree sent by Nano-Transen, I'd be best if I kept this alive."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "hydrotray3"
	density = TRUE
	layer = ABOVE_ALL_MOB_LAYER -0.1

	///the list of level choices we currently have
	var/list/level_choices = list()
	///the component attached to the tree called often enough to justify defining it
	var/datum/component/botany_tree/attached_component

	var/current_leaf_stage = 2
	var/current_trunk_style = 1
	var/current_fruit_style = 1

	var/obj/effect/tree/trunk/trunk
	var/obj/effect/tree/leaf/leaves
	var/obj/effect/tree/fruit/fruits
	var/obj/effect/tree/accessory/accessories

	var/trunk_color = "#64483F"
	var/leaf_color = "#95B458"
	var/sapling_color = "#95B458"

	var/debug = FALSE

	var/list/stored_fruits = list()

/obj/machinery/mother_tree/Initialize(mapload)
	. = ..()
	trunk = new()
	leaves = new()

	trunk.icon_state = "sapling_1"

	trunk.color = sapling_color
	leaves.color = leaf_color

	src.vis_contents += trunk
	src.vis_contents += leaves
	AddComponent(/datum/component/botany_tree)
	attached_component = src.GetComponent(/datum/component/botany_tree)

	return INITIALIZE_HINT_LATELOAD

/obj/machinery/mother_tree/LateInitialize()
	. = ..()
	for(var/obj/machinery/hydroponics/located_hydroponics in range(attached_component.pulse_range))
		located_hydroponics.connected_tree = src
		attached_component.connected_trays |= located_hydroponics

/obj/machinery/mother_tree/update_overlays()
	. = ..()
	if(attached_component.current_level + 1 >= 5)
		trunk.icon_state = "trunk_[current_trunk_style]"
		leaves.icon_state = "leaf_[current_trunk_style]_[current_leaf_stage]"

		if(current_trunk_style == 2)
			trunk.pixel_x = -20
			leaves.pixel_x = -20
			attached_component.y_offset = 2.1
		else
			attached_component.y_offset = 2

		trunk.color = trunk_color
		leaves.color = leaf_color

	if(fruits)
		. += fruits
/obj/machinery/mother_tree/examine(mob/user)
	. = ..()
	.+= "Unfufilled Level Requirements:"
	for(var/item in attached_component.unfufilled_requirements)
		var/obj/item/seeds/listed_seed = item
		.+= "[initial(listed_seed.name)]"

/obj/machinery/mother_tree/add_context(atom/source, list/context, obj/item/held_item, mob/user)
	context[SCREENTIP_CONTEXT_LMB] = "Pick Fruit"
	context[SCREENTIP_CONTEXT_RMB] = "Choose Level Up Perk"
	context[SCREENTIP_CONTEXT_ALT_LMB] = "Attempt Requirement Reroll"
	return CONTEXTUAL_SCREENTIP_SET

/obj/machinery/mother_tree/attack_hand(mob/living/user)
	. = ..()
	if(!(user.istate & ISTATE_HARM))
		return
	if(stored_fruits.len)
		var/obj/item/picked_fruit = pick(stored_fruits)
		if(Adjacent(user) && !issiliconoradminghost(user))
			if (!user.put_in_hands(picked_fruit))
				picked_fruit.forceMove(drop_location())
		else
			picked_fruit.forceMove(drop_location())
		stored_fruits -= picked_fruit

/obj/machinery/mother_tree/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(!attached_component.unfufilled_requirements.len || debug)
		level_choices = attached_component.trigger_level()
		run_choice(user)
		return
	if(level_choices.len)
		run_choice(user)
		return

/obj/machinery/mother_tree/AltClick(mob/user)
	. = ..()
	if(!attached_component.reroll())
		to_chat(user, "Sorry you have already rerolled this level.")


/obj/machinery/mother_tree/proc/run_choice(mob/user)
	var/datum/tree_node/choice = input(user, "Select a trait for the tree", "Strange Tree") as null|anything in level_choices
	if(!choice)
		return
	if(choice.visual_change)
		if(choice.color_change_trunk)
			trunk_color = choice.color_change_trunk
		if(choice.color_change_leaf)
			leaf_color = choice.color_change_leaf
		if(choice.visual_change == "Trunk")
			current_trunk_style = choice.visual_numerical_change
		update_overlays()

	attached_component.handle_added_node(choice)
	attached_component.handle_levelup()
	handle_levelup()
	level_choices = list()

/obj/machinery/mother_tree/proc/handle_levelup()
	var/current_level = attached_component.current_level
	current_leaf_stage = 1 + round(current_level / 5)

/obj/effect/tree
	icon = 'monkestation/icons/obj/mother_tree.dmi'
	layer = ABOVE_ALL_MOB_LAYER
	pixel_x = -16
	pixel_y = 10
	appearance_flags = RESET_ALPHA | RESET_COLOR | RESET_TRANSFORM | KEEP_APART | TILE_BOUND
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	///offsets for where the sprite should be placed goes x,y
	var/list/offsets_for_sprites

/obj/effect/tree/trunk
	icon_state = "trunk_1"

/obj/effect/tree/leaf
	icon_state = "none"

/obj/effect/tree/fruit
	var/list/stored_images
	offsets_for_sprites = list(
		//REGULAR TREE OFFSETS
		list(
			list(0,5,7,5,-12,24,11,-13,-22),
			list(0,5,3,12,15,-10,-16,-17,-5)
		),
		//STRANGE TREE OFFSETS
		list(
			list(4,0,17,17,22-14,-17),
			list(-1,19,19,8,4,2,15)
		)
	)
