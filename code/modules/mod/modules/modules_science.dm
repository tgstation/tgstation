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

///Anomaly Locked - Causes the module to not function without an anomaly.
/obj/item/mod/module/anomaly_locked
	name = "MOD anomaly locked module"
	desc = "A form of a module, locked behind an anomalous core to function."
	incompatible_modules = list(/obj/item/mod/module/anomaly_locked)
	/// The core item the module runs off.
	var/obj/item/assembly/signaler/anomaly/core
	/// Accepted types of anomaly cores
	var/list/accepted_anomalies = list(/obj/item/assembly/signaler/anomaly)

/obj/item/mod/module/anomaly_locked/examine(mob/user)
	. = ..()
	if(!length(accepted_anomalies))
		return
	if(core)
		. += span_notice("There is a [core.name] installed in it. You could remove it with a <b>screwdriver</b>...")
	else
		var/core_string = ""
		for(var/path in accepted_anomalies)
			var/atom/core_path = path
			if(path == accepted_anomalies[1])
				core_string += initial(core_path.name)
			else if(path == accepted_anomalies[length(accepted_anomalies)])
				core_string += "or [initial(core_path.name)]"
			else
				core_string += ", [initial(core_path.name)]"
		. += span_notice("You need to insert \a [core_string] for this module to function.")

/obj/item/mod/module/anomaly_locked/on_select()
	if(!core)
		balloon_alert(mod.wearer, "no core!")
		return
	return ..()

/obj/item/mod/module/anomaly_locked/attackby(obj/item/item, mob/living/user, params)
	if(item.type in accepted_anomalies)
		if(core)
			balloon_alert(user, "core already in!")
			return
		if(!user.transferItemToLoc(item, src))
			return
		core = item
		balloon_alert(user, "core installed")
		playsound(src, 'sound/machines/click.ogg', 30, TRUE)
	else
		return ..()

/obj/item/mod/module/anomaly_locked/screwdriver_act(mob/living/user, obj/item/tool)
	. = ..()
	if(!core)
		balloon_alert(user, "no core!")
		return
	balloon_alert(user, "removing core...")
	if(!do_after(user, 3 SECONDS, target = src))
		balloon_alert(user, "interrupted!")
		return
	balloon_alert(user, "core removed")
	core.forceMove(drop_location())
	if(Adjacent(user) && !issilicon(user))
		user.put_in_hands(core)
	core = null

///Anti-Gravity - Makes the user weightless.
/obj/item/mod/module/anomaly_locked/antigrav
	name = "MOD anti-gravity module"
	desc = "A module that uses a gravitational core to make the user completely weightless."
	icon_state = "antigrav"
	module_type = MODULE_TOGGLE
	complexity = 3
	active_power_cost = DEFAULT_CELL_DRAIN * 0.7
	cooldown_time = 0.5 SECONDS
	accepted_anomalies = list(/obj/item/assembly/signaler/anomaly/grav)

/obj/item/mod/module/anomaly_locked/antigrav/on_activation()
	. = ..()
	if(!.)
		return
	if(mod.wearer.has_gravity())
		new /obj/effect/temp_visual/mook_dust(get_turf(src))
	mod.wearer.AddElement(/datum/element/forced_gravity, 0)
	mod.wearer.update_gravity(mod.wearer.has_gravity())
	playsound(src, 'sound/effects/gravhit.ogg', 50)

/obj/item/mod/module/anomaly_locked/antigrav/on_deactivation()
	. = ..()
	if(!.)
		return
	mod.wearer.RemoveElement(/datum/element/forced_gravity, 0)
	mod.wearer.update_gravity(mod.wearer.has_gravity())
	if(mod.wearer.has_gravity())
		new /obj/effect/temp_visual/mook_dust(get_turf(src))
	playsound(src, 'sound/effects/gravhit.ogg', 50)

#define TELEPORT_TIME 3 SECONDS

///Teleporter - Lets the user teleport to a nearby location.
/obj/item/mod/module/anomaly_locked/teleporter
	name = "MOD teleporter module"
	desc = "A module that uses a bluespace core to let the user transport their particles elsewhere."
	icon_state = "teleporter"
	module_type = MODULE_ACTIVE
	complexity = 3
	use_power_cost = DEFAULT_CELL_DRAIN * 5
	cooldown_time = 5 SECONDS
	accepted_anomalies = list(/obj/item/assembly/signaler/anomaly/bluespace)

/obj/item/mod/module/anomaly_locked/teleporter/on_select_use(atom/target)
	. = ..()
	if(!.)
		return
	var/turf/open/target_turf = get_turf(target)
	if(!istype(target_turf) || target_turf.is_blocked_turf_ignore_climbable() || !(target_turf in view(mod.wearer)))
		balloon_alert(mod.wearer, "invalid target!")
		return
	balloon_alert(mod.wearer, "teleporting...")
	var/matrix/user_matrix = matrix(mod.wearer.transform)
	animate(mod.wearer, TELEPORT_TIME, color = COLOR_CYAN, transform = user_matrix.Scale(4, 0.25), easing = EASE_OUT)
	if(!do_after(mod.wearer, TELEPORT_TIME, target = mod))
		balloon_alert(mod.wearer, "interrupted!")
		animate(mod.wearer, TELEPORT_TIME, color = null, transform = user_matrix.Scale(0.25, 4), easing = EASE_IN)
		return
	animate(mod.wearer, TELEPORT_TIME*0.1, color = null, transform = user_matrix.Scale(0.25, 4), easing = EASE_IN)
	if(!do_teleport(mod.wearer, target_turf, asoundin = 'sound/effects/phasein.ogg'))
		return
	drain_power(use_power_cost)

#undef TELEPORT_TIME
