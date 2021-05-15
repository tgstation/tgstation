/**
 * # Integrated Circuitboard
 *
 * A circuitboard that holds components that work together
 *
 * Has a limited amount of power.
 */
/obj/item/integrated_circuit
	name = "integrated circuit"

	/// The power of the integrated circuit
	var/obj/item/stock_parts/cell/cell

	/// The attached components
	var/list/obj/item/component/attached_components

/obj/item/integrated_circuit/loaded/Initialize()
	. = ..()
	cell = new /obj/item/stock_parts/cell/high(src)

/obj/item/integrated_circuit/attackby(obj/item/I, mob/living/user, params)
	. = ..()
	if(iscomponent(I))
		add_component(I)

/obj/item/integrated_circuit/proc/add_component(obj/item/component/to_add)
	if(to_add.parent)
		return

	to_add.parent = src
	attached_components += to_add
	RegisterSignal(to_add, COMSIG_MOVABLE_MOVED, .proc/component_move_handler)

/obj/item/integrated_circuit/proc/component_move_handler(obj/item/component/source)
	SIGNAL_HANDLER
	if(source.loc != src)
		remove_component(source)

/obj/item/integrated_circuit/proc/remove_component(obj/item/component/to_remove)
	UnregisterSignal(to_remove, COMSIG_MOVABLE_MOVED)

/obj/item/integrated_circuit/get_cell()
	return cell

/obj/item/integrated_circuit/ui_data(mob/user)
	. = list()


/obj/item/integrated_circuit/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "IntegratedCircuit", name)
		ui.open()
