#define CAN_DEFAULT_RELEASE_PRESSURE 	(ONE_ATMOSPHERE)
///Used when setting the mode of the canisters, enabling us to switch the overlays
//These are used as icon states later down the line for tier overlays
#define CANISTER_TIER_1					"tier 1"
#define CANISTER_TIER_2					"tier 2"
#define CANISTER_TIER_3					"tier 3"

/obj/machinery/portable_atmospherics/canister
	name = "canister"
	desc = "A canister for the storage of gas."
	icon_state = "yellow"
	density = TRUE
	base_icon_state = "yellow" //Used to make dealing with breaking the canister less hellish.
	volume = 1000
	armor = list(MELEE = 50, BULLET = 50, LASER = 50, ENERGY = 100, BOMB = 10, BIO = 100, RAD = 100, FIRE = 80, ACID = 50)
	max_integrity = 250
	integrity_failure = 0.4
	pressure_resistance = 7 * ONE_ATMOSPHERE
	req_access = list()

	var/valve_open = FALSE
	var/release_log = ""

	var/filled = 0.5
	var/gas_type

	var/release_pressure = ONE_ATMOSPHERE
	var/can_max_release_pressure = (ONE_ATMOSPHERE * 10)
	var/can_min_release_pressure = (ONE_ATMOSPHERE / 10)
	///Max amount of heat allowed inside of the canister before it starts to melt (different tiers have different limits)
	var/heat_limit = 5000
	///Max amount of pressure allowed inside of the canister before it starts to break (different tiers have different limits)
	var/pressure_limit = 50000

	var/temperature_resistance = 1000 + T0C
	var/starter_temp
	// Prototype vars
	var/prototype = FALSE
	var/valve_timer = null
	var/timer_set = 30
	var/default_timer_set = 30
	var/minimum_timer_set = 1
	var/maximum_timer_set = 300
	var/timing = FALSE
	var/restricted = FALSE
	///Set the tier of the canister and overlay used
	var/mode = CANISTER_TIER_1

	var/update = 0
	var/static/list/label2types = list(
		"n2" = /obj/machinery/portable_atmospherics/canister/nitrogen,
		"o2" = /obj/machinery/portable_atmospherics/canister/oxygen,
		"co2" = /obj/machinery/portable_atmospherics/canister/carbon_dioxide,
		"plasma" = /obj/machinery/portable_atmospherics/canister/toxins,
		"n2o" = /obj/machinery/portable_atmospherics/canister/nitrous_oxide,
		"no2" = /obj/machinery/portable_atmospherics/canister/nitryl,
		"bz" = /obj/machinery/portable_atmospherics/canister/bz,
		"air" = /obj/machinery/portable_atmospherics/canister/air,
		"water vapor" = /obj/machinery/portable_atmospherics/canister/water_vapor,
		"tritium" = /obj/machinery/portable_atmospherics/canister/tritium,
		"hyper-noblium" = /obj/machinery/portable_atmospherics/canister/nob,
		"stimulum" = /obj/machinery/portable_atmospherics/canister/stimulum,
		"pluoxium" = /obj/machinery/portable_atmospherics/canister/pluoxium,
		"caution" = /obj/machinery/portable_atmospherics/canister,
		"miasma" = /obj/machinery/portable_atmospherics/canister/miasma,
		"freon" = /obj/machinery/portable_atmospherics/canister/freon,
		"hydrogen" = /obj/machinery/portable_atmospherics/canister/hydrogen,
		"healium" = /obj/machinery/portable_atmospherics/canister/healium,
		"proto_nitrate" = /obj/machinery/portable_atmospherics/canister/proto_nitrate,
		"zauker" = /obj/machinery/portable_atmospherics/canister/zauker,
		"halon" = /obj/machinery/portable_atmospherics/canister/halon
	)

/obj/machinery/portable_atmospherics/canister/interact(mob/user)
	if(!allowed(user))
		to_chat(user, "<span class='alert'>Error - Unauthorized User.</span>")
		playsound(src, 'sound/misc/compiler-failure.ogg', 50, TRUE)
		return
	..()

