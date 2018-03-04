////////////////////////////////
///// Construction datums //////
////////////////////////////////
/datum/construction/mecha
	var/base_icon

/datum/construction/mecha/custom_action(obj/item/I, mob/living/user, diff)
	var/target_index = index + diff
	var/list/current_step = steps[index]
	var/list/target_step

	if(target_index > 0 && target_index <= steps.len)
		target_step = steps[target_index]

	. = TRUE

	if(I.tool_behaviour)
		. = I.use_tool(holder, user, 0, volume=50)

	else if(diff == FORWARD)
		switch(current_step["action"])
			if(ITEM_DELETE)
				. = user.transferItemToLoc(I, holder)
				if(.)
					qdel(I)

			if(ITEM_MOVE_INSIDE)
				. = user.transferItemToLoc(I, holder)

			else if(istype(I, /obj/item/stack))
				. = I.use_tool(holder, user, 0, volume=50, amount=current_step["amount"])


	// Going backwards? Undo the last action. Drop/respawn the items used in last action, if any.
	if(. && diff == BACKWARD && target_step && !target_step["no_refund"])
		var/target_step_key = target_step["key"]

		switch(target_step["action"])
			if(ITEM_DELETE)
				new target_step_key(drop_location())

			if(ITEM_MOVE_INSIDE)
				var/obj/item/located_item = locate(target_step_key) in holder
				if(located_item)
					located_item.forceMove(drop_location())

			else if(ispath(target_step_key, /obj/item/stack))
				new target_step_key(drop_location(), target_step["amount"])


/datum/construction/mecha/spawn_result()
	if(!result)
		return

	// Remove default mech power cell, as we replace it with a new one.
	var/obj/mecha/M = new result(drop_location())
	QDEL_NULL(M.cell)

	M.CheckParts(holder.contents)

	SSblackbox.record_feedback("tally", "mechas_created", 1, M.name)
	QDEL_NULL(holder)

/datum/construction/mecha/update_holder(step_index)
	..()
	// By default, each step in mech construction has a single icon_state:
	// "[base_icon][index - 1]"
	// For example, Ripley's step 1 icon_state is "ripley0".
	if(!steps[index]["icon_state"] && base_icon)
		holder.icon_state = "[base_icon][index - 1]"

/datum/construction/unordered/mecha_chassis/custom_action(obj/item/I, mob/living/user, typepath)
	. = user.transferItemToLoc(I, holder)
	if(.)
		user.visible_message("[user] has connected [I] to [holder].", "<span class='notice'>You connect [I] to [holder].</span>")
		holder.add_overlay(I.icon_state+"+o")
		qdel(I)

/datum/construction/unordered/mecha_chassis/spawn_result()
	holder.icon = 'icons/mecha/mech_construction.dmi'
	holder.density = TRUE
	holder.cut_overlays()

	var/obj/item/mecha_parts/chassis/chassis = holder
	chassis.construct = new result(holder)
	qdel(src)



/datum/construction/unordered/mecha_chassis/ripley
	result = /datum/construction/mecha/ripley
	steps = list(
		/obj/item/mecha_parts/part/ripley_torso,
		/obj/item/mecha_parts/part/ripley_left_arm,
		/obj/item/mecha_parts/part/ripley_right_arm,
		/obj/item/mecha_parts/part/ripley_left_leg,
		/obj/item/mecha_parts/part/ripley_right_leg
	)

/datum/construction/mecha/ripley
	result = /obj/mecha/working/ripley
	base_icon = "ripley"
	steps = list(
		//1
		list(
			"key" = TOOL_WRENCH,
			"desc" = "The hydraulic systems are disconnected."
		),

		//2
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_WRENCH,
			"desc" = "The hydraulic systems are connected."
		),

		//3
		list(
			"key" = /obj/item/stack/cable_coil,
			"amount" = 5,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The hydraulic systems are active."
		),

		//4
		list(
			"key" = TOOL_WIRECUTTER,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The wiring is added."
		),

		//5
		list(
			"key" = /obj/item/circuitboard/mecha/ripley/main,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The wiring is adjusted."
		),

		//6
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Central control module is installed."
		),

		//7
		list(
			"key" = /obj/item/circuitboard/mecha/ripley/peripherals,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Central control module is secured."
		),

		//8
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Peripherals control module is installed."
		),

		//9
		list(
			"key" = /obj/item/stock_parts/cell,
			"action" = ITEM_MOVE_INSIDE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Peripherals control module is secured."
		),

		//10
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "The power cell is installed."
		),

		//11
		list(
			"key" = /obj/item/stack/sheet/metal,
			"amount" = 5,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The power cell is secured."
		),

		//12
		list(
			"key" = TOOL_WRENCH,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Internal armor is installed."
		),

		//13
		list(
			"key" = TOOL_WELDER,
			"back_key" = TOOL_WRENCH,
			"desc" = "Internal armor is wrenched."
		),

		//14
		list(
			"key" = /obj/item/stack/sheet/plasteel,
			"amount" = 5,
			"back_key" = TOOL_WELDER,
			"desc" = "Internal armor is welded."
		),

		//15
		list(
			"key" = TOOL_WRENCH,
			"back_key" = TOOL_CROWBAR,
			"desc" = "External armor is installed."
		),

		//16
		list(
			"key" = TOOL_WELDER,
			"back_key" = TOOL_WRENCH,
			"desc" = "External armor is wrenched."
		),
	)

