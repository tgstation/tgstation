//This file was auto-corrected by findeclaration.exe on 25.5.2012 20:42:33

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
	name = "Portable Generator"
	desc = "A portable generator for emergency backup power"
	icon = 'icons/obj/power.dmi'
	icon_state = "portgen0"
	density = 1
	anchored = 0
	directwired = 1
	use_power = 0

	var/active = 0
	var/power_gen = 5000
	var/open = 0
	var/recent_fault = 0
	var/power_output = 1

	proc/HasFuel() //Placeholder for fuel check.
		return 1

	proc/UseFuel() //Placeholder for fuel use.
		return

	proc/handleInactive()
		return

	process()
		if(active && HasFuel() && !crit_fail && anchored)
			if(prob(reliability))
				add_avail(power_gen * power_output)
			else if(!recent_fault)
				recent_fault = 1
			else crit_fail = 1
			UseFuel()
			for(var/mob/M in viewers(1, src))
				if (M.client && M.machine == src)
					src.updateUsrDialog()

		else
			active = 0
			icon_state = initial(icon_state)
			handleInactive()

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
	var/sheets = 0
	var/max_sheets = 100
	var/sheet_path = /obj/item/stack/sheet/plasma
	var/board_path = "/obj/item/weapon/circuitboard/pacman"
	var/sheet_left = 0 // How much is left of the sheet
	var/time_per_sheet = 10
	var/heat = 0

	New()
		..()
		component_parts = list()
		component_parts += new /obj/item/weapon/stock_parts/matter_bin(src)
		component_parts += new /obj/item/weapon/stock_parts/micro_laser(src)
		component_parts += new /obj/item/weapon/cable_coil(src)
		component_parts += new /obj/item/weapon/cable_coil(src)
		component_parts += new /obj/item/weapon/stock_parts/capacitor(src)
		component_parts += new board_path(src)
		RefreshParts()

	RefreshParts()
		var/temp_rating = 0
		var/temp_reliability = 0
		for(var/obj/item/weapon/stock_parts/SP in component_parts)
			if(istype(SP, /obj/item/weapon/stock_parts/matter_bin))
				max_sheets = SP.rating * SP.rating * 50
			else if(istype(SP, /obj/item/weapon/stock_parts/micro_laser) || istype(SP, /obj/item/weapon/stock_parts/capacitor))
				temp_rating += SP.rating
		for(var/obj/item/weapon/CP in component_parts)
			temp_reliability += CP.reliability
		reliability = min(round(temp_reliability / 4), 100)
		power_gen = round(initial(power_gen) * (max(2, temp_rating) / 2))

	examine()
		..()
		usr << "\blue The generator has [sheets] units of fuel left, producing [power_gen] per cycle."
		if(crit_fail) usr << "\red The generator seems to have broken down."

	HasFuel()
		if(sheets >= 1 / (time_per_sheet / power_output) - sheet_left)
			return 1
		return 0

	UseFuel()
		var/needed_sheets = 1 / (time_per_sheet / power_output)
		var/temp = min(needed_sheets, sheet_left)
		needed_sheets -= temp
		sheet_left -= temp
		sheets -= round(needed_sheets)
		needed_sheets -= round(needed_sheets)
		if (sheet_left <= 0 && sheets > 0)
			sheet_left = 1 - needed_sheets
			sheets--

		var/lower_limit = 56 + power_output * 10
		var/upper_limit = 76 + power_output * 10
		var/bias = 0
		if (power_output > 4)
			upper_limit = 400
			bias = power_output * 3
		if (heat < lower_limit)
			heat += 3
		else
			heat += rand(-7 + bias, 7 + bias)
			if (heat < lower_limit)
				heat = lower_limit
			if (heat > upper_limit)
				heat = upper_limit

		if (heat > 300)
			overheat()
			del(src)
		return

	handleInactive()
		heat -= 2
		if (heat < 0)
			heat = 0
		else
			for(var/mob/M in viewers(1, src))
				if (M.client && M.machine == src)
					src.updateUsrDialog()

	proc
		overheat()
			explosion(src.loc, 2, 5, 2, -1)

	attackby(var/obj/item/O as obj, var/mob/user as mob)
		if(istype(O, sheet_path))
			var/obj/item/stack/addstack = O
			var/amount = min((max_sheets - sheets), addstack.amount)
			if(amount < 1)
				user << "\blue The [src.name] is full!"
				return
			user << "\blue You add [amount] sheets to the [src.name]."
			sheets += amount
			addstack.use(amount)
			return
		else if (istype(O, /obj/item/weapon/card/emag))
			emagged = 1
			emp_act(1)
		else if(!active)
			if(istype(O, /obj/item/weapon/wrench))
				anchored = !anchored
				playsound(src.loc, 'Deconstruct.ogg', 50, 1)
				if(anchored)
					user << "\blue You secure the generator to the floor."
				else
					user << "\blue You unsecure the generator from the floor."
				makepowernets()
			else if(istype(O, /obj/item/weapon/screwdriver))
				open = !open
				playsound(src.loc, 'Screwdriver.ogg', 50, 1)
				if(open)
					user << "\blue You open the access panel."
				else
					user << "\blue You close the access panel."
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
		if (!anchored)
			return

		interact(user)

	attack_ai(mob/user as mob)
		interact(user)

	attack_paw(mob/user as mob)
		interact(user)

	proc
		interact(mob/user)
			if (get_dist(src, user) > 1 )
				if (!istype(user, /mob/living/silicon/ai))
					user.machine = null
					user << browse(null, "window=port_gen")
					return

			user.machine = src

			var/dat = text("<b>[name]</b><br>")
			if (active)
				dat += text("Generator: <A href='?src=\ref[src];action=disable'>On</A><br>")
			else
				dat += text("Generator: <A href='?src=\ref[src];action=enable'>Off</A><br>")
			dat += text("sheets: [sheets]<br>")
			var/stack_percent = round(sheet_left * 100, 1)
			dat += text("Current stack: [stack_percent]%<br>")
			dat += text("Power output: <A href='?src=\ref[src];action=lower_power'>-</A> [power_gen * power_output] <A href='?src=\ref[src];action=higher_power'>+</A><br>")
			dat += text("Heat: [heat]<br>")
			dat += "<br><A href='?src=\ref[src];action=close'>Close</A>"
			user << browse("[dat]", "window=port_gen")

	Topic(href, href_list)
		if(..())
			return

		src.add_fingerprint(usr)
		if(href_list["action"])
			if(href_list["action"] == "enable")
				if(!active && HasFuel() && !crit_fail)
					active = 1
					icon_state = "portgen1"
					src.updateUsrDialog()
			if(href_list["action"] == "disable")
				if (active)
					active = 0
					icon_state = "portgen0"
					src.updateUsrDialog()
			if(href_list["action"] == "lower_power")
				if (power_output > 1)
					power_output--
					src.updateUsrDialog()
			if (href_list["action"] == "higher_power")
				if (power_output < 4 || emagged)
					power_output++
					src.updateUsrDialog()
			if (href_list["action"] == "close")
				usr << browse(null, "window=port_gen")
				usr.machine = null

/obj/machinery/power/port_gen/pacman/super
	name = "S.U.P.E.R.P.A.C.M.A.N.-type Portable Generator"
	icon_state = "portgen1"
	sheet_path = /obj/item/stack/sheet/uranium
	power_gen = 15000
	time_per_sheet = 25
	board_path = "/obj/item/weapon/circuitboard/pacman/super"
	overheat()
		explosion(src.loc, 3, 3, 3, -1)

/obj/machinery/power/port_gen/pacman/mrs
	name = "M.R.S.P.A.C.M.A.N.-type Portable Generator"
	icon_state = "portgen2"
	sheet_path = /obj/item/stack/sheet/diamond
	power_gen = 40000
	time_per_sheet = 30
	board_path = "/obj/item/weapon/circuitboard/pacman/mrs"
	overheat()
		explosion(src.loc, 4, 4, 4, -1)
