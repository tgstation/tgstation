/*
 * False Walls
 */
/obj/structure/falsewall
	name = "wall"
	desc = "A huge chunk of metal used to separate rooms."
	anchored = TRUE
	icon = 'icons/turf/walls/false_walls.dmi'
	icon_state = "wall-open"
	base_icon_state = "wall"
	layer = LOW_OBJ_LAYER
	density = TRUE
	opacity = TRUE
	max_integrity = 100
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_WALLS + SMOOTH_GROUP_CLOSED_TURFS
	canSmoothWith = SMOOTH_GROUP_WALLS
	can_be_unanchored = FALSE
	can_atmos_pass = ATMOS_PASS_DENSITY
	rad_insulation = RAD_MEDIUM_INSULATION
	material_flags = MATERIAL_EFFECTS
	/// The icon this falsewall is faking being. we'll switch out our icon with this when we're in fake mode
	var/fake_icon = 'icons/turf/walls/wall.dmi'
	var/mineral = /obj/item/stack/sheet/iron
	var/mineral_amount = 2
	var/walltype = /turf/closed/wall
	var/girder_type = /obj/structure/girder/displaced
	var/opening = FALSE


/obj/structure/falsewall/Initialize(mapload)
	. = ..()
	var/obj/item/stack/initialized_mineral = new mineral // Okay this kinda sucks.
	set_custom_materials(initialized_mineral.mats_per_unit, mineral_amount)
	qdel(initialized_mineral)
	air_update_turf(TRUE, TRUE)

/obj/structure/falsewall/attack_hand(mob/user, list/modifiers)
	if(opening)
		return
	. = ..()
	if(.)
		return

	opening = TRUE
	if(!density)
		var/srcturf = get_turf(src)
		for(var/mob/living/obstacle in srcturf) //Stop people from using this as a shield
			opening = FALSE
			return
	update_appearance()
	addtimer(CALLBACK(src, TYPE_PROC_REF(/obj/structure/falsewall, toggle_open)), 0.5 SECONDS)

/obj/structure/falsewall/proc/toggle_open()
	if(!QDELETED(src))
		set_density(!density)
		set_opacity(density)
		opening = FALSE
		update_appearance()
		air_update_turf(TRUE, !density)

/obj/structure/falsewall/update_icon(updates=ALL)//Calling icon_update will refresh the smoothwalls if it's closed, otherwise it will make sure the icon is correct if it's open
	. = ..()
	if(!density || !(updates & UPDATE_SMOOTHING))
		return

	if(opening)
		smoothing_flags = NONE
		clear_smooth_overlays()
	else
		smoothing_flags = SMOOTH_BITMASK
		QUEUE_SMOOTH(src)

/obj/structure/falsewall/update_icon_state()
	if(opening)
		icon = initial(icon)
		icon_state = "[base_icon_state]-[density ? "opening" : "closing"]"
		return ..()
	if(density)
		icon = fake_icon
		icon_state = "[base_icon_state]-[smoothing_junction]"
	else
		icon = initial(icon)
		icon_state = "[base_icon_state]-open"
	return ..()

/obj/structure/falsewall/proc/ChangeToWall(delete = 1)
	var/turf/T = get_turf(src)
	T.place_on_top(walltype)
	if(delete)
		qdel(src)
	return T

/obj/structure/falsewall/tool_act(mob/living/user, obj/item/tool, list/modifiers)
	if(!opening || !tool.tool_behaviour)
		return ..()
	to_chat(user, span_warning("You must wait until the door has stopped moving!"))
	return ITEM_INTERACT_BLOCKING

/obj/structure/falsewall/screwdriver_act(mob/living/user, obj/item/tool)
	if(!density)
		to_chat(user, span_warning("You can't reach, close it first!"))
		return
	var/turf/loc_turf = get_turf(src)
	if(loc_turf.density)
		to_chat(user, span_warning("[src] is blocked!"))
		return ITEM_INTERACT_SUCCESS
	if(!isfloorturf(loc_turf))
		to_chat(user, span_warning("[src] bolts must be tightened on the floor!"))
		return ITEM_INTERACT_SUCCESS
	user.visible_message(span_notice("[user] tightens some bolts on the wall."), span_notice("You tighten the bolts on the wall."))
	ChangeToWall()
	return ITEM_INTERACT_SUCCESS


/obj/structure/falsewall/welder_act(mob/living/user, obj/item/tool)
	if(tool.use_tool(src, user, 0 SECONDS, volume=50))
		dismantle(user, TRUE)
		return ITEM_INTERACT_SUCCESS
	return