/datum/construction/mecha/ripley/custom_action(obj/item/I, mob/living/user, diff)
	if(!..())
		return FALSE

	switch(index)
		if(1)
			user.visible_message("[user] connects [holder] hydraulic systems", "<span class='notice'>You connect [holder] hydraulic systems.</span>")
		if(2)
			if(diff==FORWARD)
				user.visible_message("[user] activates [holder] hydraulic systems.", "<span class='notice'>You activate [holder] hydraulic systems.</span>")
			else
				user.visible_message("[user] disconnects [holder] hydraulic systems", "<span class='notice'>You disconnect [holder] hydraulic systems.</span>")
		if(3)
			if(diff==FORWARD)
				user.visible_message("[user] adds the wiring to [holder].", "<span class='notice'>You add the wiring to [holder].</span>")
			else
				user.visible_message("[user] deactivates [holder] hydraulic systems.", "<span class='notice'>You deactivate [holder] hydraulic systems.</span>")
		if(4)
			if(diff==FORWARD)
				user.visible_message("[user] adjusts the wiring of [holder].", "<span class='notice'>You adjust the wiring of [holder].</span>")
			else
				user.visible_message("[user] removes the wiring from [holder].", "<span class='notice'>You remove the wiring from [holder].</span>")
		if(5)
			if(diff==FORWARD)
				user.visible_message("[user] installs the central control module into [holder].", "<span class='notice'>You install the central computer mainboard into [holder].</span>")
			else
				user.visible_message("[user] disconnects the wiring of [holder].", "<span class='notice'>You disconnect the wiring of [holder].</span>")
		if(6)
			if(diff==FORWARD)
				user.visible_message("[user] secures the mainboard.", "<span class='notice'>You secure the mainboard.</span>")
			else
				user.visible_message("[user] removes the central control module from [holder].", "<span class='notice'>You remove the central computer mainboard from [holder].</span>")
		if(7)
			if(diff==FORWARD)
				user.visible_message("[user] installs the peripherals control module into [holder].", "<span class='notice'>You install the peripherals control module into [holder].</span>")
			else
				user.visible_message("[user] unfastens the mainboard.", "<span class='notice'>You unfasten the mainboard.</span>")
		if(8)
			if(diff==FORWARD)
				user.visible_message("[user] secures the peripherals control module.", "<span class='notice'>You secure the peripherals control module.</span>")
			else
				user.visible_message("[user] removes the peripherals control module from [holder].", "<span class='notice'>You remove the peripherals control module from [holder].</span>")
		if(9)
			if(diff==FORWARD)
				user.visible_message("[user] installs the power cell into [holder].", "<span class='notice'>You install the power cell into [holder].</span>")
			else
				user.visible_message("[user] unfastens the peripherals control module.", "<span class='notice'>You unfasten the peripherals control module.</span>")
		if(10)
			if(diff==FORWARD)
				user.visible_message("[user] secures the power cell.", "<span class='notice'>You secure the power cell.</span>")
			else
				user.visible_message("[user] prys the power cell from [holder].", "<span class='notice'>You pry the power cell from [holder].</span>")
		if(11)
			if(diff==FORWARD)
				user.visible_message("[user] installs the internal armor layer to [holder].", "<span class='notice'>You install the internal armor layer to [holder].</span>")
			else
				user.visible_message("[user] unfastens the power cell.", "<span class='notice'>You unfasten the power cell.</span>")
		if(12)
			if(diff==FORWARD)
				user.visible_message("[user] secures the internal armor layer.", "<span class='notice'>You secure the internal armor layer.</span>")
			else
				user.visible_message("[user] pries internal armor layer from [holder].", "<span class='notice'>You pry internal armor layer from [holder].</span>")
		if(13)
			if(diff==FORWARD)
				user.visible_message("[user] welds the internal armor layer to [holder].", "<span class='notice'>You weld the internal armor layer to [holder].</span>")
			else
				user.visible_message("[user] unfastens the internal armor layer.", "<span class='notice'>You unfasten the internal armor layer.</span>")
		if(14)
			if(diff==FORWARD)
				user.visible_message("[user] installs the external reinforced armor layer to [holder].", "<span class='notice'>You install the external reinforced armor layer to [holder].</span>")
			else
				user.visible_message("[user] cuts the internal armor layer from [holder].", "<span class='notice'>You cut the internal armor layer from [holder].</span>")
		if(15)
			if(diff==FORWARD)
				user.visible_message("[user] secures the external armor layer.", "<span class='notice'>You secure the external reinforced armor layer.</span>")
			else
				user.visible_message("[user] pries external armor layer from [holder].", "<span class='notice'>You pry external armor layer from [holder].</span>")
		if(16)
			if(diff==FORWARD)
				user.visible_message("[user] welds the external armor layer to [holder].", "<span class='notice'>You weld the external armor layer to [holder].</span>")
			else
				user.visible_message("[user] unfastens the external armor layer.", "<span class='notice'>You unfasten the external armor layer.</span>")
	return TRUE

/datum/construction/unordered/mecha_chassis/gygax
	result = /datum/construction/mecha/gygax
	steps = list(
		/obj/item/mecha_parts/part/gygax_torso,
		/obj/item/mecha_parts/part/gygax_left_arm,
		/obj/item/mecha_parts/part/gygax_right_arm,
		/obj/item/mecha_parts/part/gygax_left_leg,
		/obj/item/mecha_parts/part/gygax_right_leg,
		/obj/item/mecha_parts/part/gygax_head
	)

/datum/construction/mecha/gygax
	result = /obj/mecha/combat/gygax
	base_icon = "gygax"
	steps = list(
		//1
		list(
			"key" = TOOL_WRENCH,
			"desc" = "The hydraulic systems are disconnected."
		),

		//2
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_WRENCH,
			"desc" = "The hydraulic systems are connected."
		),

		//3
		list(
			"key" = /obj/item/stack/cable_coil,
			"amount" = 5,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The hydraulic systems are active."
		),

		//4
		list(
			"key" = TOOL_WIRECUTTER,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The wiring is added."
		),

		//5
		list(
			"key" = /obj/item/circuitboard/mecha/gygax/main,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The wiring is adjusted."
		),

		//6
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Central control module is installed."
		),

		//7
		list(
			"key" = /obj/item/circuitboard/mecha/gygax/peripherals,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Central control module is secured."
		),

		//8
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Peripherals control module is installed."
		),

		//9
		list(
			"key" = /obj/item/circuitboard/mecha/gygax/targeting,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Peripherals control module is secured."
		),

		//10
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Weapon control module is installed."
		),

		//11
		list(
			"key" = /obj/item/stock_parts/scanning_module,
			"action" = ITEM_MOVE_INSIDE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Weapon control module is secured."
		),

		//12
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Advanced scanner module is installed."
		),

		//13
		list(
			"key" = /obj/item/stock_parts/capacitor,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Advanced scanner module is secured."
		),

		//14
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Advanced capacitor is installed."
		),

		//15
		list(
			"key" = /obj/item/stock_parts/cell,
			"action" = ITEM_MOVE_INSIDE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Advanced capacitor is secured."
		),

		//16
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "The power cell is installed."
		),

		//17
		list(
			"key" = /obj/item/stack/sheet/metal,
			"amount" = 5,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The power cell is secured."
		),

		//18
		list(
			"key" = TOOL_WRENCH,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Internal armor is installed."
		),

		//19
		list(
			"key" = TOOL_WELDER,
			"back_key" = TOOL_WRENCH,
			"desc" = "Internal armor is wrenched."
		),

		//20
		list(
			"key" = /obj/item/mecha_parts/part/gygax_armor,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_WELDER,
			"desc" = "Internal armor is welded."
		),

		//21
		list(
			"key" = TOOL_WRENCH,
			"back_key" = TOOL_CROWBAR,
			"desc" = "External armor is installed."
		),

		//22
		list(
			"key" = TOOL_WELDER,
			"back_key" = TOOL_WRENCH,
			"desc" = "External armor is wrenched."
		),

	)

/datum/construction/mecha/gygax/action(atom/used_atom,mob/user)
	return check_step(used_atom,user)

