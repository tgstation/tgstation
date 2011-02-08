///////////////////////////
////// Mecha Chassis //////
///////////////////////////

/obj/mecha_chassis
	name="Mecha Chassis"
	icon = 'mech_construct.dmi'
	icon_state = "backbone"
	var/datum/construction/construct
	flags = FPRINT | CONDUCT

/obj/mecha_chassis/ripley
	name = "Ripley Chassis Frame"

	New()
		..()
		construct = new /datum/construction/mecha/ripley_chassis(src)

	attackby(obj/item/W as obj, mob/user as mob)
		if(istype(W, /obj/item/mecha_parts))
			if(construct)
				construct.check_all_steps(W, user)
		else
			..()
		return

/obj/mecha_chassis/ripley_full
	name = "Ripley Chassis"
	icon_state = "ripley_chassis"

	New()
		..()
		construct = new /datum/construction/mecha/ripley(src)

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if(!construct || !construct.check_step(W, user))
			..()
		return


/obj/mecha_chassis/gygax
	name = "Gygax Chassis Frame"

	New()
		..()
		construct = new /datum/construction/mecha/gygax_chassis(src)

	attackby(obj/item/W as obj, mob/user as mob)
		if(istype(W, /obj/item/mecha_parts))
			if(construct)
				construct.check_all_steps(W, user)
		else
			..()
		return

/obj/mecha_chassis/gygax_full
	name = "Gygax Chassis"
	icon_state = "gygax_chassis"

	New()
		..()
		construct = new /datum/construction/mecha/gygax(src)

	attackby(obj/item/weapon/W as obj, mob/user as mob)
		if(!construct || !construct.check_step(W, user))
			..()
		return

/////////////////////////
////// Mecha Parts //////
/////////////////////////


/obj/item/mecha_parts
	name = "mecha part"
	icon = 'mech_construct.dmi'
	icon_state = "blank"
	w_class = 20
	flags = FPRINT | TABLEPASS | CONDUCT

/////////// Ripley

/obj/item/mecha_parts/part/ripley_torso
	name="Ripley Torso"
	icon_state = "ripley_harness"

/obj/item/mecha_parts/part/ripley_left_arm
	name="Ripley Left Arm"
	icon_state = "ripley_l_arm"

/obj/item/mecha_parts/part/ripley_right_arm
	name="Ripley Right Arm"
	icon_state = "ripley_r_arm"

/obj/item/mecha_parts/part/ripley_left_leg
	name="Ripley Left Leg"
	icon_state = "ripley_l_leg"

/obj/item/mecha_parts/part/ripley_right_leg
	name="Ripley Right Leg"
	icon_state = "ripley_r_leg"

///////// Gygax

/obj/item/mecha_parts/part/gygax_torso
	name="Gygax Torso"
	icon_state = "gygax_harness"

/obj/item/mecha_parts/part/gygax_head
	name="Gygax Head"
	icon_state = "gygax_head"

/obj/item/mecha_parts/part/gygax_left_arm
	name="Gygax Left Arm"
	icon_state = "gygax_l_arm"

/obj/item/mecha_parts/part/gygax_right_arm
	name="Gygax Right Arm"
	icon_state = "gygax_r_arm"

/obj/item/mecha_parts/part/gygax_left_leg
	name="Gygax Left Leg"
	icon_state = "gygax_l_leg"

/obj/item/mecha_parts/part/gygax_right_leg
	name="Gygax Right Leg"
	icon_state = "gygax_r_leg"

/obj/item/mecha_parts/part/gygax_armour
	name="Gygax Armour Plates"
	icon_state = "gygax_armour"




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

	ripley/peripherals
		name = "Circuit board (Ripley Peripherals Control module)"
		icon_state = "mcontroller"

	ripley/main
		name = "Circuit board (Ripley Central Control module)"
		icon_state = "mainboard"

	gygax/peripherals
		name = "Circuit board (Gygax Peripherals Control module)"
		icon_state = "mcontroller"

	gygax/targeting
		name = "Circuit board (Weapon Control and Targeting module)"
		icon_state = "mcontroller"

	gygax/main
		name = "Circuit board (Gygax Central Control module)"
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
		if(C.amount<3)
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
	result = "/obj/mecha_chassis/ripley_full"
	steps = list(list("key"="/obj/item/mecha_parts/part/ripley_torso"),//1
					 list("key"="/obj/item/mecha_parts/part/ripley_left_arm"),//2
					 list("key"="/obj/item/mecha_parts/part/ripley_right_arm"),//3
					 list("key"="/obj/item/mecha_parts/part/ripley_left_leg"),//4
					 list("key"="/obj/item/mecha_parts/part/ripley_right_leg")//5
					)

	custom_action(step, atom/used_atom, mob/user)
/*
		switch(step)
			if(5)
			if(4)
			if(3)
			if(2)
			if(1)
*/
		user.visible_message("[user] has connected [used_atom] to [holder].", "You connect [used_atom] to [holder]")
		holder.overlays += used_atom.icon_state+"+o"
		del used_atom
		return 1


