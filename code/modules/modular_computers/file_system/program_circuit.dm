/**
 * Circuit components of modular programs are special.
 * They're added to the unremovable components of the shell when the prog is installed and deleted if uninstalled.
 * This means they don't work like normal unremovable comps that live and die along with their shell.
 */
/obj/item/circuit_component/mod_program
	display_name = "Abstract Modular Program"
	desc = "I've spent lot of time thinking how to get this to work. If you see this, I either failed or someone else did, so report it."
	/**
	 * The program that installed us into the shell/usb_port comp. Needed to avoid having too many signals for every program.
	 * This is also the program we need to install on the modular computer if the circuit is admin-loaded.
	 * Just make sure each of these components is associated to one and only type of program, no subtypes of anything.
	 */
	var/datum/computer_file/program/associated_program

	///Starts the program if possible, placing it in the background if another's active.
	var/datum/port/input/start
	///kills the program.
	var/datum/port/input/kill
	///binary for whether the program is running or not
	var/datum/port/output/running

/obj/item/circuit_component/mod_program/Initialize(mapload)
	if(associated_program)
		display_name = initial(associated_program.filedesc)
		desc = initial(associated_program.extended_desc)
	return ..() // Set the name correctly

/obj/item/circuit_component/mod_program/register_shell(atom/movable/shell)
	. = ..()
	var/obj/item/modular_computer/computer
	if(istype(shell, /obj/item/modular_computer))
		computer = shell
	else if(istype(shell, /obj/machinery/modular_computer))
		var/obj/machinery/modular_computer/console = shell
		computer = console.cpu

	///Find the associated program in the computer's stored_files (install it otherwise) and store a reference to it.
	var/datum/computer_file/program/found_program = locate(associated_program) in computer.stored_files
	///The integrated circuit was loaded/duplicated
	if(isnull(found_program))
		associated_program = new associated_program()
		computer.store_file(associated_program)
	else
		associated_program = found_program

	RegisterSignal(associated_program, COMSIG_COMPUTER_PROGRAM_START, PROC_REF(on_start))
	RegisterSignal(associated_program, COMSIG_COMPUTER_PROGRAM_KILL, PROC_REF(on_kill))

/obj/item/circuit_component/mod_program/unregister_shell()
	UnregisterSignal(associated_program, list(COMSIG_COMPUTER_PROGRAM_START, COMSIG_COMPUTER_PROGRAM_KILL))
	associated_program = initial(associated_program)
	return ..()

/obj/item/circuit_component/mod_program/populate_ports()
	. = ..()
	SHOULD_CALL_PARENT(TRUE)
	start = add_input_port("Start", PORT_TYPE_SIGNAL, trigger = PROC_REF(start_prog))
	kill = add_input_port("Kill", PORT_TYPE_SIGNAL, trigger = PROC_REF(kill_prog))
	running = add_output_port("Running", PORT_TYPE_NUMBER)

///For most programs, triggers only work if they're open (either active or idle).
/obj/item/circuit_component/mod_program/should_receive_input(datum/port/input/port)
	. = ..()
	if(!.)
		return FALSE
	if(isnull(associated_program))
		return FALSE
	if(!associated_program.computer.enabled)
		return FALSE
	if(associated_program.program_flags & PROGRAM_CIRCUITS_RUN_WHEN_CLOSED || COMPONENT_TRIGGERED_BY(start, port))
		return TRUE
	var/obj/item/modular_computer/computer = associated_program.computer
	if(computer.active_program == associated_program || (associated_program in computer.idle_threads))
		return TRUE
	return FALSE

/obj/item/circuit_component/mod_program/proc/start_prog(datum/port/input/port)
	associated_program.computer.open_program(program = associated_program)

/obj/item/circuit_component/mod_program/proc/on_start(mob/living/user)
	SIGNAL_HANDLER
	running.set_output(TRUE)

/obj/item/circuit_component/mod_program/proc/kill_prog(datum/port/input/port)
	associated_program.kill_program()

/obj/item/circuit_component/mod_program/proc/on_kill(mob/living/user)
	SIGNAL_HANDLER
	running.set_output(FALSE)

/obj/item/circuit_component/mod_program/get_ui_notices()
	. = ..()
	if(!(associated_program.program_flags & PROGRAM_CIRCUITS_RUN_WHEN_CLOSED))
		. += create_ui_notice("Requires open program for inputs", "purple")