/obj/structure/falsewall/attackby(obj/item/W, mob/user, params)
	if(!opening)
		return ..()
	to_chat(user, span_warning("You must wait until the door has stopped moving!"))
	return

/obj/structure/falsewall/proc/dismantle(mob/user, disassembled=TRUE, obj/item/tool = null)
	user.visible_message(span_notice("[user] dismantles the false wall."), span_notice("You dismantle the false wall."))
	if(tool)
		tool.play_tool_sound(src, 100)
	else
		playsound(src, 'sound/items/tools/welder.ogg', 100, TRUE)
	deconstruct(disassembled)

/obj/structure/falsewall/atom_deconstruct(disassembled = TRUE)
	if(disassembled)
		new girder_type(loc)
	if(mineral_amount)
		for(var/i in 1 to mineral_amount)
			new mineral(loc)

/obj/structure/falsewall/get_dumping_location()
	return null

/obj/structure/falsewall/examine_status(mob/user) //So you can't detect falsewalls by examine.
	to_chat(user, span_notice("The outer plating is <b>welded</b> firmly in place."))
	return null

/*
 * False R-Walls
 */

/obj/structure/falsewall/reinforced
	name = "reinforced wall"
	desc = "A huge chunk of reinforced metal used to separate rooms."
	fake_icon = 'icons/turf/walls/reinforced_wall.dmi'
	icon_state = "reinforced_wall-open"
	base_icon_state = "reinforced_wall"
	walltype = /turf/closed/wall/r_wall
	mineral = /obj/item/stack/sheet/plasteel
	smoothing_flags = SMOOTH_BITMASK

/obj/structure/falsewall/reinforced/examine_status(mob/user)
	to_chat(user, span_notice("The outer <b>grille</b> is fully intact."))
	return null

/obj/structure/falsewall/reinforced/attackby(obj/item/tool, mob/user)
	..()
	if(tool.tool_behaviour == TOOL_WIRECUTTER)
		dismantle(user, TRUE, tool)

/*
 * Uranium Falsewalls
 */

/obj/structure/falsewall/uranium
	name = "uranium wall"
	desc = "A wall with uranium plating. This is probably a bad idea."
	fake_icon = 'icons/turf/walls/uranium_wall.dmi'
	icon_state = "uranium_wall-open"
	base_icon_state = "uranium_wall"
	mineral = /obj/item/stack/sheet/mineral/uranium
	walltype = /turf/closed/wall/mineral/uranium
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_URANIUM_WALLS + SMOOTH_GROUP_WALLS
	canSmoothWith = SMOOTH_GROUP_URANIUM_WALLS

	/// Mutex to prevent infinite recursion when propagating radiation pulses
	var/active = null

	/// The last time a radiation pulse was performed
	var/last_event = 0

/obj/structure/falsewall/uranium/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ATOM_PROPAGATE_RAD_PULSE, PROC_REF(radiate))

/obj/structure/falsewall/uranium/attackby(obj/item/W, mob/user, params)
	radiate()
	return ..()

/obj/structure/falsewall/uranium/attack_hand(mob/user, list/modifiers)
	radiate()
	return ..()

/obj/structure/falsewall/uranium/proc/radiate()
	SIGNAL_HANDLER
	if(active)
		return
	if(world.time <= last_event + 1.5 SECONDS)
		return
	active = TRUE
	radiation_pulse(
		src,
		max_range = 3,
		threshold = RAD_LIGHT_INSULATION,
		chance = URANIUM_IRRADIATION_CHANCE,
		minimum_exposure_time = URANIUM_RADIATION_MINIMUM_EXPOSURE_TIME,
	)
	propagate_radiation_pulse()
	last_event = world.time
	active = FALSE
/*
 * Other misc falsewall types
 */

/obj/structure/falsewall/gold
	name = "gold wall"
	desc = "A wall with gold plating. Swag!"
	fake_icon = 'icons/turf/walls/gold_wall.dmi'
	icon_state = "gold_wall-open"
	base_icon_state = "gold_wall"
	mineral = /obj/item/stack/sheet/mineral/gold
	walltype = /turf/closed/wall/mineral/gold
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_GOLD_WALLS + SMOOTH_GROUP_WALLS
	canSmoothWith = SMOOTH_GROUP_GOLD_WALLS