/obj/machinery/portable_atmospherics/canister/examine(user)
	. = ..()
	if(mode)
		. += "<span class='notice'>This canister is [mode]. A sticker on its side says <b>MAX PRESSURE: [siunit(pressure_limit, "Pa", 0)]</b>.</span>"

/obj/machinery/portable_atmospherics/canister/nitrogen
	name = "Nitrogen canister"
	desc = "Nitrogen gas. Reportedly useful for something."
	icon_state = "red"
	base_icon_state = "red"
	gas_type = /datum/gas/nitrogen

/obj/machinery/portable_atmospherics/canister/oxygen
	name = "Oxygen canister"
	desc = "Oxygen. Necessary for human life."
	icon_state = "blue"
	base_icon_state = "blue"
	gas_type = /datum/gas/oxygen

/obj/machinery/portable_atmospherics/canister/carbon_dioxide
	name = "Carbon dioxide canister"
	desc = "Carbon dioxide. What the fuck is carbon dioxide?"
	icon_state = "black"
	base_icon_state = "black"
	gas_type = /datum/gas/carbon_dioxide

/obj/machinery/portable_atmospherics/canister/toxins
	name = "Plasma canister"
	desc = "Plasma gas. The reason YOU are here. Highly toxic."
	icon_state = "orange"
	base_icon_state = "orange"
	gas_type = /datum/gas/plasma

/obj/machinery/portable_atmospherics/canister/bz
	name = "\improper BZ canister"
	desc = "BZ, a powerful hallucinogenic nerve agent."
	icon_state = "purple"
	base_icon_state = "purple"
	gas_type = /datum/gas/bz

/obj/machinery/portable_atmospherics/canister/nitrous_oxide
	name = "Nitrous oxide canister"
	desc = "Nitrous oxide gas. Known to cause drowsiness."
	icon_state = "redws"
	base_icon_state = "redws"
	gas_type = /datum/gas/nitrous_oxide

/obj/machinery/portable_atmospherics/canister/air
	name = "Air canister"
	desc = "Pre-mixed air."
	icon_state = "grey"
	base_icon_state = "grey"

/obj/machinery/portable_atmospherics/canister/tritium
	name = "Tritium canister"
	desc = "Tritium. Inhalation might cause irradiation."
	icon_state = "green"
	base_icon_state = "green"
	gas_type = /datum/gas/tritium

/obj/machinery/portable_atmospherics/canister/nob
	name = "Hyper-noblium canister"
	desc = "Hyper-Noblium. More noble than all other gases."
	icon_state = "nob"
	base_icon_state = "nob"
	gas_type = /datum/gas/hypernoblium

/obj/machinery/portable_atmospherics/canister/nitryl
	name = "Nitryl canister"
	desc = "Nitryl gas. Feels great 'til the acid eats your lungs."
	icon_state = "brown"
	base_icon_state = "brown"
	gas_type = /datum/gas/nitryl

/obj/machinery/portable_atmospherics/canister/stimulum
	name = "Stimulum canister"
	desc = "Stimulum. High energy gas, high energy people."
	icon_state = "darkpurple"
	base_icon_state = "darkpurple"
	gas_type = /datum/gas/stimulum

/obj/machinery/portable_atmospherics/canister/pluoxium
	name = "Pluoxium canister"
	desc = "Pluoxium. Like oxygen, but more bang for your buck."
	icon_state = "darkblue"
	base_icon_state = "darkblue"
	gas_type = /datum/gas/pluoxium

/obj/machinery/portable_atmospherics/canister/water_vapor
	name = "Water vapor canister"
	desc = "Water Vapor. We get it, you vape."
	icon_state = "water_vapor"
	base_icon_state = "water_vapor"
	gas_type = /datum/gas/water_vapor
	filled = 1

/obj/machinery/portable_atmospherics/canister/miasma
	name = "Miasma canister"
	desc = "Miasma. Makes you wish your nose was blocked."
	icon_state = "miasma"
	base_icon_state = "miasma"
	gas_type = /datum/gas/miasma
	filled = 1

