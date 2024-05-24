#define TEG_EFFICIENCY 0.65

/obj/machinery/power/thermoelectric_generator
	name = "thermoelectric generator"
	desc = "It's a high efficiency thermoelectric generator."
	icon = 'goon/icons/teg.dmi'
	icon_state = "teg"
	base_icon_state = "teg"
	density = TRUE
	use_power = NO_POWER_USE
	circuit = /obj/item/circuitboard/machine/thermoelectric_generator

	///our internal semiconductor
	var/obj/item/smithed_part/thermal_semi_conductor/conductor
	///list of applied teg states
	var/list/teg_states = list()
	///the temperature of our semi conductor
	var/semi_temp = T20C
	///our base scale level
	var/base_scale = 50

	///The cold circulator machine, containing cold gas for the mix.
	var/obj/machinery/atmospherics/components/binary/circulator/cold_circ
	///The hot circulator machine, containing very hot gas for the mix.
	var/obj/machinery/atmospherics/components/binary/circulator/hot_circ
	///The amount of power the generator is currently producing.
	var/lastgen = 0
	///The amount of power the generator has last produced.
	var/lastgenlev = -1
	/**
	 * Used in overlays for the TEG, basically;
	 * one number is for the cold mix, one is for the hot mix
	 * If the cold mix has pressure in it, then the first number is 1, else 0
	 * If the hot mix has pressure in it, then the second number is 1, else 0
	 * Neither has pressure: 00
	 * Only cold has pressure: 10
	 * Only hot has pressure: 01
	 * Both has pressure: 11
	 */
	var/last_pressure_overlay = "00"
	///our tegs overall damage
	var/damage = 0
	///our powerlevel
	var/powerlevel = 0

	//static list of messages to say
	var/static/list/prefixes = list("an upsetting", "an unsettling", "a scary", "a loud", "a grouchy", "a grumpy", "an awful", "a horrible", "a despicable", "a pretty rad", "a godawful")
	var/static/list/suffixes = list("noise", "racket", "ruckus", "sound", "clatter", "hubbub", "whirring", "clanging", "bang")


	var/list/past_power_levels = list()
	var/max_history = 50


/obj/machinery/power/thermoelectric_generator/Initialize(mapload)
	. = ..()

	if(mapload)
		conductor = new(src)
		add_teg_state(/datum/thermoelectric_state/worked_material)

	find_circulators()
	connect_to_network()
	SSair.start_processing_machine(src)
	update_appearance()

/obj/machinery/power/thermoelectric_generator/Destroy()
	null_circulators()
	SSair.stop_processing_machine(src)
	return ..()

/obj/machinery/power/thermoelectric_generator/on_deconstruction()
	null_circulators()

/obj/machinery/power/thermoelectric_generator/update_overlays()
	. = ..()
	if(machine_stat & (NOPOWER|BROKEN))
		return

	powerlevel = clamp(round(lastgenlev * 26 / 4000000), 0, 26)
	if(powerlevel)
		. += mutable_appearance('goon/icons/teg.dmi', "[base_icon_state]-op[powerlevel]")
		. += emissive_appearance('goon/icons/teg.dmi', "[base_icon_state]-op[powerlevel]", src)
	if(lastgen)
		.+= emissive_appearance('goon/icons/teg.dmi', "teg-on-emissive", src)

/obj/machinery/power/thermoelectric_generator/wrench_act(mob/living/user, obj/item/tool)
	if(!panel_open)
		balloon_alert(user, "open the panel!")
		return
	set_anchored(!anchored)
	tool.play_tool_sound(src)
	if(anchored)
		connect_to_network()
	else
		null_circulators()
	balloon_alert(user, "[anchored ? "secure" : "unsecure"]")
	return TRUE

/obj/machinery/power/thermoelectric_generator/multitool_act(mob/living/user, obj/item/tool)
	. = ..()
	if(!anchored)
		return
	find_circulators()
	balloon_alert(user, "circulators updated")
	return TRUE

