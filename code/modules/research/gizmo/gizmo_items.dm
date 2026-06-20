/// A handheld gizmo, with some different activation modes
/obj/item/gizmo
	name = "gizmo"
	desc = "Невероятно! Это же... а правда, что это? Оно ещё и маленькое..."
	icon = 'icons/obj/science/gizmos.dmi'

	resistance_flags = FIRE_PROOF | UNACIDABLE | ACID_PROOF

	/// Possible icon states
	var/list/icon_states = list("gizmo_item_1")
	/// Reference to the gizmo master controller that handles all the other gizmo stuff
	var/datum/gizmo_controller/controller = /datum/gizmo_controller/item
	// BANDASTATION EDIT START: gizmo name randomizing
	var/list/possible_names = list(
		"штуковина", "штука-дрюка", "хреновина", "полярный инвертор", "реверсивный рецептор", "флопиксель", "репопулятор", "квантовый квантовик",
		"ну этот, как его", "делатель всякого", "квазифазер", "выполнятель задач", "интерфейсный респондер", "кинетический обсервер", "турбинный энкапсулятор",
		"бипкодел", "агрегат", "приблуда", "прибамбас", "девайс", "плюмбус",
	)
	// BANDASTATION EDIT END

/obj/item/gizmo/Initialize(mapload)
	. = ..()
	name = pick(possible_names) // BANDASTATION EDIT:  gizmo name randomizing

	if(icon_states)
		base_icon_state = pick(icon_states)
		icon_state = base_icon_state

	controller = new controller(src)
	controller.generate_interfaces(src)

/obj/item/gizmo/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	add_fingerprint(user)

	if(is_wire_tool(tool))
		attempt_wire_interaction(user)
		return ITEM_INTERACT_SUCCESS
	return NONE

/// Hard-mode code-crack gizmo
/obj/item/gizmo/moo
	controller = /datum/gizmo_controller/moo
