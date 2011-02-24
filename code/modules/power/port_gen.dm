/* new portable generator - work in progress

/obj/machinery/power/port_gen
	name = "portable generator"
	desc = "A portable generator used for emergency backup power."
	icon = 'generator.dmi'
	icon_state = "off"
	density = 1
	anchored = 0
	directwired = 0
	var/t_status = 0
	var/t_per = 5000
	var/filter = 1
	var/tank = null
	var/turf/inturf
	var/starter = 0
	var/rpm = 0
	var/rpmtarget = 0
	var/capacity = 1e6
	var/turf/outturf
	var/lastgen


/obj/machinery/power/port_gen/process()
ideally we're looking to generate 5000

/obj/machinery/power/port_gen/attackby(obj/item/weapon/W, mob/user)
tank [un]loading stuff

/obj/machinery/power/port_gen/attack_hand(mob/user)
turn on/off

/obj/machinery/power/port_gen/examine()
display round(lastgen) and plasmatank amount

*/

//Previous code been here forever, adding new framework for portable generators


//Baseline portable generator. Has all the default handling. Not intended to be used on it's own (since it generates unlimited power).
/obj/machinery/power/port_gen
	name = "protable generator"
	desc = "A portable generator for emergency backup power"
	icon = 'power.dmi'
	icon_state = "portgen0"
	density = 1
	anchored = 0
	directwired = 1
	use_power = 0
	var
		active = 0
		power_gen = 5000
		open = 0
		recent_fault = 0

	proc
		HasFuel() //Placeholder for fuel check.
			return 1

		UseFuel() //Placeholder for fuel use.
			return

	process()
		if(active && HasFuel() && !crit_fail && powernet)
			if(prob(reliability)) add_avail(power_gen)
			else if(!recent_fault) recent_fault = 1
			else crit_fail = 1
			UseFuel()
		else
			active = 0
			icon_state = initial(icon_state)

	attack_hand(mob/user as mob)
		if(..())
			return
		if(!anchored)
			return

	examine()
		set src in oview(1)
		if(active)
			usr << "\blue The generator is on."
		else
			usr << "\blue The generator is off."

/obj/machinery/power/port_gen/pacman
	name = "P.A.C.M.A.N.-type Portable Generator"
	var
		plasma_coins = 0
		max_coins = 120

	New()
		..()
		component_parts = list()
		component_parts += new /obj/item/weapon/stock_parts/matter_bin(src)
		component_parts += new /obj/item/weapon/stock_parts/micro_laser(src)
		component_parts += new /obj/item/weapon/cable_coil(src)
		component_parts += new /obj/item/weapon/cable_coil(src)
		component_parts += new /obj/item/weapon/stock_parts/capacitor(src)
		component_parts += new /obj/item/weapon/circuitboard/pacman(src)
		RefreshParts()

	RefreshParts()
		var/temp_rating = 0
		var/temp_reliability = 0
		for(var/obj/item/weapon/stock_parts/SP in component_parts)
			if(istype(SP, /obj/item/weapon/stock_parts/matter_bin))
				max_coins = SP.rating * SP.rating * 120
			else if(istype(SP, /obj/item/weapon/stock_parts/micro_laser) || istype(SP, /obj/item/weapon/stock_parts/capacitor))
				temp_rating += SP.rating
		for(var/obj/item/weapon/CP in component_parts)
			temp_reliability += CP.reliability
		reliability = min(round(temp_reliability / 4), 100)
		power_gen = round(5000 * (max(2, temp_rating) / 2))

	examine()
		..()
		usr << "\blue The generator has [plasma_coins] units of fuel left, producing [power_gen] per cycle."
		if(crit_fail) usr << "\red The generator seems to have broken down."

	HasFuel()
		if(plasma_coins)
			return 1
		return 0

	UseFuel()
		if(plasma_coins)
			plasma_coins--
		return

	attackby(var/obj/item/O as obj, var/mob/user as mob)
		if(istype(O, /obj/item/weapon/coin/plasma))
			if(plasma_coins >= max_coins)
				user << "\red The generator already has it's maximum amount of fuel!"
				return
			plasma_coins++
			user.drop_item()
			del(O)
			user << "\blue You add a coin to the generator."

		else if(!active)
			if(istype(O, /obj/item/weapon/wrench))
				anchored = !anchored
				if(anchored)
					user << "\blue The generator is locked into place."
				else
					user << "\blue The generator is unbolted from the floor."
				makepowernets()
			else if(istype(O, /obj/item/weapon/screwdriver))
				open = !open
			else if(istype(O, /obj/item/weapon/crowbar) && !open)
				var/obj/machinery/constructable_frame/machine_frame/new_frame = new /obj/machinery/constructable_frame/machine_frame(src.loc)
				for(var/obj/item/I in component_parts)
					if(I.reliability < 100)
						I.crit_fail = 1
					I.loc = src.loc
				new_frame.state = 2
				new_frame.icon_state = "box_1"
				del(src)

	attack_hand(mob/user as mob)
		..()
		if(!active && HasFuel() && !crit_fail && powernet)
			active = 1
			icon_state = "portgen1"
			user << "\blue The generator is on."
		else if(active)
			active = 0
			icon_state = "portgen0"
			user << "\blue The generator is off."
