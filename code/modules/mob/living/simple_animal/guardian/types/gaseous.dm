//Gaseous
/mob/living/simple_animal/hostile/guardian/gaseous
	melee_damage_lower = 10
	melee_damage_upper = 10
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 0)
	range = 7
	playstyle_string = span_holoparasite("As a <b>gaseous</b> type, you have only light damage resistance, but you can expel gas in an area. In addition, your punches cause sparks, and you make your summoner inflammable.")
	magic_fluff_string = span_holoparasite("..And draw the Atmospheric Technician, flooding the area with gas!")
	tech_fluff_string = span_holoparasite("Boot sequence complete. Atmospheric modules activated. Holoparasite swarm online.")
	carp_fluff_string = span_holoparasite("CARP CARP CARP! You caught one! OH GOD, EVERYTHING'S ON FIRE. Except you and the fish.")
	miner_fluff_string = span_holoparasite("You encounter... Plasma, the bringer of fire.")
	creator_name = "Gaseous"
	creator_desc = "Creates sparks on touch and continuously expels a gas of its choice. Automatically extinguishes the user if they catch on fire."
	creator_icon = "gaseous"
	toggle_button_type = /atom/movable/screen/guardian/toggle_mode/gases
	/// Gas being expelled.
	var/expelled_gas = null
	/// Rate of temperature stabilization per second.
	var/temp_stabilization_rate = 0.1
	/// Possible gases to expel, with how much moles they create.
	var/static/list/possible_gases = list(
		/datum/gas/oxygen = 50,
		/datum/gas/nitrogen = 750, //overpressurizing is hard!.
		/datum/gas/water_vapor = 1, //you need incredibly little water vapor for the effects to kick in
		/datum/gas/nitrous_oxide = 15,
		/datum/gas/carbon_dioxide = 50,
		/datum/gas/plasma = 3,
		/datum/gas/bz = 10,
	)
	/// Gas colors, used for the particles.
	var/static/list/gas_colors = list(
		/datum/gas/oxygen = "#63BFDD", //color of frozen oxygen
		/datum/gas/nitrogen = "#777777", //grey (grey)
		/datum/gas/water_vapor = "#96ADCF", //water is slightly blue
		/datum/gas/nitrous_oxide = "#FEFEFE", //white like the sprite
		/datum/gas/carbon_dioxide = "#222222", //black like coal
		/datum/gas/plasma = "#B233CC", //color of the plasma sprite
		/datum/gas/bz = "#FAFF00", //color of the bz metabolites reagent
	)

/mob/living/simple_animal/hostile/guardian/gaseous/Initialize(mapload, theme)
	. = ..()
	RegisterSignal(src, COMSIG_ATOM_PRE_PRESSURE_PUSH, PROC_REF(stop_pressure))

/mob/living/simple_animal/hostile/guardian/gaseous/AttackingTarget(atom/attacked_target)
	. = ..()
	if(!isliving(target))
		return
	do_sparks(1, TRUE, target)

/mob/living/simple_animal/hostile/guardian/gaseous/recall(forced)
	expelled_gas = null
	QDEL_NULL(particles) //need to delete before putting in another object
	. = ..()
	if(. && summoner)
		UnregisterSignal(summoner, COMSIG_ATOM_PRE_PRESSURE_PUSH)

/mob/living/simple_animal/hostile/guardian/gaseous/manifest(forced)
	. = ..()
	if(. && summoner)
		RegisterSignal(summoner, COMSIG_ATOM_PRE_PRESSURE_PUSH, PROC_REF(stop_pressure))

/mob/living/simple_animal/hostile/guardian/gaseous/Life(delta_time, times_fired)
	. = ..()
	if(summoner)
		summoner.extinguish_mob()
		summoner.set_fire_stacks(0, remove_wet_stacks = FALSE)
		summoner.adjust_bodytemperature(get_temp_change_amount((summoner.get_body_temp_normal() - summoner.bodytemperature), temp_stabilization_rate * delta_time))
	if(!expelled_gas)
		return
	var/datum/gas_mixture/mix_to_spawn = new()
	mix_to_spawn.add_gas(expelled_gas)
	mix_to_spawn.gases[expelled_gas][MOLES] = possible_gases[expelled_gas] * delta_time
	mix_to_spawn.temperature = T20C
	var/turf/open/our_turf = get_turf(src)
	our_turf.assume_air(mix_to_spawn)

/mob/living/simple_animal/hostile/guardian/gaseous/toggle_modes()
	var/list/gases = list("None")
	for(var/datum/gas/gas as anything in possible_gases)
		gases[initial(gas.name)] = gas
	var/picked_gas = tgui_input_list(src, "Select a gas to expel.", "Gas Producer", gases)
	if(picked_gas == "None")
		expelled_gas = null
		QDEL_NULL(particles)
		to_chat(src, span_notice("You stopped expelling gas."))
		return
	var/gas_type = gases[picked_gas]
	if(!picked_gas || !gas_type)
		return
	to_chat(src, span_bolddanger("You are now expelling [picked_gas]."))
	investigate_log("set their gas type to [picked_gas].", INVESTIGATE_ATMOS)
	expelled_gas = gas_type
	if(!particles)
		particles = new /particles/smoke/steam()
		particles.position = list(-1, 8, 0)
		particles.fadein = 5
		particles.height = 200
	particles.color = gas_colors[gas_type]

/mob/living/simple_animal/hostile/guardian/gaseous/proc/stop_pressure(datum/source)
	SIGNAL_HANDLER
	return COMSIG_ATOM_BLOCKS_PRESSURE
