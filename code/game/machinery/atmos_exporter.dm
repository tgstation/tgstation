/obj/machinery/atmos_points
	name = "atmospheric export computer"
	desc = "used to monitor the galactic atmos markets"
	icon = 'icons/obj/machines/engi_points.dmi'
	icon_state = "atmos"
	verb_say = "states"
	density = TRUE
	anchored = TRUE
	var/market_cooldown = 0
	var/export_target = ""
	var/export_name = "------"
	var/list/gas = list()
	var/list/concentration = list()

	// requirements of the canister we want to export
	var/upressure = 0
	var/lpressure = 0
	var/utemp = 0
	var/ltemp = 0
	var/price = 200
	var/can_turf
	// requirements for the economy canister
	var/list/e_gas = list()
	var/economy_name = ""
	var/e_pressure = 0
	var/e_temp = 0
	var/e_price = 200
	var/e_concentration1 = 0
	// requirements for the standard canister
	var/standard_name = ""
	var/list/s_gas = list()
	var/s_pressure = 0
	var/s_temp = 0
	var/s_price = 600
	var/s_concentration1 = 0
	var/s_concentration2 = 0
	// requirements for the premium canister
	var/premium_name = ""
	var/list/p_gas = list() // premium stats
	var/p_pressure = 0
	var/p_temp = 0
	var/p_price = 1000
	var/p_concentration1 = 0
	var/p_concentration2 = 0
	var/p_concentration3 = 0
	var/list/quality = list()

/obj/machinery/atmos_points_exporter
	name = "atmospheric canister exporter"
	desc = "used to export canisters for engineering points"
	icon = 'icons/obj/machines/teleporter.dmi'
	icon_state = "floorflush_c"
	verb_say = "states"
	density = FALSE
	anchored = TRUE

/obj/machinery/atmos_points_exporter/Initialize()
	..()
	atmos_exporter_list += src

/obj/machinery/atmos_points_exporter/Destroy()
	atmos_exporter_list -= src
	return ..()

/obj/machinery/atmos_points_exporter/proc/export()
	for(var/obj/machinery/portable_atmospherics/canister/C in get_turf(src))
		animate(C, transform = matrix() - matrix(), alpha = 0, color = rgb(0, 0, 0), time = 10)
		for(var/t in 1 to 5)
			C.pixel_y--
			sleep(2)
			if(!C || QDELETED(C) || !src || QDELETED(src))
				return
		icon_state = "floorflush_a2"
		qdel(C)

/obj/machinery/atmos_points_exporter/proc/ship()
	icon_state = "floorflush_a"
	playsound(src, 'sound/machines/Ding.ogg', 100, 1)
	addtimer(CALLBACK(src, .proc/export), 20)


/obj/machinery/atmos_points/Initialize()
	..()
	quality = list("Economy","Standard","Premium")
	e_gas += "Initializing"
	s_gas += "Initializing"
	s_gas += "Initializing"
	p_gas += "Initializing"
	p_gas += "Initializing"
	p_gas += "Initializing"

/obj/machinery/atmos_points/interact(mob/user)
	user.set_machine(src)
	for(var/obj/machinery/atmos_points_exporter/AE in atmos_exporter_list)
		can_turf = get_turf(AE)
	var/dat = ("Time until market update: [round((market_cooldown - world.time)/10)] seconds<br>")
	dat += "</div>"
	dat += ("<A href='?src=\ref[src];action=send'>Export Canister</A> to <A href='?src=\ref[src];action=choose'> [export_name]</A><br>")
	dat += ("<A href='?src=\ref[src];action=scan'>Scan Canister Contents</A><br><br>")
	dat += "</div>"
	dat += ("<u><b>Economy canister order for [economy_name]:</b></u><br>")
	dat += ("Economy canister value: <b>[e_price] points</b><br>")
	dat += ("Economy canister gas: <b>[e_gas[1]]</b><br>")
	dat += ("Economy canister pressure range: <b>[e_pressure-200] to [e_pressure+200]kPa</b><br>")
	dat += ("Economy canister temperature: <b>[e_temp-50] to [e_temp+50]K</b><br>")
	dat += "<br>"
	dat += ("<u><b>Standard canister order for [standard_name]:</b></u><br>")
	dat += ("Standard canister value: <b>[s_price] points</b><br>")
	dat += ("Standard canister gas: <b>[s_gas[1]] at [(s_concentration1 - 5)]-[(s_concentration1 + 5)]%, [s_gas[2]] at [s_concentration2 - 5]-[s_concentration2 + 5]%</b><br>")
	dat += ("Standard canister pressure range: <b>[s_pressure-100] to [s_pressure+100]kPa </b><br>")
	dat += ("Standard canister temperature: <b>[s_temp-30] to [s_temp+30]K</b><br>")
	dat += "<br>"
	dat += ("<u><b>Premium canister order for [premium_name]:</b></u><br>")
	dat += ("Premium canister value: <b>[p_price] points</b><br>")
	dat += ("Premium canister gas: <b>[p_gas[1]] at [(p_concentration1 - 5)]-[(p_concentration1 + 5)]%, [p_gas[2]] at [p_concentration2 - 5]-[p_concentration2 + 5]%, [p_gas[3]] at [p_concentration3 - 5]-[p_concentration3 + 5]%</b><br>")
	dat += ("Premium canister pressure range: <b>[p_pressure-50] to [p_pressure+50] kPa </b><br>")
	dat += ("Premium canister temperature: <b>[p_temp-15] to [p_temp+15]K</b><br>")
	var/datum/browser/popup = new(user, "vending", "Atmos Exporter", 400, 500)
	popup.set_content(dat)
	popup.open()
	updateUsrDialog()

