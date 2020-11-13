/**
 * R&D Research Point Hardware
 *
 * These machines are responsible for the passive creation of research points.
 * Servers consume energy and produce heat. Hot machines have reduced effeciency.
 * Multiple servers help, but only one block can be mined at a time. The Birthday Paradox implies diminishing returns.
 */
/obj/machinery/rnd/server
	name = "\improper R&D Server"
	desc = "A computer system running a deep neural network that processes arbitrary information to produce data useable in the development of new technologies. In layman's terms, it makes research points."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "RD-server-on"
	req_access = list(ACCESS_RD)
	// Point mining
	var/working = TRUE
	var/research_disabled = FALSE
	var/datum/techweb_node/researching_node
	var/total_mining_income = 0
	var/part_efficiency = 1 // Bonus from higher parts.
	var/pool_efficiency = 1 // Updated by the Research controller.
	var/department_pool = TECHWEB_POINT_TYPE_GENERIC
	// Heat Management
	var/current_temp = T20C
	var/temp_per_cycle = 10 // n degC per second
	var/temp_tolerance_low = T0C
	var/temp_tolerance_high = T0C + 60 // 60C, maximum comfortable temperature before effeciency loss
	var/temp_tolerance_max = T0C + 100 // 100C, maximum temperature before the RD server shuts itself off
	var/temp_penalty_coefficient = 0.025 // Reduces effeciency by n% per degree Celsius over temp_tolerance_high
	// Antagonist Fun
	var/total_syndicate_income = 0
	var/malf_ai_slave = FALSE
	// Communication
	var/obj/item/radio/radio
	var/radio_key = /obj/item/encryptionkey/headset_sci
	var/science_channel = RADIO_CHANNEL_SCIENCE
	var/syndicate_channel = RADIO_CHANNEL_SYNDICATE

/obj/machinery/rnd/server/Initialize()
	. = ..()
	name += " [num2hex(rand(1,65535), -1)]" //gives us a random four-digit hex number as part of the name. Y'know, for fluff.
	SSresearch.servers |= src
	stored_research = SSresearch.science_tech
	// default temp is turf
	var/turf/L = loc
	if(isturf(L))
		current_temp = L.temperature
	// radio
	radio = new(src)
	radio.keyslot = new radio_key
	radio.listening = 0
	radio.recalculateChannels()

/obj/machinery/rnd/server/Destroy()
	SSresearch.servers -= src
	return ..()

/obj/machinery/rnd/server/RefreshParts()
	// 3% effeciency per capcaitor per tier after 1, so 16% at T5
	part_efficiency = 1
	for(var/obj/item/stock_parts/capacitor/C in src)
		part_efficiency += (C.rating - 1) * 0.03
	// -2C heat per laser tier after 1, so 2C total at T5
	temp_per_cycle = 10
	for(var/obj/item/stock_parts/micro_laser/ML in src)
		temp_per_cycle -= (ML.rating - 1) * 2
	temp_per_cycle = max(temp_per_cycle, 0) // just in case we get more ridiculous parts


/obj/machinery/rnd/server/update_icon_state()
	if(machine_stat & EMPED || machine_stat & NOPOWER)
		icon_state = "RD-server-off"
	else if(research_disabled)
		icon_state = "RD-server-halt"
	else
		icon_state = "RD-server-on"

/obj/machinery/rnd/server/power_change()
	. = ..()
	refresh_working()
	return

/obj/machinery/rnd/server/proc/refresh_working()
	if(machine_stat & EMPED || research_disabled || machine_stat & NOPOWER)
		working = FALSE
	else
		working = TRUE
	update_icon()

