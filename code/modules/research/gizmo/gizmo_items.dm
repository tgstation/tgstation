/obj/item/gizmo
	name = "gizmo"
	desc = "Fliggoes the giggoe when its oven in hot the device."
	icon = 'icons/obj/science/gizmos.dmi'

	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF

	var/list/icon_states = list("gizmo_item_1")
	var/datum/gizmo_controller/controller = /datum/gizmo_controller/item

/obj/item/gizmo/Initialize(mapload)
	. = ..()

	if(icon_states)
		base_icon_state = pick(icon_states)
		icon_state = base_icon_state

	controller = new controller(src)
	controller.generate_interfaces(src)
