/////////////////////////
////// Mecha Parts //////
/////////////////////////

/obj/item/mecha_parts
	name = "mecha part"
	icon = 'mech_construct.dmi'
	icon_state = "blank"
	w_class = 20
	flags = FPRINT | TABLEPASS | CONDUCT
	origin_tech = "programming=2;materials=2"
	var/construction_time = 100
	var/list/construction_cost = list("metal"=20000,"glass"=5000)


/obj/item/mecha_parts/chassis
	name="Mecha Chassis"
	icon_state = "backbone"
	var/datum/construction/construct
	flags = FPRINT | CONDUCT

	attackby(obj/item/W as obj, mob/user as mob)
		if(!construct || !construct.action(W, user))
			..()
		return

	attack_hand()
		return

/////////// Ripley

/obj/item/mecha_parts/chassis/ripley
	name = "Ripley Chassis"

	New()
		..()
		construct = new /datum/construction/mecha/ripley_chassis(src)

/obj/item/mecha_parts/part/ripley_torso
	name="Ripley Torso"
	icon_state = "ripley_harness"
	construction_time = 300
	construction_cost = list("metal"=40000,"glass"=15000)

/obj/item/mecha_parts/part/ripley_left_arm
	name="Ripley Left Arm"
	icon_state = "ripley_l_arm"
	construction_time = 200
	construction_cost = list("metal"=25000)

/obj/item/mecha_parts/part/ripley_right_arm
	name="Ripley Right Arm"
	icon_state = "ripley_r_arm"
	construction_time = 200
	construction_cost = list("metal"=25000)

/obj/item/mecha_parts/part/ripley_left_leg
	name="Ripley Left Leg"
	icon_state = "ripley_l_leg"
	construction_time = 200
	construction_cost = list("metal"=30000)

/obj/item/mecha_parts/part/ripley_right_leg
	name="Ripley Right Leg"
	icon_state = "ripley_r_leg"
	construction_time = 200
	construction_cost = list("metal"=30000)

///////// Gygax

/obj/item/mecha_parts/chassis/gygax
	name = "Gygax Chassis"
	construction_cost = list("metal"=25000)

	New()
		..()
		construct = new /datum/construction/mecha/gygax_chassis(src)

/obj/item/mecha_parts/part/gygax_torso
	name="Gygax Torso"
	icon_state = "gygax_harness"
	origin_tech = "programming=3;materials=4;biotech=1"
	construction_time = 300
	construction_cost = list("metal"=50000,"glass"=20000)

/obj/item/mecha_parts/part/gygax_head
	name="Gygax Head"
	icon_state = "gygax_head"
	origin_tech = "programming=3;materials=4;magnets=3"
	construction_time = 200
	construction_cost = list("metal"=20000,"glass"=10000)

/obj/item/mecha_parts/part/gygax_left_arm
	name="Gygax Left Arm"
	icon_state = "gygax_l_arm"
	origin_tech = "programming=3;materials=4"
	construction_time = 200
	construction_cost = list("metal"=30000,"glass"=20000)

/obj/item/mecha_parts/part/gygax_right_arm
	name="Gygax Right Arm"
	icon_state = "gygax_r_arm"
	origin_tech = "programming=3;materials=4"
	construction_time = 200
	construction_cost = list("metal"=30000,"glass"=20000)

/obj/item/mecha_parts/part/gygax_left_leg
	name="Gygax Left Leg"
	icon_state = "gygax_l_leg"
	origin_tech = "programming=3;materials=4"
	construction_time = 200
	construction_cost = list("metal"=35000,"glass"=20000)

/obj/item/mecha_parts/part/gygax_right_leg
	name="Gygax Right Leg"
	icon_state = "gygax_r_leg"
	origin_tech = "programming=3;materials=4"
	construction_time = 200
	construction_cost = list("metal"=35000,"glass"=20000)

/obj/item/mecha_parts/part/gygax_armour
	name="Gygax Armour Plates"
	icon_state = "gygax_armour"
	origin_tech = "materials=5;combat=4"
	construction_time = 600
	construction_cost = list("metal"=75000,"diamond"=10000)

////////// Firefighter

/obj/item/mecha_parts/chassis/firefighter
	name = "Ripley-on-Fire Chassis"

	New()
		..()
		construct = new /datum/construction/mecha/firefighter_chassis(src)