/datum/construction/mecha/gygax/custom_action(obj/item/I, mob/living/user, diff)
	if(!..())
		return FALSE

	switch(index)
		if(1)
			user.visible_message("[user] connects [holder] hydraulic systems", "<span class='notice'>You connect [holder] hydraulic systems.</span>")
		if(2)
			if(diff==FORWARD)
				user.visible_message("[user] activates [holder] hydraulic systems.", "<span class='notice'>You activate [holder] hydraulic systems.</span>")
			else
				user.visible_message("[user] disconnects [holder] hydraulic systems", "<span class='notice'>You disconnect [holder] hydraulic systems.</span>")
		if(3)
			if(diff==FORWARD)
				user.visible_message("[user] adds the wiring to [holder].", "<span class='notice'>You add the wiring to [holder].</span>")
			else
				user.visible_message("[user] deactivates [holder] hydraulic systems.", "<span class='notice'>You deactivate [holder] hydraulic systems.</span>")
		if(4)
			if(diff==FORWARD)
				user.visible_message("[user] adjusts the wiring of [holder].", "<span class='notice'>You adjust the wiring of [holder].</span>")
			else
				user.visible_message("[user] removes the wiring from [holder].", "<span class='notice'>You remove the wiring from [holder].</span>")
		if(5)
			if(diff==FORWARD)
				user.visible_message("[user] installs the central control module into [holder].", "<span class='notice'>You install the central computer mainboard into [holder].</span>")
			else
				user.visible_message("[user] disconnects the wiring of [holder].", "<span class='notice'>You disconnect the wiring of [holder].</span>")
		if(6)
			if(diff==FORWARD)
				user.visible_message("[user] secures the mainboard.", "<span class='notice'>You secure the mainboard.</span>")
			else
				user.visible_message("[user] removes the central control module from [holder].", "<span class='notice'>You remove the central computer mainboard from [holder].</span>")
		if(7)
			if(diff==FORWARD)
				user.visible_message("[user] installs the peripherals control module into [holder].", "<span class='notice'>You install the peripherals control module into [holder].</span>")
			else
				user.visible_message("[user] unfastens the mainboard.", "<span class='notice'>You unfasten the mainboard.</span>")
		if(8)
			if(diff==FORWARD)
				user.visible_message("[user] secures the peripherals control module.", "<span class='notice'>You secure the peripherals control module.</span>")
			else
				user.visible_message("[user] removes the peripherals control module from [holder].", "<span class='notice'>You remove the peripherals control module from [holder].</span>")
		if(9)
			if(diff==FORWARD)
				user.visible_message("[user] installs the weapon control module into [holder].", "<span class='notice'>You install the weapon control module into [holder].</span>")
			else
				user.visible_message("[user] unfastens the peripherals control module.", "<span class='notice'>You unfasten the peripherals control module.</span>")
		if(10)
			if(diff==FORWARD)
				user.visible_message("[user] secures the weapon control module.", "<span class='notice'>You secure the weapon control module.</span>")
			else
				user.visible_message("[user] removes the weapon control module from [holder].", "<span class='notice'>You remove the weapon control module from [holder].</span>")
		if(11)
			if(diff==FORWARD)
				user.visible_message("[user] installs scanner module to [holder].", "<span class='notice'>You install scanner module to [holder].</span>")
			else
				user.visible_message("[user] unfastens the weapon control module.", "<span class='notice'>You unfasten the weapon control module.</span>")
		if(12)
			if(diff==FORWARD)
				user.visible_message("[user] secures the advanced scanner module.", "<span class='notice'>You secure the scanner module.</span>")
			else
				user.visible_message("[user] removes the advanced scanner module from [holder].", "<span class='notice'>You remove the scanner module from [holder].</span>")
		if(13)
			if(diff==FORWARD)
				user.visible_message("[user] installs capacitor to [holder].", "<span class='notice'>You install capacitor to [holder].</span>")
			else
				user.visible_message("[user] unfastens the  scanner module.", "<span class='notice'>You unfasten the scanner module.</span>")
		if(14)
			if(diff==FORWARD)
				user.visible_message("[user] secures the capacitor.", "<span class='notice'>You secure the capacitor.</span>")
			else
				user.visible_message("[user] removes the capacitor from [holder].", "<span class='notice'>You remove the capacitor from [holder].</span>")
		if(15)
			if(diff==FORWARD)
				user.visible_message("[user] installs the power cell into [holder].", "<span class='notice'>You install the power cell into [holder].</span>")
			else
				user.visible_message("[user] unfastens the capacitor.", "<span class='notice'>You unfasten the capacitor.</span>")
		if(16)
			if(diff==FORWARD)
				user.visible_message("[user] secures the power cell.", "<span class='notice'>You secure the power cell.</span>")
			else
				user.visible_message("[user] prys the power cell from [holder].", "<span class='notice'>You pry the power cell from [holder].</span>")
		if(17)
			if(diff==FORWARD)
				user.visible_message("[user] installs the internal armor layer to [holder].", "<span class='notice'>You install the internal armor layer to [holder].</span>")
			else
				user.visible_message("[user] unfastens the power cell.", "<span class='notice'>You unfasten the power cell.</span>")
		if(18)
			if(diff==FORWARD)
				user.visible_message("[user] secures the internal armor layer.", "<span class='notice'>You secure the internal armor layer.</span>")
			else
				user.visible_message("[user] pries internal armor layer from [holder].", "<span class='notice'>You pry internal armor layer from [holder].</span>")
		if(19)
			if(diff==FORWARD)
				user.visible_message("[user] welds the internal armor layer to [holder].", "<span class='notice'>You weld the internal armor layer to [holder].</span>")
			else
				user.visible_message("[user] unfastens the internal armor layer.", "<span class='notice'>You unfasten the internal armor layer.</span>")
		if(20)
			if(diff==FORWARD)
				user.visible_message("[user] installs Gygax Armor Plates to [holder].", "<span class='notice'>You install Gygax Armor Plates to [holder].</span>")
			else
				user.visible_message("[user] cuts the internal armor layer from [holder].", "<span class='notice'>You cut the internal armor layer from [holder].</span>")
		if(21)
			if(diff==FORWARD)
				user.visible_message("[user] secures Gygax Armor Plates.", "<span class='notice'>You secure Gygax Armor Plates.</span>")
			else
				user.visible_message("[user] pries Gygax Armor Plates from [holder].", "<span class='notice'>You pry Gygax Armor Plates from [holder].</span>")
		if(22)
			if(diff==FORWARD)
				user.visible_message("[user] welds Gygax Armor Plates to [holder].", "<span class='notice'>You weld Gygax Armor Plates to [holder].</span>")
			else
				user.visible_message("[user] unfastens Gygax Armor Plates.", "<span class='notice'>You unfasten Gygax Armor Plates.</span>")
	return TRUE

/datum/construction/unordered/mecha_chassis/firefighter
	result = /datum/construction/mecha/firefighter
	steps = list(
		/obj/item/mecha_parts/part/ripley_torso,
		/obj/item/mecha_parts/part/ripley_left_arm,
		/obj/item/mecha_parts/part/ripley_right_arm,
		/obj/item/mecha_parts/part/ripley_left_leg,
		/obj/item/mecha_parts/part/ripley_right_leg,
		/obj/item/clothing/suit/fire
	)

/datum/construction/mecha/firefighter
	result = /obj/mecha/working/ripley/firefighter
	base_icon = "fireripley"
	steps = list(
		//1
		list(
			"key" = TOOL_WRENCH,
			"desc" = "The hydraulic systems are disconnected."
		),

		//2
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_WRENCH,
			"desc" = "The hydraulic systems are connected."
		),

		//3
		list(
			"key" = /obj/item/stack/cable_coil,
			"amount" = 5,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The hydraulic systems are active."
		),

		//4
		list(
			"key" = TOOL_WIRECUTTER,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The wiring is added."
		),

		//5
		list(
			"key" = /obj/item/circuitboard/mecha/ripley/main,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The wiring is adjusted."
		),

		//6
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Central control module is installed."
		),

		//7
		list(
			"key" = /obj/item/circuitboard/mecha/ripley/peripherals,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Central control module is secured."
		),

		//8
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Peripherals control module is installed."
		),

		//9
		list(
			"key" = /obj/item/stock_parts/cell,
			"action" = ITEM_MOVE_INSIDE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Peripherals control module is secured."
		),

		//10
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "The power cell is installed."
		),

		//11
		list(
			"key" = /obj/item/stack/sheet/plasteel,
			"amount" = 5,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The power cell is secured."
		),

		//12
		list(
			"key" = TOOL_WRENCH,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Internal armor is installed."
		),

		//13
		list(
			"key" = TOOL_WELDER,
			"back_key" = TOOL_WRENCH,
			"desc" = "Internal armor is wrenched."
		),

		//14
		list(
			"key" = /obj/item/stack/sheet/plasteel,
			"amount" = 5,
			"back_key" = TOOL_WELDER,
			"desc" = "Internal armor is welded."
		),

		//15
		list(
			"key" = /obj/item/stack/sheet/plasteel,
			"amount" = 5,
			"back_key" = TOOL_CROWBAR,
			"desc" = "External armor is being installed."
		),

		//16
		list(
			"key" = TOOL_WRENCH,
			"back_key" = TOOL_CROWBAR,
			"desc" = "External armor is installed."
		),

		//17
		list(
			"key" = TOOL_WELDER,
			"back_key" = TOOL_WRENCH,
			"desc" = "External armor is wrenched."
		),
	)