/obj/structure/falsewall/silver
	name = "silver wall"
	desc = "A wall with silver plating. Shiny."
	fake_icon = 'icons/turf/walls/silver_wall.dmi'
	icon_state = "silver_wall-open"
	base_icon_state = "silver_wall"
	mineral = /obj/item/stack/sheet/mineral/silver
	walltype = /turf/closed/wall/mineral/silver
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_SILVER_WALLS + SMOOTH_GROUP_WALLS
	canSmoothWith = SMOOTH_GROUP_SILVER_WALLS

/obj/structure/falsewall/diamond
	name = "diamond wall"
	desc = "A wall with diamond plating. You monster."
	fake_icon = 'icons/turf/walls/diamond_wall.dmi'
	icon_state = "diamond_wall-open"
	base_icon_state = "diamond_wall"
	mineral = /obj/item/stack/sheet/mineral/diamond
	walltype = /turf/closed/wall/mineral/diamond
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_DIAMOND_WALLS + SMOOTH_GROUP_WALLS
	canSmoothWith = SMOOTH_GROUP_DIAMOND_WALLS
	max_integrity = 800

/obj/structure/falsewall/plasma
	name = "plasma wall"
	desc = "A wall with plasma plating. This is definitely a bad idea."
	fake_icon = 'icons/turf/walls/plasma_wall.dmi'
	icon_state = "plasma_wall-open"
	base_icon_state = "plasma_wall"
	mineral = /obj/item/stack/sheet/mineral/plasma
	walltype = /turf/closed/wall/mineral/plasma
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_PLASMA_WALLS + SMOOTH_GROUP_WALLS
	canSmoothWith = SMOOTH_GROUP_PLASMA_WALLS

/obj/structure/falsewall/bananium
	name = "bananium wall"
	desc = "A wall with bananium plating. Honk!"
	fake_icon = 'icons/turf/walls/bananium_wall.dmi'
	icon_state = "bananium_wall-open"
	base_icon_state = "bananium_wall"
	mineral = /obj/item/stack/sheet/mineral/bananium
	walltype = /turf/closed/wall/mineral/bananium
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_BANANIUM_WALLS + SMOOTH_GROUP_WALLS
	canSmoothWith = SMOOTH_GROUP_BANANIUM_WALLS


/obj/structure/falsewall/sandstone
	name = "sandstone wall"
	desc = "A wall with sandstone plating. Rough."
	fake_icon = 'icons/turf/walls/sandstone_wall.dmi'
	icon_state = "sandstone_wall-open"
	base_icon_state = "sandstone_wall"
	mineral = /obj/item/stack/sheet/mineral/sandstone
	walltype = /turf/closed/wall/mineral/sandstone
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_SANDSTONE_WALLS + SMOOTH_GROUP_WALLS
	canSmoothWith = SMOOTH_GROUP_SANDSTONE_WALLS

/obj/structure/falsewall/wood
	name = "wooden wall"
	desc = "A wall with wooden plating. Stiff."
	fake_icon = 'icons/turf/walls/wood_wall.dmi'
	icon_state = "wood_wall-open"
	base_icon_state = "wood_wall"
	mineral = /obj/item/stack/sheet/mineral/wood
	walltype = /turf/closed/wall/mineral/wood
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_WOOD_WALLS + SMOOTH_GROUP_WALLS
	canSmoothWith = SMOOTH_GROUP_WOOD_WALLS

/obj/structure/falsewall/bamboo
	name = "bamboo wall"
	desc = "A wall with bamboo finish. Zen."
	fake_icon = 'icons/turf/walls/bamboo_wall.dmi'
	icon_state = "bamboo_wall-open"
	base_icon_state = "bamboo_wall"
	mineral = /obj/item/stack/sheet/mineral/bamboo
	walltype = /turf/closed/wall/mineral/bamboo
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_WALLS + SMOOTH_GROUP_BAMBOO_WALLS + SMOOTH_GROUP_CLOSED_TURFS
	canSmoothWith = SMOOTH_GROUP_BAMBOO_WALLS

/obj/structure/falsewall/iron
	name = "rough iron wall"
	desc = "A wall with rough metal plating."
	fake_icon = 'icons/turf/walls/iron_wall.dmi'
	icon_state = "iron_wall-open"
	base_icon_state = "iron_wall"
	mineral = /obj/item/stack/rods
	mineral_amount = 5
	walltype = /turf/closed/wall/mineral/iron
	base_icon_state = "iron_wall"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_IRON_WALLS + SMOOTH_GROUP_WALLS
	canSmoothWith = SMOOTH_GROUP_IRON_WALLS