/obj/item/mecha_parts/part/firefighter_torso
	name="Ripley-on-Fire Torso"
	icon_state = "ripley_harness"

/obj/item/mecha_parts/part/firefighter_left_arm
	name="Ripley-on-Fire Left Arm"
	icon_state = "ripley_l_arm"

/obj/item/mecha_parts/part/firefighter_right_arm
	name="Ripley-on-Fire Right Arm"
	icon_state = "ripley_r_arm"

/obj/item/mecha_parts/part/firefighter_left_leg
	name="Ripley-on-Fire Left Leg"
	icon_state = "ripley_l_leg"

/obj/item/mecha_parts/part/firefighter_right_leg
	name="Ripley-on-Fire Right Leg"
	icon_state = "ripley_r_leg"


////////// HONK

/obj/item/mecha_parts/chassis/honker
	name = "H.O.N.K Chassis"

	New()
		..()
		construct = new /datum/construction/mecha/honker_chassis(src)

/obj/item/mecha_parts/part/honker_torso
	name="H.O.N.K Torso"
	icon_state = "honker_harness"
	construction_time = 300
	construction_cost = list("metal"=35000,"glass"=10000,"bananium"=10000)

/obj/item/mecha_parts/part/honker_head
	name="H.O.N.K Head"
	icon_state = "honker_head"
	construction_time = 200
	construction_cost = list("metal"=15000,"glass"=5000,"bananium"=5000)

/obj/item/mecha_parts/part/honker_left_arm
	name="H.O.N.K Left Arm"
	icon_state = "honker_l_arm"
	construction_time = 200
	construction_cost = list("metal"=20000,"bananium"=5000)

/obj/item/mecha_parts/part/honker_right_arm
	name="H.O.N.K Right Arm"
	icon_state = "honker_r_arm"
	construction_time = 200
	construction_cost = list("metal"=20000,"bananium"=5000)

/obj/item/mecha_parts/part/honker_left_leg
	name="H.O.N.K Left Leg"
	icon_state = "honker_l_leg"
	construction_time = 200
	construction_cost = list("metal"=20000,"bananium"=5000)

/obj/item/mecha_parts/part/honker_right_leg
	name="H.O.N.K Right Leg"
	icon_state = "honker_r_leg"
	construction_time = 200
	construction_cost = list("metal"=20000,"bananium"=5000)


/obj/item/mecha_parts/circuitboard
	name = "Exosuit Circuit board"
	icon = 'module.dmi'
	icon_state = "std_mod"
	item_state = "electronic"
	flags = FPRINT | TABLEPASS| CONDUCT
	force = 5.0
	w_class = 2.0
	throwforce = 5.0
	throw_speed = 3
	throw_range = 15

	ripley
		origin_tech = "programming=3;materials=1"

	ripley/peripherals
		name = "Circuit board (Ripley Peripherals Control module)"
		icon_state = "mcontroller"

	ripley/main
		name = "Circuit board (Ripley Central Control module)"
		icon_state = "mainboard"

	gygax
		origin_tech = "programming=4;materials=2"

	gygax/peripherals
		name = "Circuit board (Gygax Peripherals Control module)"
		icon_state = "mcontroller"

	gygax/targeting
		name = "Circuit board (Gygax Weapon Control and Targeting module)"
		icon_state = "mcontroller"
		origin_tech = "programming=3;materials=1;combat=3"

	gygax/main
		name = "Circuit board (Gygax Central Control module)"
		icon_state = "mainboard"

	firefighter/peripherals
		name = "Circuit board (Ripley-on-Fire Peripherals Control module)"
		icon_state = "mcontroller"

	honker
		origin_tech = "programming=3;materials=2"

	honker/peripherals
		name = "Circuit board (H.O.N.K Peripherals Control module)"
		icon_state = "mcontroller"

	honker/targeting
		name = "Circuit board (H.O.N.K Weapon Control and Targeting module)"
		icon_state = "mcontroller"

	honker/main
		name = "Circuit board (H.O.N.K Central Control module)"
		icon_state = "mainboard"


////////////////////////////////
///// Construction datums //////
////////////////////////////////

