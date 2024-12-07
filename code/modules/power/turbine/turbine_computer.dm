/obj/machinery/computer/turbine_computer
	name = "gas turbine control computer"
	desc = "A computer to remotely control a gas turbine."
	icon_screen = "turbinecomp"
	icon_keyboard = "tech_key"
	circuit = /obj/item/circuitboard/computer/turbine_computer
	///Weakref of the connected machine to this computer
	var/datum/weakref/turbine_core
	///Easy way to connect a computer and a turbine roundstart by setting an id on both this and the core_rotor
	var/mapping_id

/obj/machinery/computer/turbine_computer/post_machine_initialize()
	. = ..()

	if(!mapping_id)
		return
	for(var/obj/machinery/power/turbine/core_rotor/main as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/power/turbine/core_rotor))
		if(main.mapping_id != mapping_id)
			continue
		register_machine(main)
		break

/obj/machinery/computer/turbine_computer/multitool_act(mob/living/user, obj/item/multitool/multitool)
	. = ITEM_INTERACT_FAILURE
	if(!istype(multitool.buffer, /obj/machinery/power/turbine/core_rotor))
		to_chat(user, span_notice("Wrong machine type in [multitool] buffer..."))
		return
	if(turbine_core)
		to_chat(user, span_notice("Changing [src] bluespace network..."))
	if(!do_after(user, 0.2 SECONDS, src))
		return

	playsound(get_turf(user), 'sound/machines/click.ogg', 10, TRUE)
	register_machine(multitool.buffer)
	to_chat(user, span_notice("You link [src] to the console in [multitool]'s buffer."))
	return ITEM_INTERACT_SUCCESS

/**
 * Links the rotor with this computer
 * Arguments
 *
 * * obj/machinery/power/turbine/core_rotor/machine - the machine to link
 */
/obj/machinery/computer/turbine_computer/proc/register_machine(obj/machinery/power/turbine/core_rotor/machine)
	PRIVATE_PROC(TRUE)

	turbine_core = WEAKREF(machine)

/obj/machinery/computer/turbine_computer/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TurbineComputer", name)
		ui.open()

/obj/machinery/computer/turbine_computer/ui_data(mob/user)
	. = list()

	//do we have the main rotor with all parts connected
	var/obj/machinery/power/turbine/core_rotor/main_control = turbine_core?.resolve()
	if(QDELETED(main_control) || !main_control.all_parts_connected)
		.["connected"] = FALSE
		return
	else
		.["connected"] = TRUE

	//operation status
	.["active"] = main_control.active
	.["rpm"] = main_control.rpm
	.["power"] = energy_to_power(main_control.produced_energy)
	.["integrity"] = main_control.get_turbine_integrity()

	//running parameters
	.["max_rpm"] = main_control.max_allowed_rpm
	.["max_temperature"] = main_control.max_allowed_temperature
	.["temp"] = main_control.compressor.input_turf?.air.temperature || 0
	.["regulator"] = main_control.compressor.intake_regulator

/obj/machinery/computer/turbine_computer/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("toggle_power")
			var/obj/machinery/power/turbine/core_rotor/main_control = turbine_core?.resolve()
			if(!main_control)
				return FALSE

			if(!main_control.active) //turning on the machine requires all part to be linked
				if(!main_control.activate_parts(ui.user, check_only = TRUE))
					return FALSE
			else if(main_control.rpm > 1000) //turning off requires rpm to be less than 1000
				return FALSE

			main_control.toggle_power()
			main_control.rpm = 0
			main_control.produced_energy = 0
			return TRUE

		if("regulate")
			var/intake_size = params["regulate"]
			if(isnull(intake_size))
				return FALSE

			intake_size = text2num(intake_size)
			if(isnull(intake_size))
				return FALSE

			var/obj/machinery/power/turbine/core_rotor/main_control = turbine_core?.resolve()
			if(!main_control)
				return FALSE

			if(QDELETED(main_control.compressor))
				return FALSE

			main_control.compressor.intake_regulator = clamp(intake_size, 0.01, 1)
			return TRUE