/datum/construction/mecha/firefighter/custom_action(obj/item/I, mob/living/user, diff)
	if(!..())
		return FALSE

	//TODO: better messages.
	switch(index)
		if(1)
			user.visible_message("[user] connects [holder] hydraulic systems", "<span class='notice'>You connect [holder] hydraulic systems.</span>")
		if(2)
			if(diff==FORWARD)
				user.visible_message("[user] activates [holder] hydraulic systems.", "<span class='notice'>You activate [holder] hydraulic systems.</span>")
			else
				user.visible_message("[user] disconnects [holder] hydraulic systems", "<span class='notice'>You disconnect [holder] hydraulic systems.</span>")
		if(3)
			if(diff==FORWARD)
				user.visible_message("[user] adds the wiring to [holder].", "<span class='notice'>You add the wiring to [holder].</span>")
			else
				user.visible_message("[user] deactivates [holder] hydraulic systems.", "<span class='notice'>You deactivate [holder] hydraulic systems.</span>")
		if(4)
			if(diff==FORWARD)
				user.visible_message("[user] adjusts the wiring of [holder].", "<span class='notice'>You adjust the wiring of [holder].</span>")
			else
				user.visible_message("[user] removes the wiring from [holder].", "<span class='notice'>You remove the wiring from [holder].</span>")
		if(5)
			if(diff==FORWARD)
				user.visible_message("[user] installs the central control module into [holder].", "<span class='notice'>You install the central computer mainboard into [holder].</span>")
			else
				user.visible_message("[user] disconnects the wiring of [holder].", "<span class='notice'>You disconnect the wiring of [holder].</span>")
		if(6)
			if(diff==FORWARD)
				user.visible_message("[user] secures the mainboard.", "<span class='notice'>You secure the mainboard.</span>")
			else
				user.visible_message("[user] removes the central control module from [holder].", "<span class='notice'>You remove the central computer mainboard from [holder].</span>")
		if(7)
			if(diff==FORWARD)
				user.visible_message("[user] installs the peripherals control module into [holder].", "<span class='notice'>You install the peripherals control module into [holder].</span>")
			else
				user.visible_message("[user] unfastens the mainboard.", "<span class='notice'>You unfasten the mainboard.</span>")
		if(8)
			if(diff==FORWARD)
				user.visible_message("[user] secures the peripherals control module.", "<span class='notice'>You secure the peripherals control module.</span>")
			else
				user.visible_message("[user] removes the peripherals control module from [holder].", "<span class='notice'>You remove the peripherals control module from [holder].</span>")
		if(9)
			if(diff==FORWARD)
				user.visible_message("[user] installs the power cell into [holder].", "<span class='notice'>You install the power cell into [holder].</span>")
			else
				user.visible_message("[user] unfastens the peripherals control module.", "<span class='notice'>You unfasten the peripherals control module.</span>")
		if(10)
			if(diff==FORWARD)
				user.visible_message("[user] secures the power cell.", "<span class='notice'>You secure the power cell.</span>")
			else
				user.visible_message("[user] prys the power cell from [holder].", "<span class='notice'>You pry the power cell from [holder].</span>")
		if(11)
			if(diff==FORWARD)
				user.visible_message("[user] installs the internal armor layer to [holder].", "<span class='notice'>You install the internal armor layer to [holder].</span>")
			else
				user.visible_message("[user] unfastens the power cell.", "<span class='notice'>You unfasten the power cell.</span>")
		if(12)
			if(diff==FORWARD)
				user.visible_message("[user] secures the internal armor layer.", "<span class='notice'>You secure the internal armor layer.</span>")
			else
				user.visible_message("[user] pries internal armor layer from [holder].", "<span class='notice'>You pry internal armor layer from [holder].</span>")
		if(13)
			if(diff==FORWARD)
				user.visible_message("[user] welds the internal armor layer to [holder].", "<span class='notice'>You weld the internal armor layer to [holder].</span>")
			else
				user.visible_message("[user] unfastens the internal armor layer.", "<span class='notice'>You unfasten the internal armor layer.</span>")
		if(14)
			if(diff==FORWARD)
				user.visible_message("[user] starts to install the external armor layer to [holder].", "<span class='notice'>You install the external armor layer to [holder].</span>")
			else
				user.visible_message("[user] cuts the internal armor layer from [holder].", "<span class='notice'>You cut the internal armor layer from [holder].</span>")
		if(15)
			if(diff==FORWARD)
				user.visible_message("[user] installs the external reinforced armor layer to [holder].", "<span class='notice'>You install the external reinforced armor layer to [holder].</span>")
			else
				user.visible_message("[user] removes the external armor from [holder].", "<span class='notice'>You remove the external armor from [holder].</span>")
		if(16)
			if(diff==FORWARD)
				user.visible_message("[user] secures the external armor layer.", "<span class='notice'>You secure the external reinforced armor layer.</span>")
			else
				user.visible_message("[user] pries external armor layer from [holder].", "<span class='notice'>You pry external armor layer from [holder].</span>")
		if(17)
			if(diff==FORWARD)
				user.visible_message("[user] welds the external armor layer to [holder].", "<span class='notice'>You weld the external armor layer to [holder].</span>")
			else
				user.visible_message("[user] unfastens the external armor layer.", "<span class='notice'>You unfasten the external armor layer.</span>")
	return TRUE

/datum/construction/unordered/mecha_chassis/honker
	result = /datum/construction/mecha/honker
	steps = list(
		/obj/item/mecha_parts/part/honker_torso,
		/obj/item/mecha_parts/part/honker_left_arm,
		/obj/item/mecha_parts/part/honker_right_arm,
		/obj/item/mecha_parts/part/honker_left_leg,
		/obj/item/mecha_parts/part/honker_right_leg,
		/obj/item/mecha_parts/part/honker_head
	)

/datum/construction/mecha/honker
	result = /obj/mecha/combat/honker
	steps = list(
		//1
		list(
			"key" = /obj/item/bikehorn
		),

		//2
		list(
			"key" = /obj/item/circuitboard/mecha/honker/main,
			"action" = ITEM_DELETE
		),

		//3
		list(
			"key" = /obj/item/bikehorn
		),

		//4
		list(
			"key" = /obj/item/circuitboard/mecha/honker/peripherals,
			"action" = ITEM_DELETE
		),

		//5
		list(
			"key" = /obj/item/bikehorn
		),

		//6
		list(
			"key" = /obj/item/circuitboard/mecha/honker/targeting,
			"action" = ITEM_DELETE
		),

		//7
		list(
			"key" = /obj/item/bikehorn
		),

		//8
		list(
			"key" = /obj/item/stock_parts/cell,
			"action" = ITEM_MOVE_INSIDE
		),

		//9
		list(
			"key" = /obj/item/bikehorn
		),

		//10
		list(
			"key" = /obj/item/clothing/mask/gas/clown_hat,
			"action" = ITEM_DELETE
		),

		//11
		list(
			"key" = /obj/item/bikehorn
		),

		//12
		list(
			"key" = /obj/item/clothing/shoes/clown_shoes,
			"action" = ITEM_DELETE
		),

		//13
		list(
			"key" = /obj/item/bikehorn
		),
	)

// HONK doesn't have any construction step icons, so we just set an icon once.
/datum/construction/mecha/honker/update_holder(step_index)
	if(step_index == 1)
		holder.icon = 'icons/mecha/mech_construct.dmi'
		holder.icon_state = "honker_chassis"
	..()