/obj/machinery/portable_atmospherics/canister/freon
	name = "Freon canister"
	desc = "Freon. Can absorb heat"
	icon_state = "freon"
	base_icon_state = "freon"
	gas_type = /datum/gas/freon
	filled = 1

/obj/machinery/portable_atmospherics/canister/hydrogen
	name = "Hydrogen canister"
	desc = "Hydrogen, highly flammable"
	icon_state = "h2"
	base_icon_state = "h2"
	gas_type = /datum/gas/hydrogen
	filled = 1

/obj/machinery/portable_atmospherics/canister/healium
	name = "Healium canister"
	desc = "Healium, causes deep sleep"
	icon_state = "healium"
	base_icon_state = "healium"
	gas_type = /datum/gas/healium
	filled = 1

/obj/machinery/portable_atmospherics/canister/proto_nitrate
	name = "Proto Nitrate canister"
	desc = "Proto Nitrate, reacts differently with various gases"
	icon_state = "proto_nitrate"
	base_icon_state = "proto_nitrate"
	gas_type = /datum/gas/proto_nitrate
	filled = 1

/obj/machinery/portable_atmospherics/canister/zauker
	name = "Zauker canister"
	desc = "Zauker, highly toxic"
	icon_state = "zauker"
	base_icon_state = "zauker"
	gas_type = /datum/gas/zauker
	filled = 1

/obj/machinery/portable_atmospherics/canister/halon
	name = "Halon canister"
	desc = "Halon, removes oxygen from high temperature fires and cools down the area"
	icon_state = "halon"
	base_icon_state = "halon"
	gas_type = /datum/gas/halon
	filled = 1

/obj/machinery/portable_atmospherics/canister/fusion_test
	name = "fusion test canister"
	desc = "Don't be a badmin."
	heat_limit = 1e12
	pressure_limit = 1e14
	mode = CANISTER_TIER_3

/obj/machinery/portable_atmospherics/canister/fusion_test/create_gas()
	air_contents.add_gases(/datum/gas/hydrogen, /datum/gas/plasma, /datum/gas/tritium)
	air_contents.gases[/datum/gas/hydrogen][MOLES] = 500
	air_contents.gases[/datum/gas/plasma][MOLES] = 500
	air_contents.gases[/datum/gas/tritium][MOLES] = 350
	air_contents.temperature = 10000

/obj/machinery/portable_atmospherics/canister/proc/get_time_left()
	if(timing)
		. = round(max(0, valve_timer - world.time) / 10, 1)
	else
		. = timer_set

/obj/machinery/portable_atmospherics/canister/proc/set_active()
	timing = !timing
	if(timing)
		valve_timer = world.time + (timer_set * 10)
	update_icon()

/obj/machinery/portable_atmospherics/canister/proto
	name = "prototype canister"


/obj/machinery/portable_atmospherics/canister/proto/default
	name = "prototype canister"
	desc = "The best way to fix an atmospheric emergency... or the best way to introduce one."
	icon_state = "proto"
	base_icon_state = "proto"
	volume = 5000
	max_integrity = 300
	temperature_resistance = 2000 + T0C
	can_max_release_pressure = (ONE_ATMOSPHERE * 30)
	can_min_release_pressure = (ONE_ATMOSPHERE / 30)
	prototype = TRUE


/obj/machinery/portable_atmospherics/canister/proto/default/oxygen
	name = "prototype canister"
	desc = "A prototype canister for a prototype bike, what could go wrong?"
	gas_type = /datum/gas/oxygen
	filled = 1
	release_pressure = ONE_ATMOSPHERE*2

/obj/machinery/portable_atmospherics/canister/tier_1
	heat_limit = 5000
	pressure_limit = 50000
	mode = CANISTER_TIER_1

/obj/machinery/portable_atmospherics/canister/tier_2
	heat_limit = 500000
	pressure_limit = 5e6
	volume = 3000
	max_integrity = 300
	can_max_release_pressure = (ONE_ATMOSPHERE * 30)
	can_min_release_pressure = (ONE_ATMOSPHERE / 30)
	mode = CANISTER_TIER_2

