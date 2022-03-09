/*
 * Tram Walls
 */
/obj/structure/tramwall
	name = "wall"
	desc = "A huge chunk of metal used to separate rooms."
	anchored = TRUE
	icon = 'icons/turf/walls/wall.dmi'
	icon_state = "wall-0"
	base_icon_state = "wall"
	layer = LOW_OBJ_LAYER
	density = TRUE
	opacity = TRUE
	max_integrity = 100
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_CLOSED_TURFS, SMOOTH_GROUP_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_WALLS)
	can_be_unanchored = FALSE
	can_atmos_pass = ATMOS_PASS_DENSITY
	rad_insulation = RAD_MEDIUM_INSULATION
	material_flags = MATERIAL_EFFECTS
	var/mineral = /obj/item/stack/sheet/iron
	var/mineral_amount = 2
	var/tram_wall_type = /obj/structure/tramwall
	var/girder_type = /obj/structure/girder/tram


/obj/structure/tramwall/Initialize(mapload)
	. = ..()
	var/obj/item/stack/initialized_mineral = new mineral
	set_custom_materials(initialized_mineral.mats_per_unit, mineral_amount)
	qdel(initialized_mineral)
	air_update_turf(TRUE, TRUE)

/obj/structure/tramwall/attackby(obj/item/welder, mob/user, params)
	if(welder.tool_behaviour == TOOL_WELDER)
		if(!welder.tool_start_check(user, amount=0))
			return FALSE

		to_chat(user, span_notice("You begin slicing through the outer plating..."))
		if(welder.use_tool(src, user, 10 SECONDS, volume=100))
			to_chat(user, span_notice("You remove the outer plating."))
			dismantle(user, TRUE)
	else
		return ..()

/obj/structure/tramwall/proc/dismantle(mob/user, disassembled=TRUE, obj/item/tool = null)
	user.visible_message(span_notice("[user] dismantles the wall."), span_notice("You dismantle the wall."))
	if(tool)
		tool.play_tool_sound(src, 100)
	else
		playsound(src, 'sound/items/welder.ogg', 100, TRUE)
	deconstruct(disassembled)

/obj/structure/tramwall/deconstruct(disassembled = TRUE)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(disassembled)
			new girder_type(loc)
		if(mineral_amount)
			for(var/i in 1 to mineral_amount)
				new mineral(loc)
	qdel(src)

/obj/structure/tramwall/get_dumping_location()
	return null

/obj/structure/tramwall/examine_status(mob/user)
	to_chat(user, span_notice("The outer plating is <b>welded</b> firmly in place."))
	return null


/*
 * Other misc tramwall types
 */

/obj/structure/tramwall/titanium
	name = "wall"
	desc = "A light-weight titanium wall used in shuttles."
	icon = 'icons/turf/walls/shuttle_wall.dmi'
	icon_state = "shuttle_wall-0"
	base_icon_state = "shuttle_wall"
	mineral = /obj/item/stack/sheet/mineral/titanium
	tram_wall_type = /obj/structure/tramwall/titanium
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_WALLS, SMOOTH_GROUP_TITANIUM_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_TITANIUM_WALLS, SMOOTH_GROUP_AIRLOCK, SMOOTH_GROUP_SHUTTLE_PARTS)

/obj/structure/tramwall/plastitanium
	name = "wall"
	desc = "An evil wall of plasma and titanium."
	icon = 'icons/turf/walls/plastitanium_wall.dmi'
	icon_state = "plastitanium_wall-0"
	base_icon_state = "plastitanium_wall"
	mineral = /obj/item/stack/sheet/mineral/plastitanium
	tram_wall_type = /obj/structure/tramwall/plastitanium
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_WALLS, SMOOTH_GROUP_PLASTITANIUM_WALLS)
	canSmoothWith = list(SMOOTH_GROUP_PLASTITANIUM_WALLS, SMOOTH_GROUP_AIRLOCK, SMOOTH_GROUP_SHUTTLE_PARTS)
