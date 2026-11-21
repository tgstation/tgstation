
/obj/structure/chair/e_chair
	name = "electric chair"
	desc = "Looks absolutely SHOCKING!"
	icon_state = "echair0"
	var/last_time = 1
	item_chair = null

/obj/structure/chair/e_chair/Initialize(mapload)
	. = ..()
	var/mutable_appearance/export_to_component = mutable_appearance('icons/obj/chairs.dmi', "echair_over", OBJ_LAYER, src, appearance_flags = KEEP_APART)
	export_to_component = color_atom_overlay(export_to_component)

	AddComponent(\
		/datum/component/electrified_buckle,\
		overlays_to_add = list(export_to_component),\
		shock_flags = (SHOCK_NOGLOVES)\
	)

/obj/structure/chair/e_chair/wrench_act(mob/living/user, obj/item/tool)
	var/obj/structure/chair/non_electric_chair = new /obj/structure/chair(loc)
	tool.play_tool_sound(src)
	non_electric_chair.setDir(dir)
	qdel(src)
	return ITEM_INTERACT_SUCCESS