/obj/machinery/portable_atmospherics/canister/tier_3
	heat_limit = 1e12
	pressure_limit = 1e14
	volume = 5000
	max_integrity = 500
	can_max_release_pressure = (ONE_ATMOSPHERE * 30)
	can_min_release_pressure = (ONE_ATMOSPHERE / 50)
	mode = CANISTER_TIER_3

/obj/machinery/portable_atmospherics/canister/Initialize(mapload, datum/gas_mixture/existing_mixture)
	. = ..()
	if(existing_mixture)
		air_contents.copy_from(existing_mixture)
	else
		create_gas()
	update_icon()


/obj/machinery/portable_atmospherics/canister/proc/create_gas()
	if(gas_type)
		air_contents.add_gas(gas_type)
		if(starter_temp)
			air_contents.temperature = starter_temp
		air_contents.gases[gas_type][MOLES] = (maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature)
		if(starter_temp)
			air_contents.temperature = starter_temp

/obj/machinery/portable_atmospherics/canister/air/create_gas()
	air_contents.add_gases(/datum/gas/oxygen, /datum/gas/nitrogen)
	air_contents.gases[/datum/gas/oxygen][MOLES] = (O2STANDARD * maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature)
	air_contents.gases[/datum/gas/nitrogen][MOLES] = (N2STANDARD * maximum_pressure * filled) * air_contents.volume / (R_IDEAL_GAS_EQUATION * air_contents.temperature)

/obj/machinery/portable_atmospherics/canister/update_icon_state()
	if(machine_stat & BROKEN)
		icon_state = "[base_icon_state]-1"

/obj/machinery/portable_atmospherics/canister/update_overlays()
	. = ..()
	var/isBroken = machine_stat & BROKEN
	///Function is used to actually set the overlays
	. += "[mode]-[isBroken]"
	if(isBroken)
		return
	if(holding)
		. += "can-open"
	if(connected_port)
		. += "can-connector"
	var/pressure = air_contents.return_pressure()
	if(pressure >= 40 * ONE_ATMOSPHERE)
		. += "can-3"
	else if(pressure >= 10 * ONE_ATMOSPHERE)
		. += "can-2"
	else if(pressure >= 5 * ONE_ATMOSPHERE)
		. += "can-1"
	else if(pressure >= 10)
		. += "can-0"

/obj/machinery/portable_atmospherics/canister/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > (temperature_resistance * mode))
		take_damage(5, BURN, 0)


/obj/machinery/portable_atmospherics/canister/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(!(machine_stat & BROKEN))
			canister_break()
		if(disassembled)
			switch(mode)
				if(CANISTER_TIER_1)
					new /obj/item/stack/sheet/metal (loc, 10)
				if(CANISTER_TIER_2)
					new /obj/item/stack/sheet/metal (loc, 10)
					new /obj/item/stack/sheet/plasteel (loc, 5)
				if(CANISTER_TIER_3)
					new /obj/item/stack/sheet/metal (loc, 10)
					new /obj/item/stack/sheet/plasteel (loc, 5)
					new /obj/item/stack/sheet/bluespace_crystal (loc, 1)
		else
			new /obj/item/stack/sheet/metal (loc, 5)
	qdel(src)

/obj/machinery/portable_atmospherics/canister/welder_act(mob/living/user, obj/item/I)
	..()
	if(user.a_intent == INTENT_HARM)
		return FALSE

	if(!I.tool_start_check(user, amount=0))
		return TRUE
	var/pressure = air_contents.return_pressure()
	if(pressure > 300)
		to_chat(user, "<span class='alert'>The pressure gauge on \the [src] indicates a high pressure inside... maybe you want to reconsider?</span>")
		message_admins("[src] deconstructed by [ADMIN_LOOKUPFLW(user)]")
		log_game("[src] deconstructed by [key_name(user)]")
	to_chat(user, "<span class='notice'>You begin cutting \the [src] apart...</span>")
	if(I.use_tool(src, user, 3 SECONDS, volume=50))
		to_chat(user, "<span class='notice'>You cut \the [src] apart.</span>")
		deconstruct(TRUE)

	return TRUE

