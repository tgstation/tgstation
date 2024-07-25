/obj/item/conveyor_sorter
	name = "conveyor sorter lister"
	desc = "A tool that is used to not only create the conveyor sorters, but give lists to the conveyor sorters."
	icon = 'monkestation/code/modules/conveyor_sorter/icons/conveyor_sorter.dmi'
	icon_state = "lister"
	///the list of conveyor sorters spawned by
	var/list/spawned_sorters = list()
	///the list of things that are currently within the sorting list
	var/list/current_sort = list()
	///This controls the maximum amount of sorters that can be spawned by one lister item.
	var/max_sorters = 4
	///This controls the maximum amount of items that can be added to the sorting list.
	var/max_items = 5
	/// This is used for the improved sorter, so that it can use the improved sorter type instead of the normal sorter type.
	var/conveyor_type = /obj/effect/decal/conveyor_sorter

/obj/item/conveyor_sorter/Destroy()
	for(var/deleting_sorters in spawned_sorters)
		qdel(deleting_sorters)
	return ..()

/obj/item/conveyor_sorter/examine(mob/user)
	. = ..()
	. += span_notice("Use it to place down a conveyor sorter, up to a limit of <b>[max_sorters]</b>.")
	. += span_notice("This sorter can sort up to <b>[max_items]</b> Items.")
	. += span_notice("Use Alt-Click to reset the sorting list.")
	. += span_notice("Attack things to attempt to add to the sorting list.")

/obj/item/conveyor_sorter/attack_self(mob/user, modifiers)
	if(length(spawned_sorters) >= max_sorters)
		to_chat(user, span_warning("You may only have [max_sorters] spawned conveyor sorters!"))
		return
	var/obj/effect/decal/conveyor_sorter/new_cs = new conveyor_type(get_turf(src))
	new_cs.parent_item = src
	new_cs.sorting_list = current_sort
	spawned_sorters += new_cs

/obj/item/conveyor_sorter/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	if(target == src)
		return ..()
	if(!proximity_flag)
		return ..()
	if(!ismovable(target))
		return ..()
	if(istype(target, /obj/effect/decal/conveyor_sorter))
		return
	if(is_type_in_list(target, current_sort))
		to_chat(user, span_warning("[target] is already in [src]'s sorting list!"))
		return
	if(length(current_sort) >= max_items)
		to_chat(user, span_warning("[src] already has [max_items] things within the sorting list!"))
		return
	current_sort += target.type
	to_chat(user, span_notice("[target] has been added to [src]'s sorting list."))

/obj/item/conveyor_sorter/AltClick(mob/user)
	visible_message("[src] pings, resetting its sorting list!")
	playsound(src, 'sound/machines/ping.ogg', 30, TRUE)
	current_sort = list()

/obj/effect/decal/conveyor_sorter
	name = "conveyor sorter"
	desc = "A mark that will sort items out based on what they are."
	icon = 'monkestation/code/modules/conveyor_sorter/icons/conveyor_sorter.dmi'
	icon_state = "sorter"
	layer = OBJ_LAYER
	plane = GAME_PLANE
	///the list of items that will be sorted to the sorted direction
	var/list/sorting_list = list()
	//the direction that the items in the sorting list will be moved to
	dir = NORTH
	///the parent conveyor sorter lister item, used for deletion
	var/obj/item/conveyor_sorter/parent_item
	var/list/directions =  list("North", "East", "South", "West") //This is used for the tgui input list, so that the user can choose which direction to sort to.
	/// To prevent spam
	COOLDOWN_DECLARE(use_cooldown)

	light_outer_range = 3
	light_color = COLOR_RED_LIGHT

/obj/effect/decal/conveyor_sorter/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/decal/conveyor_sorter/Destroy()
	if(parent_item)
		parent_item.spawned_sorters -= src
		parent_item = null
	return ..()

/obj/effect/decal/conveyor_sorter/examine(mob/user)
	. = ..()
	. += span_notice("Attack with conveyor sorter lister to set the sorting list.")
	. += span_notice("Slap with empty hands to change the sorting direction.")
	. += span_notice("Alt-Click to reset the sorting list.")
	. += span_notice("Ctrl-Click to remove.")

