/obj/machinery/atmospherics/components/unary/thermomachine/deployable
	icon = 'modular_doppler/colony_fabricator/icons/thermomachine.dmi'
	name = "atmospheric temperature regulator"
	desc = "A much more tame variant of the thermomachines commonly seen in station scale temperature control devices. \
		Its upper and lower bounds for temperature are highly limited, though it has a higher than standard heat capacity \
		and the benefit of being undeployable when you're done with it."
	circuit = null
	greyscale_config = /datum/greyscale_config/thermomachine/deployable
	min_temperature = T0C
	max_temperature = FIRE_MINIMUM_TEMPERATURE_TO_SPREAD + 50
	heat_capacity = 10000
	/// The item we turn into when repacked
	var/repacked_type = /obj/item/flatpacked_machine/thermomachine
	/// Soundloop for while the thermomachine is turned on
	var/datum/looping_sound/conditioner_running/soundloop

/obj/machinery/atmospherics/components/unary/thermomachine/deployable/Initialize(mapload)
	. = ..()
	soundloop = new(src, FALSE)
	AddElement(/datum/element/repackable, repacked_type, 2 SECONDS)
	AddElement(/datum/element/manufacturer_examine, COMPANY_FRONTIER)
	flick("thermo_deploy", src)

	// Makes for certain that we are visually facing the correct way
	setDir(dir)
	update_appearance()

/obj/machinery/atmospherics/components/unary/thermomachine/deployable/RefreshParts()
	. = ..()
	heat_capacity = 10000
	min_temperature = T0C
	max_temperature = FIRE_MINIMUM_TEMPERATURE_TO_SPREAD + 50

/obj/machinery/atmospherics/components/unary/thermomachine/deployable/default_deconstruction_crowbar()
	return

/obj/machinery/atmospherics/components/unary/thermomachine/deployable/process_atmos()
	if(on && !soundloop.loop_started)
		soundloop.start()
	else if(soundloop.loop_started)
		soundloop.stop()
	. = ..()

// Item for creating the regulator and carrying it about

/obj/item/flatpacked_machine/thermomachine
	name = "flat-packed atmospheric temperature regulator"
	icon_state = "thermomachine_packed"
	type_to_deploy = /obj/machinery/atmospherics/components/unary/thermomachine/deployable
	custom_materials = list(
		/datum/material/iron = SHEET_MATERIAL_AMOUNT * 7.5,
		/datum/material/glass = SHEET_MATERIAL_AMOUNT,
	)

// This prevents some weird visual bugs with the inlet
/obj/item/flatpacked_machine/thermomachine/give_deployable_component()
	AddComponent(/datum/component/deployable, deploy_time, type_to_deploy, direction_setting = FALSE)

// Greyscale config for the light on this machine

/datum/greyscale_config/thermomachine/deployable
	name = "Deployable Thermomachine"
	icon_file = 'modular_doppler/colony_fabricator/icons/thermomachine.dmi'
