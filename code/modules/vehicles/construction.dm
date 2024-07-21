/obj/item/circuitboard/pod
	name = "pod control board"
	icon_state = "std_mod"

/obj/item/pod_runner
	name = "pod frame runner"
	desc = "A metal runner with pod frame parts. Use a wirecutter to snip them free."
	var/build_path = /obj/structure/pod_construction

/obj/item/pod_runner/wirecutter_act(mob/living/user, obj/item/tool)
	. = NONE
	tool.play_tool_sound(src)
	if(!do_after(user, 5 SECONDS, src))
		return ITEM_INTERACT_FAILURE
	tool.play_tool_sound(src)
	new build_path(get_turf(src))
	qdel(src)
	return ITEM_INTERACT_SUCCESS

//steps:
//wrench, now dense
//weld
//cable
//wirecutters
//board
//screw
// MAYBE:: add and weld internal plating
// attach armor
// MAYBE:: crowbar armor into place
// wrench armor
// weld armor
// MAYBE:: window?
/obj/structure/pod_construction
