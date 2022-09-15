/obj/machinery/modular_computer/console/preset
	// Can be changed to give devices specific hardware
	var/_has_second_id_slot = FALSE
	var/_has_printer = FALSE
	var/_has_battery = FALSE
	var/_has_ai = FALSE

/obj/machinery/modular_computer/console/preset/Initialize(mapload)
	. = ..()
	if(!cpu)
		return

	cpu.install_component(new /obj/item/computer_hardware/card_slot)
	if(_has_second_id_slot)
		cpu.install_component(new /obj/item/computer_hardware/card_slot/secondary)
	if(_has_printer)
		cpu.install_component(new /obj/item/computer_hardware/printer)
	if(_has_battery)
		cpu.install_component(new /obj/item/computer_hardware/battery(cpu, /obj/item/stock_parts/cell/computer/super))
	if(_has_ai)
		cpu.install_component(new /obj/item/computer_hardware/ai_slot)
	install_programs()

// Override in child types to install preset-specific programs.
/obj/machinery/modular_computer/console/preset/proc/install_programs()
	return

// ===== ENGINEERING CONSOLE =====
/obj/machinery/modular_computer/console/preset/engineering
	console_department = "Engineering"
	name = "engineering console"
	desc = "A stationary computer. This one comes preloaded with engineering programs."

/obj/machinery/modular_computer/console/preset/engineering/install_programs()
	var/obj/item/computer_hardware/hard_drive/hard_drive = cpu.all_components[MC_HDD]
	hard_drive.store_file(new/datum/computer_file/program/power_monitor())
	hard_drive.store_file(new/datum/computer_file/program/alarm_monitor())
	hard_drive.store_file(new/datum/computer_file/program/supermatter_monitor())

// ===== RESEARCH CONSOLE =====
/obj/machinery/modular_computer/console/preset/research
	console_department = "Research"
	name = "research director's console"
	desc = "A stationary computer. This one comes preloaded with research programs."
	_has_second_id_slot = TRUE
	_has_ai = TRUE

/obj/machinery/modular_computer/console/preset/research/install_programs()
	var/obj/item/computer_hardware/hard_drive/hard_drive = cpu.all_components[MC_HDD]
	hard_drive.store_file(new/datum/computer_file/program/ntnetmonitor())
	hard_drive.store_file(new/datum/computer_file/program/chatclient())
	hard_drive.store_file(new/datum/computer_file/program/aidiag())
	hard_drive.store_file(new/datum/computer_file/program/robocontrol())
	hard_drive.store_file(new/datum/computer_file/program/scipaper_program())

// ===== COMMAND CONSOLE =====
/obj/machinery/modular_computer/console/preset/command
	console_department = "Command"
	name = "command console"
	desc = "A stationary computer. This one comes preloaded with command programs."
	_has_second_id_slot = TRUE
	_has_printer = TRUE

/obj/machinery/modular_computer/console/preset/command/install_programs()
	var/obj/item/computer_hardware/hard_drive/hard_drive = cpu.all_components[MC_HDD]
	hard_drive.store_file(new/datum/computer_file/program/chatclient())
	hard_drive.store_file(new/datum/computer_file/program/card_mod())


// ===== IDENTIFICATION CONSOLE =====
/obj/machinery/modular_computer/console/preset/id
	console_department = "Identification"
	name = "identification console"
	desc = "A stationary computer. This one comes preloaded with identification modification programs."
	_has_second_id_slot = TRUE
	_has_printer = TRUE

/obj/machinery/modular_computer/console/preset/id/install_programs()
	var/obj/item/computer_hardware/hard_drive/hard_drive = cpu.all_components[MC_HDD]
	hard_drive.store_file(new/datum/computer_file/program/chatclient())
	hard_drive.store_file(new/datum/computer_file/program/card_mod())
	hard_drive.store_file(new/datum/computer_file/program/job_management())
	hard_drive.store_file(new/datum/computer_file/program/crew_manifest())

/obj/machinery/modular_computer/console/preset/id/centcom
	desc = "A stationary computer. This one comes preloaded with CentCom identification modification programs."

/obj/machinery/modular_computer/console/preset/id/centcom/install_programs()
	var/obj/item/computer_hardware/hard_drive/hard_drive = cpu.all_components[MC_HDD]
	var/datum/computer_file/program/card_mod/card_mod_centcom = new /datum/computer_file/program/card_mod()
	card_mod_centcom.is_centcom = TRUE
	hard_drive.store_file(new /datum/computer_file/program/chatclient())
	hard_drive.store_file(card_mod_centcom)
	hard_drive.store_file(new /datum/computer_file/program/job_management())
	hard_drive.store_file(new /datum/computer_file/program/crew_manifest())