/datum/construction/mecha/honker/custom_action(obj/item/I, mob/living/user, diff)
	if(!..())
		return FALSE

	if(istype(I, /obj/item/bikehorn))
		playsound(holder, 'sound/items/bikehorn.ogg', 50, 1)
		user.visible_message("HONK!")

	//TODO: better messages.
	switch(index)
		if(2)
			user.visible_message("[user] installs the central control module into [holder].", "<span class='notice'>You install the central control module into [holder].</span>")
		if(4)
			user.visible_message("[user] installs the peripherals control module into [holder].", "<span class='notice'>You install the peripherals control module into [holder].</span>")
		if(6)
			user.visible_message("[user] installs the weapon control module into [holder].", "<span class='notice'>You install the weapon control module into [holder].</span>")
		if(8)
			user.visible_message("[user] installs the power cell into [holder].", "<span class='notice'>You install the power cell into [holder].</span>")
		if(10)
			user.visible_message("[user] puts clown wig and mask on [holder].", "<span class='notice'>You put clown wig and mask on [holder].</span>")
		if(12)
			user.visible_message("[user] puts clown boots on [holder].", "<span class='notice'>You put clown boots on [holder].</span>")
	return TRUE

/datum/construction/unordered/mecha_chassis/durand
	result = /datum/construction/mecha/durand
	steps = list(
		/obj/item/mecha_parts/part/durand_torso,
		/obj/item/mecha_parts/part/durand_left_arm,
		/obj/item/mecha_parts/part/durand_right_arm,
		/obj/item/mecha_parts/part/durand_left_leg,
		/obj/item/mecha_parts/part/durand_right_leg,
		/obj/item/mecha_parts/part/durand_head
	)

/datum/construction/mecha/durand
	result = /obj/mecha/combat/durand
	base_icon = "durand"
	steps = list(
		//1
		list(
			"key" = TOOL_WRENCH,
			"desc" = "The hydraulic systems are disconnected."
		),

		//2
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_WRENCH,
			"desc" = "The hydraulic systems are connected."
		),

		//3
		list(
			"key" = /obj/item/stack/cable_coil,
			"amount" = 5,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The hydraulic systems are active."
		),

		//4
		list(
			"key" = TOOL_WIRECUTTER,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The wiring is added."
		),

		//5
		list(
			"key" = /obj/item/circuitboard/mecha/durand/main,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The wiring is adjusted."
		),

		//6
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Central control module is installed."
		),

		//7
		list(
			"key" = /obj/item/circuitboard/mecha/durand/peripherals,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Central control module is secured."
		),

		//8
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Peripherals control module is installed."
		),

		//9
		list(
			"key" = /obj/item/circuitboard/mecha/durand/targeting,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Peripherals control module is secured."
		),

		//10
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Weapon control module is installed."
		),

		//11
		list(
			"key" = /obj/item/stock_parts/scanning_module,
			"action" = ITEM_MOVE_INSIDE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Weapon control module is secured."
		),

		//12
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Phasic scanner module is installed."
		),

		//13
		list(
			"key" = /obj/item/stock_parts/capacitor,
			"action" = ITEM_MOVE_INSIDE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Phasic scanner module is secured."
		),

		//14
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Super capacitor is installed."
		),

		//15
		list(
			"key" = /obj/item/stock_parts/cell,
			"action" = ITEM_MOVE_INSIDE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Super capacitor is secured."
		),

		//16
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "The power cell is installed."
		),

		//17
		list(
			"key" = /obj/item/stack/sheet/metal,
			"amount" = 5,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The power cell is secured."
		),

		//18
		list(
			"key" = TOOL_WRENCH,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Internal armor is installed."
		),

		//19
		list(
			"key" = TOOL_WELDER,
			"back_key" = TOOL_WRENCH,
			"desc" = "Internal armor is wrenched."
		),

		//20
		list(
			"key" = /obj/item/mecha_parts/part/durand_armor,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_WELDER,
			"desc" = "Internal armor is welded."
		),

		//21
		list(
			"key" = TOOL_WRENCH,
			"back_key" = TOOL_CROWBAR,
			"desc" = "External armor is installed."
		),

		//22
		list(
			"key" = TOOL_WELDER,
			"back_key" = TOOL_WRENCH,
			"desc" = "External armor is wrenched."
		),
	)


/datum/construction/mecha/durand/custom_action(obj/item/I, mob/living/user, diff)
	if(!..())
		return FALSE

	//TODO: better messages.
	switch(index)
		if(1)
			user.visible_message("[user] connects [holder] hydraulic systems", "<span class='notice'>You connect [holder] hydraulic systems.</span>")
		if(2)
			if(diff==FORWARD)
				user.visible_message("[user] activates [holder] hydraulic systems.", "<span class='notice'>You activate [holder] hydraulic systems.</span>")
			else
				user.visible_message("[user] disconnects [holder] hydraulic systems", "<span class='notice'>You disconnect [holder] hydraulic systems.</span>")
		if(3)
			if(diff==FORWARD)
				user.visible_message("[user] adds the wiring to [holder].", "<span class='notice'>You add the wiring to [holder].</span>")
			else
				user.visible_message("[user] deactivates [holder] hydraulic systems.", "<span class='notice'>You deactivate [holder] hydraulic systems.</span>")
		if(4)
			if(diff==FORWARD)
				user.visible_message("[user] adjusts the wiring of [holder].", "<span class='notice'>You adjust the wiring of [holder].</span>")
			else
				user.visible_message("[user] removes the wiring from [holder].", "<span class='notice'>You remove the wiring from [holder].</span>")
		if(5)
			if(diff==FORWARD)
				user.visible_message("[user] installs the central control module into [holder].", "<span class='notice'>You install the central computer mainboard into [holder].</span>")
			else
				user.visible_message("[user] disconnects the wiring of [holder].", "<span class='notice'>You disconnect the wiring of [holder].</span>")
		if(6)
			if(diff==FORWARD)
				user.visible_message("[user] secures the mainboard.", "<span class='notice'>You secure the mainboard.</span>")
			else
				user.visible_message("[user] removes the central control module from [holder].", "<span class='notice'>You remove the central computer mainboard from [holder].</span>")
		if(7)
			if(diff==FORWARD)
				user.visible_message("[user] installs the peripherals control module into [holder].", "<span class='notice'>You install the peripherals control module into [holder].</span>")
			else
				user.visible_message("[user] unfastens the mainboard.", "<span class='notice'>You unfasten the mainboard.</span>")
		if(8)
			if(diff==FORWARD)
				user.visible_message("[user] secures the peripherals control module.", "<span class='notice'>You secure the peripherals control module.</span>")
			else
				user.visible_message("[user] removes the peripherals control module from [holder].", "<span class='notice'>You remove the peripherals control module from [holder].</span>")
		if(9)
			if(diff==FORWARD)
				user.visible_message("[user] installs the weapon control module into [holder].", "<span class='notice'>You install the weapon control module into [holder].</span>")
			else
				user.visible_message("[user] unfastens the peripherals control module.", "<span class='notice'>You unfasten the peripherals control module.</span>")
		if(10)
			if(diff==FORWARD)
				user.visible_message("[user] secures the weapon control module.", "<span class='notice'>You secure the weapon control module.</span>")
			else
				user.visible_message("[user] removes the weapon control module from [holder].", "<span class='notice'>You remove the weapon control module from [holder].</span>")
		if(11)
			if(diff==FORWARD)
				user.visible_message("[user] installs scanner module to [holder].", "<span class='notice'>You install phasic scanner module to [holder].</span>")
			else
				user.visible_message("[user] unfastens the weapon control module.", "<span class='notice'>You unfasten the weapon control module.</span>")
		if(12)
			if(diff==FORWARD)
				user.visible_message("[user] secures the scanner module.", "<span class='notice'>You secure the scanner module.</span>")
			else
				user.visible_message("[user] removes the scanner module from [holder].", "<span class='notice'>You remove the scanner module from [holder].</span>")
		if(13)
			if(diff==FORWARD)
				user.visible_message("[user] installs capacitor to [holder].", "<span class='notice'>You install capacitor to [holder].</span>")
			else
				user.visible_message("[user] unfastens the scanner module.", "<span class='notice'>You unfasten the scanner module.</span>")
		if(14)
			if(diff==FORWARD)
				user.visible_message("[user] secures the capacitor.", "<span class='notice'>You secure the capacitor.</span>")
			else
				user.visible_message("[user] removes the super capacitor from [holder].", "<span class='notice'>You remove the capacitor from [holder].</span>")
		if(15)
			if(diff==FORWARD)
				user.visible_message("[user] installs the power cell into [holder].", "<span class='notice'>You install the power cell into [holder].</span>")
			else
				user.visible_message("[user] unfastens the capacitor.", "<span class='notice'>You unfasten the capacitor.</span>")
		if(16)
			if(diff==FORWARD)
				user.visible_message("[user] secures the power cell.", "<span class='notice'>You secure the power cell.</span>")
			else
				user.visible_message("[user] prys the power cell from [holder].", "<span class='notice'>You pry the power cell from [holder].</span>")
		if(17)
			if(diff==FORWARD)
				user.visible_message("[user] installs the internal armor layer to [holder].", "<span class='notice'>You install the internal armor layer to [holder].</span>")
			else
				user.visible_message("[user] unfastens the power cell.", "<span class='notice'>You unfasten the power cell.</span>")
		if(18)
			if(diff==FORWARD)
				user.visible_message("[user] secures the internal armor layer.", "<span class='notice'>You secure the internal armor layer.</span>")
			else
				user.visible_message("[user] pries internal armor layer from [holder].", "<span class='notice'>You pry internal armor layer from [holder].</span>")
		if(19)
			if(diff==FORWARD)
				user.visible_message("[user] welds the internal armor layer to [holder].", "<span class='notice'>You weld the internal armor layer to [holder].</span>")
			else
				user.visible_message("[user] unfastens the internal armor layer.", "<span class='notice'>You unfasten the internal armor layer.</span>")
		if(20)
			if(diff==FORWARD)
				user.visible_message("[user] installs Durand Armor Plates to [holder].", "<span class='notice'>You install Durand Armor Plates to [holder].</span>")
			else
				user.visible_message("[user] cuts the internal armor layer from [holder].", "<span class='notice'>You cut the internal armor layer from [holder].</span>")
		if(21)
			if(diff==FORWARD)
				user.visible_message("[user] secures Durand Armor Plates.", "<span class='notice'>You secure Durand Armor Plates.</span>")
			else
				user.visible_message("[user] pries Durand Armor Plates from [holder].", "<span class='notice'>You pry Durand Armor Plates from [holder].</span>")
		if(22)
			if(diff==FORWARD)
				user.visible_message("[user] welds Durand Armor Plates to [holder].", "<span class='notice'>You weld Durand Armor Plates to [holder].</span>")
			else
				user.visible_message("[user] unfastens Durand Armor Plates.", "<span class='notice'>You unfasten Durand Armor Plates.</span>")
	return TRUE

