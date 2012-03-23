/turf/simulated/floor/mech_bay_recharge_floor
	name = "Mech Bay Recharge Station"
	icon = 'mech_bay.dmi'
	icon_state = "recharge_floor"
	var/obj/machinery/mech_bay_recharge_port/recharge_port
	var/obj/machinery/computer/mech_bay_power_console/recharge_console
	var/obj/mecha/recharging_mecha = null

	Entered(var/obj/mecha/mecha)
		. = ..()
		if(istype(mecha))
			mecha.occupant_message("<b>Initializing power control devices.</b>")
			init_devices()
			if(recharge_console && recharge_port)
				recharging_mecha = mecha
				recharge_console.mecha_in(mecha)
				return
			else if(!recharge_console)
				mecha.occupant_message("<font color='red'>Control console not found. Terminating.</font>")
			else if(!recharge_port)
				mecha.occupant_message("<font color='red'>Power port not found. Terminating.</font>")
		return

	Exited(atom)
		. = ..()
		if(atom == recharging_mecha)
			recharging_mecha = null
			if(recharge_console)
				recharge_console.mecha_out()
		return

	proc/init_devices()
		recharge_console = locate() in range(1,src)
		recharge_port = locate(/obj/machinery/mech_bay_recharge_port, get_step(src, WEST))
		if(recharge_console)
			recharge_console.recharge_floor = src
			if(recharge_port)
				recharge_console.recharge_port = recharge_port
		if(recharge_port)
			recharge_port.recharge_floor = src
			if(recharge_console)
				recharge_port.recharge_console = recharge_console
		return




/obj/machinery/mech_bay_recharge_port
	name = "Mech Bay Power Port"
	density = 1
	anchored = 1
	icon = 'mech_bay.dmi'
	icon_state = "recharge_port"
	var/turf/simulated/floor/mech_bay_recharge_floor/recharge_floor
	var/obj/machinery/computer/mech_bay_power_console/recharge_console
	var/datum/global_iterator/mech_bay_recharger/pr_recharger

	New()
		..()
		pr_recharger = new /datum/global_iterator/mech_bay_recharger(null,0)
		return

	proc/start_charge(var/obj/mecha/recharging_mecha)
		if(stat&(NOPOWER|BROKEN))
			recharging_mecha.occupant_message("<font color='red'>Power port not responding. Terminating.</font>")
			return 0
		else
			if(recharging_mecha.cell)
				recharging_mecha.occupant_message("Now charging...")
				pr_recharger.start(list(src,recharging_mecha))
				return 1
			else
				return 0

	proc/stop_charge()
		if(recharge_console && !recharge_console.stat)
			recharge_console.icon_state = initial(recharge_console.icon_state)
		pr_recharger.stop()
		return

	proc/active()
		if(pr_recharger.active())
			return 1
		else
			return 0

	power_change()
		if(powered())
			stat &= ~NOPOWER
		else
			spawn(rand(0, 15))
				stat |= NOPOWER
				pr_recharger.stop()
		return

	proc/set_voltage(new_voltage)
		if(new_voltage && isnum(new_voltage))
			pr_recharger.max_charge = new_voltage
			return 1
		else
			return 0


/datum/global_iterator/mech_bay_recharger
	delay = 20
	var/max_charge = 45
	check_for_null = 0 //since port.stop_charge() must be called. The checks are made in process()

	process(var/obj/machinery/mech_bay_recharge_port/port, var/obj/mecha/mecha)
		if(!port)
			return 0
		if(mecha && mecha in port.recharge_floor)
			if(!mecha.cell)	return
			var/delta = min(max_charge, mecha.cell.maxcharge - mecha.cell.charge)
			if(delta>0)
				mecha.give_power(delta)
				port.use_power(delta*150)
			else
				mecha.occupant_message("<font color='blue'><b>Fully charged.</b></font>")
				port.stop_charge()
		else
			port.stop_charge()
		return




/obj/machinery/computer/mech_bay_power_console
	name = "Mech Bay Power Control Console"
	density = 1
	anchored = 1
	icon = 'computer.dmi'
	icon_state = "recharge_comp"
	circuit = "/obj/item/weapon/circuitboard/mech_bay_power_console"
	var/autostart = 1
	var/voltage = 45
	var/turf/simulated/floor/mech_bay_recharge_floor/recharge_floor
	var/obj/machinery/mech_bay_recharge_port/recharge_port

	proc/mecha_in(var/obj/mecha/mecha)
		if(stat&(NOPOWER|BROKEN))
			mecha.occupant_message("<font color='red'>Control console not responding. Terminating...</font>")
			return
		if(recharge_port && autostart)
			var/answer = recharge_port.start_charge(mecha)
			if(answer)
				recharge_port.set_voltage(voltage)
				src.icon_state = initial(src.icon_state)+"_on"
		return

	proc/mecha_out()
		if(recharge_port)
			recharge_port.stop_charge()
		return


	power_change()
		if(stat & BROKEN)
			icon_state = initial(icon_state)+"_broken"
			if(recharge_port)
				recharge_port.stop_charge()
		else if(powered())
			icon_state = initial(icon_state)
			stat &= ~NOPOWER
		else
			spawn(rand(0, 15))
				icon_state = initial(icon_state)+"_nopower"
				stat |= NOPOWER
				if(recharge_port)
					recharge_port.stop_charge()

	set_broken()
		icon_state = initial(icon_state)+"_broken"
		stat |= BROKEN
		if(recharge_port)
			recharge_port.stop_charge()

	attack_hand(mob/user as mob)
		if(..()) return
		var/output = "<html><head><title>[src.name]</title></head><body>"
		if(!recharge_floor)
			output += "<font color='red'>Mech Bay Recharge Station not initialized.</font><br>"
		else
			output += {"<b>Mech Bay Recharge Station Data:</b><div style='margin-left: 15px;'>
							<b>Mecha: </b>[recharge_floor.recharging_mecha||"None"]<br>"}
			if(recharge_floor.recharging_mecha)
				var/cell_charge = recharge_floor.recharging_mecha.get_charge()
				output += "<b>Cell charge: </b>[isnull(cell_charge)?"No powercell found":"[recharge_floor.recharging_mecha.cell.charge]/[recharge_floor.recharging_mecha.cell.maxcharge]"]<br>"
			output += "</div>"
		if(!recharge_port)
			output += "<font color='red'>Mech Bay Power Port not initialized.</font><br>"
		else
			output += "<b>Mech Bay Power Port Status: </b>[recharge_port.active()?"Now charging":"On hold"]<br>"

		/*
		output += {"<hr>
						<b>Settings:</b>
						<div style='margin-left: 15px;'>
						<b>Start sequence on succesful init: </b><a href='?src=\ref[src];autostart=1'>[autostart?"On":"Off"]</a><br>
						<b>Recharge Port Voltage: </b><a href='?src=\ref[src];voltage=30'>Low</a> - <a href='?src=\ref[src];voltage=45'>Medium</a> - <a href='?src=\ref[src];voltage=60'>High</a><br>
						</div>"}
		*/

		output += "</ body></html>"
		user << browse(output, "window=mech_bay_console")
		onclose(user, "mech_bay_console")
		return


	Topic(href, href_list)
		if(href_list["autostart"])
			autostart = !autostart
		if(href_list["voltage"])
			voltage = text2num(href_list["voltage"])
			if(recharge_port)
				recharge_port.set_voltage(voltage)
		updateUsrDialog()
		return