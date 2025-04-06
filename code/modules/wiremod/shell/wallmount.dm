/obj/structure/wallmount_circuit
	name = "circuit box"
	desc = "A wall-mounted box suitable for the installation of integrated circuits."
	icon = 'icons/obj/science/circuits.dmi'
	icon_state = "wallmount"
	layer = BELOW_OBJ_LAYER
	anchored = TRUE

	resistance_flags = LAVA_PROOF | FIRE_PROOF

/obj/structure/wallmount_circuit/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/shell, null, SHELL_CAPACITY_LARGE, SHELL_FLAG_REQUIRE_ANCHOR|SHELL_FLAG_USB_PORT)

/obj/structure/wallmount_circuit/wrench_act(mob/living/user, obj/item/tool)
	var/datum/component/shell/shell_comp = GetComponent(/datum/component/shell)
	if(shell_comp.locked)
		balloon_alert(user, "locked!")
		return ITEM_INTERACT_FAILURE
	to_chat(user, span_notice("You start unsecuring the circuit box..."))
	if(tool.use_tool(src, user, 40, volume=50))
		to_chat(user, span_notice("You unsecure the circuit box."))
		playsound(loc, 'sound/items/deconstruct.ogg', 50, TRUE)
		deconstruct(TRUE)
	return ITEM_INTERACT_SUCCESS

/obj/item/wallframe/circuit
	name = "circuit box frame"
	desc = "A box that can be mounted on a wall and have circuits installed."
	icon = 'icons/obj/science/circuits.dmi'
	icon_state = "wallmount_assembly"
	result_path = /obj/structure/wallmount_circuit
	pixel_shift = 32
