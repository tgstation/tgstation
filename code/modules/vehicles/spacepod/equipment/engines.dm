/obj/item/pod_equipment/engine
	interface_id = "GenericLines"
	slot = POD_SLOT_ENGINE
	icon_state = "engine"
	/// force we add everytime the vehicle attempts to move in a direction to said direction
	var/force_per_move = 0

/obj/item/pod_equipment/engine/examine(mob/user)
	. = ..()
	. += span_notice("It has a label: Capable of exerting up to <b>[force_per_move]</b> newtons.")

/obj/item/pod_equipment/engine/on_attach(mob/user)
	. = ..()
	pod.force_per_move += force_per_move

/obj/item/pod_equipment/engine/on_detach(mob/user)
	. = ..()
	pod.force_per_move -= force_per_move

/obj/item/pod_equipment/engine/ui_data(mob/user)
	return list(
		"lines" = list(
			"Power" = "[force_per_move]N",
		)
	)

/obj/item/pod_equipment/engine/light
	name = "light ion engine"
	desc = "A mark I pod engine. Cheap to produce and maintain, but is not that fast."
	force_per_move = 2.5 NEWTONS

/obj/item/pod_equipment/engine/default
	name = "ion engine"
	desc = "A mark II pod engine."
	force_per_move = 4 NEWTONS

/obj/item/pod_equipment/engine/fast
	name = "deuterium engine"
	desc = "A mark III pod engine. Plastered with warning labels."
	force_per_move = 6.5 NEWTONS

/obj/item/pod_equipment/engine/faster
	name = "improved deuterium engine"
	desc = "A mark IV pod engine. Probably not healthy in the long term."
	force_per_move = 8 NEWTONS