/obj/machinery/rnd/server/proc/mine(base_income)
	if(!researching_node)
		return FALSE
	var/income = base_income * get_net_efficiency()
	var/list/points = list()
	points[department_pool] = income
	// Do research. Returns TRUE if the node completed this cycle.
	var/finished = SSresearch.science_tech.add_research_points_to_node(researching_node, points)
	if(finished)
		investigate_log("[name] finished researching [researching_node.id]([json_encode(researching_node.research_costs)]) on techweb id [stored_research.id].", INVESTIGATE_RESEARCH)
		radio.talk_into(src, "[researching_node.display_name] has been researched.", science_channel, language = get_selected_language())
		researching_node = FALSE
	produce_heat()
	return TRUE

/obj/machinery/rnd/server/emag_act(mob/user)
	if(machine_stat & EMAGGED)
		return
	machine_stat |= EMAGGED
	playsound(src, "sparks", 75, TRUE)
	to_chat(user, "<span class='notice'>The [name] is now slaved to Syndicate research posts.</span>")

/obj/machinery/rnd/server/emp_act()
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	machine_stat |= EMPED
	addtimer(CALLBACK(src, .proc/unemp), 600)
	refresh_working()

/obj/machinery/rnd/server/proc/unemp()
	machine_stat &= ~EMPED
	refresh_working()

/obj/machinery/rnd/server/ui_data()
	. = list()
	.["ref"] = REF(src)
	.["name"] = name
	.["current_temp"] = current_temp
	.["current_temp_color"] = get_temp_color()
	.["efficiency"] = get_net_efficiency()
	.["research_disabled"] = research_disabled
	.["researching_node"] = researching_node ? researching_node.serialize_list() : FALSE
	.["emagged"] = (obj_flags & EMAGGED ? 1 : 0)
	.["emped"] = (machine_stat & EMPED ? 1 : 0)
	.["unpowered"] = (machine_stat & NOPOWER ? 1 : 0)

/obj/machinery/rnd/server/proc/set_research_disabled(disabled)
	research_disabled = disabled
	refresh_working()

/obj/machinery/rnd/server/proc/get_temp_color()
	var/green = 1;
	var/red = 1;
	var/overheat = max((current_temp - temp_tolerance_high), 0)
	if(overheat > 0)
		green = 1 - (overheat * temp_penalty_coefficient)
	else
		var/underheat = max((current_temp - temp_tolerance_low), 0)
		red = underheat / (temp_tolerance_high - temp_tolerance_low)
	red *= 255
	green *= 255
	return "rgb([red],[green],0)"

/obj/machinery/rnd/server/proc/get_temp_efficiency()
	return 1 - (max((current_temp - temp_tolerance_high), 0) * temp_penalty_coefficient)

/obj/machinery/rnd/server/proc/get_net_efficiency()
	return part_efficiency * get_temp_efficiency()

/obj/machinery/rnd/server/proc/produce_heat()
	if(machine_stat & (NOPOWER|BROKEN) || !working)
		return PROCESS_KILL

	var/turf/L = loc
	if(!isturf(L))
		return

	var/datum/gas_mixture/env = L.return_air()
	// The RD Server will increase 1degC of heat in a normal atmosphere of moles.
	// 0.5 if turf is twice as dense as normal, 2 if twice as thin
	var/heatFactor = max(MOLES_CELLSTANDARD / env.total_moles(), 0)
	// Adjust external temperature by cycle energy and mole heat factor
	env.temperature += temp_per_cycle * heatFactor
	// If our air is hotter than the CPU, we bump the CPU's internal temperature as well.
	if (env.temperature > current_temp + temp_per_cycle)
		current_temp += temp_per_cycle
	// If our air is cooler than the CPU, we drop the CPU's internal temperature.
	else if (env.temperature < current_temp - temp_per_cycle)
		current_temp = max(current_temp - temp_per_cycle, temp_tolerance_low) // we never run cooler than freezing.

	air_update_turf()

	if(current_temp > temp_tolerance_max)
		radio.talk_into(src, "Terminating research work due to unsafe processor temperatures.", science_channel, language = get_selected_language())
		current_temp = T20C
		research_disabled = TRUE
		refresh_working()
		return