/obj/machinery/portable_atmospherics/canister/obj_break(damage_flag)
	. = ..()
	if(!.)
		return
	canister_break()

/obj/machinery/portable_atmospherics/canister/proc/canister_break()
	disconnect()
	var/datum/gas_mixture/expelled_gas = air_contents.remove(air_contents.total_moles())
	var/turf/T = get_turf(src)
	T.assume_air(expelled_gas)
	air_update_turf()

	obj_break()
	density = FALSE
	playsound(src.loc, 'sound/effects/spray.ogg', 10, TRUE, -3)
	investigate_log("was destroyed.", INVESTIGATE_ATMOS)

	if(holding)
		holding.forceMove(T)
		holding = null

/obj/machinery/portable_atmospherics/canister/replace_tank(mob/living/user, close_valve)
	. = ..()
	if(.)
		if(close_valve)
			valve_open = FALSE
			update_icon()
			investigate_log("Valve was <b>closed</b> by [key_name(user)].", INVESTIGATE_ATMOS)
		else if(valve_open && holding)
			investigate_log("[key_name(user)] started a transfer into [holding].", INVESTIGATE_ATMOS)

/obj/machinery/portable_atmospherics/canister/process_atmos(delta_time)
	..()
	if(machine_stat & BROKEN)
		return PROCESS_KILL
	if(timing && valve_timer < world.time)
		valve_open = !valve_open
		timing = FALSE

	// Handle gas transfer.
	if(valve_open)
		var/turf/T = get_turf(src)
		var/datum/gas_mixture/target_air = holding ? holding.air_contents : T.return_air()

		if(air_contents.release_gas_to(target_air, release_pressure) && !holding)
			air_update_turf()

	var/our_pressure = air_contents.return_pressure()
	var/our_temperature = air_contents.return_temperature()

	///function used to check the limit of the canisters and also set the amount of damage that the canister can receive, if the heat and pressure are way higher than the limit the more damage will be done
	if(our_temperature > heat_limit || our_pressure > pressure_limit)
		take_damage(clamp((our_temperature/heat_limit) * (our_pressure/pressure_limit) * delta_time * 2, 5, 50), BURN, 0)
	update_icon()

/obj/machinery/portable_atmospherics/canister/ui_state(mob/user)
	return GLOB.physical_state

/obj/machinery/portable_atmospherics/canister/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Canister", name)
		ui.open()

/obj/machinery/portable_atmospherics/canister/ui_data()
	var/data = list()
	data["portConnected"] = connected_port ? 1 : 0
	data["tankPressure"] = round(air_contents.return_pressure() ? air_contents.return_pressure() : 0)
	data["releasePressure"] = round(release_pressure ? release_pressure : 0)
	data["defaultReleasePressure"] = round(CAN_DEFAULT_RELEASE_PRESSURE)
	data["minReleasePressure"] = round(can_min_release_pressure)
	data["maxReleasePressure"] = round(can_max_release_pressure)
	data["valveOpen"] = valve_open ? 1 : 0

	data["isPrototype"] = prototype ? 1 : 0
	if (prototype)
		data["restricted"] = restricted
		data["timing"] = timing
		data["time_left"] = get_time_left()
		data["timer_set"] = timer_set
		data["timer_is_not_default"] = timer_set != default_timer_set
		data["timer_is_not_min"] = timer_set != minimum_timer_set
		data["timer_is_not_max"] = timer_set != maximum_timer_set

	data["hasHoldingTank"] = holding ? 1 : 0
	if (holding)
		data["holdingTank"] = list()
		data["holdingTank"]["name"] = holding.name
		data["holdingTank"]["tankPressure"] = round(holding.air_contents.return_pressure())
	return data