/obj/machinery/power/thermoelectric_generator/screwdriver_act(mob/user, obj/item/tool)
	if(!anchored)
		balloon_alert(user, "anchor it down!")
		return
	toggle_panel_open()
	tool.play_tool_sound(src)
	balloon_alert(user, "panel [panel_open ? "open" : "closed"]")
	return TRUE

/obj/machinery/power/thermoelectric_generator/crowbar_act(mob/living/user, obj/item/tool)
	default_deconstruction_crowbar(tool)
	return TRUE

/obj/machinery/power/thermoelectric_generator/wirecutter_act(mob/living/user, obj/item/tool)
	if(conductor && panel_open)
		remove_conductor()
	return TRUE

/obj/machinery/power/thermoelectric_generator/attacked_by(obj/item/attacking_item, mob/living/user)
	if(!conductor && panel_open)
		if(istype(attacking_item, /obj/item/smithed_part/thermal_semi_conductor))
			insert_conductor(attacking_item, user)
			return FALSE
	. = ..()


/obj/machinery/power/thermoelectric_generator/proc/remove_conductor()
	remove_teg_state(/datum/thermoelectric_state/worked_material)
	conductor.forceMove(get_turf(src))
	conductor = null

/obj/machinery/power/thermoelectric_generator/proc/insert_conductor(obj/item/smithed_part/thermal_semi_conductor/semi, mob/living/user)
	semi.forceMove(src)
	conductor = semi
	add_teg_state(/datum/thermoelectric_state/worked_material)

/obj/machinery/power/thermoelectric_generator/process()
	//Setting this number higher just makes the change in power output slower, it doesnt actualy reduce power output cause **math**
	var/power_output = round(lastgen / 10)
	add_avail(power_output)
	lastgenlev = power_output
	lastgen -= power_output
	process_engine()

/obj/machinery/power/thermoelectric_generator/process_atmos()
	if(!cold_circ || !hot_circ)
		return
	if(!powernet)
		return

	var/datum/gas_mixture/cold_air = cold_circ.return_transfer_air()
	var/datum/gas_mixture/hot_air = hot_circ.return_transfer_air()


	if(cold_air && hot_air)
		var/cold_air_heat_capacity = cold_air.heat_capacity()
		var/hot_air_heat_capacity = hot_air.heat_capacity()

		var/delta_temperature = hot_air.temperature - cold_air.temperature

		if(delta_temperature > 0 && cold_air_heat_capacity > 0 && hot_air_heat_capacity > 0)
			var/efficiency = (1 - cold_air.temperature / hot_air.temperature) * return_efficiency_scale(delta_temperature, hot_air_heat_capacity, cold_air_heat_capacity)

			var/energy_transfer = delta_temperature * hot_air_heat_capacity * cold_air_heat_capacity / (hot_air_heat_capacity + cold_air_heat_capacity - hot_air_heat_capacity * efficiency)
			var/heat = energy_transfer * (1 - efficiency)
			lastgen += energy_transfer * efficiency
			hot_air.temperature -= energy_transfer / hot_air_heat_capacity

			past_power_levels += lastgen
			if (length(past_power_levels) > max_history)
				past_power_levels.Cut(1, 2)

			cold_air.temperature += heat / cold_air_heat_capacity

	if(hot_air)
		var/datum/gas_mixture/hot_circ_air1 = hot_circ.airs[1]
		hot_circ_air1.merge(hot_air)

	if(cold_air)
		var/datum/gas_mixture/cold_circ_air1 = cold_circ.airs[1]
		cold_circ_air1.merge(cold_air)

	var/current_pressure = "[cold_circ?.last_pressure_delta > 0 ? "1" : "0"][hot_circ?.last_pressure_delta > 0 ? "1" : "0"]"
	if(current_pressure != last_pressure_overlay)
		//this requires an update to overlays.
		last_pressure_overlay = current_pressure

	update_appearance(UPDATE_ICON)

