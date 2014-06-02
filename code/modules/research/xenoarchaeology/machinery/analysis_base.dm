//Handles how much the temperature changes on power use. (Joules/Kelvin)
//Equates to as much heat energy per kelvin as a quarter tile of air.
#define XENOARCH_HEAT_CAPACITY 5000

//Handles heat transfer to the air. (In watts)
//Can heat a single tile 2 degrees per tick.
#define XENOARCH_MAX_ENERGY_TRANSFER 4000

//How many joules of electrical energy produce how many joules of heat energy?
#define XENOARCH_HEAT_COEFFICIENT 3


/obj/machinery/anomaly
	name = "Analysis machine"
	desc = "A specialised, complex analysis machine."
	anchored = 1
	density = 1
	icon = 'icons/obj/virology.dmi'
	icon_state = "analyser"

	idle_power_usage = 20 //watts
	active_power_usage = 300 //Because  I need to make up numbers~

	var/obj/item/weapon/reagent_containers/glass/held_container
	var/obj/item/weapon/tank/fuel_container
	var/target_scan_ticks = 30
	var/report_num = 0
	var/scan_process = 0
	var/temperature = 273	//measured in kelvin, if this exceeds 1200, the machine is damaged and requires repairs
							//if this exceeds 600 and safety is enabled it will shutdown
							//temp greater than 600 also requires a safety prompt to initiate scanning
	var/max_temp = 450

/obj/machinery/anomaly/New()
	..()

	//for analysis debugging
	/*var/obj/item/weapon/reagent_containers/glass/solution_tray/S = new(src.loc)
	var/turf/unsimulated/mineral/diamond/D
	for(var/turf/unsimulated/mineral/diamond/M in world)
		D = M
		break
	S.reagents.add_reagent("analysis_sample", 1, D.geological_data)
	S.reagents.add_reagent("chlorine", 1, null)*/

/obj/machinery/anomaly/process()
	//not sure if everything needs to heat up, or just the GLPC
	var/datum/gas_mixture/env = loc.return_air()
	var/environmental_temp = env.temperature
	if(scan_process)
		if(scan_process++ > target_scan_ticks)
			FinishScan()
		else if(temperature > 400)
			src.visible_message("\blue \icon[src] shuts down from the heat!", 2)
			scan_process = 0
		else if(temperature > 350 && prob(10))
			src.visible_message("\blue \icon[src] bleets plaintively.", 2)
			if(temperature > 400)
				scan_process = 0

		//show we're busy
		if(prob(5))
			src.visible_message("\blue \icon[src] [pick("whirrs","chuffs","clicks")][pick(" quietly"," softly"," sadly"," excitedly"," energetically"," angrily"," plaintively")].", 2)

		use_power = 2

	else
		use_power = 1

	//Add 3000 joules when active.  This is about 0.6 degrees per tick.
	//May need adjustment
	if(use_power == 1)
		var/heat_added = active_power_usage *XENOARCH_HEAT_COEFFICIENT

		if(temperature < max_temp)
			temperature += heat_added/XENOARCH_HEAT_CAPACITY

		var/temperature_difference = abs(environmental_temp-temperature)
		var/datum/gas_mixture/removed = loc.remove_air(env.total_moles*0.25)
		var/heat_capacity = removed.heat_capacity()

		heat_added = max(temperature_difference*heat_capacity, XENOARCH_MAX_ENERGY_TRANSFER)

		if(temperature > environmental_temp)
			//cool down to match the air
			temperature = max(TCMB, temperature - heat_added/XENOARCH_HEAT_CAPACITY)
			removed.temperature = max(TCMB, removed.temperature + heat_added/heat_capacity)

			if(temperature_difference > 10 && prob(5))
				src.visible_message("\blue \icon[src] hisses softly.", 2)

		else
			//heat up to match the air
			temperature = max(TCMB, temperature + heat_added/XENOARCH_HEAT_CAPACITY)
			removed.temperature = max(TCMB, removed.temperature - heat_added/heat_capacity)

			if(temperature_difference > 10 && prob(5))
				src.visible_message("\blue \icon[src] plinks quietly.", 2)

		env.merge(removed)