//PHAZON

/datum/construction/unordered/mecha_chassis/phazon
	result = /datum/construction/mecha/phazon
	steps = list(
		/obj/item/mecha_parts/part/phazon_torso,
		/obj/item/mecha_parts/part/phazon_left_arm,
		/obj/item/mecha_parts/part/phazon_right_arm,
		/obj/item/mecha_parts/part/phazon_left_leg,
		/obj/item/mecha_parts/part/phazon_right_leg,
		/obj/item/mecha_parts/part/phazon_head
	)

/datum/construction/mecha/phazon
	result = /obj/mecha/combat/phazon
	base_icon = "phazon"
	steps = list(
		//1
		list(
			"key" = TOOL_WRENCH,
			"desc" = "The hydraulic systems are disconnected."
		),

		//2
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_WRENCH,
			"desc" = "The hydraulic systems are connected."
		),

		//3
		list(
			"key" = /obj/item/stack/cable_coil,
			"amount" = 5,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The hydraulic systems are active."
		),

		//4
		list(
			"key" = TOOL_WIRECUTTER,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The wiring is added."
		),

		//5
		list(
			"key" = /obj/item/circuitboard/mecha/phazon/main,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The wiring is adjusted."
		),

		//6
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Central control module is installed."
		),

		//7
		list(
			"key" = /obj/item/circuitboard/mecha/phazon/peripherals,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Central control module is secured."
		),

		//8
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Peripherals control module is installed"
		),

		//9
		list(
			"key" = /obj/item/circuitboard/mecha/phazon/targeting,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Peripherals control module is secured."
		),

		//10
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Weapon control is installed."
		),

		//11
		list(
			"key" = /obj/item/stock_parts/scanning_module,
			"action" = ITEM_MOVE_INSIDE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Weapon control module is secured."
		),

		//12
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Phasic scanner module is installed."
		),

		//13
		list(
			"key" = /obj/item/stock_parts/capacitor,
			"action" = ITEM_MOVE_INSIDE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Phasic scanner module is secured."
		),

		//14
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Super capacitor is installed."
		),

		//15
		list(
			"key" = /obj/item/stack/ore/bluespace_crystal,
			"amount" = 1,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Super capacitor is secured."
		),

		//16
		list(
			"key" = /obj/item/stack/cable_coil,
			"amount" = 5,
			"back_key" = TOOL_CROWBAR,
			"desc" = "The bluespace crystal is installed."
		),

		//17
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_WIRECUTTER,
			"desc" = "The bluespace crystal is connected."
		),

		//18
		list(
			"key" = /obj/item/stock_parts/cell,
			"action" = ITEM_MOVE_INSIDE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The bluespace crystal is engaged."
		),

		//19
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "The power cell is installed.",
			"icon_state" = "phazon17"
			// This is the point where a step icon is skipped, so "icon_state" had to be set manually starting from here.
		),

		//20
		list(
			"key" = /obj/item/stack/sheet/plasteel,
			"amount" = 5,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The power cell is secured.",
			"icon_state" = "phazon18"
		),

		//21
		list(
			"key" = TOOL_WRENCH,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Phase armor is installed.",
			"icon_state" = "phazon19"
		),

		//22
		list(
			"key" = TOOL_WELDER,
			"back_key" = TOOL_WRENCH,
			"desc" = "Phase armor is wrenched.",
			"icon_state" = "phazon20"
		),

		//23
		list(
			"key" = /obj/item/mecha_parts/part/phazon_armor,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_WELDER,
			"desc" = "Phase armor is welded.",
			"icon_state" = "phazon21"
		),

		//24
		list(
			"key" = TOOL_WRENCH,
			"back_key" = TOOL_CROWBAR,
			"desc" = "External armor is installed.",
			"icon_state" = "phazon22"
		),

		//25
		list(
			"key" = TOOL_WELDER,
			"back_key" = TOOL_WRENCH,
			"desc" = "External armor is wrenched.",
			"icon_state" = "phazon23"
		),

		//26
		list(
			"key" = /obj/item/device/assembly/signaler/anomaly,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_WELDER,
			"desc" = "Anomaly core socket is open.",
			"icon_state" = "phazon24"
		),
	)


