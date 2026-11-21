/obj/item/stack/tile/light
	name = "light tile"
	singular_name = "light floor tile"
	desc = "A floor tile, made out of glass. It produces light."
	icon_state = "tile_e"
	obj_flags = CONDUCTS_ELECTRICITY
	attack_verb_continuous = list("bashes", "batters", "bludgeons", "thrashes", "smashes")
	attack_verb_simple = list("bash", "batter", "bludgeon", "thrash", "smash")
	turf_type = /turf/open/floor/light
	merge_type = /obj/item/stack/tile/light
	mats_per_unit = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT * 1.05, /datum/material/glass = SHEET_MATERIAL_AMOUNT * 1.05)
	var/state = 0

/obj/item/stack/tile/light/crowbar_act(mob/living/user, obj/item/tool)
	new/obj/item/stack/sheet/iron(user.loc)
	amount--
	new/obj/item/stack/light_w(user.loc)
	if(amount <= 0)
		qdel(src)
	return ITEM_INTERACT_SUCCESS


/obj/item/stack/tile/light/place_tile(turf/open/target_plating, mob/user)
	. = ..()
	var/turf/open/floor/light/floor = .
	floor?.state = state
