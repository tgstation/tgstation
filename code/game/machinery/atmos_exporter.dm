/obj/machinery/atmos_points
	name = "atmospheric canister exporter"
	desc = "Who's a good boy?"
	icon = 'icons/obj/machines/teleporter.dmi'
	icon_state = "floorflush_c"
	verb_say = "states"
	density = 0
	anchored = 1
	var/market_cooldown = 0
	var/export_target = "------"

	var/list/gas = list()
	var/upressure = 0
	var/lpressure = 0
	var/utemp = 0
	var/ltemp = 0
	var/price = 200
	var/list/concentration = list()

	var/economy_name = ""
	var/list/e_gas = list() // budget stats
	var/e_pressure = 0
	var/e_temp = 0
	var/e_price = 200
	var/e_concentration1 = 0

	var/standard_name = ""
	var/list/s_gas = list() // standard stats
	var/s_pressure = 0
	var/s_temp = 0
	var/s_price = 600
	var/s_concentration1 = 0
	var/s_concentration2 = 0

	var/premium_name = ""
	var/list/p_gas = list() // premium stats
	var/p_pressure = 0
	var/p_temp = 0
	var/p_price = 1000
	var/p_concentration1 = 0
	var/p_concentration2 = 0
	var/p_concentration3 = 0


/obj/machinery/atmos_points/attack_ai(mob/user)
	interact(user)

/obj/machinery/atmos_points/attack_paw(mob/user)
	interact(user)

/obj/machinery/atmos_points/interact(mob/user)
	if (get_dist(src, user) > 1 )
		if(!isAI(user))
			user.unset_machine()
			user << browse(null, "window=port_gen")
			return
	user.set_machine(src)
	var/dat = text("Time until market update: [(market_cooldown - world.time)/10] seconds<br>")
	dat += "</div>"
	dat += text("<A href='?src=\ref[src];action=send'>Export Canister</A> to <A href='?src=\ref[src];action=choose'> [export_target]</A><br>")
	dat += text("<A href='?src=\ref[src];action=scan'>Scan Canister Contents</A><br><br>")
	dat += "</div>"
	dat += text("<u>Economy canister order for [economy_name]:</u><br>")
	dat += text("Economy canister gas: <b>[e_gas[1]]</b><br>")
	dat += text("Economy canister pressure range: <b>[e_pressure-200] to [e_pressure+200]kpa</b><br>")
	dat += text("Economy canister temperature: <b>[e_temp-50] to [e_temp+50] kelvin<b><br>")
	dat += "<br>"
	dat += text("<u>Standard canister order for [standard_name]:</u><br>")
	dat += text("Standard canister gas: [s_gas[1]] at [(s_concentration1 - 5)]-[(s_concentration1 + 5)]%, [s_gas[2]] at [s_concentration2 - 5]-[s_concentration2 + 5]%<br>")
	dat += text("Standard canister pressure range: [s_pressure-100] to [s_pressure+100] kpa <br>")
	dat += text("Standard canister temperature: [s_temp-30] to [s_temp+30] kelvin<br>")
	dat += "<br>"
	dat += text("<u>Premium canister order for [premium_name]:</u><br>")
	dat += text("Premium canister gas: [p_gas[1]] at [(p_concentration1 - 5)]-[(p_concentration1 + 5)]%, [p_gas[2]] at [p_concentration2 - 5]-[p_concentration2 + 5]%, [p_gas[3]] at [p_concentration3 - 5]-[p_concentration3 + 5]%<br>")
	dat += text("Premium canister pressure range: [p_pressure-50] to [p_pressure+50] kpa <br>")
	dat += text("Premium canister temperature: [p_temp-15] to [p_temp+15] kelvin<br>")
	dat += "</div>"
	dat += "<br><A href='?src=\ref[src];action=close'>Close</A>"
	var/datum/browser/popup = new(user, "vending", "Atmos Exporter", 400, 600)
	popup.set_content(dat)
	popup.open()
	src.updateUsrDialog()