/datum/construction/mecha/phazon/custom_action(obj/item/I, mob/living/user, diff)
	if(!..())
		return FALSE

	//TODO: better messages.
	switch(index)
		if(1)
			user.visible_message("[user] connects [holder] hydraulic systems", "<span class='notice'>You connect [holder] hydraulic systems.</span>")
		if(2)
			if(diff==FORWARD)
				user.visible_message("[user] activates [holder] hydraulic systems.", "<span class='notice'>You activate [holder] hydraulic systems.</span>")
			else
				user.visible_message("[user] disconnects [holder] hydraulic systems", "<span class='notice'>You disconnect [holder] hydraulic systems.</span>")
		if(3)
			if(diff==FORWARD)
				user.visible_message("[user] adds the wiring to [holder].", "<span class='notice'>You add the wiring to [holder].</span>")
			else
				user.visible_message("[user] deactivates [holder] hydraulic systems.", "<span class='notice'>You deactivate [holder] hydraulic systems.</span>")
		if(4)
			if(diff==FORWARD)
				user.visible_message("[user] adjusts the wiring of [holder].", "<span class='notice'>You adjust the wiring of [holder].</span>")
			else
				user.visible_message("[user] removes the wiring from [holder].", "<span class='notice'>You remove the wiring from [holder].</span>")
		if(5)
			if(diff==FORWARD)
				user.visible_message("[user] installs the central control module into [holder].", "<span class='notice'>You install the central computer mainboard into [holder].</span>")
			else
				user.visible_message("[user] disconnects the wiring of [holder].", "<span class='notice'>You disconnect the wiring of [holder].</span>")
		if(6)
			if(diff==FORWARD)
				user.visible_message("[user] secures the mainboard.", "<span class='notice'>You secure the mainboard.</span>")
			else
				user.visible_message("[user] removes the central control module from [holder].", "<span class='notice'>You remove the central computer mainboard from [holder].</span>")
		if(7)
			if(diff==FORWARD)
				user.visible_message("[user] installs the peripherals control module into [holder].", "<span class='notice'>You install the peripherals control module into [holder].</span>")
			else
				user.visible_message("[user] unfastens the mainboard.", "<span class='notice'>You unfasten the mainboard.</span>")
		if(8)
			if(diff==FORWARD)
				user.visible_message("[user] secures the peripherals control module.", "<span class='notice'>You secure the peripherals control module.</span>")
			else
				user.visible_message("[user] removes the peripherals control module from [holder].", "<span class='notice'>You remove the peripherals control module from [holder].</span>")
		if(9)
			if(diff==FORWARD)
				user.visible_message("[user] installs the weapon control module into [holder].", "<span class='notice'>You install the weapon control module into [holder].</span>")
			else
				user.visible_message("[user] unfastens the peripherals control module.", "<span class='notice'>You unfasten the peripherals control module.</span>")
		if(10)
			if(diff==FORWARD)
				user.visible_message("[user] secures the weapon control module.", "<span class='notice'>You secure the weapon control module.</span>")
			else
				user.visible_message("[user] removes the weapon control module from [holder].", "<span class='notice'>You remove the weapon control module from [holder].</span>")
		if(11)
			if(diff==FORWARD)
				user.visible_message("[user] installs phasic scanner module to [holder].", "<span class='notice'>You install scanner module to [holder].</span>")
			else
				user.visible_message("[user] unfastens the weapon control module.", "<span class='notice'>You unfasten the weapon control module.</span>")
		if(12)
			if(diff==FORWARD)
				user.visible_message("[user] secures the phasic scanner module.", "<span class='notice'>You secure the scanner module.</span>")
			else
				user.visible_message("[user] removes the phasic scanner module from [holder].", "<span class='notice'>You remove the scanner module from [holder].</span>")
		if(13)
			if(diff==FORWARD)
				user.visible_message("[user] installs super capacitor to [holder].", "<span class='notice'>You install capacitor to [holder].</span>")
			else
				user.visible_message("[user] unfastens the phasic scanner module.", "<span class='notice'>You unfasten the scanner module.</span>")
		if(14)
			if(diff==FORWARD)
				user.visible_message("[user] secures the super capacitor.", "<span class='notice'>You secure the capacitor.</span>")
			else
				user.visible_message("[user] removes the super capacitor from [holder].", "<span class='notice'>You remove the capacitor from [holder].</span>")
		if(15)
			if(diff==FORWARD)
				user.visible_message("[user] installs the bluespace crystal.", "<span class='notice'>You install the bluespace crystal.</span>")
			else
				user.visible_message("[user] unsecures the super capacitor from [holder].", "<span class='notice'>You unsecure the capacitor from [holder].</span>")
		if(16)
			if(diff==FORWARD)
				user.visible_message("[user] connects the bluespace crystal.", "<span class='notice'>You connect the bluespace crystal.</span>")
			else
				user.visible_message("[user] removes the bluespace crystal from [holder].", "<span class='notice'>You remove the bluespace crystal from [holder].</span>")
		if(17)
			if(diff==FORWARD)
				user.visible_message("[user] engages the bluespace crystal.", "<span class='notice'>You engage the bluespace crystal.</span>")
			else
				user.visible_message("[user] disconnects the bluespace crystal from [holder].", "<span class='notice'>You disconnect the bluespace crystal from [holder].</span>")
		if(18)
			if(diff==FORWARD)
				user.visible_message("[user] installs the power cell into [holder].", "<span class='notice'>You install the power cell into [holder].</span>")
			else
				user.visible_message("[user] disengages the bluespace crystal.", "<span class='notice'>You disengage the bluespace crystal.</span>")
		if(19)
			if(diff==FORWARD)
				user.visible_message("[user] secures the power cell.", "<span class='notice'>You secure the power cell.</span>")
			else
				user.visible_message("[user] prys the power cell from [holder].", "<span class='notice'>You pry the power cell from [holder].</span>")
		if(20)
			if(diff==FORWARD)
				user.visible_message("[user] installs the phase armor layer to [holder].", "<span class='notice'>You install the phase armor layer to [holder].</span>")
			else
				user.visible_message("[user] unfastens the power cell.", "<span class='notice'>You unfasten the power cell.</span>")
		if(21)
			if(diff==FORWARD)
				user.visible_message("[user] secures the phase armor layer.", "<span class='notice'>You secure the phase armor layer.</span>")
			else
				user.visible_message("[user] pries the phase armor layer from [holder].", "<span class='notice'>You pry the phase armor layer from [holder].</span>")
		if(22)
			if(diff==FORWARD)
				user.visible_message("[user] welds the phase armor layer to [holder].", "<span class='notice'>You weld the phase armor layer to [holder].</span>")
			else
				user.visible_message("[user] unfastens the phase armor layer.", "<span class='notice'>You unfasten the phase armor layer.</span>")
		if(23)
			if(diff==FORWARD)
				user.visible_message("[user] installs Phazon Armor Plates to [holder].", "<span class='notice'>You install Phazon Armor Plates to [holder].</span>")
			else
				user.visible_message("[user] cuts phase armor layer from [holder].", "<span class='notice'>You cut the phase armor layer from [holder].</span>")
		if(24)
			if(diff==FORWARD)
				user.visible_message("[user] secures Phazon Armor Plates.", "<span class='notice'>You secure Phazon Armor Plates.</span>")
			else
				user.visible_message("[user] pries Phazon Armor Plates from [holder].", "<span class='notice'>You pry Phazon Armor Plates from [holder].</span>")
		if(25)
			if(diff==FORWARD)
				user.visible_message("[user] welds Phazon Armor Plates to [holder].", "<span class='notice'>You weld Phazon Armor Plates to [holder].</span>")
			else
				user.visible_message("[user] unfastens Phazon Armor Plates.", "<span class='notice'>You unfasten Phazon Armor Plates.</span>")
		if(26)
			if(diff==FORWARD)
				user.visible_message("[user] carefully inserts the anomaly core into [holder] and secures it.",
					"<span class='notice'>You slowly place the anomaly core into its socket and close its chamber.</span>")
	return TRUE

//ODYSSEUS