/obj/effect/decal/conveyor_sorter/attack_hand(mob/living/user, list/modifiers)
	var/user_choice = tgui_input_list(user, "Choose which direction to sort to!", "Direction choice", directions)
	if(!user_choice)
		return ..()

	var/dir = text2dir(user_choice)
	if(!dir)
		return ..()

	setDir(dir)

	visible_message("[src] pings, updating its sorting direction!")
	playsound(src, 'sound/machines/ping.ogg', 30, TRUE)

/obj/effect/decal/conveyor_sorter/attackby(obj/item/used_item, mob/user, params)
	if(istype(used_item, /obj/item/conveyor_sorter))
		var/obj/item/conveyor_sorter/cs_item = used_item
		sorting_list = cs_item.current_sort
		visible_message("[src] pings, updating its sorting list!")
		playsound(src, 'sound/machines/ping.ogg', 30, TRUE)
		return
	else
		return ..()

/obj/effect/decal/conveyor_sorter/AltClick(mob/user)
	visible_message("[src] pings, resetting its sorting list!")
	playsound(src, 'sound/machines/ping.ogg', 30, TRUE)
	sorting_list = list()

/obj/effect/decal/conveyor_sorter/CtrlClick(mob/user)
	visible_message("[src] begins to ping violently!")
	playsound(src, 'sound/machines/ping.ogg', 30, TRUE)
	qdel(src)

/obj/effect/decal/conveyor_sorter/proc/on_entered(datum/source, atom/movable/entering_atom)
	SIGNAL_HANDLER
	if(is_type_in_list(entering_atom, sorting_list) && !entering_atom.anchored && COOLDOWN_FINISHED(src, use_cooldown))
		COOLDOWN_START(src, use_cooldown, 1 SECONDS)
		entering_atom.Move(get_step(src, dir))

/datum/design/conveyor_sorter
	name = "Conveyor Sorter"
	desc = "A wonderful item that can set markers and forcefully move stuff to a direction."
	id = "conveysorter"
	build_type = PROTOLATHE | AWAY_LATHE
	build_path = /obj/item/conveyor_sorter
	materials = list(/datum/material/iron = 500, /datum/material/plastic = 500)
	category = list(
		RND_CATEGORY_EQUIPMENT
	)
	departmental_flags = DEPARTMENT_BITFLAG_CARGO

/datum/techweb_node/conveyor_sorter
	id = "conveyorsorter"
	display_name = "Conveyor Sorter"
	description = "Finally, the ability to automatically sort stuff."
	prereq_ids = list("bluespace_basic", "engineering")
	design_ids = list(
		"conveysorter",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 2500)

/obj/item/conveyor_sorter/improved
	name = "improved conveyor sorter lister"
	desc = "A tool that is used to not only create the conveyor sorters, but give lists to the conveyor sorters."
	icon_state = "lister_improved"
	max_sorters = 8
	max_items = 10
	conveyor_type = /obj/effect/decal/conveyor_sorter/improved

/obj/effect/decal/conveyor_sorter/improved
	name = "improved conveyor sorter"
	desc = "A mark that will sort items out based on what they are. This one can sort in multiple directions."
	icon = 'monkestation/code/modules/conveyor_sorter/icons/conveyor_sorter.dmi'
	icon_state = "sorter_improved"
	light_outer_range = 3
	light_color = COLOR_BLUE_LIGHT
	directions = list("North", "East", "South", "West", "NorthEast", "NorthWest", "SouthEast", "SouthWest")

/datum/design/conveyor_sorter/improved
	name = "Improved Conveyor Sorter"
	desc = "A wonderful item that can set markers and forcefully move stuff to a direction. With more capacity to sort more!"
	id = "conveyor_sorter_improved"
	build_path = /obj/item/conveyor_sorter/improved
	materials = list(
		/datum/material/iron = 500,
		/datum/material/plastic = 500,
		/datum/material/gold = 500,
		/datum/material/bluespace = 500,
	)


/datum/techweb_node/conveyor_sorter/improved
	id = "conveyor_sorter_improved"
	display_name = "Improved Conveyor Sorter"
	description = "An improved version of the conveyor sorter, this one allows for more control over sorting."
	prereq_ids = list("practical_bluespace", "conveyorsorter")
	design_ids = list(
		"conveyor_sorter_improved",
	)
	research_costs = list(TECHWEB_POINT_TYPE_GENERIC = 7500)