/obj/machinery/atmos_points/Topic(href, href_list)
	if(..())
		return
	switch(href_list["action"])
		if ("choose")
			reset()
			export_target = input(usr, "Choose your export quality", "Quality:") as null|anything in list("Economy","Standard","Premium")
			switch(export_target)
				if("Economy")
					export_target = economy_name
					gas = e_gas
					upressure = e_pressure + 200
					lpressure = e_pressure - 200
					utemp = e_temp + 50
					ltemp = e_temp - 50
					concentration = e_concentration1
					price = e_price
				if("Standard")
					export_target = standard_name
					gas = s_gas
					upressure = s_pressure + 100
					lpressure = s_pressure - 100
					utemp = s_temp + 30
					ltemp = s_temp - 30
					concentration = s_concentration1
					concentration = s_concentration2
					price = s_price
				if("Premium")
					export_target = premium_name
					gas = p_gas
					upressure = s_pressure + 50
					lpressure = s_pressure - 50
					utemp = s_temp + 15
					ltemp = s_temp - 15
					concentration += p_concentration1
					concentration += p_concentration2
					concentration += p_concentration3
					price = p_price
			src.updateUsrDialog()
		if ("scan")
			for(var/obj/machinery/portable_atmospherics/canister/C in get_turf(src))
				src.visible_message("<span class='danger'> Canister contains [LAZYLEN(C.air_contents.gases)] gases at [C.air_contents.return_pressure()]kpa pressure and with an internal temperature of [C.air_contents.temperature] kelvin.</span>")
		if ("send")
			for(var/obj/machinery/portable_atmospherics/canister/C in get_turf(src))
				if((lpressure) <= C.air_contents.return_pressure() && C.air_contents.return_pressure() <= (upressure))
					if((ltemp) <= C.air_contents.temperature && C.air_contents.temperature <= (utemp))
						var/total_moles = C.air_contents.total_moles()
						var/list/can_gas = C.air_contents.gases
						var/i = 0
						for(var/id in gas)
							visible_message("<span class='danger'>NOW CHECKING [id], [can_gas[id]]</span>")
							visible_message("<span class='danger'>[gas.len] versus [can_gas.len]</span>")
							if(can_gas[id] && gas.len == can_gas.len)
								var/gas_concentration = (can_gas[id][MOLES]/total_moles)*100
								i++
								visible_message("<span class='danger'>[gas_concentration] versus [concentration[i]]</span>")
								if(gas_concentration <= (concentration[i]-5) || gas_concentration >= (concentration[i]+5))
									visible_message("<span class='danger'>Invalid gas composition detected!</span>")
									return
							else
								visible_message("<span class='danger'>Invalid gas detected!</span>")
								return
							visible_message("<span class='danger'>Valid [export_target] canister detected... exporting now. Your department will receive [price] points!</span>")
							icon_state = "floorflush_a"
							playsound(src, 'sound/machines/Ding.ogg', 100, 1)
							spawn(20)
								qdel(C)
								icon_state = "floorflush_a2"
								reset()
					else
						visible_message("<span class='danger'>Invalid temperature detected!</span>")
				else
					visible_message("<span class='danger'>Invalid pressure detected!</span>")
			src.updateUsrDialog()
		if ("close")
			usr.unset_machine()

/obj/machinery/atmos_points/proc/reset()
	export_target = "------"
	gas.Cut()
	concentration.Cut()
	upressure = 0
	lpressure = 0
	utemp = 0
	ltemp = 0

/obj/machinery/atmos_points/process()
	if(market_cooldown < world.time)
		economy_name = corp_name()
		var/e_choice = rand(1,5)
		switch(e_choice)
			if(1)
				e_gas += "o2"
			if(2)
				e_gas += "n2"
			if(3)
				e_gas += "n2o"
			if(4)
				e_gas += "plasma"
			if(5)
				e_gas += "co2"
		e_pressure = rand(1,4500)
		e_temp = rand(75,550)
		e_concentration1 = 100
		e_price = rand(200,500)

		standard_name = corp_name()
		for(var/i in 1 to 2)
			var/s_choice = rand(1,5)
			switch(s_choice)
				if(1)
					s_gas += "o2"
				if(2)
					s_gas += "n2"
				if(3)
					s_gas += "n2o"
				if(4)
					s_gas += "plasma"
				if(5)
					s_gas += "co2"
		s_pressure = rand(1,4500)
		s_temp = rand(75,550)
		s_concentration1 = rand(20,80)
		s_concentration2 = 100 - s_concentration1
		s_price = rand(500,800)

		premium_name = corp_name()
		for(var/i in 1 to 3)
			var/p_choice = rand(1,5)
			switch(p_choice)
				if(1)
					p_gas += "o2"
				if(2)
					p_gas += "n2"
				if(3)
					p_gas += "n2o"
				if(4)
					p_gas += "plasma"
				if(5)
					p_gas += "co2"
		p_pressure = rand(2000,9000)
		p_temp = rand(0,1)
		if(p_temp)
			p_temp = rand(600,5000)
		else
			p_temp = rand(5,70)
		p_concentration1 = rand(5,45)
		p_concentration2 = rand(5,45)
		p_concentration3 = 100 - p_concentration1 - p_concentration2
		p_price = rand(1000,3000)

		market_cooldown = world.time + 3000
		reset()


/obj/machinery/atmos_points/proc/corp_name()
	var/name = ""

	// Prefix
	name += pick("Clandestine", "Prima", "Blue", "Front", "Max", "Atmosia", "Shell", "North", "Omni", "Newton", "Cyber", "Red Harvest", "Gene", "Plasmatech")

	// Suffix
	if (prob(80))
		name += " "

		// Full
		if (prob(60))
			name += pick("Consortium", "Collective", "Corporation", "Group", "Holdings", "Biotech", "Industries", "Systems", "Products", "Chemicals", "Enterprises", "Creations", "International", "Intergalactic", "Interplanetary", "Foundation", "Positronics", "Hive")
		// Broken
		else
			name += pick("Syndi", "Corp", "Bio", "System", "Prod", "Chem", "Inter", "Hive")
			name += pick("", "-")
			name += pick("Tech", "Sun", "Co", "Tek", "X", "Inc", "Code")
	// Small
	else
		name += pick("-", "*", "")
		name += pick("Tech", "Sun", "Co", "Tek", "X", "Inc", "Gen", "Star", "Dyne", "Code", "Hive")

	return name
