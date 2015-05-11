/obj/machinery/power/generator/type2
	name = "thermoelectric generator"
	desc = "It's a high efficiency thermoelectric generator."
	icon_state = "teg"
	anchored = 1
	density = 1
	use_power = 0

	var/obj/machinery/atmospherics/unary/generator_input/input1
	var/obj/machinery/atmospherics/unary/generator_input/input2

	var/input1_dir=NORTH
	var/input2_dir=SOUTH


/obj/machinery/power/generator/type2/reconnect()
	input1_dir = turn(dir, 90)
	input2_dir = turn(dir, -90)
	input1 = locate(/obj/machinery/atmospherics/unary/generator_input) in get_step(src,input1_dir)
	input2 = locate(/obj/machinery/atmospherics/unary/generator_input) in get_step(src,input2_dir)
	updateicon()

/obj/machinery/power/generator/type2/operable()
	return !(stat & (NOPOWER|BROKEN) || !anchored || !input1 || !input2)

#define GENRATE 800		// generator output coefficient from Q

/obj/machinery/power/generator/type2/process()
	if(!input1 || !input2 || !anchored || stat & (NOPOWER|BROKEN))
		return

	var/datum/gas_mixture/air1 = input1.return_exchange_air()
	var/datum/gas_mixture/air2 = input2.return_exchange_air()

	lastgen = 0

	if(air1 && air2)
		var/datum/gas_mixture/hot_air = air1
		var/datum/gas_mixture/cold_air = air2
		if(hot_air.temperature < cold_air.temperature)
			hot_air = air2
			cold_air = air1

		var/hot_air_heat_capacity = hot_air.heat_capacity()
		var/cold_air_heat_capacity = cold_air.heat_capacity()

		var/delta_temperature = hot_air.temperature - cold_air.temperature

		if(delta_temperature > 1 && cold_air_heat_capacity > 0.01 && hot_air_heat_capacity > 0.01)
			var/efficiency = (1 - cold_air.temperature/hot_air.temperature)*0.65 //65% of Carnot efficiency

			var/energy_transfer = delta_temperature*hot_air_heat_capacity*cold_air_heat_capacity/(hot_air_heat_capacity+cold_air_heat_capacity)

			var/heat = energy_transfer*(1-efficiency)
			lastgen = energy_transfer*efficiency

			hot_air.temperature = hot_air.temperature - energy_transfer/hot_air_heat_capacity
			cold_air.temperature = cold_air.temperature + heat/cold_air_heat_capacity

			//world << "POWER: [lastgen] W generated at [efficiency*100]% efficiency and sinks sizes [cold_air_heat_capacity], [hot_air_heat_capacity]"

			if(input1.network)
				input1.network.update = 1

			if(input2.network)
				input2.network.update = 1

			add_avail(lastgen)
	// update icon overlays only if displayed level has changed

	var/genlev = max(0, min( round(11*lastgen / 100000), 11))
	if(genlev != lastgenlev)
		lastgenlev = genlev
		updateicon()

	src.updateDialog()


/obj/machinery/power/generator/type2/attack_ai(mob/user)
	src.add_hiddenprint(user)
	if(stat & (BROKEN|NOPOWER)) return
	interact(user)

/obj/machinery/power/generator/type2/attack_hand(mob/user)
	add_fingerprint(user)
	if(stat & (BROKEN|NOPOWER)) return
	interact(user)

/obj/machinery/power/generator/type2/proc/get_loop_state(var/loop_name,var/loop_dir,var/obj/machinery/atmospherics/unary/generator_input/loop)
	if(!loop)
		return "<b>[loop_name] Loop</b> ([dir2text(loop_dir)], <span style=\"color:red;font-weight:bold;\">UNCONNECTED</span>)<br />"
	else
		return {"<B>Cold Loop</B> ([dir2text(loop_dir)])
<ul>
	<li><b>Temperature:</b> [round(loop.air_contents.temperature, 0.1)] K</li>
	<li><b>Pressure:</b> [round(loop.air_contents.return_pressure(), 0.1)] kPa</li>
</ul>"}

/obj/machinery/power/generator/type2/interact(mob/user)
	if ( (get_dist(src, user) > 1 ) && (!istype(user, /mob/living/silicon/ai)))
		user.unset_machine()
		user << browse(null, "window=teg")
		return

	user.set_machine(src)

	var/t = "<h2>Thermo-Electric Generator Mk. 2</h2>"


	// AUTOFIXED BY fix_string_idiocy.py
	// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\power\generator_type2.dm:113: t += "Output : [round(lastgen)] W<BR><BR>"
	t += {"Output : [round(lastgen)] W<BR><BR>
[get_loop_state("Cold",input1_dir,input1)]
[get_loop_state("Hot",input2_dir,input2)]
<BR><HR><A href='?src=\ref[src];close=1'>Close</A>
| <A href='?src=\ref[src];reconnect=1'>Refresh Inputs</A>"}
	// END AUTOFIX
	user << browse(t, "window=teg;size=460x300")
	onclose(user, "teg")
	return 1