/datum/construction/mecha/ripley
	result = "/obj/mecha/working/ripley"
	steps = list(list("key"="/obj/item/weapon/weldingtool"),//1
					 list("key"="/obj/item/weapon/wrench"),//2
					 list("key"="/obj/item/stack/sheet/r_metal"),//3
					 list("key"="/obj/item/weapon/weldingtool"),//4
					 list("key"="/obj/item/weapon/wrench"),//5
					 list("key"="/obj/item/stack/sheet/metal"),//6
					 list("key"="/obj/item/weapon/screwdriver"),//7
					 list("key"="/obj/item/mecha_parts/circuitboard/ripley/peripherals"),//8
					 list("key"="/obj/item/weapon/screwdriver"),//9
					 list("key"="/obj/item/mecha_parts/circuitboard/ripley/main"),//10
					 list("key"="/obj/item/weapon/wirecutters"),//11
					 list("key"="/obj/item/weapon/cable_coil"),//12
					 list("key"="/obj/item/weapon/screwdriver"),//13
					 list("key"="/obj/item/weapon/wrench")//14
					)

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



/datum/construction/mecha/gygax_chassis
	result = "/obj/mecha_chassis/gygax_full"
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


/datum/construction/mecha/gygax
	result = "/obj/mecha/combat/gygax"
	steps = list(list("key"="/obj/item/weapon/weldingtool"),//1
					 list("key"="/obj/item/weapon/wrench"),//2
					 list("key"="/obj/item/mecha_parts/part/gygax_armour"),//3
					 list("key"="/obj/item/weapon/weldingtool"),//4
					 list("key"="/obj/item/weapon/wrench"),//5
					 list("key"="/obj/item/stack/sheet/metal"),//6
					 list("key"="/obj/item/weapon/wrench"),//7
					 list("key"="/obj/item/weapon/gun/energy/taser_gun"),//8
					 list("key"="/obj/item/weapon/wrench"),//9
					 list("key"="/obj/item/weapon/gun/energy/laser_gun"),//10
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
				user.visible_message("[user] installs the laser gun into the weapon socket.", "You install the laser gun into the weapon socket.")
				del used_atom
			if(9)
				user.visible_message("[user] secures the laser gun in place and connects it to [holder] powernet.", "You secure the laser gun in place and connect it to [holder] powernet.")
			if(8)
				user.visible_message("[user] installs the taser gun into the weapon socket.", "You install the taser gun into the weapon socket.")
				del used_atom
			if(7)
				user.visible_message("[user] secures the taser gun in place and connects it to [holder] powernet.", "You secure the taser gun in place and connect it to [holder] powernet.")
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



////////////////// misc ////////////////



/obj/item/weapon/book/manual/ripley_build_and_repair
	name = "APLU \"Ripley\" Construction and Operation Manual"
	icon = 'library.dmi'
	icon_state ="book"
	due_date = 0 // Game time in 1/10th seconds
	author = "Weyland-Yutani Corp"		 // Who wrote the thing, can be changed by pen or PC. It is not automatically assigned
	unique = 1   // 0 - Normal book, 1 - Should not be treated as normal book, unable to be copied, unable to be modified

//big pile of shit below.

	dat = {"<html>
				<head>
				<style>
				h1 {font-size: 18px; margin: 15px 0px 5px;}
				h2 {font-size: 15px; margin: 15px 0px 5px;}
				li {margin: 2px 0px 2px 15px;}
				ul {list-style: none; margin: 5px; padding: 0px;}
				ol {margin: 5px; padding: 0px 15px;}
				</style>
				</head>
				<body>
				<center>
				<b style='font-size: 12px;'>Weyland-Yutani - Building Better Worlds</b>
				<h1>Autonomous Power Loader Unit \"Ripley\"</h1>
				</center>
				<h2>Specifications:</h2>
				<ul>
				<li><b>Class:</b> Autonomous Power Loader</li>
				<li><b>Scope:</b> Logistics and Construction</li>
				<li><b>Weight:</b> 820kg (without operator and with empty cargo compartment)</li>
				<li><b>Height:</b> 2.5m</li>
				<li><b>Width:</b> 1.8m</li>
				<li><b>Top speed:</b> 5km/hour</li>
				<li><b>Operation in vacuum/hostile environment:</b> Possible</b>
				<li><b>Airtank Volume:</b> 500liters</li>
				<li><b>Devices:</b>
					<ul>
					<li>Hydraulic Clamp</li>
					<li>High-speed Drill</li>
					</ul>
				</li>
				<li><b>Propulsion Device:</b> Powercell-powered electro-hydraulic system.</li>
				<li><b>Powercell capacity:</b> Varies.</li>
				</ul>

				<h2>Construction:</h2>
				<ol>
				<li>Connect all exosuit parts to the chassis frame</li>
				<li>Connect all hydraulic fittings and tighten them up with a wrench</li>
				<li>Adjust the servohydraulics with a screwdriver</li>
				<li>Wire the chassis. (Cable is not included.)</li>
				<li>Use the wirecutters to remove the excess cable if needed.</li>
				<li>Install the central control module (Not included. Use supplied datadisk to create one).</li>
				<li>Secure the mainboard with a screwdriver.</li>
				<li>Install the peripherals control module (Not included. Use supplied datadisk to create one).</li>
				<li>Secure the mainboard with a screwdriver</li>
				<li>Install the internal armor plating (Not included due to Nanotrasen regulations.)</li>
				<li>Secure the internal armor plating with a wrench</li>
				<li>Weld the internal armor plating to the chassis</li>
				<li>Install the external reinforced armor plating (Not included due to Nanotrasen regulations.)</li>
				<li>Secure the external reinforced armor plating with a wrench</li>
				<li>Weld the external reinforced armor plating to the chassis</li>
				</ol>
				</body>
				</html>

				<h2>Operation</h2>
				Coming soon...
			"}
