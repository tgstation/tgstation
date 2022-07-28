#define TANK_DISPENSER_CAPACITY 10

/obj/structure/tank_dispenser
	name = "tank dispenser"
	desc = "A simple yet bulky storage device for gas tanks. Holds up to 10 oxygen tanks and 10 plasma tanks."
	icon = 'icons/obj/objects.dmi'
	icon_state = "dispenser"
	density = TRUE
	anchored = TRUE
	max_integrity = 300
	var/oxygentanks = TANK_DISPENSER_CAPACITY
	var/plasmatanks = TANK_DISPENSER_CAPACITY
	var/obj/item/tank/internals/oxytank_type = /obj/item/tank/internals/oxygen
	var/obj/item/tank/internals/plasmatank_type = /obj/item/tank/internals/plasma

/obj/structure/tank_dispenser/oxygen
	plasmatanks = 0

/obj/structure/tank_dispenser/plasma
	oxygentanks = 0

/obj/structure/tank_dispenser/emptytank
	name = "empty tank dispenser"
	oxytank_type = /obj/item/tank/internals/oxygen/empty
	plasmatank_type = /obj/item/tank/internals/plasma/empty

/obj/structure/tank_dispenser/Initialize(mapload)
	. = ..()
	for(var/i in 1 to oxygentanks)
		new oxytank_type(src)
	for(var/i in 1 to plasmatanks)
		new plasmatank_type(src)
	update_appearance()

/obj/structure/tank_dispenser/update_overlays()
	. = ..()
	switch(oxygentanks)
		if(1 to 3)
			. += "oxygen-[oxygentanks]"
		if(4 to TANK_DISPENSER_CAPACITY)
			. += "oxygen-4"
	switch(plasmatanks)
		if(1 to 4)
			. += "plasma-[plasmatanks]"
		if(5 to TANK_DISPENSER_CAPACITY)
			. += "plasma-5"

/obj/structure/tank_dispenser/wrench_act(mob/living/user, obj/item/tool)
	. = ..()
	default_unfasten_wrench(user, tool)
	return TOOL_ACT_TOOLTYPE_SUCCESS

/obj/structure/tank_dispenser/attackby(obj/item/I, mob/living/user, params)
	var/full
	if(istype(I, plasmatank_type))
		if(plasmatanks < TANK_DISPENSER_CAPACITY)
			plasmatanks++
		else
			full = TRUE
	else if(istype(I, oxytank_type))
		if(oxygentanks < TANK_DISPENSER_CAPACITY)
			oxygentanks++
		else
			full = TRUE
	else if(!user.combat_mode)
		to_chat(user, span_notice("[I] does not fit into [src]."))
		return
	else
		return ..()
	if(full)
		to_chat(user, span_notice("[src] can't hold any more of [I]."))
		return

	if(!user.transferItemToLoc(I, src))
		return
	to_chat(user, span_notice("You put [I] in [src]."))
	update_appearance()

/obj/structure/tank_dispenser/ui_state(mob/user)
	return GLOB.physical_state

/obj/structure/tank_dispenser/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TankDispenser", name)
		ui.open()

/obj/structure/tank_dispenser/ui_data(mob/user)
	var/list/data = list()
	data["oxygen"] = oxygentanks
	data["plasma"] = plasmatanks

	return data

/obj/structure/tank_dispenser/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("plasma")
			var/obj/item/tank/internals/tank = locate(plasmatank_type) in src
			if(tank && Adjacent(usr))
				usr.put_in_hands(tank)
				plasmatanks--
			. = TRUE
		if("oxygen")
			var/obj/item/tank/internals/tank = locate(oxytank_type) in src
			if(tank && Adjacent(usr))
				usr.put_in_hands(tank)
				oxygentanks--
			. = TRUE
	update_appearance()


/obj/structure/tank_dispenser/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		for(var/X in src)
			var/obj/item/I = X
			I.forceMove(loc)
		new /obj/item/stack/sheet/iron (loc, 2)
	qdel(src)

#undef TANK_DISPENSER_CAPACITY
