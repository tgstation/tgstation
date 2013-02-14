
/obj/machinery/anomaly
	anchored = 1
	density = 1
	//
	var/obj/item/weapon/reagent_containers/glass/held_container
	var/obj/item/weapon/tank/fuel_container
	var/target_scan_ticks = 60
	var/report_num = 0
	var/scan_process = 0
	var/heat_accumulation_rate = 1
	var/temperature = 273	//measured in kelvin, if this exceeds 1200, the machine is damaged and requires repairs
							//if this exceeds 600 and safety is enabled it will shutdown
							//temp greater than 600 also requires a safety prompt to initiate scanning
	var/scanner_dir = 0
	var/obj/machinery/anomaly/scanner/owned_scanner = null

/obj/machinery/anomaly/New()
	..()
	//connect to a nearby scanner pad
	if(scanner_dir)
		owned_scanner = locate(/obj/machinery/anomaly/scanner) in get_step(src, scanner_dir)
	if(!owned_scanner)
		owned_scanner = locate(/obj/machinery/anomaly/scanner) in orange(1)

	var/obj/item/weapon/reagent_containers/glass/solution_tray/S = new(src.loc)
	var/turf/simulated/mineral/diamond/D
	for(var/turf/simulated/mineral/diamond/M in world)
		D = M
		break
	S.reagents.add_reagent("analysis_sample", 1, D.geological_data)
	S.reagents.add_reagent("calcium", 1, D.geological_data)

/obj/machinery/anomaly/process()
	//not sure if everything needs to heat up, or just the GLPC
	var/datum/gas_mixture/env = loc.return_air()
	var/environmental_temp = env.temperature
	if(scan_process)
		if(scan_process++ > target_scan_ticks)
			FinishScan()

		//heat up as we go, but if the air is freezing then heat up much slower
		var/new_heat = heat_accumulation_rate + heat_accumulation_rate * rand(-5,5) / 10
		temperature += new_heat
		if(temperature > 350 && prob(10))
			src.visible_message("\blue \icon[src] bleets plaintively.", 2)
			if(temperature > 400)
				scan_process = 0

		//show we're busy
		if(prob(10))
			src.visible_message("\blue \icon[src] [pick("whirrs","chuffs","clicks")][pick(" quietly"," softly"," sadly"," excitedly"," energetically"," angrily"," plaintively")].", 2)

	if(temperature > environmental_temp)
		//cool down to match the air
		temperature -= heat_accumulation_rate + heat_accumulation_rate * rand(-5,5) / 10
		if(temperature < environmental_temp)
			temperature = environmental_temp
		if(prob(10))
			src.visible_message("\blue \icon[src] hisses softly.", 2)

	else if(temperature < environmental_temp)
		//heat up to match the air
		temperature += heat_accumulation_rate + rand(-5,5) / 10
		if(temperature > environmental_temp)
			temperature = environmental_temp
		else
			if(prob(10))
				src.visible_message("\blue \icon[src] plinks quietly.", 2)

	//warm up the lab slightly
	if(env.temperature < temperature)
		env.temperature += (temperature - env.temperature) * 0.1

//this proc should be overriden by each individual machine
/obj/machinery/anomaly/attack_hand(var/mob/user as mob)
	if(stat & (NOPOWER|BROKEN))
		return
	user.machine = src
	var/dat = "<B>[src.name]</B><BR>"
	dat += "[owned_scanner ? "Scanner connected." : "Scanner disconnected."]<br>"
	dat += "Module heat level: [temperature] kelvin<br>"
	dat += "Safeties set at 300k, shielding failure at 400k. Failure to maintain safe heat levels may result in equipment damage.<br>"
	dat += "<hr>"
	if(scan_process)
		dat += "Scan in progress<br><br><br>"
	else
		dat += "[held_container ? "<A href='?src=\ref[src];eject_beaker=1'>Eject beaker</a>" : "No beaker inserted."]<br>"
		dat += "[fuel_container ? "<A href='?src=\ref[src];eject_fuel=1'>Eject fuel tank</a>" : "No fuel tank inserted."]<br>"
		dat += "[held_container ? "<A href='?src=\ref[src];begin=1'>Begin scanning</a>" : ""]"
	dat += "<hr>"
	dat += "<A href='?src=\ref[src];refresh=1'>Refresh</a><BR>"
	dat += "<A href='?src=\ref[src];close=1'>Close</a><BR>"
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

	else if(istype(W, /obj/item/weapon/tank))
		//var/obj/item/weapon/reagent_containers/glass/G = W
		if(fuel_container)
			user << "\red You must remove the [fuel_container] first."
		else
			user << "\blue You put the [fuel_container] into the [src]."
			user.drop_item(W)
			fuel_container.loc = src
			fuel_container = W
			updateDialog()
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
	..()
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
		if(temperature >= 300)
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
			specifity = 0.7 * (scanned_sample.find_presence[carrier_name] / scanned_sample.total_spread) + 0.3
		else
			specifity = rand(0, 0.5)

	return specifity