/datum/construction/mecha/custom_action(step, atom/used_atom, mob/user)
	if(istype(used_atom, /obj/item/weapon/weldingtool))
		var/obj/item/weapon/weldingtool/W = used_atom
		if (W:remove_fuel(2, user))
			playsound(holder, 'Welder2.ogg', 50, 1)
		else
			return 0
	else if(istype(used_atom, /obj/item/weapon/wrench))
		playsound(holder, 'Ratchet.ogg', 50, 1)

	else if(istype(used_atom, /obj/item/weapon/wirecutters))
		playsound(holder, 'Wirecutter.ogg', 50, 1)

	else if(istype(used_atom, /obj/item/weapon/cable_coil))
		var/obj/item/weapon/cable_coil/C = used_atom
		if(C.amount<4)
			user << ("There's not enough cable to finish the task.")
			return 0
		else
			C.use(4)
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
		if (W:remove_fuel(2, user))
			playsound(holder, 'Welder2.ogg', 50, 1)
		else
			return 0
	else if(istype(used_atom, /obj/item/weapon/wrench))
		playsound(holder, 'Ratchet.ogg', 50, 1)

	else if(istype(used_atom, /obj/item/weapon/wirecutters))
		playsound(holder, 'Wirecutter.ogg', 50, 1)

	else if(istype(used_atom, /obj/item/weapon/cable_coil))
		var/obj/item/weapon/cable_coil/C = used_atom
		if(C.amount<4)
			user << ("There's not enough cable to finish the task.")
			return 0
		else
			C.use(4)
	else if(istype(used_atom, /obj/item/stack))
		var/obj/item/stack/S = used_atom
		if(S.amount < 5)
			user << ("There's not enough material in this stack.")
			return 0
		else
			S.use(5)
	return 1


