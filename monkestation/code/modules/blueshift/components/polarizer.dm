GLOBAL_LIST_EMPTY(polarization_controllers)

/**
 * A component for windows to allow them to be dynamically rendered opaque /
 * transparent based on a button press.
 */
/datum/component/polarization_controller
	/// The ID of the polarizer we're listening to.
	var/id
	/// The color of the window when polarized.
	var/polarized_color = "#222222"
	/// The color the window was before it was polarized.
	var/non_polarized_color = "#FFFFFF"
	/// The time it takes for the polarization process to happen.
	var/polarization_process_duration = 0.5 SECONDS
	/// The capacitor that was used on the window, if any. Can be null if the
	/// window was spawned already polarized.
	var/obj/item/stock_parts/capacitor/used_capacitor


/datum/component/polarization_controller/Initialize(obj/item/stock_parts/capacitor/used_capacitor = null, polarizer_id = null)
	if(!istype(parent, /obj/structure/window))
		return COMPONENT_INCOMPATIBLE

	var/obj/managed_window = parent

	if(used_capacitor)
		src.used_capacitor = used_capacitor
		used_capacitor.forceMove(managed_window)

	if(polarizer_id)
		id = "[polarizer_id]"
		// But why make it a string here? Otherwise it won't be an associative list and it kind of explodes. Shitty, I know.
		LAZYADDASSOC(GLOB.polarization_controllers, id, list(src))

	RegisterSignal(parent, COMSIG_ATOM_ATTACKBY, PROC_REF(on_window_attackby))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_window_examine))
	RegisterSignal(parent, COMSIG_ATOM_TOOL_ACT(TOOL_MULTITOOL), PROC_REF(on_window_multitool_act))


/datum/component/polarization_controller/Destroy(force, silent)
	if(id)
		LAZYREMOVEASSOC(GLOB.polarization_controllers, id, list(src))

	if(used_capacitor)
		QDEL_NULL(used_capacitor)

	return ..()


/**
 * Handles toggling the window between opaque and transparent.
 *
 * Arguments:
 * * should_be_opaque - Boolean on whether or not the window should now be opaque.
 */
/datum/component/polarization_controller/proc/toggle(should_be_opaque)
	var/obj/managed_window = parent

	// No need to do anything if we're already at the right opacity.
	if(managed_window.opacity == !!should_be_opaque)
		return

	if(should_be_opaque)
		non_polarized_color = managed_window.color
		animate(managed_window, alpha = 255, color = polarized_color, time = polarization_process_duration)
		addtimer(CALLBACK(managed_window, TYPE_PROC_REF(/atom, set_opacity), TRUE), polarization_process_duration) // So that is changes opacity mid-way through the animation, hopefully.
	else
		animate(managed_window, alpha = initial(managed_window.alpha), color = non_polarized_color, time = polarization_process_duration)
		managed_window.set_opacity(FALSE) // So that is changes opacity mid-way through the animation, hopefully.



/**
 * Called when the parent window is being hit by an item
 *
 * Arguments:
 * * obj/item/attacking_item - The item hitting this atom
 * * mob/user - The wielder of this item
 * * params - click params such as alt/shift etc
 *
 * See: [/obj/item/proc/melee_attack_chain]
 */
/datum/component/polarization_controller/proc/on_window_attackby(datum/source, obj/item/attacking_item, mob/user, params)
	SIGNAL_HANDLER

	if(!istype(attacking_item, /obj/item/assembly/control/polarizer))
		return

	var/obj/item/assembly/control/polarizer/polarizer = attacking_item
	var/atom/parent_atom = parent

	if(!polarizer.id)
		parent_atom.balloon_alert(user, "set id on controller first!")
		return COMPONENT_NO_AFTERATTACK

	if(id)
		LAZYREMOVEASSOC(GLOB.polarization_controllers, id, list(src))

	id = "[polarizer.id]"

	LAZYADDASSOC(GLOB.polarization_controllers, id, list(src))
	parent_atom.balloon_alert(user, "linked polarizer!")

	return COMPONENT_NO_AFTERATTACK


/**
 * Handles adding the examine strings to windows that have a polarization
 * controller installed.
 */
/datum/component/polarization_controller/proc/on_window_examine(datum/source, mob/user, list/examine_strings)
	SIGNAL_HANDLER

	examine_strings += span_notice("It has a polarization controller installed.")
	examine_strings += span_notice("Use a <b>window polarizing controller</b> on it to link it to that controller's current ID.")
	examine_strings += span_notice("Use a <b>multitool</b> on it to remove the polarization controller.")


/**
 * Signal handler to handle the removal of this component when someone uses a
 * multitool (or something that acts like one) on the parent window.
 */
/datum/component/polarization_controller/proc/on_window_multitool_act(datum/source, mob/user, obj/item/tool)
	SIGNAL_HANDLER

	remove_polarization_controller(source, user, tool)

	return COMPONENT_BLOCK_TOOL_ATTACK


/**
 * Proc that handles removing the polarization controller.
 * Had to be made into a separate proc so that it wouldn't be waited for by the
 * signal handler for the multitool tool act.
 */
/datum/component/polarization_controller/proc/remove_polarization_controller(datum/source, mob/user, obj/item/tool)
	set waitfor = FALSE

	var/obj/managed_window = parent

	managed_window.balloon_alert(user, "removing polarization controller")

	if(!do_after(user, 1 SECONDS, managed_window))
		managed_window.balloon_alert(user, "cancelled removal")
		return

	toggle(FALSE)

	if(!used_capacitor)
		used_capacitor = new

	used_capacitor.forceMove(managed_window.drop_location())

	used_capacitor = null

	UnregisterSignal(parent, COMSIG_ATOM_ATTACKBY)
	UnregisterSignal(parent, COMSIG_ATOM_EXAMINE)
	UnregisterSignal(parent, COMSIG_ATOM_TOOL_ACT(TOOL_MULTITOOL))

	managed_window.balloon_alert(user, "removed polarization controller")

	qdel(src)