/obj/machinery/power/thermoelectric_generator/proc/return_efficiency_scale(delta_temperature, heat_capacity, cold_capacity)
	var/returned_scale = base_scale

	var/heat = delta_temperature * (heat_capacity* cold_capacity /(heat_capacity + cold_capacity))
	semi_temp += heat / heat_capacity
	semi_temp -= heat / cold_capacity
	semi_temp = max(semi_temp, 1)

	returned_scale += clamp((1.70 * log(semi_temp)) - 15, -5, 15)

	return returned_scale * 0.01 //we return as a decimal precent

/obj/machinery/power/thermoelectric_generator/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "ThermoElectricGenerator", name)
		ui.open()

/obj/machinery/power/thermoelectric_generator/ui_data(mob/user)
	var/list/data = list()
	data["error_message"] = null

	var/datum/gas_mixture/cold_circ_air1 = cold_circ?.airs[1]
	var/datum/gas_mixture/cold_circ_air2 = cold_circ?.airs[2]

	var/datum/gas_mixture/hot_circ_air1 = hot_circ?.airs[1]
	var/datum/gas_mixture/hot_circ_air2 = hot_circ?.airs[2]

	data["last_power_output"] = display_power(lastgenlev)

	data["past_power_info"] = past_power_levels

	var/list/cold_data = list()
	if(cold_circ_air2 && cold_circ_air1)
		cold_data["temperature_inlet"] = round(cold_circ_air2.temperature, 0.1)
		cold_data["temperature_outlet"] = round(cold_circ_air1.temperature, 0.1)
		cold_data["pressure_inlet"] = round(cold_circ_air2.return_pressure(), 0.1)
		cold_data["pressure_outlet"] = round(cold_circ_air1.return_pressure(), 0.1)
	data["cold_data"] = list(cold_data)

	var/list/hot_data = list()
	if(hot_circ_air1 && hot_circ_air2)
		hot_data["temperature_inlet"] = round(hot_circ_air2.temperature, 0.1)
		hot_data["temperature_outlet"] = round(hot_circ_air1.temperature, 0.1)
		hot_data["pressure_inlet"] = round(hot_circ_air2.return_pressure(), 0.1)
		hot_data["pressure_outlet"] = round(hot_circ_air1.return_pressure(), 0.1)
	data["hot_data"] = list(hot_data)

	if(!powernet)
		data["error_message"] = "Unable to connect to the power network!"
		return data
	if(!cold_circ && !hot_circ)
		data["error_message"] = "Unable to locate any parts! Multitool the machine to sync to nearby parts."
		return data
	if(!cold_circ)
		data["error_message"] = "Unable to locate cold circulator!"
		return data
	if(!hot_circ)
		data["error_message"] = "Unable to locate hot circulator!"
		return data

	return data

///Finds and connects nearby valid circulators to the machine, nulling out previous ones.
/obj/machinery/power/thermoelectric_generator/proc/find_circulators()
	null_circulators()
	var/list/valid_circulators = list()

	if(dir & (NORTH|SOUTH))
		var/obj/machinery/atmospherics/components/binary/circulator/east_circulator = locate() in get_step(src, EAST)
		if(east_circulator)
			valid_circulators += east_circulator
		var/obj/machinery/atmospherics/components/binary/circulator/west_circulator = locate() in get_step(src, WEST)
		if(west_circulator)
			valid_circulators += west_circulator

	if(!valid_circulators.len)
		return

	for(var/obj/machinery/atmospherics/components/binary/circulator/circulators as anything in valid_circulators)
		if(circulators.mode == CIRCULATOR_COLD && !cold_circ)
			cold_circ = circulators
			circulators.generator = src
			continue
		if(circulators.mode == CIRCULATOR_HOT && !hot_circ)
			hot_circ = circulators
			circulators.generator = src

