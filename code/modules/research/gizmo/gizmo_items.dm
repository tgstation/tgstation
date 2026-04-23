/// A handheld gizmo, with some different activation modes
/obj/item/gizmo
	name = "gizmo"
	desc = "Fliggoes the giggoe when its oven in hot the device."
	icon = 'icons/obj/science/gizmos.dmi'

	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF

	/// Possible icon states
	var/list/icon_states = list("gizmo_item_1")
	/// Reference to the gizmo master controller that handles all the other gizmo stuff
	var/datum/gizmo_controller/controller = /datum/gizmo_controller/item

/obj/item/gizmo/Initialize(mapload)
	. = ..()

	if(icon_states)
		base_icon_state = pick(icon_states)
		icon_state = base_icon_state

	controller = new controller(src)
	controller.generate_interfaces(src)