/datum/construction/mecha/ripley_chassis
	steps = list(list("key"="/obj/item/mecha_parts/part/ripley_torso"),//1
					 list("key"="/obj/item/mecha_parts/part/ripley_left_arm"),//2
					 list("key"="/obj/item/mecha_parts/part/ripley_right_arm"),//3
					 list("key"="/obj/item/mecha_parts/part/ripley_left_leg"),//4
					 list("key"="/obj/item/mecha_parts/part/ripley_right_leg")//5
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
		const_holder.density = 1
		spawn()
			del src
		return


/datum/construction/reversible/mecha/ripley
	result = "/obj/mecha/working/ripley"
	steps = list(list("key"=/obj/item/weapon/weldingtool,"backkey"=/obj/item/weapon/wrench),//1
					 list("key"=/obj/item/weapon/wrench,"backkey"=/obj/item/weapon/crowbar),//2
					 list("key"=/obj/item/stack/sheet/r_metal,"backkey"=/obj/item/weapon/weldingtool),//3
					 list("key"=/obj/item/weapon/weldingtool,"backkey"=/obj/item/weapon/wrench),//4
					 list("key"=/obj/item/weapon/wrench,"backkey"=/obj/item/weapon/crowbar),//5
					 list("key"=/obj/item/stack/sheet/metal,"backkey"=/obj/item/weapon/screwdriver),//6
					 list("key"=/obj/item/weapon/screwdriver,"backkey"=/obj/item/weapon/crowbar),//7
					 list("key"=/obj/item/mecha_parts/circuitboard/ripley/peripherals,"backkey"=/obj/item/weapon/screwdriver),//8
					 list("key"=/obj/item/weapon/screwdriver,"backkey"=/obj/item/weapon/crowbar),//9
					 list("key"=/obj/item/mecha_parts/circuitboard/ripley/main,"backkey"=/obj/item/weapon/screwdriver),//10
					 list("key"=/obj/item/weapon/wirecutters,"backkey"=/obj/item/weapon/screwdriver),//11
					 list("key"=/obj/item/weapon/cable_coil,"backkey"=/obj/item/weapon/screwdriver),//12
					 list("key"=/obj/item/weapon/screwdriver,"backkey"=/obj/item/weapon/wrench),//13
					 list("key"=/obj/item/weapon/wrench)//14
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
					new /obj/item/mecha_parts/circuitboard/ripley/main(get_turf(holder))
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
					new /obj/item/mecha_parts/circuitboard/ripley/peripherals(get_turf(holder))
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
					user.visible_message("[user] installs external reinforced armor layer to [holder].", "You install external reinforced armor layer to [holder].")
				else
					user.visible_message("[user] cuts internal armor layer from [holder].", "You cut the internal armor layer from [holder].")
			if(2)
				if(diff==FORWARD)
					user.visible_message("[user] secures external armor layer.", "You secure external reinforced armor layer.")
				else
					user.visible_message("[user] pries external armor layer from [holder].", "You prie external armor layer from [holder].")
					var/obj/item/stack/sheet/r_metal/MS = new /obj/item/stack/sheet/r_metal(get_turf(holder))
					MS.amount = 5
			if(1)
				if(diff==FORWARD)
					user.visible_message("[user] welds external armor layer to [holder].", "You weld external armor layer to [holder].")
				else
					user.visible_message("[user] unfastens the external armor layer.", "You unfasten the external armor layer.")
		return 1



/datum/construction/mecha/gygax_chassis
	steps = list(list("key"="/obj/item/mecha_parts/part/gygax_torso"),//1
					 list("key"="/obj/item/mecha_parts/part/gygax_left_arm"),//2
					 list("key"="/obj/item/mecha_parts/part/gygax_right_arm"),//3
					 list("key"="/obj/item/mecha_parts/part/gygax_left_leg"),//4
					 list("key"="/obj/item/mecha_parts/part/gygax_right_leg"),//5
					 list("key"="/obj/item/mecha_parts/part/gygax_head")
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
		const_holder.construct = new /datum/construction/mecha/gygax(const_holder)
		const_holder.density = 1
		spawn()
			del src
		return



/datum/construction/mecha/gygax
	result = "/obj/mecha/combat/gygax"
	steps = list(list("key"="/obj/item/weapon/weldingtool"),//1
					 list("key"="/obj/item/weapon/wrench"),//2
					 list("key"="/obj/item/mecha_parts/part/gygax_armour"),//3
					 list("key"="/obj/item/weapon/weldingtool"),//4
					 list("key"="/obj/item/weapon/wrench"),//5
					 list("key"="/obj/item/stack/sheet/metal"),//6
					 list("key"="/obj/item/weapon/screwdriver"),//7
					 list("key"="/obj/item/weapon/stock_parts/capacitor/adv"),//8
					 list("key"="/obj/item/weapon/screwdriver"),//9
					 list("key"="/obj/item/weapon/stock_parts/scanning_module/adv"),//10
					 list("key"="/obj/item/weapon/screwdriver"),//11
					 list("key"="/obj/item/mecha_parts/circuitboard/gygax/targeting"),//12
					 list("key"="/obj/item/weapon/screwdriver"),//13
					 list("key"="/obj/item/mecha_parts/circuitboard/gygax/peripherals"),//14
					 list("key"="/obj/item/weapon/screwdriver"),//15
					 list("key"="/obj/item/mecha_parts/circuitboard/gygax/main"),//16
					 list("key"="/obj/item/weapon/wirecutters"),//17
					 list("key"="/obj/item/weapon/cable_coil"),//18
					 list("key"="/obj/item/weapon/screwdriver"),//19
					 list("key"="/obj/item/weapon/wrench")//20
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
				user.visible_message("[user] installs advanced scanner module to [holder].", "You install advanced scanner module to [holder].")
				del used_atom
			if(9)
				user.visible_message("[user] secures the advanced scanner module.", "You secure the advanced scanner module.")
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
				user.visible_message("[user] installs Gygax Armour Plates to [holder].", "You install Gygax Armour Plates to [holder].")
				holder.overlays += used_atom.icon_state
				del used_atom
			if(2)
				user.visible_message("[user] secures Gygax Armour Plates.", "You secure Gygax Armour Plates.")
			if(1)
				user.visible_message("[user] welds Gygax Armour Plates to [holder].", "You weld Gygax Armour Plates to [holder].")
		return 1


/datum/construction/mecha/firefighter_chassis
	steps = list(list("key"="/obj/item/mecha_parts/part/firefighter_torso"),//1
					 list("key"="/obj/item/mecha_parts/part/firefighter_left_arm"),//2
					 list("key"="/obj/item/mecha_parts/part/firefighter_right_arm"),//3
					 list("key"="/obj/item/mecha_parts/part/firefighter_left_leg"),//4
					 list("key"="/obj/item/mecha_parts/part/firefighter_right_leg")//5
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
		const_holder.construct = new /datum/construction/mecha/firefighter(const_holder)
		const_holder.density = 1
		spawn()
			del src
		return


/datum/construction/mecha/firefighter
	result = "/obj/mecha/working/firefighter"
	steps = list(list("key"="/obj/item/weapon/weldingtool"),//1
					 list("key"="/obj/item/weapon/wrench"),//2
					 list("key"="/obj/item/stack/sheet/r_metal"),//3
					 list("key"="/obj/item/weapon/weldingtool"),//4
					 list("key"="/obj/item/weapon/wrench"),//5
					 list("key"="/obj/item/stack/sheet/metal"),//6
					 list("key"="/obj/item/weapon/screwdriver"),//7
					 list("key"="/obj/item/mecha_parts/circuitboard/firefighter/peripherals"),//8
					 list("key"="/obj/item/weapon/screwdriver"),//9
					 list("key"="/obj/item/mecha_parts/circuitboard/ripley/main"),//10
					 list("key"="/obj/item/weapon/wirecutters"),//11
					 list("key"="/obj/item/weapon/cable_coil"),//12
					 list("key"="/obj/item/weapon/screwdriver"),//13
					 list("key"="/obj/item/weapon/wrench")//14
					)

	action(atom/used_atom,mob/user as mob)
		return check_step(used_atom,user)


	custom_action(step, atom/used_atom, mob/user)
		if(!..())
			return 0

		//TODO: better messages.
		switch(step)
			if(14)
				user.visible_message("[user] connects [holder] hydraulic systems", "You connect [holder] hydraulic systems.")
			if(13)
				user.visible_message("[user] adjusts [holder] hydraulic systems.", "You adjust [holder] hydraulic systems.")
			if(12)
				user.visible_message("[user] adds the wiring to [holder].", "You add the wiring to [holder].")
			if(11)
				user.visible_message("[user] adjusts the wiring of [holder].", "You adjust the wiring of [holder].")
			if(10)
				user.visible_message("[user] installs the central control module into [holder].", "You install the central computer mainboard into [holder].")
				del used_atom
			if(9)
				user.visible_message("[user] secures the mainboard.", "You secure the mainboard.")
			if(8)
				user.visible_message("[user] installs the peripherals control module into [holder].", "You install the peripherals control module into [holder].")
				del used_atom
			if(7)
				user.visible_message("[user] secures the peripherals control module.", "You secure the peripherals control module.")
			if(6)
				user.visible_message("[user] installs internal armor layer to [holder].", "You install internal armor layer to [holder].")
			if(5)
				user.visible_message("[user] secures internal armor layer.", "You secure internal armor layer.")
			if(4)
				user.visible_message("[user] welds internal armor layer to [holder].", "You weld the internal armor layer to [holder].")
			if(3)
				user.visible_message("[user] installs external reinforced armor layer to [holder].", "You install external reinforced armor layer to [holder].")
			if(2)
				user.visible_message("[user] secures external armor layer.", "You secure external reinforced armor layer.")
			if(1)
				user.visible_message("[user] welds external armor layer to [holder].", "You weld external armor layer to [holder].")
		return 1



/datum/construction/mecha/honker_chassis
	steps = list(list("key"="/obj/item/mecha_parts/part/honker_torso"),//1
					 list("key"="/obj/item/mecha_parts/part/honker_left_arm"),//2
					 list("key"="/obj/item/mecha_parts/part/honker_right_arm"),//3
					 list("key"="/obj/item/mecha_parts/part/honker_left_leg"),//4
					 list("key"="/obj/item/mecha_parts/part/honker_right_leg"),//5
					 list("key"="/obj/item/mecha_parts/part/honker_head")
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
	steps = list(list("key"="/obj/item/weapon/bikehorn"),//1
					 list("key"="/obj/item/clothing/shoes/clown_shoes"),//2
					 list("key"="/obj/item/weapon/bikehorn"),//3
					 list("key"="/obj/item/clothing/mask/gas/clown_hat"),//4
					 list("key"="/obj/item/weapon/bikehorn"),//5
					 list("key"="/obj/item/mecha_parts/circuitboard/honker/targeting"),//6
					 list("key"="/obj/item/weapon/bikehorn"),//7
					 list("key"="/obj/item/mecha_parts/circuitboard/honker/peripherals"),//8
					 list("key"="/obj/item/weapon/bikehorn"),//9
					 list("key"="/obj/item/mecha_parts/circuitboard/honker/main"),//10
					 list("key"="/obj/item/weapon/bikehorn"),//11
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




////////////////// misc ////////////////



