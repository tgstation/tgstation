// thermo electric generator powered by twinned gas turbines
// more realistic than type 2, and also cooler
#define ENERGY_TRANSFER_FACTOR 10
/*/obj/machinery/power/generator/verb/set_amount(var/g as num)
	set src in view(1)

	gen_amount = g

*/

/obj/machinery/power/generator/New()
	..()

	spawn(5)
		circ1 = locate(/obj/machinery/atmospherics/binary/circulator) in get_step(src,WEST)
		circ2 = locate(/obj/machinery/atmospherics/binary/circulator) in get_step(src,EAST)
		if(!circ1 || !circ2)
			stat |= BROKEN

		updateicon()

/obj/machinery/power/generator/proc/updateicon()

	if(stat & (NOPOWER|BROKEN))
		overlays = null
	else
		overlays = null

		if(lastgenlev != 0)
			overlays += image('power.dmi', "teg-op[lastgenlev]")

#define GENRATE 0.1		// generator output coefficient from Q
#define MAX_SAFE_OUTPUT 1000000

/obj/machinery/power/generator/process()

	if(!circ1 || !circ2)
		return

	var/datum/gas_mixture/air1 = circ1.return_transfer_air()
	var/datum/gas_mixture/air2 = circ2.return_transfer_air()
	//
	var/datum/gas_mixture/hot_air = air1
	var/datum/gas_mixture/cold_air = air2

	lastgen = 0

	if(hot_air && cold_air)
		if(hot_air.temperature < cold_air.temperature)
			hot_air = air2
			cold_air = air1

		var/cold_air_heat_capacity = cold_air.heat_capacity()
		var/hot_air_heat_capacity = hot_air.heat_capacity()

		var/delta_temperature = hot_air.temperature - cold_air.temperature

		if(delta_temperature > 0 && cold_air_heat_capacity > 0 && hot_air_heat_capacity > 0)
			var/efficiency = (1 - cold_air.temperature/hot_air.temperature)*0.65 //65% of Carnot efficiency

			var/energy_transfer = delta_temperature*hot_air_heat_capacity*cold_air_heat_capacity/(hot_air_heat_capacity+cold_air_heat_capacity)

			var/heat = energy_transfer*(1-efficiency)
			lastgen = energy_transfer * efficiency * GENRATE

			//ENERGY_TRANSFER_FACTOR to beef up the amount of heat passed over
			hot_air.temperature -= energy_transfer/hot_air_heat_capacity
			cold_air.temperature += heat/cold_air_heat_capacity


			//world << "POWER: [lastgen] W generated at [efficiency*100]% efficiency and sinks sizes [cold_air_heat_capacity], [hot_air_heat_capacity]"

			//if producing more than 1 million watts, emit sparks and waste a little power
			var/runoff = 0
			if(lastgen > MAX_SAFE_OUTPUT)
				runoff = lastgen - MAX_SAFE_OUTPUT
				if( prob(max( 100, (100 * runoff / MAX_SAFE_OUTPUT) )) )
					lastgen -= rand(1, 10) * (runoff / 100)
					var/datum/effect/effect/system/spark_spread/s = new /datum/effect/effect/system/spark_spread
					s.set_up(5, 1, src)
					s.start()
			//
			add_avail(lastgen)

	// update icon overlays only if displayed level has changed

	if(air1)
		circ1.air2.merge(air1)

	if(air2)
		circ2.air2.merge(air2)

	var/genlev = max(0, min( round(11*lastgen / MAX_SAFE_OUTPUT), 11))
	if(genlev != lastgenlev)
		lastgenlev = genlev
		updateicon()

	src.updateDialog()

/obj/machinery/power/generator/attack_ai(mob/user)
	if(stat & (BROKEN|NOPOWER)) return

	interact(user)

/obj/machinery/power/generator/attack_hand(mob/user)

	add_fingerprint(user)

	if(stat & (BROKEN|NOPOWER)) return

	if(lastgenlev > MAX_SAFE_OUTPUT)
		electrocute_mob(user, get_area(src), src, 0.7)

	interact(user)

/obj/machinery/power/generator/proc/interact(mob/user)
	if ( (get_dist(src, user) > 1 ) && (!istype(user, /mob/living/silicon/ai)))
		user.machine = null
		user << browse(null, "window=teg")
		return

	user.machine = src

	var/obj/machinery/atmospherics/binary/circulator/hot_circ = circ1
	var/obj/machinery/atmospherics/binary/circulator/cold_circ = circ2
	if(hot_circ.air1.temperature < cold_circ.air1.temperature)
		hot_circ = circ2
		cold_circ = circ1

	var/t = "<PRE><B>Thermo-Electric Generator</B><HR>"

	t += "Output : [round(lastgen)] W<BR><BR>"

	t += "<B>Cold loop</B><BR>"
	t += "Temperature Inlet: [round(cold_circ.air1.temperature, 0.1)] K<BR>"
	t += "Temperature Outlet: [round(cold_circ.air2.temperature, 0.1)] K<BR>"
	t += "Pressure Inlet: [round(cold_circ.air1.return_pressure(), 0.1)] kPa<BR>"
	t += "Pressure Outlet: [round(cold_circ.air2.return_pressure(), 0.1)] kPa<BR>"

	t += "<B>Hot loop</B><BR>"
	t += "Temperature Inlet: [round(hot_circ.air1.temperature, 0.1)] K<BR>"
	t += "Temperature Outlet: [round(hot_circ.air2.temperature, 0.1)] K<BR>"
	t += "Pressure Inlet: [round(hot_circ.air1.return_pressure(), 0.1)] kPa<BR>"
	t += "Pressure Outlet: [round(hot_circ.air2.return_pressure(), 0.1)] kPa<BR>"

	t += "<BR><HR><A href='?src=\ref[src];close=1'>Close</A>"

	t += "</PRE>"
	user << browse(t, "window=teg;size=460x300")
	onclose(user, "teg")
	return 1

/obj/machinery/power/generator/Topic(href, href_list)
	..()

	if( href_list["close"] )
		usr << browse(null, "window=teg")
		usr.machine = null
		return 0

	return 1

/obj/machinery/power/generator/power_change()
	..()
	updateicon()