/datum/construction/unordered/mecha_chassis/odysseus
	result = /datum/construction/mecha/odysseus
	steps = list(
		/obj/item/mecha_parts/part/odysseus_torso,
		/obj/item/mecha_parts/part/odysseus_head,
		/obj/item/mecha_parts/part/odysseus_left_arm,
		/obj/item/mecha_parts/part/odysseus_right_arm,
		/obj/item/mecha_parts/part/odysseus_left_leg,
		/obj/item/mecha_parts/part/odysseus_right_leg
	)

/datum/construction/mecha/odysseus
	result = /obj/mecha/medical/odysseus
	base_icon = "odysseus"
	steps = list(
		//1
		list(
			"key" = TOOL_WRENCH,
			"desc" = "The hydraulic systems are disconnected."
		),

		//2
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_WRENCH,
			"desc" = "The hydraulic systems are connected."
		),

		//3
		list(
			"key" = /obj/item/stack/cable_coil,
			"amount" = 5,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The hydraulic systems are active."
		),

		//4
		list(
			"key" = TOOL_WIRECUTTER,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The wiring is added."
		),

		//5
		list(
			"key" = /obj/item/circuitboard/mecha/odysseus/main,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The wiring is adjusted."
		),

		//6
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Central control module is installed."
		),

		//7
		list(
			"key" = /obj/item/circuitboard/mecha/odysseus/peripherals,
			"action" = ITEM_DELETE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Central control module is secured."
		),

		//8
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Peripherals control module is installed."
		),

		//9
		list(
			"key" = /obj/item/stock_parts/cell,
			"action" = ITEM_MOVE_INSIDE,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "Peripherals control module is secured."
		),

		//10
		list(
			"key" = TOOL_SCREWDRIVER,
			"back_key" = TOOL_CROWBAR,
			"desc" = "The power cell is installed."
		),

		//11
		list(
			"key" = /obj/item/stack/sheet/metal,
			"amount" = 5,
			"back_key" = TOOL_SCREWDRIVER,
			"desc" = "The power cell is secured."
		),

		//12
		list(
			"key" = TOOL_WRENCH,
			"back_key" = TOOL_CROWBAR,
			"desc" = "Internal armor is installed."
		),

		//13
		list(
			"key" = TOOL_WELDER,
			"back_key" = TOOL_WRENCH,
			"desc" = "Internal armor is wrenched."
		),

		//14
		list(
			"key" = /obj/item/stack/sheet/plasteel,
			"amount" = 5,
			"back_key" = TOOL_WELDER,
			"desc" = "Internal armor is welded."
		),

		//15
		list(
			"key" = TOOL_WRENCH,
			"back_key" = TOOL_CROWBAR,
			"desc" = "External armor is installed."
		),

		//16
		list(
			"key" = TOOL_WELDER,
			"back_key" = TOOL_WRENCH,
			"desc" = "External armor is wrenched."
		),
	)

/datum/construction/mecha/odysseus/custom_action(obj/item/I, mob/living/user, diff)
	if(!..())
		return FALSE

	//TODO: better messages.
	switch(index)
		if(1)
			user.visible_message("[user] connects [holder] hydraulic systems", "<span class='notice'>You connect [holder] hydraulic systems.</span>")
		if(2)
			if(diff==FORWARD)
				user.visible_message("[user] activates [holder] hydraulic systems.", "<span class='notice'>You activate [holder] hydraulic systems.</span>")
			else
				user.visible_message("[user] disconnects [holder] hydraulic systems", "<span class='notice'>You disconnect [holder] hydraulic systems.</span>")
		if(3)
			if(diff==FORWARD)
				user.visible_message("[user] adds the wiring to [holder].", "<span class='notice'>You add the wiring to [holder].</span>")
			else
				user.visible_message("[user] deactivates [holder] hydraulic systems.", "<span class='notice'>You deactivate [holder] hydraulic systems.</span>")
		if(4)
			if(diff==FORWARD)
				user.visible_message("[user] adjusts the wiring of [holder].", "<span class='notice'>You adjust the wiring of [holder].</span>")
			else
				user.visible_message("[user] removes the wiring from [holder].", "<span class='notice'>You remove the wiring from [holder].</span>")
		if(5)
			if(diff==FORWARD)
				user.visible_message("[user] installs the central control module into [holder].", "<span class='notice'>You install the central computer mainboard into [holder].</span>")
			else
				user.visible_message("[user] disconnects the wiring of [holder].", "<span class='notice'>You disconnect the wiring of [holder].</span>")
		if(6)
			if(diff==FORWARD)
				user.visible_message("[user] secures the mainboard.", "<span class='notice'>You secure the mainboard.</span>")
			else
				user.visible_message("[user] removes the central control module from [holder].", "<span class='notice'>You remove the central computer mainboard from [holder].</span>")
		if(7)
			if(diff==FORWARD)
				user.visible_message("[user] installs the peripherals control module into [holder].", "<span class='notice'>You install the peripherals control module into [holder].</span>")
			else
				user.visible_message("[user] unfastens the mainboard.", "<span class='notice'>You unfasten the mainboard.</span>")
		if(8)
			if(diff==FORWARD)
				user.visible_message("[user] secures the peripherals control module.", "<span class='notice'>You secure the peripherals control module.</span>")
			else
				user.visible_message("[user] removes the peripherals control module from [holder].", "<span class='notice'>You remove the peripherals control module from [holder].</span>")
		if(9)
			if(diff==FORWARD)
				user.visible_message("[user] installs the power cell into [holder].", "<span class='notice'>You install the power cell into [holder].</span>")
			else
				user.visible_message("[user] unfastens the peripherals control module.", "<span class='notice'>You unfasten the peripherals control module.</span>")
		if(10)
			if(diff==FORWARD)
				user.visible_message("[user] secures the power cell.", "<span class='notice'>You secure the power cell.</span>")
			else
				user.visible_message("[user] prys the power cell from [holder].", "<span class='notice'>You pry the power cell from [holder].</span>")
		if(11)
			if(diff==FORWARD)
				user.visible_message("[user] installs the internal armor layer to [holder].", "<span class='notice'>You install the internal armor layer to [holder].</span>")
			else
				user.visible_message("[user] unfastens the power cell.", "<span class='notice'>You unfasten the power cell.</span>")
		if(12)
			if(diff==FORWARD)
				user.visible_message("[user] secures the internal armor layer.", "<span class='notice'>You secure the internal armor layer.</span>")
			else
				user.visible_message("[user] pries internal armor layer from [holder].", "<span class='notice'>You pry internal armor layer from [holder].</span>")
		if(13)
			if(diff==FORWARD)
				user.visible_message("[user] welds the internal armor layer to [holder].", "<span class='notice'>You weld the internal armor layer to [holder].</span>")
			else
				user.visible_message("[user] unfastens the internal armor layer.", "<span class='notice'>You unfasten the internal armor layer.</span>")
		if(14)
			if(diff==FORWARD)
				user.visible_message("[user] installs the external armor layer to [holder].", "<span class='notice'>You install the external reinforced armor layer to [holder].</span>")
			else
				user.visible_message("[user] cuts the internal armor layer from [holder].", "<span class='notice'>You cut the internal armor layer from [holder].</span>")
		if(15)
			if(diff==FORWARD)
				user.visible_message("[user] secures the external armor layer.", "<span class='notice'>You secure the external reinforced armor layer.</span>")
			else
				user.visible_message("[user] pries the external armor layer from [holder].", "<span class='notice'>You pry the external armor layer from [holder].</span>")
		if(16)
			if(diff==FORWARD)
				user.visible_message("[user] welds the external armor layer to [holder].", "<span class='notice'>You weld the external armor layer to [holder].</span>")
			else
				user.visible_message("[user] unfastens the external armor layer.", "<span class='notice'>You unfasten the external armor layer.</span>")
	return TRUE
