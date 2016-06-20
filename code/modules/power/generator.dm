/obj/machinery/power/generator
	name = "thermoelectric generator"
	desc = "It's a high efficiency thermoelectric generator."
	icon_state = "teg"
	density = 1
	anchored = 0

	use_power = 0
	idle_power_usage = 100 //Watts, I hope.  Just enough to do the computer and display things.

	var/thermal_efficiency = 0.65

	var/tmp/obj/machinery/atmospherics/binary/circulator/circ1
	var/tmp/obj/machinery/atmospherics/binary/circulator/circ2

	var/tmp/last_gen    = 0
	var/tmp/lastgenlev  = 0 // Used in update_icon()
	var/const/max_power = 500000 // Amount of W produced at which point the meter caps.

	machine_flags = WRENCHMOVE | FIXED2WORK

	var/tmp/datum/html_interface/nanotrasen/interface
	var/tmp/on_pipenet_tick_key

/obj/machinery/power/generator/New()
	..()

	spawn(1)
		reconnect()

	var/const/head = {"
		<link rel="stylesheet" type="text/css" href="shared.css"/>
		<script>
			//Behold my trash javascript.
			function setDisabled()
			{
				document.getElementById("operatable").style.display = "none";
				document.getElementById("n_operatable").style.display = "block";
			}

			function setEnabled()
			{
				document.getElementById("operatable").style.display = "block";
				document.getElementById("n_operatable").style.display = "none";
			}
		</script>
	"}

	interface = new(src, name, 450, 410, head)

	html_machines += src
	on_pipenet_tick_key = global.on_pipenet_tick.Add(src, "pipenet_process")

	init_ui()

/obj/machinery/power/generator/Destroy()
	. = ..()
	if(circ1)
		circ1.linked_generator = null
		circ1 = null

	if(circ2)
		circ2.linked_generator = null
		circ2 = null

	qdel(interface)
	interface = null

	html_machines -= src
	global.on_pipenet_tick.Remove(on_pipenet_tick_key)

/obj/machinery/power/generator/proc/init_ui()
	interface.updateLayout({"
	<div class="item">
		<div class="itemLabel">
			Total output:
		</div>
		<div class="itemContent" id="total_out">
			X
		</div>
	</div>
	<div id="operatable">
	<table style="width: 100%; font-size: 12px;">
		<tr>
			<td>
				<div class="statusDisplay">
					<h1 id="circ1">
						Primary Circulator (right)
					</h1>
					<div class="item">
						<div class="itemLabel">
							Flow Capacity:
						</div>
						<div class="itemContent" id="circ1_flow_cap">
							X
						</div>
					</div>
					<br>
					<br>
					<div class="item">
						<div class="itemLabel">
							Inlet Pressure:
						</div>
						<div class="itemContent" id="circ1_in_pressure">
							X
						</div>
					</div>
					<div class="item">
						<div class="itemLabel">
							Inlet Temperature:
						</div>
						<div class="itemContent" id="circ1_in_temp">
							X
						</div>
					</div>
					<br>
					<br>
					<div class="item">
						<div class="itemLabel">
							Outlet Pressure:
						</div>
						<div class="itemContent" id="circ1_out_pressure">
							X
						</div>
					</div>
					<div class="item">
						<div class="itemLabel">
							Outlet Temperature:
						</div>
						<div class="itemContent" id="circ1_out_temp">
							X
						</div>
					</div><br><br>
				</div>
			</td>
			<td>
				<div class="statusDisplay">
					<h1 id="circ2">
						Secondary Circulator (left)
					</h1>
					<div class="item">
						<div class="itemLabel">
							Flow Capacity:
						</div>
						<div class="itemContent" id="circ2_flow_cap">
							X
						</div>
					</div>
					<br>
					<br>
					<div class="item">
						<div class="itemLabel">
							Inlet Pressure:
						</div>
						<div class="itemContent" id="circ2_in_pressure">
							X
						</div>
					</div>
					<div class="item">
						<div class="itemLabel">
							Inlet Temperature:
						</div>
						<div class="itemContent" id="circ2_in_temp">
							X
						</div>
					</div>
					<br>
					<br>
					<div class="item">
						<div class="itemLabel">
							Outlet Pressure:
						</div>
						<div class="itemContent" id="circ2_out_pressure">
							X
						</div>
					</div>
					<div class="item">
						<div class="itemLabel">
							Outlet Temperature:
						</div>
						<div class="itemContent" id="circ2_out_temp">
							X
						</div>
					</div><br><br>
				</div>
			</td>
		</tr>
	</table>
	</div>
	<div id="n_operatable" class="notice" style="display: none;">
		Unable to connect to circulators. <br>
		Ensure both are in position and wrenched into place.
	</div>
	"})

/obj/item/weapon/paper/generator
	name = "paper - 'generator instructions'"
	info = "<h2>How to setup the Thermo-Generator</h2><ol> <li>To the top right is a room full of canisters; to the bottom there is a room full of pipes. Connect C02 canisters to the pipe room's top connector ports, the canisters will help act as a buffer so only remove them when refilling the gas..</li> <li>Connect 3 plasma and 2 oxygen canisters to the bottom ports of the pipe room.</li> <li>Turn on all the pumps and valves in the room except for the one connected to the yellow pipe and red pipe, no adjustments to the pump strength needed.</li> <li>Look into the camera monitor to see the burn chamber. When it is full of plasma, press the igniter button.</li> <li>Setup the SMES cells in the North West of Engineering and set an input of half the max; and an output that is half the input.</li></ol>Well done, you should have a functioning generator generating power. If the generator stops working, and there is enough gas and it's hot and cold, it might mean there is too much pressure and you need to turn on the pump that is connected to the red and yellow pipes to release the pressure. Make sure you don't take out too much pressure though.<br>You optimize the generator you must work out how much power your station is using and lowering the circulation pumps enough so that the generator doesn't create excess power, and it will allow the generator to powering the station for a longer duration, without having to replace the canisters. "

//generators connect in dir and reverse_dir(dir) directions
//mnemonic to determine circulator/generator directions: the cirulators orbit clockwise around the generator
//so a circulator to the NORTH of the generator connects first to the EAST, then to the WEST
//and a circulator to the WEST of the generator connects first to the NORTH, then to the SOUTH
//note that the circulator's outlet dir is it's always facing dir, and it's inlet is always the reverse
/obj/machinery/power/generator/proc/reconnect()
	if(circ1)
		circ1.linked_generator = null
		circ1 = null

	if(circ2)
		circ2.linked_generator = null
		circ2 = null

	if(!src.loc || !anchored)
		return

	if(src.dir & (EAST|WEST))
		circ1 = locate(/obj/machinery/atmospherics/binary/circulator) in get_step(src,EAST)
		if(circ1 && !circ1.anchored)
			circ1 = null

		circ2 = locate(/obj/machinery/atmospherics/binary/circulator) in get_step(src,WEST)
		if(circ2 && !circ2.anchored)
			circ2 = null

		if(circ1 && circ2)
			if(circ1.dir != SOUTH || circ2.dir != NORTH)
				circ1 = null
				circ2 = null

	else if(src.dir & (NORTH|SOUTH))
		circ1 = locate(/obj/machinery/atmospherics/binary/circulator) in get_step(src,NORTH)
		circ2 = locate(/obj/machinery/atmospherics/binary/circulator) in get_step(src,SOUTH)

		if(circ1 && circ2 && (circ1.dir != EAST || circ2.dir != WEST))
			circ1 = null
			circ2 = null

	if(circ1)
		circ1.linked_generator = src

	if(circ2)
		circ2.linked_generator = src

	update_icon()
	updateUsrDialog()

/obj/machinery/power/generator/wrenchAnchor()
	. = ..()
	reconnect()

/obj/machinery/power/generator/proc/operable()
	return circ1 && circ2 && anchored && !(stat & (BROKEN|NOPOWER))

/obj/machinery/power/generator/update_icon()
	overlays = 0

	if(!operable())
		return

	overlays += image(icon = icon, icon_state = "teg_mid")

	if(lastgenlev != 0)
		overlays += image(icon = icon, icon_state = "teg-op[lastgenlev]")

// We actually tick power gen on the pipenet process to make sure we're synced with pipenet updates.
/obj/machinery/power/generator/proc/pipenet_process(var/list/event_args, var/datum/controller/process/pipenet/owner)
	if(!operable())
		return

	var/datum/gas_mixture/air1 = circ1.return_transfer_air()
	var/datum/gas_mixture/air2 = circ2.return_transfer_air()

	if(air1 && air2)
		var/air1_heat_capacity = air1.heat_capacity()
		var/air2_heat_capacity = air2.heat_capacity()
		var/delta_temperature = abs(air2.temperature - air1.temperature)

		if(delta_temperature > 0 && air1_heat_capacity > 0 && air2_heat_capacity > 0)
			var/energy_transfer = delta_temperature * air2_heat_capacity * air1_heat_capacity / (air2_heat_capacity + air1_heat_capacity)
			var/heat = energy_transfer * (1 - thermal_efficiency)
			last_gen = energy_transfer * thermal_efficiency * 0.05

			if(air2.temperature > air1.temperature)
				air2.temperature = air2.temperature - energy_transfer/air2_heat_capacity
				air1.temperature = air1.temperature + heat/air1_heat_capacity
			else
				air2.temperature = air2.temperature + heat/air2_heat_capacity
				air1.temperature = air1.temperature - energy_transfer/air1_heat_capacity

	//Transfer the air.
	circ1.air2.merge(air1)
	circ2.air2.merge(air2)

	//Update the gas networks.
	if(circ1.network2)
		circ1.network2.update = TRUE

	if(circ2.network2)
		circ2.network2.update = TRUE

	//Update icon overlays and power usage only if displayed level has changed.
	var/genlev = Clamp(round(11 * last_gen / max_power), 0, 11)

	if(last_gen > 100 && genlev == 0)
		genlev = 1

	if(genlev != lastgenlev)
		lastgenlev = genlev
		update_icon()

	updateUsrDialog()

/obj/machinery/power/generator/process()
	if (operable())
		add_avail(last_gen)

/obj/machinery/power/generator/attack_ai(mob/user)
	return attack_hand(user)

/obj/machinery/power/generator/attack_hand(mob/user)
	. = ..()
	if(.)
		return

	interface.show(user)
	updateUsrDialog()

/obj/machinery/power/generator/updateUsrDialog()
	if(operable())
		interface.executeJavaScript("setEnabled()")
	else
		interface.executeJavaScript("setDisabled()")

	var/vertical = 0
	if(dir & (NORTH | SOUTH))
		vertical = 1

	interface.updateContent("circ1", "Primary circulator ([vertical ? "top"		: "right"])")
	interface.updateContent("circ2", "Primary circulator ([vertical ? "bottom"	: "left"])")

	interface.updateContent("total_out", format_watts(last_gen))

	if(!circ1 || !circ2)	//From this point on it's circulator data.
		return

	// CIRCULATOR 1
	interface.updateContent("circ1_flow_cap",		"[round(circ1.volume_capacity_used * 100)] %")

	interface.updateContent("circ1_in_pressure",	"[round(circ1.air1.return_pressure(),	0.1)] kPa")
	interface.updateContent("circ1_in_temp",		"[round(circ1.air1.temperature,		0.1)] K")

	interface.updateContent("circ1_out_pressure",	"[round(circ1.air2.return_pressure(),	0.1)] kPa")
	interface.updateContent("circ1_out_temp",		"[round(circ1.air2.temperature,		0.1)] K")


	// CIRCULATOR 2
	interface.updateContent("circ2_flow_cap",		"[round(circ2.volume_capacity_used * 100)] %")

	interface.updateContent("circ2_in_pressure",	"[round(circ2.air1.return_pressure(),	0.1)] kPa")
	interface.updateContent("circ2_in_temp",		"[round(circ2.air1.temperature,		0.1)] K")

	interface.updateContent("circ2_out_pressure",	"[round(circ2.air2.return_pressure(),	0.1)] kPa")
	interface.updateContent("circ2_out_temp",		"[round(circ2.air2.temperature,		0.1)] K")

//Needs to be overriden because else it will use the shitty set_machine().
/obj/machinery/power/generator/hiIsValidClient(datum/html_interface_client/hclient, datum/html_interface/hi)
	return hclient.client.mob.html_mob_check(src.type)

/obj/machinery/power/generator/power_change()
	..()
	update_icon()

/obj/machinery/power/generator/verb/rotate_clock()
	set category = "Object"
	set name = "Rotate Generator (Clockwise)"
	set src in view(1)

	if (usr.isUnconscious() || usr.restrained()  || anchored)
		return

	src.dir = turn(src.dir, 90)

/obj/machinery/power/generator/verb/rotate_anticlock()
	set category = "Object"
	set name = "Rotate Generator (Counterclockwise)"
	set src in view(1)

	if (usr.isUnconscious() || usr.restrained()  || anchored)
		return

	src.dir = turn(src.dir, -90)
