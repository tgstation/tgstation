
//Baseline portable generator. Has all the default handling. Not intended to be used on it's own (since it generates unlimited power).
/obj/machinery/power/port_gen
	name = "portable generator"
	desc = "A portable generator for emergency backup power."
	icon = 'icons/obj/power.dmi'
	icon_state = "portgen0_0"
	density = 1
	anchored = 0
	use_power = 0

	var/active = 0
	var/power_gen = 5000
	var/recent_fault = 0
	var/power_output = 1
	var/consumption = 0
	var/base_icon = "portgen0"

/obj/machinery/power/port_gen/proc/HasFuel() //Placeholder for fuel check.
	return 1

/obj/machinery/power/port_gen/proc/UseFuel() //Placeholder for fuel use.
	return

/obj/machinery/power/port_gen/proc/DropFuel()
	return

/obj/machinery/power/port_gen/proc/handleInactive()
	return

/obj/machinery/power/port_gen/update_icon()
	icon_state = "[base_icon]_[active]"

/obj/machinery/power/port_gen/process()
	if(active && HasFuel() && !crit_fail && anchored && powernet)
		add_avail(power_gen * power_output)
		UseFuel()
		src.updateDialog()

	else
		active = 0
		handleInactive()
		update_icon()

/obj/machinery/power/port_gen/attack_hand(mob/user)
	if(..())
		return
	if(!anchored)
		return

