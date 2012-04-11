////////////////////////////////
///// Construction datums //////
////////////////////////////////

/datum/construction/mecha/custom_action(step, atom/used_atom, mob/user)
	if(istype(used_atom, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/W = used_atom
		if (W:remove_fuel(0, user))
			playsound(holder, 'Welder2.ogg', 50, 1)
		else
			return 0
	else if(istype(used_atom, /obj/item/weapon/wrench))
		playsound(holder, 'Ratchet.ogg', 50, 1)

	else if(istype(used_atom, /obj/item/weapon/screwdriver))
		playsound(holder, 'Screwdriver.ogg', 50, 1)

	else if(istype(used_atom, /obj/item/weapon/wirecutters))
		playsound(holder, 'Wirecutter.ogg', 50, 1)

	else if(istype(used_atom, /obj/item/weapon/cable_coil))
		var/obj/item/weapon/cable_coil/C = used_atom
		if(C.amount<4)
			user << ("There's not enough cable to finish the task.")
			return 0
		else
			C.use(4)
			playsound(holder, 'Deconstruct.ogg', 50, 1)
	else if(istype(used_atom, /obj/item/stack))
		var/obj/item/stack/S = used_atom
		if(S.amount < 5)
			user << ("There's not enough material in this stack.")
			return 0
		else
			S.use(5)
	return 1

/datum/construction/reversible/mecha/custom_action(index as num, diff as num, atom/used_atom, mob/user as mob)
	if(istype(used_atom, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/W = used_atom
		if (W:remove_fuel(0, user))
			playsound(holder, 'Welder2.ogg', 50, 1)
		else
			return 0
	else if(istype(used_atom, /obj/item/weapon/wrench))
		playsound(holder, 'Ratchet.ogg', 50, 1)

	else if(istype(used_atom, /obj/item/weapon/screwdriver))
		playsound(holder, 'Screwdriver.ogg', 50, 1)

	else if(istype(used_atom, /obj/item/weapon/wirecutters))
		playsound(holder, 'Wirecutter.ogg', 50, 1)

	else if(istype(used_atom, /obj/item/weapon/cable_coil))
		var/obj/item/weapon/cable_coil/C = used_atom
		if(C.amount<4)
			user << ("There's not enough cable to finish the task.")
			return 0
		else
			C.use(4)
			playsound(holder, 'Deconstruct.ogg', 50, 1)
	else if(istype(used_atom, /obj/item/stack))
		var/obj/item/stack/S = used_atom
		if(S.amount < 5)
			user << ("There's not enough material in this stack.")
			return 0
		else
			S.use(5)
	return 1


/datum/construction/mecha/ripley_chassis
	steps = list(list("key"=/obj/item/mecha_parts/part/ripley_torso),//1
					 list("key"=/obj/item/mecha_parts/part/ripley_left_arm),//2
					 list("key"=/obj/item/mecha_parts/part/ripley_right_arm),//3
					 list("key"=/obj/item/mecha_parts/part/ripley_left_leg),//4
					 list("key"=/obj/item/mecha_parts/part/ripley_right_leg)//5
					)

	custom_action(step, atom/used_atom, mob/user)
		user.visible_message("[user] has connected [used_atom] to [holder].", "You connect [used_atom] to [holder]")
		holder.overlays += used_atom.icon_state+"+o"
		del used_atom
		return 1

	action(atom/used_atom,mob/user as mob)
		return check_all_steps(used_atom,user)

	spawn_result()
		var/obj/item/mecha_parts/chassis/const_holder = holder
		const_holder.construct = new /datum/construction/reversible/mecha/ripley(const_holder)
		const_holder.icon = 'ripley_construct.dmi'
		const_holder.icon_state = "ripley_step_14"
		const_holder.density = 1
		const_holder.overlays.len = 0
		spawn()
			del src
		return


/datum/construction/reversible/mecha/ripley
	result = "/obj/mecha/working/ripley"
	steps = list(
					//1
					list("key"=/obj/item/weapon/weldingtool,
							"backkey"=/obj/item/weapon/wrench,
							"desc"="External armor is wrenched."),
					//2
					 list("key"=/obj/item/weapon/wrench,
					 		"backkey"=/obj/item/weapon/crowbar,
					 		"desc"="External armor is installed."),
					 //3
					 list("key"=/obj/item/stack/sheet/plasteel,
					 		"backkey"=/obj/item/weapon/weldingtool,
					 		"desc"="Internal armor is welded."),
					 //4
					 list("key"=/obj/item/weapon/weldingtool,
					 		"backkey"=/obj/item/weapon/wrench,
					 		"desc"="Internal armor is wrenched"),
					 //5
					 list("key"=/obj/item/weapon/wrench,
					 		"backkey"=/obj/item/weapon/crowbar,
					 		"desc"="Internal armor is installed"),
					 //6
					 list("key"=/obj/item/stack/sheet/metal,
					 		"backkey"=/obj/item/weapon/screwdriver,
					 		"desc"="Peripherals control module is secured"),
					 //7
					 list("key"=/obj/item/weapon/screwdriver,
					 		"backkey"=/obj/item/weapon/crowbar,
					 		"desc"="Peripherals control module is installed"),
					 //8
					 list("key"=/obj/item/weapon/circuitboard/mecha/ripley/peripherals,
					 		"backkey"=/obj/item/weapon/screwdriver,
					 		"desc"="Central control module is secured"),
					 //9
					 list("key"=/obj/item/weapon/screwdriver,
					 		"backkey"=/obj/item/weapon/crowbar,
					 		"desc"="Central control module is installed"),
					 //10
					 list("key"=/obj/item/weapon/circuitboard/mecha/ripley/main,
					 		"backkey"=/obj/item/weapon/screwdriver,
					 		"desc"="The wiring is adjusted"),
					 //11
					 list("key"=/obj/item/weapon/wirecutters,
					 		"backkey"=/obj/item/weapon/screwdriver,
					 		"desc"="The wiring is added"),
					 //12
					 list("key"=/obj/item/weapon/cable_coil,
					 		"backkey"=/obj/item/weapon/screwdriver,
					 		"desc"="The hydraulic systems are active."),
					 //13
					 list("key"=/obj/item/weapon/screwdriver,
					 		"backkey"=/obj/item/weapon/wrench,
					 		"desc"="The hydraulic systems are connected."),
					 //14
					 list("key"=/obj/item/weapon/wrench,
					 		"desc"="The hydraulic systems are disconnected.")
					)

	action(atom/used_atom,mob/user as mob)
		return check_step(used_atom,user)

	custom_action(index, diff, atom/used_atom, mob/user)
		if(!..())
			return 0

		//TODO: better messages.
		switch(index)
			if(14)
				user.visible_message("[user] connects [holder] hydraulic systems", "You connect [holder] hydraulic systems.")
				holder.icon_state = "ripley_step_13"
			if(13)
				if(diff==FORWARD)
					user.visible_message("[user] activates [holder] hydraulic systems.", "You activate [holder] hydraulic systems.")
					holder.icon_state = "ripley_step_12"
				else
					user.visible_message("[user] disconnects [holder] hydraulic systems", "You disconnect [holder] hydraulic systems.")
					holder.icon_state = "ripley_step_14"
			if(12)
				if(diff==FORWARD)
					user.visible_message("[user] adds the wiring to [holder].", "You add the wiring to [holder].")
					holder.icon_state = "ripley_step_11"
				else
					user.visible_message("[user] deactivates [holder] hydraulic systems.", "You deactivate [holder] hydraulic systems.")
					holder.icon_state = "ripley_step_13"
			if(11)
				if(diff==FORWARD)
					user.visible_message("[user] adjusts the wiring of [holder].", "You adjust the wiring of [holder].")
					holder.icon_state = "ripley_step_10"
				else
					user.visible_message("[user] removes the wiring from [holder].", "You remove the wiring from [holder].")
					var/obj/item/weapon/cable_coil/coil = new /obj/item/weapon/cable_coil(get_turf(holder))
					coil.amount = 4
					holder.icon_state = "ripley_step_12"
			if(10)
				if(diff==FORWARD)
					user.visible_message("[user] installs the central control module into [holder].", "You install the central computer mainboard into [holder].")
					del used_atom
					holder.icon_state = "ripley_step_9"
				else
					user.visible_message("[user] disconnects the wiring of [holder].", "You disconnect the wiring of [holder].")
					holder.icon_state = "ripley_step_11"
			if(9)
				if(diff==FORWARD)
					user.visible_message("[user] secures the mainboard.", "You secure the mainboard.")
					holder.icon_state = "ripley_step_8"
				else
					user.visible_message("[user] removes the central control module from [holder].", "You remove the central computer mainboard from [holder].")
					new /obj/item/weapon/circuitboard/mecha/ripley/main(get_turf(holder))
					holder.icon_state = "ripley_step_10"
			if(8)
				if(diff==FORWARD)
					user.visible_message("[user] installs the peripherals control module into [holder].", "You install the peripherals control module into [holder].")
					del used_atom
					holder.icon_state = "ripley_step_7"
				else
					user.visible_message("[user] unfastens the mainboard.", "You unfasten the mainboard.")
					holder.icon_state = "ripley_step_9"
			if(7)
				if(diff==FORWARD)
					user.visible_message("[user] secures the peripherals control module.", "You secure the peripherals control module.")
					holder.icon_state = "ripley_step_6"
				else
					user.visible_message("[user] removes the peripherals control module from [holder].", "You remove the peripherals control module from [holder].")
					new /obj/item/weapon/circuitboard/mecha/ripley/peripherals(get_turf(holder))
					holder.icon_state = "ripley_step_8"
			if(6)
				if(diff==FORWARD)
					user.visible_message("[user] installs internal armor layer to [holder].", "You install internal armor layer to [holder].")
					holder.icon_state = "ripley_step_5"
				else
					user.visible_message("[user] unfastens the peripherals control module.", "You unfasten the peripherals control module.")
					holder.icon_state = "ripley_step_7"
			if(5)
				if(diff==FORWARD)
					user.visible_message("[user] secures internal armor layer.", "You secure internal armor layer.")
					holder.icon_state = "ripley_step_4"
				else
					user.visible_message("[user] pries internal armor layer from [holder].", "You prie internal armor layer from [holder].")
					var/obj/item/stack/sheet/metal/MS = new /obj/item/stack/sheet/metal(get_turf(holder))
					MS.amount = 5
					holder.icon_state = "ripley_step_6"
			if(4)
				if(diff==FORWARD)
					user.visible_message("[user] welds internal armor layer to [holder].", "You weld the internal armor layer to [holder].")
					holder.icon_state = "ripley_step_3"
					flick("ripley_step_3active",holder)
				else
					user.visible_message("[user] unfastens the internal armor layer.", "You unfasten the internal armor layer.")
					holder.icon_state = "ripley_step_5"
			if(3)
				if(diff==FORWARD)
					user.visible_message("[user] installs external reinforced armor layer to [holder].", "You install external reinforced armor layer to [holder].")
				else
					user.visible_message("[user] cuts internal armor layer from [holder].", "You cut the internal armor layer from [holder].")
					holder.icon_state = "ripley_step_4"
					flick("ripley_step_3active",holder)
			if(2)
				if(diff==FORWARD)
					user.visible_message("[user] secures external armor layer.", "You secure external reinforced armor layer.")
				else
					user.visible_message("[user] pries external armor layer from [holder].", "You prie external armor layer from [holder].")
					var/obj/item/stack/sheet/plasteel/MS = new /obj/item/stack/sheet/plasteel(get_turf(holder))
					MS.amount = 5
			if(1)
				if(diff==FORWARD)
					user.visible_message("[user] welds external armor layer to [holder].", "You weld external armor layer to [holder].")
				else
					user.visible_message("[user] unfastens the external armor layer.", "You unfasten the external armor layer.")
		return 1

	spawn_result()
		..()
		feedback_inc("mecha_ripley_created",1)
		return



/datum/construction/mecha/gygax_chassis
	steps = list(list("key"=/obj/item/mecha_parts/part/gygax_torso),//1
					 list("key"=/obj/item/mecha_parts/part/gygax_left_arm),//2
					 list("key"=/obj/item/mecha_parts/part/gygax_right_arm),//3
					 list("key"=/obj/item/mecha_parts/part/gygax_left_leg),//4
					 list("key"=/obj/item/mecha_parts/part/gygax_right_leg),//5
					 list("key"=/obj/item/mecha_parts/part/gygax_head)
					)

	custom_action(step, atom/used_atom, mob/user)
		user.visible_message("[user] has connected [used_atom] to [holder].", "You connect [used_atom] to [holder]")
		holder.overlays += used_atom.icon_state+"+o"
		del used_atom
		return 1

	action(atom/used_atom,mob/user as mob)
		return check_all_steps(used_atom,user)

	spawn_result()
		var/obj/item/mecha_parts/chassis/const_holder = holder
		const_holder.construct = new /datum/construction/reversible/mecha/gygax(const_holder)
		const_holder.density = 1
		spawn()
			del src
		return


/datum/construction/reversible/mecha/gygax
	result = "/obj/mecha/combat/gygax"
	steps = list(
					//1
					list("key"=/obj/item/weapon/weldingtool,
							"backkey"=/obj/item/weapon/wrench,
							"desc"="External armor is wrenched."),
					 //2
					 list("key"=/obj/item/weapon/wrench,
					 		"backkey"=/obj/item/weapon/crowbar,
					 		"desc"="External armor is installed."),
					 //3
					 list("key"=/obj/item/mecha_parts/part/gygax_armour,
					 		"backkey"=/obj/item/weapon/weldingtool,
					 		"desc"="Internal armor is welded."),
					 //4
					 list("key"=/obj/item/weapon/weldingtool,
					 		"backkey"=/obj/item/weapon/wrench,
					 		"desc"="Internal armor is wrenched"),
					 //5
					 list("key"=/obj/item/weapon/wrench,
					 		"backkey"=/obj/item/weapon/crowbar,
					 		"desc"="Internal armor is installed"),
					 //6
					 list("key"=/obj/item/stack/sheet/metal,
					 		"backkey"=/obj/item/weapon/screwdriver,
					 		"desc"="Advanced capacitor is secured"),
					 //7
					 list("key"=/obj/item/weapon/screwdriver,
					 		"backkey"=/obj/item/weapon/crowbar,
					 		"desc"="Advanced capacitor is installed"),
					 //8
					 list("key"=/obj/item/weapon/stock_parts/capacitor/adv,
					 		"backkey"=/obj/item/weapon/screwdriver,
					 		"desc"="Advanced scanning module is secured"),
					 //9
					 list("key"=/obj/item/weapon/screwdriver,
					 		"backkey"=/obj/item/weapon/crowbar,
					 		"desc"="Advanced scanning module is installed"),
					 //10
					 list("key"=/obj/item/weapon/stock_parts/scanning_module/adv,
					 		"backkey"=/obj/item/weapon/screwdriver,
					 		"desc"="Targeting module is secured"),
					 //11
					 list("key"=/obj/item/weapon/screwdriver,
					 		"backkey"=/obj/item/weapon/crowbar,
					 		"desc"="Targeting module is installed"),
					 //12
					 list("key"=/obj/item/weapon/circuitboard/mecha/gygax/targeting,
					 		"backkey"=/obj/item/weapon/screwdriver,
					 		"desc"="Peripherals control module is secured"),
					 //13
					 list("key"=/obj/item/weapon/screwdriver,
					 		"backkey"=/obj/item/weapon/crowbar,
					 		"desc"="Peripherals control module is installed"),
					 //14
					 list("key"=/obj/item/weapon/circuitboard/mecha/gygax/peripherals,
					 		"backkey"=/obj/item/weapon/screwdriver,
					 		"desc"="Central control module is secured"),
					 //15
					 list("key"=/obj/item/weapon/screwdriver,
					 		"backkey"=/obj/item/weapon/crowbar,
					 		"desc"="Central control module is installed"),
					 //16
					 list("key"=/obj/item/weapon/circuitboard/mecha/gygax/main,
					 		"backkey"=/obj/item/weapon/screwdriver,
					 		"desc"="The wiring is adjusted"),
					 //17
					 list("key"=/obj/item/weapon/wirecutters,
					 		"backkey"=/obj/item/weapon/screwdriver,
					 		"desc"="The wiring is added"),
					 //18
					 list("key"=/obj/item/weapon/cable_coil,
					 		"backkey"=/obj/item/weapon/screwdriver,
					 		"desc"="The hydraulic systems are active."),
					 //19
					 list("key"=/obj/item/weapon/screwdriver,
					 		"backkey"=/obj/item/weapon/wrench,
					 		"desc"="The hydraulic systems are connected."),
					 //20
					 list("key"=/obj/item/weapon/wrench,
					 		"desc"="The hydraulic systems are disconnected.")
					)

	action(atom/used_atom,mob/user as mob)
		return check_step(used_atom,user)

	custom_action(index, diff, atom/used_atom, mob/user)
		if(!..())
			return 0

		//TODO: better messages.
		switch(index)
			if(20)
				user.visible_message("[user] connects [holder] hydraulic systems", "You connect [holder] hydraulic systems.")
			if(19)
				if(diff==FORWARD)
					user.visible_message("[user] activates [holder] hydraulic systems.", "You activate [holder] hydraulic systems.")
				else
					user.visible_message("[user] disconnects [holder] hydraulic systems", "You disconnect [holder] hydraulic systems.")
			if(18)
				if(diff==FORWARD)
					user.visible_message("[user] adds the wiring to [holder].", "You add the wiring to [holder].")
				else
					user.visible_message("[user] deactivates [holder] hydraulic systems.", "You deactivate [holder] hydraulic systems.")
			if(17)
				if(diff==FORWARD)
					user.visible_message("[user] adjusts the wiring of [holder].", "You adjust the wiring of [holder].")
				else
					user.visible_message("[user] removes the wiring from [holder].", "You remove the wiring from [holder].")
					var/obj/item/weapon/cable_coil/coil = new /obj/item/weapon/cable_coil(get_turf(holder))
					coil.amount = 4
			if(16)
				if(diff==FORWARD)
					user.visible_message("[user] installs the central control module into [holder].", "You install the central computer mainboard into [holder].")
					del used_atom
				else
					user.visible_message("[user] disconnects the wiring of [holder].", "You disconnect the wiring of [holder].")
			if(15)
				if(diff==FORWARD)
					user.visible_message("[user] secures the mainboard.", "You secure the mainboard.")
				else
					user.visible_message("[user] removes the central control module from [holder].", "You remove the central computer mainboard from [holder].")
					new /obj/item/weapon/circuitboard/mecha/gygax/main(get_turf(holder))
			if(14)
				if(diff==FORWARD)
					user.visible_message("[user] installs the peripherals control module into [holder].", "You install the peripherals control module into [holder].")
					del used_atom
				else
					user.visible_message("[user] unfastens the mainboard.", "You unfasten the mainboard.")
			if(13)
				if(diff==FORWARD)
					user.visible_message("[user] secures the peripherals control module.", "You secure the peripherals control module.")
				else
					user.visible_message("[user] removes the peripherals control module from [holder].", "You remove the peripherals control module from [holder].")
					new /obj/item/weapon/circuitboard/mecha/gygax/peripherals(get_turf(holder))
			if(12)
				if(diff==FORWARD)
					user.visible_message("[user] installs the weapon control module into [holder].", "You install the weapon control module into [holder].")
					del used_atom
				else
					user.visible_message("[user] unfastens the peripherals control module.", "You unfasten the peripherals control module.")
			if(11)
				if(diff==FORWARD)
					user.visible_message("[user] secures the weapon control module.", "You secure the weapon control module.")
				else
					user.visible_message("[user] removes the weapon control module from [holder].", "You remove the weapon control module from [holder].")
					new /obj/item/weapon/circuitboard/mecha/gygax/targeting(get_turf(holder))
			if(10)
				if(diff==FORWARD)
					user.visible_message("[user] installs advanced scanning module to [holder].", "You install advanced scanning module to [holder].")
					del used_atom
				else
					user.visible_message("[user] unfastens the weapon control module.", "You unfasten the weapon control module.")
			if(9)
				if(diff==FORWARD)
					user.visible_message("[user] secures the advanced scanning module.", "You secure the advanced scanning module.")
				else
					user.visible_message("[user] removes the advanced scanning module from [holder].", "You remove the advanced scanning module from [holder].")
					new /obj/item/weapon/stock_parts/scanning_module/adv(get_turf(holder))
			if(8)
				if(diff==FORWARD)
					user.visible_message("[user] installs advanced capacitor to [holder].", "You install advanced capacitor to [holder].")
					del used_atom
				else
					user.visible_message("[user] unfastens the advanced scanning module.", "You unfasten the advanced scanning module.")
			if(7)
				if(diff==FORWARD)
					user.visible_message("[user] secures the advanced capacitor.", "You secure the advanced capacitor.")
				else
					user.visible_message("[user] removes the advanced capacitor from [holder].", "You remove the advanced capacitor from [holder].")
					new /obj/item/weapon/stock_parts/capacitor/adv(get_turf(holder))
			if(6)
				if(diff==FORWARD)
					user.visible_message("[user] installs internal armor layer to [holder].", "You install internal armor layer to [holder].")
				else
					user.visible_message("[user] unfastens the advanced capacitor.", "You unfasten the advanced capacitor.")
			if(5)
				if(diff==FORWARD)
					user.visible_message("[user] secures internal armor layer.", "You secure internal armor layer.")
				else
					user.visible_message("[user] pries internal armor layer from [holder].", "You prie internal armor layer from [holder].")
					var/obj/item/stack/sheet/metal/MS = new /obj/item/stack/sheet/metal(get_turf(holder))
					MS.amount = 5
			if(4)
				if(diff==FORWARD)
					user.visible_message("[user] welds internal armor layer to [holder].", "You weld the internal armor layer to [holder].")
				else
					user.visible_message("[user] unfastens the internal armor layer.", "You unfasten the internal armor layer.")
			if(3)
				if(diff==FORWARD)
					user.visible_message("[user] installs Gygax Armour Plates to [holder].", "You install Gygax Armour Plates to [holder].")
					holder.overlays += used_atom.icon_state
					del used_atom
				else
					user.visible_message("[user] cuts internal armor layer from [holder].", "You cut the internal armor layer from [holder].")
			if(2)
				if(diff==FORWARD)
					user.visible_message("[user] secures Gygax Armour Plates.", "You secure Gygax Armour Plates.")
				else
					user.visible_message("[user] pries Gygax Armour Plates from [holder].", "You prie Gygax Armour Plates from [holder].")
					new /obj/item/mecha_parts/part/gygax_armour(get_turf(holder))
			if(1)
				if(diff==FORWARD)
					user.visible_message("[user] welds Gygax Armour Plates to [holder].", "You weld Gygax Armour Plates to [holder].")
				else
					user.visible_message("[user] unfastens Gygax Armour Plates.", "You unfasten Gygax Armour Plates.")
		return 1

	spawn_result()
		..()
		feedback_inc("mecha_gygax_created",1)
		return

/datum/construction/mecha/firefighter_chassis
	steps = list(list("key"=/obj/item/mecha_parts/part/ripley_torso),//1
					 list("key"=/obj/item/mecha_parts/part/ripley_left_arm),//2
					 list("key"=/obj/item/mecha_parts/part/ripley_right_arm),//3
					 list("key"=/obj/item/mecha_parts/part/ripley_left_leg),//4
					 list("key"=/obj/item/mecha_parts/part/ripley_right_leg),//5
					 list("key"=/obj/item/clothing/suit/fire)//6
					)

	custom_action(step, atom/used_atom, mob/user)
		user.visible_message("[user] has connected [used_atom] to [holder].", "You connect [used_atom] to [holder]")
		holder.overlays += used_atom.icon_state+"+o"
		del used_atom
		return 1

	action(atom/used_atom,mob/user as mob)
		return check_all_steps(used_atom,user)

	spawn_result()
		var/obj/item/mecha_parts/chassis/const_holder = holder
		const_holder.construct = new /datum/construction/reversible/mecha/firefighter(const_holder)
		const_holder.density = 1
		spawn()
			del src
		return


/datum/construction/reversible/mecha/firefighter
	result = "/obj/mecha/working/ripley/firefighter"
	steps = list(
					//1
					list("key"=/obj/item/weapon/weldingtool,
							"backkey"=/obj/item/weapon/wrench,
							"desc"="External armor is wrenched."),
					//2
					 list("key"=/obj/item/weapon/wrench,
					 		"backkey"=/obj/item/weapon/crowbar,
					 		"desc"="External armor is installed."),
					 //3
					 list("key"=/obj/item/stack/sheet/plasteel,
					 		"backkey"=/obj/item/weapon/crowbar,
					 		"desc"="External armor is being installed."),
					 //4
					 list("key"=/obj/item/stack/sheet/plasteel,
					 		"backkey"=/obj/item/weapon/weldingtool,
					 		"desc"="Internal armor is welded."),
					 //5
					 list("key"=/obj/item/weapon/weldingtool,
					 		"backkey"=/obj/item/weapon/wrench,
					 		"desc"="Internal armor is wrenched"),
					 //6
					 list("key"=/obj/item/weapon/wrench,
					 		"backkey"=/obj/item/weapon/crowbar,
					 		"desc"="Internal armor is installed"),

					 //7
					 list("key"=/obj/item/stack/sheet/plasteel,
					 		"backkey"=/obj/item/weapon/screwdriver,
					 		"desc"="Peripherals control module is secured"),
					 //8
					 list("key"=/obj/item/weapon/screwdriver,
					 		"backkey"=/obj/item/weapon/crowbar,
					 		"desc"="Peripherals control module is installed"),
					 //9
					 list("key"=/obj/item/weapon/circuitboard/mecha/ripley/peripherals,
					 		"backkey"=/obj/item/weapon/screwdriver,
					 		"desc"="Central control module is secured"),
					 //10
					 list("key"=/obj/item/weapon/screwdriver,
					 		"backkey"=/obj/item/weapon/crowbar,
					 		"desc"="Central control module is installed"),
					 //11
					 list("key"=/obj/item/weapon/circuitboard/mecha/ripley/main,
					 		"backkey"=/obj/item/weapon/screwdriver,
					 		"desc"="The wiring is adjusted"),
					 //12
					 list("key"=/obj/item/weapon/wirecutters,
					 		"backkey"=/obj/item/weapon/screwdriver,
					 		"desc"="The wiring is added"),
					 //13
					 list("key"=/obj/item/weapon/cable_coil,
					 		"backkey"=/obj/item/weapon/screwdriver,
					 		"desc"="The hydraulic systems are active."),
					 //14
					 list("key"=/obj/item/weapon/screwdriver,
					 		"backkey"=/obj/item/weapon/wrench,
					 		"desc"="The hydraulic systems are connected."),
					 //15
					 list("key"=/obj/item/weapon/wrench,
					 		"desc"="The hydraulic systems are disconnected.")
					)

	action(atom/used_atom,mob/user as mob)
		return check_step(used_atom,user)

	custom_action(index, diff, atom/used_atom, mob/user)
		if(!..())
			return 0

		//TODO: better messages.
		switch(index)
			if(15)
				user.visible_message("[user] connects [holder] hydraulic systems", "You connect [holder] hydraulic systems.")
			if(14)
				if(diff==FORWARD)
					user.visible_message("[user] activates [holder] hydraulic systems.", "You activate [holder] hydraulic systems.")
				else
					user.visible_message("[user] disconnects [holder] hydraulic systems", "You disconnect [holder] hydraulic systems.")
			if(13)
				if(diff==FORWARD)
					user.visible_message("[user] adds the wiring to [holder].", "You add the wiring to [holder].")
				else
					user.visible_message("[user] deactivates [holder] hydraulic systems.", "You deactivate [holder] hydraulic systems.")
			if(12)
				if(diff==FORWARD)
					user.visible_message("[user] adjusts the wiring of [holder].", "You adjust the wiring of [holder].")
				else
					user.visible_message("[user] removes the wiring from [holder].", "You remove the wiring from [holder].")
					var/obj/item/weapon/cable_coil/coil = new /obj/item/weapon/cable_coil(get_turf(holder))
					coil.amount = 4
			if(11)
				if(diff==FORWARD)
					user.visible_message("[user] installs the central control module into [holder].", "You install the central computer mainboard into [holder].")
					del used_atom
				else
					user.visible_message("[user] disconnects the wiring of [holder].", "You disconnect the wiring of [holder].")
			if(10)
				if(diff==FORWARD)
					user.visible_message("[user] secures the mainboard.", "You secure the mainboard.")
				else
					user.visible_message("[user] removes the central control module from [holder].", "You remove the central computer mainboard from [holder].")
					new /obj/item/weapon/circuitboard/mecha/ripley/main(get_turf(holder))
			if(9)
				if(diff==FORWARD)
					user.visible_message("[user] installs the peripherals control module into [holder].", "You install the peripherals control module into [holder].")
					del used_atom
				else
					user.visible_message("[user] unfastens the mainboard.", "You unfasten the mainboard.")
			if(8)
				if(diff==FORWARD)
					user.visible_message("[user] secures the peripherals control module.", "You secure the peripherals control module.")
				else
					user.visible_message("[user] removes the peripherals control module from [holder].", "You remove the peripherals control module from [holder].")
					new /obj/item/weapon/circuitboard/mecha/ripley/peripherals(get_turf(holder))
			if(7)
				if(diff==FORWARD)
					user.visible_message("[user] installs internal armor layer to [holder].", "You install internal armor layer to [holder].")
				else
					user.visible_message("[user] unfastens the peripherals control module.", "You unfasten the peripherals control module.")

			if(6)
				if(diff==FORWARD)
					user.visible_message("[user] secures internal armor layer.", "You secure internal armor layer.")
				else
					user.visible_message("[user] pries internal armor layer from [holder].", "You prie internal armor layer from [holder].")
					var/obj/item/stack/sheet/plasteel/MS = new /obj/item/stack/sheet/plasteel(get_turf(holder))
					MS.amount = 5
			if(5)
				if(diff==FORWARD)
					user.visible_message("[user] welds internal armor layer to [holder].", "You weld the internal armor layer to [holder].")
				else
					user.visible_message("[user] unfastens the internal armor layer.", "You unfasten the internal armor layer.")
			if(4)
				if(diff==FORWARD)
					user.visible_message("[user] starts to install the external armor layer to [holder].", "You start to install the external armor layer to [holder].")
				else
					user.visible_message("[user] cuts internal armor layer from [holder].", "You cut the internal armor layer from [holder].")
			if(3)
				if(diff==FORWARD)
					user.visible_message("[user] installs external reinforced armor layer to [holder].", "You install external reinforced armor layer to [holder].")
				else
					user.visible_message("[user] removes the external armor from [holder].", "You remove the external armor from [holder].")
					var/obj/item/stack/sheet/plasteel/MS = new /obj/item/stack/sheet/plasteel(get_turf(holder))
					MS.amount = 5
			if(2)
				if(diff==FORWARD)
					user.visible_message("[user] secures external armor layer.", "You secure external reinforced armor layer.")
				else
					user.visible_message("[user] pries external armor layer from [holder].", "You prie external armor layer from [holder].")
					var/obj/item/stack/sheet/plasteel/MS = new /obj/item/stack/sheet/plasteel(get_turf(holder))
					MS.amount = 5
			if(1)
				if(diff==FORWARD)
					user.visible_message("[user] welds external armor layer to [holder].", "You weld external armor layer to [holder].")
				else
					user.visible_message("[user] unfastens the external armor layer.", "You unfasten the external armor layer.")
		return 1

	spawn_result()
		..()
		feedback_inc("mecha_firefighter_created",1)
		return



/datum/construction/mecha/honker_chassis
	steps = list(list("key"=/obj/item/mecha_parts/part/honker_torso),//1
					 list("key"=/obj/item/mecha_parts/part/honker_left_arm),//2
					 list("key"=/obj/item/mecha_parts/part/honker_right_arm),//3
					 list("key"=/obj/item/mecha_parts/part/honker_left_leg),//4
					 list("key"=/obj/item/mecha_parts/part/honker_right_leg),//5
					 list("key"=/obj/item/mecha_parts/part/honker_head)
					)

	action(atom/used_atom,mob/user as mob)
		return check_all_steps(used_atom,user)

	custom_action(step, atom/used_atom, mob/user)
		user.visible_message("[user] has connected [used_atom] to [holder].", "You connect [used_atom] to [holder]")
		holder.overlays += used_atom.icon_state+"+o"
		del used_atom
		return 1

	spawn_result()
		var/obj/item/mecha_parts/chassis/const_holder = holder
		const_holder.construct = new /datum/construction/mecha/honker(const_holder)
		const_holder.density = 1
		spawn()
			del src
		return


/datum/construction/mecha/honker
	result = "/obj/mecha/combat/honker"
	steps = list(list("key"=/obj/item/weapon/bikehorn),//1
					 list("key"=/obj/item/clothing/shoes/clown_shoes),//2
					 list("key"=/obj/item/weapon/bikehorn),//3
					 list("key"=/obj/item/clothing/mask/gas/clown_hat),//4
					 list("key"=/obj/item/weapon/bikehorn),//5
					 list("key"=/obj/item/weapon/circuitboard/mecha/honker/targeting),//6
					 list("key"=/obj/item/weapon/bikehorn),//7
					 list("key"=/obj/item/weapon/circuitboard/mecha/honker/peripherals),//8
					 list("key"=/obj/item/weapon/bikehorn),//9
					 list("key"=/obj/item/weapon/circuitboard/mecha/honker/main),//10
					 list("key"=/obj/item/weapon/bikehorn),//11
					 )

	action(atom/used_atom,mob/user as mob)
		return check_step(used_atom,user)

	custom_action(step, atom/used_atom, mob/user)
		if(!..())
			return 0

		if(istype(used_atom, /obj/item/weapon/bikehorn))
			playsound(holder, 'bikehorn.ogg', 50, 1)
			user.visible_message("HONK!")

		//TODO: better messages.
		switch(step)
			if(10)
				user.visible_message("[user] installs the central control module into [holder].", "You install the central control module into [holder].")
				del used_atom
			if(8)
				user.visible_message("[user] installs the peripherals control module into [holder].", "You install the peripherals control module into [holder].")
				del used_atom
			if(6)
				user.visible_message("[user] installs the weapon control module into [holder].", "You install the weapon control module into [holder].")
				del used_atom
			if(4)
				user.visible_message("[user] puts clown wig and mask on [holder].", "You put clown wig and mask on [holder].")
				del used_atom
			if(2)
				user.visible_message("[user] puts clown boots on [holder].", "You put clown boots on [holder].")
				del used_atom
		return 1

	spawn_result()
		..()
		feedback_inc("mecha_honker_created",1)
		return

/datum/construction/mecha/durand_chassis
	steps = list(list("key"=/obj/item/mecha_parts/part/durand_torso),//1
					 list("key"=/obj/item/mecha_parts/part/durand_left_arm),//2
					 list("key"=/obj/item/mecha_parts/part/durand_right_arm),//3
					 list("key"=/obj/item/mecha_parts/part/durand_left_leg),//4
					 list("key"=/obj/item/mecha_parts/part/durand_right_leg),//5
					 list("key"=/obj/item/mecha_parts/part/durand_head)
					)

	custom_action(step, atom/used_atom, mob/user)
		user.visible_message("[user] has connected [used_atom] to [holder].", "You connect [used_atom] to [holder]")
		holder.overlays += used_atom.icon_state+"+o"
		del used_atom
		return 1

	action(atom/used_atom,mob/user as mob)
		return check_all_steps(used_atom,user)

	spawn_result()
		var/obj/item/mecha_parts/chassis/const_holder = holder
		const_holder.construct = new /datum/construction/mecha/durand(const_holder)
		const_holder.density = 1
		spawn()
			del src
		return

/datum/construction/mecha/durand
	result = "/obj/mecha/combat/durand"
	steps = list(list("key"=/obj/item/weapon/weldingtool),//1
					 list("key"=/obj/item/weapon/wrench),//2
					 list("key"=/obj/item/mecha_parts/part/durand_armour),//3
					 list("key"=/obj/item/weapon/weldingtool),//4
					 list("key"=/obj/item/weapon/wrench),//5
					 list("key"=/obj/item/stack/sheet/metal),//6
					 list("key"=/obj/item/weapon/screwdriver),//7
					 list("key"=/obj/item/weapon/stock_parts/capacitor/adv),//8
					 list("key"=/obj/item/weapon/screwdriver),//9
					 list("key"=/obj/item/weapon/stock_parts/scanning_module/adv),//10
					 list("key"=/obj/item/weapon/screwdriver),//11
					 list("key"=/obj/item/weapon/circuitboard/mecha/durand/targeting),//12
					 list("key"=/obj/item/weapon/screwdriver),//13
					 list("key"=/obj/item/weapon/circuitboard/mecha/durand/peripherals),//14
					 list("key"=/obj/item/weapon/screwdriver),//15
					 list("key"=/obj/item/weapon/circuitboard/mecha/durand/main),//16
					 list("key"=/obj/item/weapon/wirecutters),//17
					 list("key"=/obj/item/weapon/cable_coil),//18
					 list("key"=/obj/item/weapon/screwdriver),//19
					 list("key"=/obj/item/weapon/wrench)//20
					)

	action(atom/used_atom,mob/user as mob)
		return check_step(used_atom,user)

	custom_action(step, atom/used_atom, mob/user)
		if(!..())
			return 0

		//TODO: better messages.
		switch(step)
			if(20)
				user.visible_message("[user] connects [holder] hydraulic systems", "You connect [holder] hydraulic systems.")
			if(19)
				user.visible_message("[user] adjusts [holder] hydraulic systems.", "You adjust [holder] hydraulic systems.")
			if(18)
				user.visible_message("[user] adds the wiring to [holder].", "You add the wiring to [holder].")
			if(17)
				user.visible_message("[user] adjusts the wiring of [holder].", "You adjust the wiring of [holder].")
			if(16)
				user.visible_message("[user] installs the central control module into [holder].", "You install the central computer mainboard into [holder].")
				del used_atom
			if(15)
				user.visible_message("[user] secures the mainboard.", "You secure the mainboard.")
			if(14)
				user.visible_message("[user] installs the peripherals control module into [holder].", "You install the peripherals control module into [holder].")
				del used_atom
			if(13)
				user.visible_message("[user] secures the peripherals control module.", "You secure the peripherals control module.")
			if(12)
				user.visible_message("[user] installs the weapon control module into [holder].", "You install the weapon control module into [holder].")
				del used_atom
			if(11)
				user.visible_message("[user] secures the weapon control module.", "You secure the weapon control module.")
			if(10)
				user.visible_message("[user] installs advanced scanning module to [holder].", "You install advanced scanning module to [holder].")
				del used_atom
			if(9)
				user.visible_message("[user] secures the advanced scanning module.", "You secure the advanced scanning module.")
			if(8)
				user.visible_message("[user] installs advanced capacitor to [holder].", "You install advanced capacitor to [holder].")
				del used_atom
			if(7)
				user.visible_message("[user] secures the advanced capacitor.", "You secure the advanced capacitor.")
			if(6)
				user.visible_message("[user] installs internal armor layer to [holder].", "You install internal armor layer to [holder].")
			if(5)
				user.visible_message("[user] secures internal armor layer.", "You secure internal armor layer.")
			if(4)
				user.visible_message("[user] welds internal armor layer to [holder].", "You weld the internal armor layer to [holder].")
			if(3)
				user.visible_message("[user] installs Durand Armour Plates to [holder].", "You install Durand Armour Plates to [holder].")
				holder.overlays += used_atom.icon_state
				del used_atom
			if(2)
				user.visible_message("[user] secures Durand Armour Plates.", "You secure Durand Armour Plates.")
			if(1)
				user.visible_message("[user] welds Durand Armour Plates to [holder].", "You weld Durand Armour Plates to [holder].")
		return 1

	spawn_result()
		..()
		feedback_inc("mecha_durand_created",1)
		return


/datum/construction/mecha/phazon_chassis
	result = "/obj/mecha/combat/phazon"
	steps = list(list("key"=/obj/item/mecha_parts/part/phazon_torso),//1
					 list("key"=/obj/item/mecha_parts/part/phazon_left_arm),//2
					 list("key"=/obj/item/mecha_parts/part/phazon_right_arm),//3
					 list("key"=/obj/item/mecha_parts/part/phazon_left_leg),//4
					 list("key"=/obj/item/mecha_parts/part/phazon_right_leg),//5
					 list("key"=/obj/item/mecha_parts/part/phazon_head)
					)

	custom_action(step, atom/used_atom, mob/user)
		user.visible_message("[user] has connected [used_atom] to [holder].", "You connect [used_atom] to [holder]")
		holder.overlays += used_atom.icon_state+"+o"
		del used_atom
		return 1

	action(atom/used_atom,mob/user as mob)
		return check_all_steps(used_atom,user)




/datum/construction/mecha/odysseus_chassis
	steps = list(list("key"=/obj/item/mecha_parts/part/odysseus_torso),//1
					 list("key"=/obj/item/mecha_parts/part/odysseus_head),//2
					 list("key"=/obj/item/mecha_parts/part/odysseus_left_arm),//3
					 list("key"=/obj/item/mecha_parts/part/odysseus_right_arm),//4
					 list("key"=/obj/item/mecha_parts/part/odysseus_left_leg),//5
					 list("key"=/obj/item/mecha_parts/part/odysseus_right_leg)//6
					)

	custom_action(step, atom/used_atom, mob/user)
		user.visible_message("[user] has connected [used_atom] to [holder].", "You connect [used_atom] to [holder]")
		holder.overlays += used_atom.icon_state+"+o"
		del used_atom
		return 1

	action(atom/used_atom,mob/user as mob)
		return check_all_steps(used_atom,user)

	spawn_result()
		var/obj/item/mecha_parts/chassis/const_holder = holder
		const_holder.construct = new /datum/construction/reversible/mecha/odysseus(const_holder)
		const_holder.density = 1
		spawn()
			del src
		return


/datum/construction/reversible/mecha/odysseus
	result = "/obj/mecha/medical/odysseus"
	steps = list(
					//1
					list("key"=/obj/item/weapon/weldingtool,
							"backkey"=/obj/item/weapon/wrench,
							"desc"="External armor is wrenched."),
					//2
					 list("key"=/obj/item/weapon/wrench,
					 		"backkey"=/obj/item/weapon/crowbar,
					 		"desc"="External armor is installed."),
					 //3
					 list("key"=/obj/item/mecha_parts/part/odysseus_armour,
					 		"backkey"=/obj/item/weapon/weldingtool,
					 		"desc"="Internal armor is welded."),
					 //4
					 list("key"=/obj/item/weapon/weldingtool,
					 		"backkey"=/obj/item/weapon/wrench,
					 		"desc"="Internal armor is wrenched"),
					 //5
					 list("key"=/obj/item/weapon/wrench,
					 		"backkey"=/obj/item/weapon/crowbar,
					 		"desc"="Internal armor is installed"),
					 //6
					 list("key"=/obj/item/stack/sheet/metal,
					 		"backkey"=/obj/item/weapon/screwdriver,
					 		"desc"="Peripherals control module is secured"),
					 //7
					 list("key"=/obj/item/weapon/screwdriver,
					 		"backkey"=/obj/item/weapon/crowbar,
					 		"desc"="Peripherals control module is installed"),
					 //8
					 list("key"=/obj/item/weapon/circuitboard/mecha/odysseus/peripherals,
					 		"backkey"=/obj/item/weapon/screwdriver,
					 		"desc"="Central control module is secured"),
					 //9
					 list("key"=/obj/item/weapon/screwdriver,
					 		"backkey"=/obj/item/weapon/crowbar,
					 		"desc"="Central control module is installed"),
					 //10
					 list("key"=/obj/item/weapon/circuitboard/mecha/odysseus/main,
					 		"backkey"=/obj/item/weapon/screwdriver,
					 		"desc"="The wiring is adjusted"),
					 //11
					 list("key"=/obj/item/weapon/wirecutters,
					 		"backkey"=/obj/item/weapon/screwdriver,
					 		"desc"="The wiring is added"),
					 //12
					 list("key"=/obj/item/weapon/cable_coil,
					 		"backkey"=/obj/item/weapon/screwdriver,
					 		"desc"="The hydraulic systems are active."),
					 //13
					 list("key"=/obj/item/weapon/screwdriver,
					 		"backkey"=/obj/item/weapon/wrench,
					 		"desc"="The hydraulic systems are connected."),
					 //14
					 list("key"=/obj/item/weapon/wrench,
					 		"desc"="The hydraulic systems are disconnected.")
					)

	action(atom/used_atom,mob/user as mob)
		return check_step(used_atom,user)

	custom_action(index, diff, atom/used_atom, mob/user)
		if(!..())
			return 0

		//TODO: better messages.
		switch(index)
			if(14)
				user.visible_message("[user] connects [holder] hydraulic systems", "You connect [holder] hydraulic systems.")
			if(13)
				if(diff==FORWARD)
					user.visible_message("[user] activates [holder] hydraulic systems.", "You activate [holder] hydraulic systems.")
				else
					user.visible_message("[user] disconnects [holder] hydraulic systems", "You disconnect [holder] hydraulic systems.")
			if(12)
				if(diff==FORWARD)
					user.visible_message("[user] adds the wiring to [holder].", "You add the wiring to [holder].")
				else
					user.visible_message("[user] deactivates [holder] hydraulic systems.", "You deactivate [holder] hydraulic systems.")
			if(11)
				if(diff==FORWARD)
					user.visible_message("[user] adjusts the wiring of [holder].", "You adjust the wiring of [holder].")
				else
					user.visible_message("[user] removes the wiring from [holder].", "You remove the wiring from [holder].")
					var/obj/item/weapon/cable_coil/coil = new /obj/item/weapon/cable_coil(get_turf(holder))
					coil.amount = 4
			if(10)
				if(diff==FORWARD)
					user.visible_message("[user] installs the central control module into [holder].", "You install the central computer mainboard into [holder].")
					del used_atom
				else
					user.visible_message("[user] disconnects the wiring of [holder].", "You disconnect the wiring of [holder].")
			if(9)
				if(diff==FORWARD)
					user.visible_message("[user] secures the mainboard.", "You secure the mainboard.")
				else
					user.visible_message("[user] removes the central control module from [holder].", "You remove the central computer mainboard from [holder].")
					new /obj/item/weapon/circuitboard/mecha/odysseus/main(get_turf(holder))
			if(8)
				if(diff==FORWARD)
					user.visible_message("[user] installs the peripherals control module into [holder].", "You install the peripherals control module into [holder].")
					del used_atom
				else
					user.visible_message("[user] unfastens the mainboard.", "You unfasten the mainboard.")
			if(7)
				if(diff==FORWARD)
					user.visible_message("[user] secures the peripherals control module.", "You secure the peripherals control module.")
				else
					user.visible_message("[user] removes the peripherals control module from [holder].", "You remove the peripherals control module from [holder].")
					new /obj/item/weapon/circuitboard/mecha/odysseus/peripherals(get_turf(holder))
			if(6)
				if(diff==FORWARD)
					user.visible_message("[user] installs internal armor layer to [holder].", "You install internal armor layer to [holder].")
				else
					user.visible_message("[user] unfastens the peripherals control module.", "You unfasten the peripherals control module.")
			if(5)
				if(diff==FORWARD)
					user.visible_message("[user] secures internal armor layer.", "You secure internal armor layer.")
				else
					user.visible_message("[user] pries internal armor layer from [holder].", "You prie internal armor layer from [holder].")
					var/obj/item/stack/sheet/metal/MS = new /obj/item/stack/sheet/metal(get_turf(holder))
					MS.amount = 5
			if(4)
				if(diff==FORWARD)
					user.visible_message("[user] welds internal armor layer to [holder].", "You weld the internal armor layer to [holder].")
				else
					user.visible_message("[user] unfastens the internal armor layer.", "You unfasten the internal armor layer.")
			if(3)
				if(diff==FORWARD)
					user.visible_message("[user] installs [used_atom] layer to [holder].", "You install external reinforced armor layer to [holder].")
					holder.overlays += used_atom.icon_state
					del used_atom
				else
					user.visible_message("[user] cuts internal armor layer from [holder].", "You cut the internal armor layer from [holder].")
			if(2)
				if(diff==FORWARD)
					user.visible_message("[user] secures external armor layer.", "You secure external reinforced armor layer.")
				else
					var/obj/item/mecha_parts/part/odysseus_armour/MS = new /obj/item/mecha_parts/part/odysseus_armour(get_turf(holder))
					user.visible_message("[user] pries [MS] from [holder].", "You prie [MS] from [holder].")
			if(1)
				if(diff==FORWARD)
					user.visible_message("[user] welds external armor layer to [holder].", "You weld external armor layer to [holder].")
				else
					user.visible_message("[user] unfastens the external armor layer.", "You unfasten the external armor layer.")
		return 1

	spawn_result()
		..()
		feedback_inc("mecha_odysseus_created",1)
		return