/obj/machinery/modular_computer/preset
	///If set, computer will automatically boot and load this program
	var/startup_program
	///List of programs the computer starts with, given on Initialize.
	var/list/datum/computer_file/preinstalled_programs = list()

/obj/machinery/modular_computer/preset/Initialize(mapload)
	. = ..()
	if(!cpu)
		return

	for(var/programs in preinstalled_programs)
		var/datum/computer_file/program_type = new programs
		cpu.store_file(program_type)

	if(!isnull(startup_program))
		INVOKE_ASYNC(src, PROC_REF(run_startup_program))

/// If a startup program is specified and exists on the modular computer, run it after init.
/obj/machinery/modular_computer/preset/proc/run_startup_program()
	if(isnull(startup_program))
		CRASH("[src] was requested to run a program on startup, but none is set!")

	var/datum/computer_file/program/startup_file = cpu.find_file_by_name(startup_program)
	if(isnull(startup_file))
		return

	cpu.turn_on()
	cpu.active_program = startup_file

// ===== ENGINEERING CONSOLE =====
/obj/machinery/modular_computer/preset/engineering
	name = "engineering console"
	desc = "A stationary computer. This one comes preloaded with engineering programs."
	preinstalled_programs = list(
		/datum/computer_file/program/power_monitor,
		/datum/computer_file/program/alarm_monitor,
		/datum/computer_file/program/supermatter_monitor,
	)

// ===== RESEARCH CONSOLE =====
/obj/machinery/modular_computer/preset/research
	name = "research director's console"
	desc = "A stationary computer. This one comes preloaded with research programs."
	preinstalled_programs = list(
		/datum/computer_file/program/ntnetmonitor,
		/datum/computer_file/program/chatclient,
		/datum/computer_file/program/ai_restorer,
		/datum/computer_file/program/robocontrol,
		/datum/computer_file/program/scipaper_program,
	)

// ===== COMMAND CONSOLE =====
/obj/machinery/modular_computer/preset/command
	name = "command console"
	desc = "A stationary computer. This one comes preloaded with command programs."
	preinstalled_programs = list(
		/datum/computer_file/program/chatclient,
		/datum/computer_file/program/card_mod,
	)

// ===== IDENTIFICATION CONSOLE =====
/obj/machinery/modular_computer/preset/id
	name = "identification console"
	desc = "A stationary computer. This one comes preloaded with identification modification programs."
	preinstalled_programs = list(
		/datum/computer_file/program/chatclient,
		/datum/computer_file/program/card_mod,
		/datum/computer_file/program/job_management,
		/datum/computer_file/program/crew_manifest,
	)

/obj/machinery/modular_computer/preset/id/centcom
	desc = "A stationary computer. This one comes preloaded with CentCom identification modification programs."

/obj/machinery/modular_computer/preset/id/centcom/Initialize(mapload)
	. = ..()
	var/datum/computer_file/program/card_mod/card_mod_centcom = cpu.find_file_by_name(/datum/computer_file/program/card_mod::filename)
	card_mod_centcom.is_centcom = TRUE

// ===== CIVILIAN CONSOLE =====
/obj/machinery/modular_computer/preset/civilian
	name = "civilian console"
	desc = "A stationary computer. This one comes preloaded with generic programs."
	preinstalled_programs = list(
		/datum/computer_file/program/chatclient,
		/datum/computer_file/program/arcade,
	)

// curator
/obj/machinery/modular_computer/preset/curator
	name = "curator console"
	desc = "A stationary computer. This one comes preloaded with art programs."
	preinstalled_programs = list(
		/datum/computer_file/program/portrait_printer,
	)

// ===== CARGO CHAT CONSOLES =====
/obj/machinery/modular_computer/preset/cargochat
	name = "cargo interfacing console"
	desc = "A stationary computer that comes pre-loaded with software to interface with the cargo department."
	startup_program = /datum/computer_file/program/department_order::filename
	preinstalled_programs = list(
		/datum/computer_file/program/chatclient,
		/datum/computer_file/program/department_order,
	)
	/// What department type is assigned to this console?
	var/datum/job_department/department_type

/obj/machinery/modular_computer/preset/cargochat/Initialize(mapload)
	. = ..()
	REGISTER_REQUIRED_MAP_ITEM(1, 1)
	if(department_type)
		name = "[LOWER_TEXT(initial(department_type.department_name))] [name]"
		cpu.name = name

/obj/machinery/modular_computer/preset/cargochat/run_startup_program()
	. = ..()
	if(!department_type)
		return

	var/datum/computer_file/program/department_order/orderprogram = cpu.find_file_by_name(/datum/computer_file/program/department_order::filename)
	orderprogram.set_linked_department(department_type) // Set department in program dept_order

	var/datum/computer_file/program/chatclient/chatprogram = cpu.find_file_by_name(/datum/computer_file/program/chatclient::filename)
	chatprogram.username = "[LOWER_TEXT(initial(department_type.department_name))]_department"
	cpu.idle_threads += chatprogram

	update_appearance(UPDATE_ICON)

/obj/machinery/modular_computer/preset/cargochat/service
	department_type = /datum/job_department/service

/obj/machinery/modular_computer/preset/cargochat/engineering
	department_type = /datum/job_department/engineering

/obj/machinery/modular_computer/preset/cargochat/science
	department_type = /datum/job_department/science

/obj/machinery/modular_computer/preset/cargochat/security
	department_type = /datum/job_department/security

/obj/machinery/modular_computer/preset/cargochat/medical
	department_type = /datum/job_department/medical

/obj/machinery/modular_computer/preset/cargochat/cargo
	department_type = /datum/job_department/cargo
	name = "departmental interfacing console"
	desc = "A stationary computer that comes pre-loaded with software to interface with incoming departmental cargo requests."
	startup_program = /datum/computer_file/program/chatclient::filename
	preinstalled_programs = list(
		/datum/computer_file/program/chatclient,
		/datum/computer_file/program/department_order,
		/datum/computer_file/program/bounty_board,
		/datum/computer_file/program/budgetorders,
		/datum/computer_file/program/shipping,
		/datum/computer_file/program/restock_tracker,
	)

/obj/machinery/modular_computer/preset/cargochat/cargo/post_machine_initialize()
	. = ..()
	var/datum/computer_file/program/chatclient/chatprogram = cpu.find_file_by_name(startup_program)
	chatprogram.username = "cargo_requests_operator"

	var/datum/ntnet_conversation/cargochat = chatprogram.create_new_channel("#cargobus", strong = TRUE)
	for(var/obj/machinery/modular_computer/preset/cargochat/cargochat_console as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/modular_computer/preset/cargochat))
		if(cargochat_console == src)
			continue
		var/datum/computer_file/program/chatclient/other_chatprograms = cargochat_console.cpu.find_file_by_name(startup_program)
		other_chatprograms.active_channel = chatprogram.active_channel
		cargochat.add_client(other_chatprograms, silent = TRUE)
