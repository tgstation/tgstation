#define MSGS_ON					1
#define MSGS_INPUT				2

/obj/machinery/atmospherics/binary/msgs
	name = "\improper Magnetically Suspended Gas Storage Unit"
	desc = "Stores large quantities of gas in electro-magnetic suspension."
	icon = 'icons/obj/atmospherics/msgs.dmi'
	icon_state = "msgs"
	density = 1

	machine_flags = WRENCHMOVE | FIXED2WORK
	idle_power_usage = 1000					//This thing's serious

	var/internal_volume = 10000
	var/max_pressure = 10000

	var/target_pressure = 4500	//Output pressure.
	var/on = 0								//Are we taking in gas?

	var/datum/gas_mixture/air				//Internal tank.

	var/datum/html_interface/nanotrasen/interface

	var/tmp/update_flags
	var/tmp/last_pressure

/obj/machinery/atmospherics/binary/msgs/New()
	html_machines += src

	interface = new(src, sanitize(name), 500, 520)

	init_ui()

	air = new
	air.volume = internal_volume

	return ..()

//Here we set the content of the interface.
/obj/machinery/atmospherics/binary/msgs/proc/init_ui()
	var/data = {"
		<h2>
			Gas storage status
		</h2>
		<div class="statusDisplay">
			<div class="statusLabel">Total pressure: 	</div><div class="statusValue"><span id="pressurereadout">0</span> kPa</div><br>
			<div class="statusLabel">Temperature:	 	</div><div class="statusValue"><span id="tempreadout">0</span> K</div><br>
			<hr>
			<div class="statusLabel">Oxygen: 			</div><div class="statusValue"><span id="oxypercent">0</span> %</div><br>
			<div class="statusLabel">Nitrogen: 			</div><div class="statusValue"><span id="nitpercent">0</span> %</div><br>
			<div class="statusLabel">Carbon Dioxide: 	</div><div class="statusValue"><span id="co2percent">0</span> %</div><br>
			<div class="statusLabel">Plasma: 			</div><div class="statusValue"><span id="plapercent">0</span> %</div><br>
			<div class="statusLabel">Nitrous Oxide: 	</div><div class="statusValue"><span id="n2opercent">0</span> %</div><br>
		</div>
		<h2>
			I/O controls
		</h2>
		<div class="item">
			<div class="itemLabel">Input: </div>
			<div class="itemContent">
				<span id="inputtoggles">
					<a href="?src=\ref[interface];power=1">Enable</a> <a href="?src=\ref[interface];power=0" class="linkDanger">Disable</a>
				</span>
			</div>
		</div>
		<br><br>
		<div class="item">
			<div class="itemLabel">Output pressure (kPa): </div>
			<div class="itemContent">
				<form action="?src=\ref[interface]" method="get"><input type="hidden" name="src" value="\ref[interface]"/>
					<span id="pressureinput"><input type="textbox" name="set_pressure" value="0"/></span> <input type="submit" name="act" value="Set"/>
				</form>
			</div>
		</div>
	"}
	interface.updateContent("content", data)

/obj/machinery/atmospherics/binary/msgs/Destroy()
	. = ..()

	html_machines -= src

	qdel(interface)
	interface = null

	air = null

/obj/machinery/atmospherics/binary/msgs/process()
	. = ..()
	if(stat & (NOPOWER | BROKEN))
		return

	//Output handling, stolen from pump code.
	var/output_starting_pressure = air2.return_pressure()

	if((target_pressure - output_starting_pressure) > 0.01)
		//No need to output gas if target is already reached!

		//Calculate necessary moles to transfer using PV=nRT
		if((air.total_moles() > 0) && (air.temperature > 0))
			var/pressure_delta = target_pressure - output_starting_pressure
			var/transfer_moles = pressure_delta * air2.volume / (air.temperature * R_IDEAL_GAS_EQUATION)

			//Actually transfer the gas
			var/datum/gas_mixture/removed = air.remove(transfer_moles)
			air2.merge(removed)

			if(network2)
				network2.update = 1

	//Input handling. Literally pump code again with the target pressure being the max pressure of the MSGS
	var/input_starting_pressure = air1.return_pressure()

	if((max_pressure - input_starting_pressure) > 0.01)
		//No need to output gas if target is already reached!

		//Calculate necessary moles to transfer using PV=nRT
		if((air1.total_moles() > 0) && (air1.temperature > 0))
			var/pressure_delta = max_pressure - input_starting_pressure
			var/transfer_moles = pressure_delta * air.volume / (air1.temperature * R_IDEAL_GAS_EQUATION)

			//Actually transfer the gas
			var/datum/gas_mixture/removed = air1.remove(transfer_moles)
			air.merge(removed)

			if(network1)
				network1.update = 1

	updateUsrDialog()
	update_icon()

//Screw having to set a machine.
/obj/machinery/atmospherics/binary/msgs/hiIsValidClient(datum/html_interface_client/hclient, datum/html_interface/hi)
	if(hclient.client.mob)
		return hclient.client.mob.html_mob_check(src.type)

/obj/machinery/atmospherics/binary/msgs/updateUsrDialog()
	if(!interface.isUsed())
		return

	interface.updateContent("pressurereadout", round(air.return_pressure(), 0.01))
	interface.updateContent("tempreadout", air.return_temperature())

	var/total_moles = air.total_moles()
	if(round(total_moles, 0.01))	//Check if there's total moles to avoid divisions by zero.
		interface.updateContent("oxypercent", Clamp(round(100 * air.oxygen			/ total_moles, 0.1), 0, 100))
		interface.updateContent("nitpercent", Clamp(round(100 * air.nitrogen		/ total_moles, 0.1), 0, 100))
		interface.updateContent("co2percent", Clamp(round(100 * air.carbon_dioxide	/ total_moles, 0.1), 0, 100))
		interface.updateContent("plapercent", Clamp(round(100 * air.toxins			/ total_moles, 0.1), 0, 100))

		//Begin stupid shit to get the N2O amount.
		var/datum/gas/sleeping_agent/G = locate(/datum/gas/sleeping_agent) in air.trace_gases
		var/n2o_moles = 0
		if(G)
			n2o_moles = G.moles

		interface.updateContent("n2opercent", Clamp(round(100 * n2o_moles			/ total_moles, 0.1), 0, 100))

	else
		interface.updateContent("oxypercent", 0)
		interface.updateContent("nitpercent", 0)
		interface.updateContent("co2percent", 0)
		interface.updateContent("plapercent", 0)
		interface.updateContent("n2opercent", 0)

	if(on)
		interface.updateContent("inputtoggles",	{"<a href="?src=\ref[interface];power=1" class="linkOn">Enable</a> <a href="?src=\ref[interface];power=0">Disable</a>"})
	else
		interface.updateContent("inputtoggles",	{"<a href="?src=\ref[interface];power=1">Enable</a> <a href="?src=\ref[interface];power=0" class="linkDanger">Disable</a>"})

	interface.updateContent("pressureinput", 	{"<input type="textbox" name="set_pressure" value="[target_pressure]"/>"})

/obj/machinery/atmospherics/binary/msgs/Topic(href, href_list)
	. = ..()
	if(.)
		return

	if(href_list["power"])
		on = round(Clamp(text2num(href_list["power"]), 0, 1))
		updateUsrDialog()
		update_icon()
		return 1

	if(href_list["set_pressure"])
		target_pressure = round(Clamp(text2num(href_list["set_pressure"]), 0, 4500))
		update_icon()
		updateUsrDialog()
		return 1

/obj/machinery/atmospherics/binary/msgs/attack_hand(var/mob/user)
	. = ..()
	if(.)
		if(user.machine == src)
			user.unset_machine()
		return

	interface.show(user)
	updateUsrDialog()

/obj/machinery/atmospherics/binary/msgs/attack_ai(var/mob/user)
	. = attack_hand(user)

/obj/machinery/atmospherics/binary/msgs/power_change()
	. = ..()
	update_icon()

/obj/machinery/atmospherics/binary/msgs/update_icon()
	. = ..()

	var/update = 0
	if((update_flags & MSGS_INPUT) != on)
		update = 1

	if((update_flags & MSGS_ON) != !(stat & (NOPOWER | BROKEN)))
		update = 1

	var/pressure = air.return_pressure() // null ref error here.
	var/i = Clamp(round(pressure / (max_pressure / 5)), 0, 5)
	if(i != last_pressure)
		update = 1

	if(!update)
		return

	overlays.Cut()
	if(node1)
		overlays += image(icon = icon, icon_state = "node-1")

	if(node2)
		overlays += image(icon = icon, icon_state = "node-2")

	if(!(stat & (NOPOWER | BROKEN)))

		overlays += image(icon = icon, icon_state = "o-[i]")

		overlays += image(icon = icon, icon_state = "p")

		if(on)
			overlays += image(icon = icon, icon_state = "i")

/obj/machinery/atmospherics/binary/msgs/wrenchAnchor(mob/user)
	..()
	if(anchored)
		if(dir & (NORTH|SOUTH))
			initialize_directions = NORTH|SOUTH
		else if(dir & (EAST|WEST))
			initialize_directions = EAST|WEST

		initialize()
		build_network()
		if (node1)
			node1.initialize()
			node1.build_network()
		if (node2)
			node2.initialize()
			node2.build_network()
	else
		if(node1)
			node1.disconnect(src)
			if(network1)
				returnToPool(network1)
		if(node2)
			node2.disconnect(src)
			if(network2)
				returnToPool(network2)

		node1 = null
		node2 = null

/obj/machinery/atmospherics/binary/msgs/verb/rotate_clockwise()
	set category = "Object"
	set name = "Rotate MSGS (Clockwise)"
	set src in view(1)

	if(usr.isUnconscious() || usr.restrained() || anchored)
		return

	src.dir = turn(src.dir, 90)


/obj/machinery/atmospherics/binary/msgs/verb/rotate_anticlockwise()
	set category = "Object"
	set name = "Rotate MSGS (Counter-clockwise)"
	set src in view(1)

	if(usr.isUnconscious() || usr.restrained() || anchored)
		return

	src.dir = turn(src.dir, -90)

#undef MSGS_ON
#undef MSGS_INPUT
