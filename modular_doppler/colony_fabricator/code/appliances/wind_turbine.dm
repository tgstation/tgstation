/obj/machinery/power/colony_wind_turbine
	name = "miniature wind turbine"
	desc = "A post with two special-designed vertical turbine blades attached to its sides. \
		When placed outdoors in a planet with an atmosphere, will produce a small trickle of power \
		for free. If there is a storm in the area the turbine is placed, the power production will \
		multiply significantly."
	icon = 'modular_doppler/colony_fabricator/icons/wind_turbine.dmi'
	icon_state = "turbine"
	density = TRUE
	max_integrity = 100
	idle_power_usage = 0
	anchored = TRUE
	can_change_cable_layer = FALSE
	circuit = null
	layer = ABOVE_MOB_LAYER
	can_change_cable_layer = TRUE
	/// How much power the turbine makes without a storm
	var/regular_power_production = 2500
	/// How much power the turbine makes during a storm
	var/storm_power_production = 10000
	/// Is our pressure too low to function?
	var/pressure_too_low = FALSE
	/// Minimum external pressure needed to work
	var/minimum_pressure = 5
	/// What we undeploy into
	var/undeploy_type = /obj/item/flatpacked_machine/wind_turbine

/obj/machinery/power/colony_wind_turbine/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/repackable, undeploy_type, 2 SECONDS)
	AddElement(/datum/element/manufacturer_examine, COMPANY_FRONTIER)
	connect_to_network()

/obj/machinery/power/colony_wind_turbine/examine(mob/user)
	. = ..()
	var/area/turbine_area = get_area(src)
	if(!turbine_area.outdoors)
		. += span_notice("Its must be constructed <b>outdoors</b> to function.")
	if(pressure_too_low)
		. += span_notice("There must be enough atmospheric <b>pressure</b> for the turbine to spin.")


/obj/machinery/power/colony_wind_turbine/process()
	var/area/our_current_area = get_area(src)
	if(!our_current_area.outdoors)
		icon_state = "turbine"
		add_avail(0)
		return

	var/turf/our_turf = get_turf(src)
	var/datum/gas_mixture/environment = our_turf.return_air()

	if(environment.return_pressure() < minimum_pressure)
		pressure_too_low = TRUE
		icon_state = "turbine"
		add_avail(0)
		return

	pressure_too_low = FALSE
	var/storming_out = FALSE

	var/datum/weather/weather_we_track
	for(var/datum/weather/possible_weather in SSweather.processing)
		if((our_turf.z in possible_weather.impacted_z_levels) || (our_current_area in possible_weather.impacted_areas))
			weather_we_track = possible_weather
			break
	if(weather_we_track)
		if(!(weather_we_track.stage == END_STAGE))
			storming_out = TRUE

	add_avail(power_to_energy(storming_out ? storm_power_production : regular_power_production))

	var/new_icon_state = (storming_out ? "turbine_storm" : "turbine_normal")
	icon_state = new_icon_state


// Item for deploying wind turbines
/obj/item/flatpacked_machine/wind_turbine
	name = "flat-packed miniature wind turbine"
	icon = 'modular_doppler/colony_fabricator/icons/wind_turbine.dmi'
	icon_state = "turbine_packed"
	type_to_deploy = /obj/machinery/power/colony_wind_turbine
	w_class = WEIGHT_CLASS_NORMAL
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 5,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT * 2,
		/datum/material/gold = HALF_SHEET_MATERIAL_AMOUNT,
	)
