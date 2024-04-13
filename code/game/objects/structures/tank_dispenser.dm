#define TANK_DISPENSER_CAPACITY 10

/obj/structure/tank_dispenser
	name = "tank dispenser"
	desc = "A simple yet bulky storage device for gas tanks. Holds up to 10 oxygen tanks and 10 plasma tanks."
	icon = 'icons/obj/structures.dmi'
	icon_state = "dispenser"
	density = TRUE
	anchored = TRUE
	max_integrity = 300
	var/oxygentanks = TANK_DISPENSER_CAPACITY
	var/plasmatanks = TANK_DISPENSER_CAPACITY

/obj/structure/tank_dispenser/oxygen
	plasmatanks = 0

/obj/structure/tank_dispenser/plasma
	oxygentanks = 0

/obj/structure/tank_dispenser/Initialize(mapload)
	. = ..()
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
	return ITEM_INTERACT_SUCCESS

/obj/structure/tank_dispenser/attackby(obj/item/I, mob/living/user, params)
	var/full
	if(istype(I, /obj/item/tank/internals/plasma))
		if(plasmatanks < TANK_DISPENSER_CAPACITY)
			plasmatanks++
		else
			full = TRUE
	else if(istype(I, /obj/item/tank/internals/oxygen))
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
			if (plasmatanks == 0)
				return TRUE

			dispense(/obj/item/tank/internals/plasma, usr)
			plasmatanks--
		if("oxygen")
			if (oxygentanks == 0)
				return TRUE

			dispense(/obj/item/tank/internals/oxygen, usr)
			oxygentanks--

	update_appearance()
	return TRUE


/obj/structure/tank_dispenser/atom_deconstruct(disassembled = TRUE)
	for(var/X in src)
		var/obj/item/I = X
		I.forceMove(loc)
	new /obj/item/stack/sheet/iron (loc, 2)

/obj/structure/tank_dispenser/proc/dispense(tank_type, mob/receiver)
	var/existing_tank = locate(tank_type) in src
	if (isnull(existing_tank))
		existing_tank = new tank_type
	receiver.put_in_hands(existing_tank)

#undef TANK_DISPENSER_CAPACITY
