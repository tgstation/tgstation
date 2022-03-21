/obj/machinery/computer/turbine_computer
	name = "gas turbine control computer"
	desc = "A computer to remotely control a gas turbine."
	icon_screen = "turbinecomp"
	icon_keyboard = "tech_key"
	//circuit = /obj/item/circuitboard/computer/turbine_computer #TODO: all others as well
	var/obj/machinery/power/turbine/core_rotor/main_control
	var/mapping_id

/obj/machinery/computer/turbine_computer/Initialize(mapload)
	. = ..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/turbine_computer/LateInitialize()
	. = ..()
	locate_machinery()

/obj/machinery/computer/turbine_computer/Destroy()
	unregister_machine()
	return ..()

/obj/machinery/computer/turbine_computer/locate_machinery(multitool_connection)
	if(mapping_id)
		for(var/obj/machinery/power/turbine/core_rotor/main in GLOB.machines)
			if(main.mapping_id == mapping_id)
				main_control = main
				return

/obj/machinery/computer/turbine_computer/multitool_act(mob/living/user, obj/item/tool)
	var/obj/item/multitool/multitool = tool
	if(!istype(multitool.buffer, /obj/machinery/power/turbine/core_rotor))
		to_chat(user, span_notice("Wrong machine type in [multitool] buffer..."))
		return
	if(main_control)
		to_chat(user, span_notice("Changing [src] bluespace network..."))
	if(!do_after(user, 0.2 SECONDS, src))
		return
	playsound(get_turf(user), 'sound/machines/click.ogg', 10, TRUE)
	register_machine(multitool.buffer)
	to_chat(user, span_notice("You link [src] to the console in [multitool]'s buffer."))
	return TRUE

/obj/machinery/computer/turbine_computer/proc/register_machine(machine)
	main_control = machine
	RegisterSignal(main_control, COMSIG_PARENT_QDELETING, .proc/unregister_machine)

/obj/machinery/computer/turbine_computer/proc/unregister_machine()
	SIGNAL_HANDLER
	if(main_control)
		UnregisterSignal(main_control, COMSIG_PARENT_QDELETING)
		main_control = null

/obj/machinery/computer/turbine_computer/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TurbineComputer", name)
		ui.open()

/obj/machinery/computer/turbine_computer/ui_data(mob/user)
	var/list/data = list()

	return data

/obj/machinery/computer/turbine_computer/ui_act(action, params)
	. = ..()
