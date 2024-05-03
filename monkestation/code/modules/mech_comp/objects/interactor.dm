/obj/item/mcobject/interactor
	name = "interaction component"
	desc = "will either right or left click with the given item."

	icon = 'monkestation/icons/obj/mechcomp.dmi'
	icon_state = "comp_collector"
	base_icon_state = "comp_collector"

	///should we right or left click
	var/right_clicks = FALSE
	///the dummy human that is doing the clicking
	var/mob/living/carbon/human/dummy/dummy_human
	///image of the held item displayed over the component to see whats going on
	var/obj/item/held_item
	///the connected storage component to act as an inventory to grab from
	var/obj/item/mcobject/messaging/storage/connected_storage
	///the current stored direction used for interaction
	var/stored_dir = NORTH
	///the interaction range defaults to ontop of itself
	var/range = FALSE

/obj/item/mcobject/interactor/Initialize(mapload)
	. = ..()
	MC_ADD_CONFIG("Swap Click", swap_click)
	MC_ADD_CONFIG("Swap Range", set_range)
	MC_ADD_CONFIG("Change Direction", change_dir)
	MC_ADD_INPUT("swap click", swap_click_input)
	MC_ADD_INPUT("replace", replace_from_storage)
	MC_ADD_INPUT("drop", drop)
	MC_ADD_INPUT("change direction", change_dir_input)
	MC_ADD_INPUT("interact", use_on)

	dummy_human = new(src.loc)
	dummy_human.forceMove(src)
	dummy_human.name = "interaction component"

/obj/item/mcobject/interactor/multitool_act_secondary(mob/living/user, obj/item/tool)
	var/obj/item/multitool/multitool = tool
	if(!multitool.component_buffer)
		return
	if(!istype(multitool.component_buffer, /obj/item/mcobject/messaging/storage))
		return
	connected_storage = multitool.component_buffer
	say("Successfully linked to storage component")

/obj/item/mcobject/interactor/proc/drop(datum/mcmessage/input)
	if(!input)
		return
	if(connected_storage)
		connected_storage.attempt_insert(held_item)
	else
		held_item.forceMove(get_turf(src))
	held_item = null
	update_appearance()
	return TRUE

/obj/item/mcobject/interactor/proc/replace_from_storage(datum/mcmessage/input)
	var/input_number = text2num(input.cmd)
	if(isnull(input_number))
		return

	if(!connected_storage)
		say("ERROR: No connected storage components!")
		return
	if(!connected_storage.contents[input_number])
		return

	var/obj/item/listed_item = connected_storage.contents[input_number]
	if(held_item)
		connected_storage.attempt_insert(held_item)
		held_item = null
	held_item = listed_item
	dummy_human.put_in_l_hand(listed_item)
	update_appearance()
	return TRUE

/obj/item/mcobject/interactor/proc/change_dir_input(datum/mcmessage/input)
	var/input_number = text2num(input.cmd)
	if(isnull(input_number) || input_number > 8)
		return
	if(input_number in list(3, 5, 6, 7))
		return
	stored_dir = input_number
	return TRUE

/obj/item/mcobject/interactor/proc/set_range(mob/user, obj/item/tool)
	range = !range
	say("SUCCESS: Will now interact [range ? "1 tile away from the component" : "on top of the component"]")
	return TRUE

/obj/item/mcobject/interactor/proc/swap_click(mob/user, obj/item/tool)
	right_clicks = !right_clicks
	say("Changed click type to: [right_clicks ? "Right Clicks" : "Left Clicks"]")
	return TRUE

/obj/item/mcobject/interactor/proc/change_dir(mob/user, obj/item/tool)
	var/list/directions_listed = list("North" = 1, "South" = 2, "East" = 4, "West" = 8)
	var/direction_choice = tgui_input_list(user, "Select the direction to use", "Interactor Component", list("North", "South", "East", "West"))
	if(!direction_choice)
		return
	stored_dir = directions_listed[direction_choice]
	return TRUE

/obj/item/mcobject/interactor/proc/swap_click_input(datum/mcmessage/input)
	if(!input)
		return
	right_clicks = !right_clicks
	say("Changed click type to: [right_clicks ? "Right Clicks" : "Left Clicks"]")
	return TRUE

/obj/item/mcobject/interactor/proc/use_on(datum/mcmessage/input)
	set waitfor = FALSE

	if(!input)
		return
	var/turf/selected_turf = get_turf(src)
	if(range)
		selected_turf = get_step(src, stored_dir)

	for(var/atom/movable/listed_atom in selected_turf)
		if(dummy_human == listed_atom || src == listed_atom)
			continue

		if(listed_atom.type in typesof(/obj/item/mcobject))
			continue

		if(!held_item)
			if(!right_clicks)
				listed_atom.attack_hand(dummy_human)
				if(istype(listed_atom, /obj/item) && !held_item) // yoink it if its an item
					held_item = listed_atom
			else
				dummy_human.istate |= ISTATE_SECONDARY
				listed_atom.attack_hand_secondary(dummy_human)
				dummy_human.istate &= ~ISTATE_SECONDARY
		else
			if(!right_clicks)
				held_item.melee_attack_chain(dummy_human, listed_atom)
			else
				dummy_human.istate |= ISTATE_SECONDARY
				held_item.melee_attack_chain(dummy_human, listed_atom)
				dummy_human.istate &= ~ISTATE_SECONDARY

	flash()

/obj/item/mcobject/interactor/update_overlays()
	. = ..()
	var/mutable_appearance/held_image = mutable_appearance(held_item.icon, held_item.icon_state, ABOVE_OBJ_LAYER, null, FLOAT_PLANE, 70)
	held_image.color = LIGHT_COLOR_BLUE
	. += held_image

/obj/item/mcobject/interactor/attackby_secondary(obj/item/weapon, mob/user, params)
	. = ..()
	if(held_item)
		if(connected_storage)
			connected_storage.attempt_insert(held_item)
		else
			held_item.forceMove(get_turf(src))
		held_item = null
	held_item = weapon
	dummy_human.put_in_l_hand(weapon)
	update_appearance()
