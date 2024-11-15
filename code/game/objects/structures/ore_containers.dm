///structure to contain ores
/obj/structure/ore_container

/obj/structure/ore_container/attackby(obj/item/ore, mob/living/carbon/human/user, list/modifiers)
	if(istype(ore, /obj/item/stack/ore) && !user.combat_mode)
		ore.forceMove(src)
		return
	return ..()

/obj/structure/ore_container/Entered(atom/movable/mover)
	. = ..()
	update_appearance(UPDATE_OVERLAYS)

/obj/structure/ore_container/Exited(atom/movable/mover)
	. = ..()
	update_appearance(UPDATE_OVERLAYS)

/obj/structure/ore_container/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "OreContainer")
		ui.open()

/obj/structure/ore_container/ui_data(mob/user)
	var/list/ores = list()
	for(var/obj/item/stack/ore/ore_item in contents)
		ores += list(list(
			"id" = REF(ore_item),
			"name" = ore_item.name,
			"amount" = ore_item.amount,
			"icon" = ore_item::icon,
			"icon_state" = ore_item::icon_state,
		))
	return list("ores" = ores)

/obj/structure/ore_container/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()

	if(. || !isliving(ui.user))
		return TRUE

	var/mob/living/customer = ui.user
	var/obj/item/stack_to_move
	switch(action)
		if("withdraw")
			if(isnull(params["reference"]))
				return TRUE
			stack_to_move = locate(params["reference"]) in contents
			if(isnull(stack_to_move))
				return TRUE
			stack_to_move.forceMove(get_turf(customer))
			return TRUE