// ===== CIVILIAN CONSOLE =====
/obj/machinery/modular_computer/console/preset/civilian
	console_department = "Civilian"
	name = "civilian console"
	desc = "A stationary computer. This one comes preloaded with generic programs."

/obj/machinery/modular_computer/console/preset/civilian/install_programs()
	var/obj/item/computer_hardware/hard_drive/hard_drive = cpu.all_components[MC_HDD]
	hard_drive.store_file(new/datum/computer_file/program/chatclient())
	hard_drive.store_file(new/datum/computer_file/program/arcade())

// curator
/obj/machinery/modular_computer/console/preset/curator
	console_department = "Civilian"
	name = "curator console"
	desc = "A stationary computer. This one comes preloaded with art programs."
	_has_printer = TRUE

/obj/machinery/modular_computer/console/preset/curator/install_programs()
	var/obj/item/computer_hardware/hard_drive/hard_drive = cpu.all_components[MC_HDD]
	hard_drive.store_file(new/datum/computer_file/program/portrait_printer())

// ===== CARGO CHAT CONSOLES =====
/obj/machinery/modular_computer/console/preset/cargochat
	name = "cargo chatroom console"
	desc = "A stationary computer. This one comes preloaded with a chatroom for your cargo requests."
	///chat client installed on this computer, just helpful for linking all the computers
	var/datum/computer_file/program/chatclient/chatprogram

/obj/machinery/modular_computer/console/preset/cargochat/install_programs()
	var/obj/item/computer_hardware/hard_drive/hard_drive = cpu.all_components[MC_HDD]
	chatprogram = new
	chatprogram.computer = cpu
	hard_drive.store_file(chatprogram)
	chatprogram.username = "[lowertext(console_department)]_department"
	chatprogram.program_state = PROGRAM_STATE_ACTIVE
	cpu.active_program = chatprogram

//ONE PER MAP PLEASE, IT MAKES A CARGOBUS FOR EACH ONE OF THESE
/obj/machinery/modular_computer/console/preset/cargochat/cargo
	console_department = "Cargo"
	name = "department chatroom console"
	desc = "A stationary computer. This one comes preloaded with a chatroom for incoming cargo requests. You may moderate it from this computer."

/obj/machinery/modular_computer/console/preset/cargochat/cargo/install_programs()
	var/obj/item/computer_hardware/hard_drive/hard_drive = cpu.all_components[MC_HDD]

	//adding chat, setting it as the active window immediately
	chatprogram = new
	chatprogram.computer = cpu
	hard_drive.store_file(chatprogram)
	chatprogram.program_state = PROGRAM_STATE_ACTIVE
	cpu.active_program = chatprogram

	//setting up chat
	chatprogram.username = "cargo_requests_operator"
	var/datum/ntnet_conversation/cargochat = new
	cargochat.operator = chatprogram //adding operator before joining the chat prevents an unnecessary message about switching op from showing
	cargochat.add_client(chatprogram)
	cargochat.title = "#cargobus"
	cargochat.strong = TRUE
	chatprogram.active_channel = cargochat.id

/obj/machinery/modular_computer/console/preset/cargochat/cargo/LateInitialize()
	. = ..()
	var/datum/ntnet_conversation/cargochat = SSnetworks.station_network.get_chat_channel_by_id(chatprogram.active_channel)
	for(var/obj/machinery/modular_computer/console/preset/cargochat/cargochat_console in GLOB.machines)
		if(cargochat_console == src)
			continue
		cargochat_console.chatprogram.active_channel = chatprogram.active_channel
		cargochat.add_client(cargochat_console.chatprogram, silent = TRUE)

/obj/machinery/modular_computer/console/preset/cargochat/service
	console_department = "Service"

/obj/machinery/modular_computer/console/preset/cargochat/engineering
	console_department = "Engineering"

/obj/machinery/modular_computer/console/preset/cargochat/science
	console_department = "Science"

/obj/machinery/modular_computer/console/preset/cargochat/security
	console_department = "Security"

/obj/machinery/modular_computer/console/preset/cargochat/medical
	console_department = "Medical"