///Removes hot and cold circulators from the generator, nulling them.
/obj/machinery/power/thermoelectric_generator/proc/null_circulators()
	if(hot_circ)
		hot_circ.generator = null
		hot_circ = null
	if(cold_circ)
		cold_circ.generator = null
		cold_circ = null

/obj/machinery/power/thermoelectric_generator/proc/add_teg_state(datum/thermoelectric_state/passed_state)
	for(var/datum/thermoelectric_state/state as anything in teg_states)
		if(state.type == passed_state)
			return

	var/datum/thermoelectric_state/new_state = new passed_state
	new_state.owner = WEAKREF(src)
	new_state.on_apply()
	teg_states |= new_state

/obj/machinery/power/thermoelectric_generator/proc/remove_teg_state(datum/thermoelectric_state/passed_state)
	for(var/datum/thermoelectric_state/state as anything in teg_states)
		if(state.type == passed_state)
			teg_states -= state
			state.on_remove()
			qdel(state)

/obj/machinery/power/thermoelectric_generator/proc/process_engine()
	if(lastgenlev > 0)
		if(damage < 0)
			damage = 0
		damage++

	var/overwrites_process = FALSE
	for(var/datum/thermoelectric_state/state as anything in teg_states)
		if(state.process_engine())
			overwrites_process = TRUE

	if(overwrites_process)
		return
	engine_effects()