/obj/structure/falsewall/abductor
	name = "alien wall"
	desc = "A wall with alien alloy plating."
	fake_icon = 'icons/turf/walls/abductor_wall.dmi'
	icon_state = "abductor_wall-open"
	base_icon_state = "abductor_wall"
	mineral = /obj/item/stack/sheet/mineral/abductor
	walltype = /turf/closed/wall/mineral/abductor
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_ABDUCTOR_WALLS + SMOOTH_GROUP_WALLS
	canSmoothWith = SMOOTH_GROUP_ABDUCTOR_WALLS

/obj/structure/falsewall/titanium
	name = "wall"
	desc = "A light-weight titanium wall used in shuttles."
	fake_icon = 'icons/turf/walls/shuttle_wall.dmi'
	icon_state = "shuttle_wall-open"
	base_icon_state = "shuttle_wall"
	mineral = /obj/item/stack/sheet/mineral/titanium
	walltype = /turf/closed/wall/mineral/titanium
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_TITANIUM_WALLS + SMOOTH_GROUP_WALLS
	canSmoothWith = SMOOTH_GROUP_SHUTTLE_PARTS + SMOOTH_GROUP_AIRLOCK + SMOOTH_GROUP_TITANIUM_WALLS

/obj/structure/falsewall/plastitanium
	name = "wall"
	desc = "An evil wall of plasma and titanium."
	fake_icon = 'icons/turf/walls/plastitanium_wall.dmi'
	icon_state = "plastitanium_wall-open"
	base_icon_state = "plastitanium_wall"
	mineral = /obj/item/stack/sheet/mineral/plastitanium
	walltype = /turf/closed/wall/mineral/plastitanium
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_PLASTITANIUM_WALLS + SMOOTH_GROUP_WALLS
	canSmoothWith = SMOOTH_GROUP_SHUTTLE_PARTS + SMOOTH_GROUP_AIRLOCK + SMOOTH_GROUP_PLASTITANIUM_WALLS

/obj/structure/falsewall/material
	name = "wall"
	desc = "A huge chunk of material used to separate rooms."
	fake_icon = 'icons/turf/walls/material_wall.dmi'
	icon_state = "material_wall-open"
	base_icon_state = "material_wall"
	walltype = /turf/closed/wall/material
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_WALLS + SMOOTH_GROUP_CLOSED_TURFS + SMOOTH_GROUP_MATERIAL_WALLS
	canSmoothWith = SMOOTH_GROUP_MATERIAL_WALLS
	material_flags = MATERIAL_EFFECTS | MATERIAL_ADD_PREFIX | MATERIAL_COLOR | MATERIAL_AFFECT_STATISTICS

/obj/structure/falsewall/material/atom_deconstruct(disassembled = TRUE)
	if(disassembled)
		new girder_type(loc)
	for(var/material in custom_materials)
		var/datum/material/material_datum = material
		new material_datum.sheet_type(loc, FLOOR(custom_materials[material_datum] / SHEET_MATERIAL_AMOUNT, 1))

/obj/structure/falsewall/material/mat_update_desc(mat)
	desc = "A huge chunk of [mat] used to separate rooms."

/obj/structure/falsewall/material/toggle_open()
	if(!QDELETED(src))
		set_density(!density)
		var/mat_opacity = TRUE
		for(var/datum/material/mat in custom_materials)
			if(mat.alpha < 255)
				mat_opacity = FALSE
				break
		set_opacity(density && mat_opacity)
		opening = FALSE
		update_appearance()
		air_update_turf(TRUE, !density)

/obj/structure/falsewall/material/ChangeToWall(delete = 1)
	var/turf/current_turf = get_turf(src)
	var/turf/closed/wall/material/new_wall = current_turf.place_on_top(/turf/closed/wall/material)
	new_wall.set_custom_materials(custom_materials)
	if(delete)
		qdel(src)
	return current_turf

/obj/structure/falsewall/material/update_icon(updates)
	. = ..()
	for(var/datum/material/mat in custom_materials)
		if(mat.alpha < 255)
			update_transparency_underlays()
			return

/obj/structure/falsewall/material/proc/update_transparency_underlays()
	underlays.Cut()
	var/girder_icon_state = "displaced"
	if(opening)
		girder_icon_state += "_[density ? "opening" : "closing"]"
	else if(!density)
		girder_icon_state += "_open"
	var/mutable_appearance/girder_underlay = mutable_appearance('icons/obj/structures.dmi', girder_icon_state, layer = LOW_OBJ_LAYER-0.01)
	girder_underlay.appearance_flags = RESET_ALPHA | RESET_COLOR
	underlays += girder_underlay
