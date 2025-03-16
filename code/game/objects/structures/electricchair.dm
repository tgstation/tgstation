
/obj/structure/chair/e_chair
	name = "electric chair"
	desc = "Looks absolutely SHOCKING!"
	icon_state = "echair0"
	var/last_time = 1
	item_chair = null

/obj/structure/chair/e_chair/Initialize(mapload)
	. = ..()
	var/obj/item/assembly/shock_kit/stored_kit = new(contents)
	var/mutable_appearance/export_to_component = mutable_appearance('icons/obj/chairs.dmi', "echair_over", OBJ_LAYER, src, appearance_flags = KEEP_APART)
	export_to_component = color_atom_overlay(export_to_component)
	AddComponent(/datum/component/electrified_buckle, (SHOCK_REQUIREMENT_ITEM | SHOCK_REQUIREMENT_LIVE_CABLE | SHOCK_REQUIREMENT_SIGNAL_RECEIVED_TOGGLE), stored_kit, list(export_to_component))

/obj/structure/chair/e_chair/attackby(obj/item/W, mob/user, list/modifiers)
	if(W.tool_behaviour == TOOL_WRENCH)
		var/obj/structure/chair/C = new /obj/structure/chair(loc)
		W.play_tool_sound(src)
		C.setDir(dir)
		qdel(src)
		return
	. = ..()