/obj/machinery/power/thermoelectric_generator/proc/engine_effects()
	if(damage >= 100 && prob(5))
		playsound(src, pick(list('goon/sounds/teg/engine_grump1.ogg','goon/sounds/teg/engine_grump2.ogg','goon/sounds/teg/engine_grump3.ogg','goon/sounds/teg/engine_grump4.ogg')), 70, FALSE)
		audible_message(span_warning("[src] makes [pick(prefixes)] [pick(suffixes)]!"))
		damage -= 5

	switch(powerlevel)
		if(1 to 2)
			playsound(src, 'goon/sounds/teg/tractor_running.ogg', 60, FALSE)
			if(prob(3))
				playsound(src, pick(list('goon/sounds/teg/tractor_running2.ogg', 'goon/sounds/teg/tractor_running3.ogg')), 80, FALSE) // this plays ontop so play it louder
		if(3 to 11)
			playsound(src, 'goon/sounds/teg/tractor_running.ogg', 60, FALSE)
		if(12 to 15)
			playsound(src, 'goon/sounds/teg/engine_highpower.ogg', 60, FALSE)
		if(16 to 19)
			playsound(src.loc, 'goon/sounds/teg/bellalert.ogg', 60, FALSE)
			if(prob(5))
				electrical_chain(radius = 2, power = 3)
		if(20 to 21)
			playsound(src.loc, 'sound/machines/warning-buzzer.ogg', 40, FALSE)
			if(prob(5))
				var/turf/my_turf = get_turf(src)
				my_turf.pollute_turf(/datum/pollutant/smoke, 500)
				visible_message(span_warning("[src] erupts into a plume of smoke!"))
			if(damage >= 100 && prob(5))
				playsound(src, pick(list('goon/sounds/teg/engine_grump1.ogg','goon/sounds/teg/engine_grump2.ogg','goon/sounds/teg/engine_grump3.ogg','goon/sounds/teg/engine_grump4.ogg')), 70, FALSE)
				explosion(src, flame_range = 2)
				damage -= 15
		if(22 to 23)
			playsound(src, 'sound/machines/engine_alert1.ogg', 55, FALSE)
			if(prob(5))
				tesla_zap(src, 7, 7500, ZAP_MOB_STUN)
			if(prob(5))
				var/turf/my_turf = get_turf(src)
				my_turf.pollute_turf(/datum/pollutant/smoke, 500)
				visible_message(span_warning("[src] erupts into a plume of smoke!"))
			if(damage >= 100 && prob(5))
				playsound(src, pick(list('goon/sounds/teg/engine_grump1.ogg','goon/sounds/teg/engine_grump2.ogg','goon/sounds/teg/engine_grump3.ogg','goon/sounds/teg/engine_grump4.ogg')), 70, FALSE)
				explosion(src, flame_range = 2)
				damage -= 15
		if(24 to 25)
			playsound(src, 'sound/machines/engine_alert1.ogg', 55, FALSE)
			if(prob(10))
				tesla_zap(src, 7, 7500, ZAP_MOB_STUN)
			if(prob(10))
				var/turf/my_turf = get_turf(src)
				my_turf.pollute_turf(/datum/pollutant/smoke, 500)
				visible_message(span_warning("[src] erupts into a plume of smoke!"))
			if(damage >= 100 && prob(10))
				playsound(src, pick(list('goon/sounds/teg/engine_grump1.ogg','goon/sounds/teg/engine_grump2.ogg','goon/sounds/teg/engine_grump3.ogg','goon/sounds/teg/engine_grump4.ogg')), 70, FALSE)
				var/range = rand(1, 4)
				explosion(src, flame_range = range)
				for(var/atom/movable/movable in view(range, src))
					if(movable.anchored)
						continue
					if(ismob(movable))
						var/mob/living/mob = movable
						mob.Disorient(8 SECONDS, 25)
						mob.adjustBruteLoss(-10)
						var/turf/target_turf = get_edge_target_turf(mob, get_dir(src, get_step_away(mob, src)))
						mob.throw_at(target_turf, 200, 5) // begone
					else if(prob(15))
						var/turf/target_turf = get_edge_target_turf(movable, get_dir(src, get_step_away(movable, src)))
						movable.throw_at(target_turf, 200, 5) // begone
				damage -= 30

		if(26 to INFINITY)
			playsound(src.loc, 'sound/machines/engine_alert3.ogg', 55, FALSE)
			if(prob(15))
				var/turf/my_turf = get_turf(src)
				my_turf.pollute_turf(/datum/pollutant/smoke, 1500)
				visible_message(span_warning("[src] erupts into a plume of smoke!"))

			if(damage > 100 && prob(6))
				for(var/obj/structure/window/window in range(6, src)) // if we had wall durability this would check for walls and windows and deal x damage to them if they are below x integrity
					if(window.get_integrity() > 51) // better than regular window return
						continue
					if(prob(get_dist(window, src) * 5))
						continue
					window.take_damage(50)

				for(var/mob/living/mob in range(6, src))
					shake_camera(mob, 0.2 SECONDS, 5)
					mob.Disorient(1 SECONDS, 25)
				damage -= 15

			if(prob(33))
				tesla_zap(src, 7, 7500, ZAP_MOB_STUN)

			if(damage >= 100 && prob(10))
				playsound(src, pick(list('goon/sounds/teg/engine_grump1.ogg','goon/sounds/teg/engine_grump2.ogg','goon/sounds/teg/engine_grump3.ogg','goon/sounds/teg/engine_grump4.ogg')), 70, FALSE)
				var/range = rand(1, 4)
				explosion(src, flame_range = range)
				for(var/atom/movable/movable in view(range, src))
					if(movable.anchored)
						continue
					if(ismob(movable))
						var/mob/living/mob = movable
						mob.Disorient(8 SECONDS, 25)
						mob.adjustBruteLoss(-10)
						var/turf/target_turf = get_edge_target_turf(mob, get_dir(src, get_step_away(mob, src)))
						mob.throw_at(target_turf, 200, 5) // begone
					else if(prob(15))
						var/turf/target_turf = get_edge_target_turf(movable, get_dir(src, get_step_away(movable, src)))
						movable.throw_at(target_turf, 200, 5) // begone
				damage -= 30

		else
			return

#undef TEG_EFFICIENCY