//this proc should be overriden by each individual machine
/obj/machinery/anomaly/attack_hand(var/mob/user as mob)
	if(..()) return
	if(stat & (NOPOWER|BROKEN))
		return
	user.machine = src
	var/dat = "<B>[src.name]</B><BR>"

	// AUTOFIXED BY fix_string_idiocy.py
	// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\research\xenoarchaeology\machinery\analysis_base.dm:111: dat += "Module heat level: [temperature] kelvin<br>"
	dat += {"Module heat level: [temperature] kelvin<br>
		Safeties set at 350k, shielding failure at 400k. Failure to maintain safe heat levels may result in equipment damage.<br>
		<hr>"}
	// END AUTOFIX
	if(scan_process)
		dat += "Scan in progress<br><br><br>"
	else
		dat += "[held_container ? "<A href='?src=\ref[src];eject_beaker=1'>Eject beaker</a>" : "No beaker inserted."]<br>"
		//dat += "[fuel_container ? "<A href='?src=\ref[src];eject_fuel=1'>Eject fuel tank</a>" : "No fuel tank inserted."]<br>"
		dat += "[held_container ? "<A href='?src=\ref[src];begin=1'>Begin scanning</a>" : ""]"

	// AUTOFIXED BY fix_string_idiocy.py
	// C:\Users\Rob\Documents\Projects\vgstation13\code\modules\research\xenoarchaeology\machinery\analysis_base.dm:120: dat += "<hr>"
	dat += {"<hr>
		<A href='?src=\ref[src];refresh=1'>Refresh</a><BR>
		<A href='?src=\ref[src];close=1'>Close</a><BR>"}
	// END AUTOFIX
	user << browse(dat, "window=anomaly;size=450x500")
	onclose(user, "anomaly")

obj/machinery/anomaly/attackby(obj/item/weapon/W as obj, mob/living/user as mob)
	if(istype(W, /obj/item/weapon/reagent_containers/glass))
		//var/obj/item/weapon/reagent_containers/glass/G = W
		if(held_container)
			user << "\red You must remove the [held_container] first."
		else
			user << "\blue You put the [W] into the [src]."
			user.drop_item(W)
			held_container = W
			held_container.loc = src
			updateDialog()

	/*else if(istype(W, /obj/item/weapon/tank))
		//var/obj/item/weapon/reagent_containers/glass/G = W
		if(fuel_container)
			user << "\red You must remove the [fuel_container] first."
		else
			user << "\blue You put the [fuel_container] into the [src]."
			user.drop_item(W)
			fuel_container.loc = src
			fuel_container = W
			updateDialog()*/
	else
		return ..()

obj/machinery/anomaly/proc/ScanResults()
	//instantiate in children to produce unique scan behaviour
	return "\red Error initialising scanning components."

obj/machinery/anomaly/proc/FinishScan()
	scan_process = 0
	updateDialog()

	//determine the results and print a report
	if(held_container)
		src.visible_message("\blue \icon[src] makes an insistent chime.", 2)
		var/obj/item/weapon/paper/P = new(src.loc)
		P.name = "[src] report #[++report_num]"
		P.info = "<b>[src] analysis report #[report_num]</b><br><br>" + ScanResults()
		P.stamped = list(/obj/item/weapon/stamp)
		P.overlays = list("paper_stamped")
	else
		src.visible_message("\blue \icon[src] makes a low buzzing noise.", 2)

obj/machinery/anomaly/Topic(href, href_list)
	if(..()) return
	usr.set_machine(src)
	if(href_list["close"])
		usr << browse(null, "window=anomaly")
		usr.machine = null
	if(href_list["eject_beaker"])
		held_container.loc = src.loc
		held_container = null
	if(href_list["eject_fuel"])
		fuel_container.loc = src.loc
		fuel_container = null
	if(href_list["begin"])
		if(temperature >= 350)
			var/proceed = input("Unsafe internal temperature detected, enter YES below to continue.","Warning")
			if(proceed == "YES" && get_dist(src, usr) <= 1)
				scan_process = 1
		else
			scan_process = 1

	updateUsrDialog()

//whether the carrier sample matches the possible finds
//results greater than a threshold of 0.6 means a positive result
obj/machinery/anomaly/proc/GetResultSpecifity(var/datum/geosample/scanned_sample, var/carrier_name)
	var/specifity = 0
	if(scanned_sample && carrier_name)

		if(scanned_sample.find_presence.Find(carrier_name))
			specifity = 0.75 * (scanned_sample.find_presence[carrier_name] / scanned_sample.total_spread) + 0.25
		else
			specifity = rand(0, 0.5)

	return specifity
