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
	var/state = 0

/obj/item/stack/tile/light/attackby(obj/item/O, mob/user, params)
	if(O.tool_behaviour == TOOL_CROWBAR)
		new/obj/item/stack/sheet/iron(user.loc)
		amount--
		new/obj/item/stack/light_w(user.loc)
		if(amount <= 0)
			qdel(src)
	else
		return ..()

/obj/item/stack/tile/light/place_tile(turf/open/target_plating, mob/user)
	. = ..()
	var/turf/open/floor/light/floor = .
	floor?.state = state