/obj/machinery/atmos_points/Topic(href, href_list)
	if(..())
		return
	switch(href_list["action"])
		if ("choose")
			reset()
			export_target = input(usr, "Choose your export quality", "Quality:") as null|anything in quality
			if (!src || QDELETED(src))
				return
			switch(export_target)
				if("Economy")
					export_name = economy_name
					gas = e_gas.Copy()
					upressure = e_pressure + 200
					lpressure = e_pressure - 200
					utemp = e_temp + 50
					ltemp = e_temp - 50
					concentration += e_concentration1
					price = e_price
				if("Standard")
					export_name = standard_name
					gas = s_gas.Copy()
					upressure = s_pressure + 100
					lpressure = s_pressure - 100
					utemp = s_temp + 30
					ltemp = s_temp - 30
					concentration += s_concentration1
					concentration += s_concentration2
					price = s_price
				if("Premium")
					export_name = premium_name
					gas = p_gas.Copy()
					upressure = p_pressure + 50
					lpressure = p_pressure - 50
					utemp = p_temp + 15
					ltemp = p_temp - 15
					concentration += p_concentration1
					concentration += p_concentration2
					concentration += p_concentration3
					price = p_price
			updateUsrDialog()
		if ("scan")
			for(var/obj/machinery/portable_atmospherics/canister/C in get_turf(can_turf)) // "for" efficiency, only 1 can possible
				atmosanalyzer_scan(C.air_contents, usr, C)
				playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 100, 1)
		if ("send")
			for(var/obj/machinery/portable_atmospherics/canister/C in get_turf(can_turf))
				if((lpressure) <= C.air_contents.return_pressure() && C.air_contents.return_pressure() <= (upressure))
					if((ltemp) <= C.air_contents.temperature && C.air_contents.temperature <= (utemp))
						var/total_moles = C.air_contents.total_moles()
						var/list/can_gas = C.air_contents.gases
						var/i = 0
						for(var/id in gas)
							if(can_gas[id])
								var/gas_concentration = (can_gas[id][MOLES]/total_moles)*100
								i++
								if(gas_concentration <= (concentration[i]-5) || gas_concentration >= (concentration[i]+5))
									visible_message("<span class='danger'>Invalid gas composition detected!</span>")
									playsound(src, 'sound/machines/defib_failed.ogg', 100, 1)
									return
							else
								visible_message("<span class='danger'>Invalid gas detected!</span>")
								playsound(src, 'sound/machines/defib_failed.ogg', 100, 1)
								return
						visible_message("<span class='danger'>Valid [export_target] canister detected... exporting now. Your department will receive [price] points!</span>")
						C.anchored = 1
						for(var/obj/machinery/atmos_points_exporter/EX in atmos_exporter_list)
							EX.ship()
						for(var/obj/machinery/engi_points_manager/EPM in engi_points_list)
							EPM.GBP += price
							EPM.GBPearned += price
						if(export_target == "Premium")
							visible_message("<span class='danger'>You have been blessed by the atmos gods for exporting a premium canister!</span>")
							var/prize = pick(/obj/item/clothing/under/rank/atmos_elite,/obj/item/clothing/head/atmos_hood,/obj/item/clothing/neck/cloak/atmos)
							spawn_atom_to_turf(/obj/effect/overlay/temp/explosion/fast, src, 1, admin_spawn=FALSE)
							spawn_atom_to_turf(prize, src, 1, admin_spawn=FALSE)
							playsound(src, 'sound/effects/pray_chaplain.ogg', 100, 1)
						quality.Remove(export_target)
						reset()
					else
						visible_message("<span class='danger'>Invalid temperature detected!</span>")
						playsound(src, 'sound/machines/defib_failed.ogg', 100, 1)
				else
					visible_message("<span class='danger'>Invalid pressure detected!</span>")
					playsound(src, 'sound/machines/defib_failed.ogg', 100, 1)

			updateUsrDialog()

/obj/machinery/atmos_points/proc/reset()
	export_name = "------"
	export_target = ""
	gas.Cut()
	concentration.Cut()
	upressure = 0
	lpressure = 0
	utemp = 0
	ltemp = 0

/obj/machinery/atmos_points/process()
	if(market_cooldown < world.time)
		reset()
		economy_name = corp_name()
		e_gas.Cut()
		var/list/gas_list = list("o2","n2","n2o","plasma","co2")
		var/e_choice = rand(1,5)
		e_gas += gas_list[e_choice]
		e_pressure = rand(500,4500)
		e_temp = rand(75,550)
		e_concentration1 = 100
		e_price = rand(200,500)

		standard_name = corp_name()
		s_gas.Cut()
		gas_list = list("o2","n2","n2o","plasma","co2")
		for(var/x in 1 to 2)
			var/s_choice = rand(1,6-x)
			s_gas += gas_list[s_choice]
			gas_list -= gas_list[s_choice]
		s_pressure = rand(500,4500)
		s_temp = rand(75,550)
		s_concentration1 = rand(60,90)
		s_concentration2 = 100 - s_concentration1
		s_price = rand(500,950)

		premium_name = corp_name()
		p_gas.Cut()
		gas_list = list("o2","n2","n2o","plasma","co2")
		for(var/y in 1 to 3)
			var/p_choice = rand(1,6-y)
			p_gas += gas_list[p_choice]
			gas_list -= gas_list[p_choice]
		p_pressure = rand(3000,9000)
		p_temp = rand(0,1)
		if(p_temp)
			p_temp = rand(600,8000)
		else
			p_temp = rand(5,70)
		p_concentration1 = rand(10,45)
		p_concentration2 = rand(10,45)
		p_concentration3 = 100 - p_concentration1 - p_concentration2
		p_price = rand(1500,3000)

		market_cooldown = world.time + 3000
		quality = list("Economy","Standard","Premium")