/obj/machinery/portable_atmospherics/canister/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("relabel")
			var/label = input("New canister label:", name) as null|anything in sortList(label2types)
			if(label && !..())
				var/newtype = label2types[label]
				if(newtype)
					var/obj/machinery/portable_atmospherics/canister/replacement = newtype
					investigate_log("was relabelled to [initial(replacement.name)] by [key_name(usr)].", INVESTIGATE_ATMOS)
					name = initial(replacement.name)
					desc = initial(replacement.desc)
					icon_state = initial(replacement.icon_state)
					base_icon_state = icon_state
		if("restricted")
			restricted = !restricted
			if(restricted)
				req_access = list(ACCESS_ENGINE)
			else
				req_access = list()
				. = TRUE
		if("pressure")
			var/pressure = params["pressure"]
			if(pressure == "reset")
				pressure = CAN_DEFAULT_RELEASE_PRESSURE
				. = TRUE
			else if(pressure == "min")
				pressure = can_min_release_pressure
				. = TRUE
			else if(pressure == "max")
				pressure = can_max_release_pressure
				. = TRUE
			else if(pressure == "input")
				pressure = input("New release pressure ([can_min_release_pressure]-[can_max_release_pressure] kPa):", name, release_pressure) as num|null
				if(!isnull(pressure) && !..())
					. = TRUE
			else if(text2num(pressure) != null)
				pressure = text2num(pressure)
				. = TRUE
			if(.)
				release_pressure = clamp(round(pressure), can_min_release_pressure, can_max_release_pressure)
				investigate_log("was set to [release_pressure] kPa by [key_name(usr)].", INVESTIGATE_ATMOS)
		if("valve")
			var/logmsg
			valve_open = !valve_open
			if(valve_open)
				logmsg = "Valve was <b>opened</b> by [key_name(usr)], starting a transfer into \the [holding || "air"].<br>"
				if(!holding)
					var/list/danger = list()
					for(var/id in air_contents.gases)
						var/gas = air_contents.gases[id]
						if(!gas[GAS_META][META_GAS_DANGER])
							continue
						if(gas[MOLES] > (gas[GAS_META][META_GAS_MOLES_VISIBLE] || MOLES_GAS_VISIBLE)) //if moles_visible is undefined, default to default visibility
							danger[gas[GAS_META][META_GAS_NAME]] = gas[MOLES] //ex. "plasma" = 20

					if(danger.len)
						message_admins("[ADMIN_LOOKUPFLW(usr)] opened a canister that contains the following at [ADMIN_VERBOSEJMP(src)]:")
						log_admin("[key_name(usr)] opened a canister that contains the following at [AREACOORD(src)]:")
						for(var/name in danger)
							var/msg = "[name]: [danger[name]] moles."
							log_admin(msg)
							message_admins(msg)
			else
				logmsg = "Valve was <b>closed</b> by [key_name(usr)], stopping the transfer into \the [holding || "air"].<br>"
			investigate_log(logmsg, INVESTIGATE_ATMOS)
			release_log += logmsg
			. = TRUE
		if("timer")
			var/change = params["change"]
			switch(change)
				if("reset")
					timer_set = default_timer_set
				if("decrease")
					timer_set = max(minimum_timer_set, timer_set - 10)
				if("increase")
					timer_set = min(maximum_timer_set, timer_set + 10)
				if("input")
					var/user_input = input(usr, "Set time to valve toggle.", name) as null|num
					if(!user_input)
						return
					var/N = text2num(user_input)
					if(!N)
						return
					timer_set = clamp(N,minimum_timer_set,maximum_timer_set)
					log_admin("[key_name(usr)] has activated a prototype valve timer")
					. = TRUE
				if("toggle_timer")
					set_active()
		if("eject")
			if(holding)
				if(valve_open)
					message_admins("[ADMIN_LOOKUPFLW(usr)] removed [holding] from [src] with valve still open at [ADMIN_VERBOSEJMP(src)] releasing contents into the <span class='boldannounce'>air</span>.")
					investigate_log("[key_name(usr)] removed the [holding], leaving the valve open and transferring into the <span class='boldannounce'>air</span>.", INVESTIGATE_ATMOS)
				replace_tank(usr, FALSE)
				. = TRUE
	update_icon()