/obj/machinery/power/port_gen/examine(mob/user)
	..()
	to_chat(user, "It is[!active?"n't":""] running.")

/obj/machinery/power/port_gen/pacman
	name = "\improper P.A.C.M.A.N.-type portable generator"
	var/sheets = 0
	var/max_sheets = 100
	var/sheet_name = ""
	var/sheet_path = /obj/item/stack/sheet/mineral/plasma
	var/board_path = /obj/item/weapon/circuitboard/machine/pacman
	var/sheet_left = 0 // How much is left of the sheet
	var/time_per_sheet = 260
	var/current_heat = 0

/obj/machinery/power/port_gen/pacman/Initialize()
	. = ..()
	if(anchored)
		connect_to_network()

/obj/machinery/power/port_gen/pacman/New()
	..()
	var/obj/item/weapon/circuitboard/machine/B = new board_path(null)
	B.apply_default_parts(src)

	var/obj/sheet = new sheet_path(null)
	sheet_name = sheet.name

/obj/item/weapon/circuitboard/machine/pacman
	name = "PACMAN-type Generator (Machine Board)"
	build_path = /obj/machinery/power/port_gen/pacman
	origin_tech = "programming=2;powerstorage=3;plasmatech=3;engineering=3"
	req_components = list(
							/obj/item/weapon/stock_parts/matter_bin = 1,
							/obj/item/weapon/stock_parts/micro_laser = 1,
							/obj/item/stack/cable_coil = 2,
							/obj/item/weapon/stock_parts/capacitor = 1)

/obj/item/weapon/circuitboard/machine/pacman/super
	name = "SUPERPACMAN-type Generator (Machine Board)"
	build_path = /obj/machinery/power/port_gen/pacman/super
	origin_tech = "programming=3;powerstorage=4;engineering=4"

/obj/item/weapon/circuitboard/machine/pacman/mrs
	name = "MRSPACMAN-type Generator (Machine Board)"
	build_path = "/obj/machinery/power/port_gen/pacman/mrs"
	origin_tech = "programming=3;powerstorage=4;engineering=4;plasmatech=4"

/obj/machinery/power/port_gen/pacman/Destroy()
	DropFuel()
	return ..()

/obj/machinery/power/port_gen/pacman/RefreshParts()
	var/temp_rating = 0
	var/consumption_coeff = 0
	for(var/obj/item/weapon/stock_parts/SP in component_parts)
		if(istype(SP, /obj/item/weapon/stock_parts/matter_bin))
			max_sheets = SP.rating * SP.rating * 50
		else if(istype(SP, /obj/item/weapon/stock_parts/capacitor))
			temp_rating += SP.rating
		else
			consumption_coeff += SP.rating
	power_gen = round(initial(power_gen) * temp_rating * 2)
	consumption = consumption_coeff

/obj/machinery/power/port_gen/pacman/examine(mob/user)
	..()
	to_chat(user, "<span class='notice'>The generator has [sheets] units of [sheet_name] fuel left, producing [power_gen] per cycle.</span>")
	if(crit_fail) to_chat(user, "<span class='danger'>The generator seems to have broken down.</span>")

/obj/machinery/power/port_gen/pacman/HasFuel()
	if(sheets >= 1 / (time_per_sheet / power_output) - sheet_left)
		return 1
	return 0

/obj/machinery/power/port_gen/pacman/DropFuel()
	if(sheets)
		var/fail_safe = 0
		while(sheets > 0 && fail_safe < 100)
			fail_safe += 1
			var/obj/item/stack/sheet/S = new sheet_path(loc)
			var/amount = min(sheets, S.max_amount)
			S.amount = amount
			sheets -= amount

/obj/machinery/power/port_gen/pacman/UseFuel()
	var/needed_sheets = 1 / (time_per_sheet * consumption / power_output)
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
		bias = power_output - consumption * (4 - consumption)
	if (current_heat < lower_limit)
		current_heat += 4 - consumption
	else
		current_heat += rand(-7 + bias, 7 + bias)
		if (current_heat < lower_limit)
			current_heat = lower_limit
		if (current_heat > upper_limit)
			current_heat = upper_limit

	if (current_heat > 300)
		overheat()
		qdel(src)
	return

/obj/machinery/power/port_gen/pacman/handleInactive()

	if (current_heat > 0)
		current_heat = max(current_heat - 2, 0)
		src.updateDialog()

/obj/machinery/power/port_gen/pacman/proc/overheat()
	explosion(src.loc, 2, 5, 2, -1)

/obj/machinery/power/port_gen/pacman/attackby(obj/item/O, mob/user, params)
	if(istype(O, sheet_path))
		var/obj/item/stack/addstack = O
		var/amount = min((max_sheets - sheets), addstack.amount)
		if(amount < 1)
			to_chat(user, "<span class='notice'>The [src.name] is full!</span>")
			return
		to_chat(user, "<span class='notice'>You add [amount] sheets to the [src.name].</span>")
		sheets += amount
		addstack.use(amount)
		updateUsrDialog()
		return
	else if(!active)

		if(exchange_parts(user, O))
			return

		if(istype(O, /obj/item/weapon/wrench))

			if(!anchored && !isinspace())
				connect_to_network()
				to_chat(user, "<span class='notice'>You secure the generator to the floor.</span>")
				anchored = 1
			else if(anchored)
				disconnect_from_network()
				to_chat(user, "<span class='notice'>You unsecure the generator from the floor.</span>")
				anchored = 0

			playsound(src.loc, 'sound/items/deconstruct.ogg', 50, 1)
			return
		else if(istype(O, /obj/item/weapon/screwdriver))
			panel_open = !panel_open
			playsound(src.loc, O.usesound, 50, 1)
			if(panel_open)
				to_chat(user, "<span class='notice'>You open the access panel.</span>")
			else
				to_chat(user, "<span class='notice'>You close the access panel.</span>")
			return
		else if(default_deconstruction_crowbar(O))
			return
	return ..()

/obj/machinery/power/port_gen/pacman/emag_act(mob/user)
	if(!emagged)
		emagged = 1
		emp_act(1)

/obj/machinery/power/port_gen/pacman/attack_hand(mob/user)
	..()
	if (!anchored)
		return

	interact(user)

/obj/machinery/power/port_gen/pacman/attack_ai(mob/user)
	interact(user)

/obj/machinery/power/port_gen/pacman/attack_paw(mob/user)
	interact(user)

/obj/machinery/power/port_gen/pacman/interact(mob/user)
	if (get_dist(src, user) > 1 )
		if(!isAI(user))
			user.unset_machine()
			user << browse(null, "window=port_gen")
			return

	user.set_machine(src)

	var/dat = text("<b>[name]</b><br>")
	if (active)
		dat += text("Generator: <A href='?src=\ref[src];action=disable'>On</A><br>")
	else
		dat += text("Generator: <A href='?src=\ref[src];action=enable'>Off</A><br>")
	dat += text("[capitalize(sheet_name)]: [sheets] - <A href='?src=\ref[src];action=eject'>Eject</A><br>")
	var/stack_percent = round(sheet_left * 100, 1)
	dat += text("Current stack: [stack_percent]% <br>")
	dat += text("Power output: <A href='?src=\ref[src];action=lower_power'>-</A> [power_gen * power_output] <A href='?src=\ref[src];action=higher_power'>+</A><br>")
	dat += text("Power current: [(powernet == null ? "Unconnected" : "[avail()]")]<br>")
	dat += text("Heat: [current_heat]<br>")
	dat += "<br><A href='?src=\ref[src];action=close'>Close</A>"
	user << browse(dat, "window=port_gen")
	onclose(user, "port_gen")

/obj/machinery/power/port_gen/pacman/Topic(href, href_list)
	if(..())
		return

	src.add_fingerprint(usr)
	if(href_list["action"])
		if(href_list["action"] == "enable")
			if(!active && HasFuel() && !crit_fail)
				active = 1
				src.updateUsrDialog()
				update_icon()
		if(href_list["action"] == "disable")
			if (active)
				active = 0
				src.updateUsrDialog()
				update_icon()
		if(href_list["action"] == "eject")
			if(!active)
				DropFuel()
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
			usr.unset_machine()

/obj/machinery/power/port_gen/pacman/super
	name = "\improper S.U.P.E.R.P.A.C.M.A.N.-type portable generator"
	icon_state = "portgen1_0"
	base_icon = "portgen1"
	sheet_path = /obj/item/stack/sheet/mineral/uranium
	power_gen = 15000
	time_per_sheet = 85
	board_path = /obj/item/weapon/circuitboard/machine/pacman/super

/obj/machinery/power/port_gen/pacman/super/overheat()
	explosion(src.loc, 3, 3, 3, -1)

/obj/machinery/power/port_gen/pacman/mrs
	name = "\improper M.R.S.P.A.C.M.A.N.-type portable generator"
	base_icon = "portgen2"
	icon_state = "portgen2_0"
	sheet_path = /obj/item/stack/sheet/mineral/diamond
	power_gen = 40000
	time_per_sheet = 80
	board_path = /obj/item/weapon/circuitboard/machine/pacman/mrs

/obj/machinery/power/port_gen/pacman/mrs/overheat()
	explosion(src.loc, 4, 4, 4, -1)
