/obj/item/conveyor_sorter
	name = "conveyor sorter lister"
	desc = "A tool that is used to not only create the conveyor sorters, but give lists to the conveyor sorters."
	icon = 'modular_skyrat/modules/conveyor_sorter/icons/conveyor_sorter.dmi'
	icon_state = "lister"
	///the list of conveyor sorters spawned by
	var/list/spawned_sorters = list()
	///the list of things that are currently within the sorting list
	var/list/current_sort = list()

/obj/item/conveyor_sorter/Destroy()
	for(var/deleting_sorters in spawned_sorters)
		qdel(deleting_sorters)
	return ..()

/obj/item/conveyor_sorter/examine(mob/user)
	. = ..()
	. += span_notice("Use it to place down a conveyor sorter, up to three.")
	. += span_notice("Use Alt-Click to reset the sorting list.")
	. += span_notice("Attack things to attempt to add to the sorting list.")

/obj/item/conveyor_sorter/attack_self(mob/user, modifiers)
	if(length(spawned_sorters) >= 3)
		to_chat(user, span_warning("You may only have three spawned conveyor sorters!"))
		return
	var/obj/effect/decal/cleanable/conveyor_sorter/new_cs = new /obj/effect/decal/cleanable/conveyor_sorter(get_turf(src))
	new_cs.parent_item = src
	spawned_sorters += new_cs

/obj/item/conveyor_sorter/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(target == src)
		return ..()
	if(!proximity_flag)
		return ..()
	if(!ismovable(target))
		return ..()
	if(istype(target, /obj/effect/decal/cleanable/conveyor_sorter))
		return
	if(is_type_in_list(target, current_sort))
		to_chat(user, span_warning("[target] is already in [src]'s sorting list!"))
		return
	if(length(current_sort) >= 5)
		to_chat(user, span_warning("[src] already has five things within the sorting list!"))
		return
	current_sort += target.type
	to_chat(user, span_notice("[target] has been added to [src]'s sorting list."))

/obj/item/conveyor_sorter/AltClick(mob/user)
	visible_message("[src] pings, resetting its sorting list!")
	playsound(src, 'sound/machines/ping.ogg', 30, TRUE)
	current_sort = list()

/obj/effect/decal/cleanable/conveyor_sorter
	name = "conveyor sorter"
	desc = "A mark that will sort items out based on what they are."
	icon = 'modular_skyrat/modules/conveyor_sorter/icons/conveyor_sorter.dmi'
	icon_state = "sorter"
	layer = OBJ_LAYER
	plane = GAME_PLANE
	///the list of items that will be sorted to the sorted direction
	var/list/sorting_list = list()
	//the direction that the items in the sorting list will be moved to
	dir = NORTH
	///the parent conveyor sorter lister item, used for deletion
	var/obj/item/conveyor_sorter/parent_item

	light_range = 3
	light_color = COLOR_RED_LIGHT

/obj/effect/decal/cleanable/conveyor_sorter/Destroy()
	if(parent_item)
		parent_item.spawned_sorters -= src
		parent_item = null
	return ..()

/obj/effect/decal/cleanable/conveyor_sorter/examine(mob/user)
	. = ..()
	. += span_notice("Attack with conveyor sorter lister to set the sorting list.")
	. += span_notice("Slap with empty hands to change the sorting direction.")
	. += span_notice("Alt-Click to reset the sorting list.")
	. += span_notice("Ctrl-Click to remove.")

/obj/effect/decal/cleanable/conveyor_sorter/attack_hand(mob/living/user, list/modifiers)
	var/user_choice = tgui_input_list(user, "Choose which direction to sort to!", "Direction choice", list("North", "East", "South", "West"))
	if(!user_choice)
		return ..()
	switch(user_choice)
		if("North")
			setDir(NORTH)
		if("East")
			setDir(EAST)
		if("South")
			setDir(SOUTH)
		if("West")
			setDir(WEST)
	visible_message("[src] pings, updating its sorting direction!")
	playsound(src, 'sound/machines/ping.ogg', 30, TRUE)

/obj/effect/decal/cleanable/conveyor_sorter/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/conveyor_sorter))
		var/obj/item/conveyor_sorter/cs_item = W
		sorting_list = cs_item.current_sort
		visible_message("[src] pings, updating its sorting list!")
		playsound(src, 'sound/machines/ping.ogg', 30, TRUE)
		return
	else
		return ..()

/obj/effect/decal/cleanable/conveyor_sorter/AltClick(mob/user)
	visible_message("[src] pings, resetting its sorting list!")
	playsound(src, 'sound/machines/ping.ogg', 30, TRUE)
	sorting_list = list()

/obj/effect/decal/cleanable/conveyor_sorter/CtrlClick(mob/user)
	visible_message("[src] begins to ping violently!")
	playsound(src, 'sound/machines/ping.ogg', 30, TRUE)
	qdel(src)

/obj/effect/decal/cleanable/conveyor_sorter/on_entered(datum/source, atom/movable/AM)
	. = ..()
	if(is_type_in_list(AM, sorting_list) && !AM.anchored)
		AM.Move(get_step(src, dir))

/datum/design/conveyor_sorter
	name = "Conveyor Sorter"
	desc = "A wonderful item that can set markers and forcefully move stuff to a direction."
	id = "conveysorter"
	build_type = PROTOLATHE | AWAY_LATHE
	build_path = /obj/item/conveyor_sorter
	materials = list(/datum/material/iron = 500, /datum/material/plastic = 500)
	category = list("Equipment")
	departmental_flags = DEPARTMENTAL_FLAG_CARGO

/datum/techweb_node/conveyor_sorter
	id = "conveyorsorter"
	display_name = "Conveyor Sorter"
	description = "Finally, the ability to automatically sort stuff."
	prereq_ids = list("bluespace_basic", "engineering")
	design_ids = list(
		"conveysorter",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)
