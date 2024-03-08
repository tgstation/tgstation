/datum/wires/collar_bomb
	proper_name = "Collar Bomb"
	randomize = TRUE // Only one, no need for blueprints
	holder_type = /obj/item/clothing/neck/collar_bomb
	wires = list(WIRE_ACTIVATE)

/datum/wires/collar_bomb/interactable(mob/user)
	. = ..()
	var/obj/item/clothing/neck/collar_bomb/collar = holder
	if(!collar.panel_open)
		return FALSE

/datum/wires/collar_bomb/on_pulse(wire)
	var/obj/item/clothing/neck/collar_bomb/collar = holder
	if(!collar.active)
		collar.explosive_countdown(5)
	return ..()
