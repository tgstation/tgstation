//Science modules for MODsuits

//Reagent Scanner

/obj/item/mod/module/reagent_scanner
	name = "MOD reagent scanner module"
	desc = "A module based off research-oriented Nanotrasen HUDs, this is capable of scanning the contents of \
		containers and projecting the information in an easy-to-read format on the wearer's display. \
		It cannot detect flavors, so that's up to you."
	icon_state = "scanner"
	module_type = MODULE_TOGGLE
	complexity = 1
	active_power_cost = DEFAULT_CELL_DRAIN * 0.2
	incompatible_modules = list(/obj/item/mod/module/reagent_scanner)
	cooldown_time = 0.5 SECONDS

/obj/item/mod/module/reagent_scanner/on_activation()
	. = ..()
	if(!.)
		return
	ADD_TRAIT(mod.wearer, TRAIT_REAGENT_SCANNER, MOD_TRAIT)

/obj/item/mod/module/reagent_scanner/on_deactivation()
	. = ..()
	if(!.)
		return
	REMOVE_TRAIT(mod.wearer, TRAIT_REAGENT_SCANNER, MOD_TRAIT)

/obj/item/mod/module/reagent_scanner/advanced
	name = "MOD advanced reagent scanner module"
	complexity = 0
	removable = FALSE
	var/explosion_detection_dist = 21

/obj/item/mod/module/reagent_scanner/advanced/on_activation()
	. = ..()
	if(!.)
		return
	mod.wearer.research_scanner++
	RegisterSignal(SSdcs, COMSIG_GLOB_EXPLOSION, .proc/sense_explosion)

/obj/item/mod/module/reagent_scanner/advanced/on_deactivation()
	. = ..()
	if(!.)
		return
	mod.wearer.research_scanner--
	RegisterSignal(SSdcs, COMSIG_GLOB_EXPLOSION)

/obj/item/mod/module/reagent_scanner/advanced/proc/sense_explosion(datum/source, turf/epicenter,
	devastation_range, heavy_impact_range, light_impact_range, took, orig_dev_range, orig_heavy_range, orig_light_range)
	SIGNAL_HANDLER
	var/turf/wearer_turf = get_turf(mod.wearer)
	if(wearer_turf.z != epicenter.z)
		return
	if(get_dist(epicenter, wearer_turf) > explosion_detection_dist)
		return
	to_chat(mod.wearer, span_notice("Explosion detected! Epicenter: [devastation_range], Outer: [heavy_impact_range], Shock: [light_impact_range]"))

//Circuit Adapter

/obj/item/mod/module/circuit
	name = "MOD circuit adapter module"
	desc = "A popular aftermarket module, seen in wide varieties with wide applications by those across the galaxy. \
		This is able to fit any sort of integrated circuit, hooking it into controls in the suit and displaying information \
		to the HUD. Useful for universal translation, or perhaps as a calculator."
	module_type = MODULE_USABLE
	complexity = 3
	idle_power_cost = DEFAULT_CELL_DRAIN * 0.5
	incompatible_modules = list(/obj/item/mod/module/circuit)
	cooldown_time = 0.5 SECONDS
	var/obj/item/integrated_circuit/circuit

/obj/item/mod/module/circuit/Initialize(mapload)
	. = ..()
	circuit = new()
	AddComponent(/datum/component/shell, \
		list(new /obj/item/circuit_component/mod()), \
		capacity = SHELL_CAPACITY_LARGE, \
		shell_flags = SHELL_FLAG_CIRCUIT_UNREMOVABLE, \
		starting_circuit = circuit, \
	)

/obj/item/mod/module/circuit/on_install()
	circuit.set_cell(mod.cell)

/obj/item/mod/module/circuit/on_uninstall()
	circuit.set_cell(mod.cell)

/obj/item/mod/module/circuit/on_suit_activation()
	circuit.set_on(TRUE)

/obj/item/mod/module/circuit/on_suit_deactivation()
	circuit.set_on(FALSE)

/obj/item/mod/module/circuit/on_use()
	. = ..()
	if(!.)
		return
	circuit.interact(mod.wearer)

/obj/item/circuit_component/mod
	display_name = "MOD"
	desc = "Used to send and receive signals from a MODsuit."

	var/obj/item/mod/module/attached_module

	var/datum/port/input/module_to_select
	var/datum/port/input/toggle_suit
	var/datum/port/input/select_module

	var/datum/port/output/wearer
	var/datum/port/output/selected_module

/obj/item/circuit_component/mod/populate_ports()
	// Input Signals
	module_to_select = add_input_port("Module to Select", PORT_TYPE_STRING)
	toggle_suit = add_input_port("Toggle Suit", PORT_TYPE_SIGNAL)
	select_module = add_input_port("Select Module", PORT_TYPE_SIGNAL)
	// States
	wearer = add_output_port("Wearer", PORT_TYPE_ATOM)
	selected_module = add_output_port("Selected Module", PORT_TYPE_ATOM)

/obj/item/circuit_component/mod/register_shell(atom/movable/shell)
	if(istype(shell, /obj/item/mod/module))
		attached_module = shell
	RegisterSignal(attached_module, COMSIG_MOVABLE_MOVED, .proc/on_move)

/obj/item/circuit_component/mod/unregister_shell(atom/movable/shell)
	UnregisterSignal(attached_module, COMSIG_MOVABLE_MOVED)
	attached_module = null

/obj/item/circuit_component/mod/input_received(datum/port/input/port)
	var/obj/item/mod/module/module
	for(var/obj/item/mod/module/potential_module as anything in attached_module.mod.modules)
		if(potential_module.name == module_to_select.value)
			module = potential_module
	if(COMPONENT_TRIGGERED_BY(toggle_suit, port))
		INVOKE_ASYNC(attached_module.mod, /obj/item/mod/control.proc/toggle_activate, attached_module.mod.wearer)
	if(module && COMPONENT_TRIGGERED_BY(select_module, port))
		INVOKE_ASYNC(module, /obj/item/mod/module.proc/on_select)

/obj/item/circuit_component/mod/proc/on_move(atom/movable/source, atom/old_loc, dir, forced)
	SIGNAL_HANDLER
	if(istype(source.loc, /obj/item/mod/control))
		RegisterSignal(source.loc, COMSIG_MOD_MODULE_SELECTED, .proc/on_module_select)
		RegisterSignal(source.loc, COMSIG_ITEM_EQUIPPED, .proc/equip_check)
		equip_check()
	else if(istype(old_loc, /obj/item/mod/control))
		UnregisterSignal(old_loc, list(COMSIG_MOD_MODULE_SELECTED, COMSIG_ITEM_EQUIPPED))
		selected_module.set_output(null)
		wearer.set_output(null)

/obj/item/circuit_component/mod/proc/on_module_select()
	SIGNAL_HANDLER
	selected_module.set_output(attached_module.mod.selected_module)

/obj/item/circuit_component/mod/proc/equip_check()
	SIGNAL_HANDLER

	if(!attached_module.mod?.wearer)
		return
	wearer.set_output(attached_module.mod.wearer)
