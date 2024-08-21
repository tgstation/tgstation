/*
 * False Walls
 */

/// Stores a list of icon -> icon but with all fullblack pixels fully transparent
/// I would LOVE to do this with colormatrix bullshit but alpha does NOT cap at 1 on some GPUs for some stupid reason
GLOBAL_LIST_INIT(falsewall_alpha_icons, generate_transparent_falsewalls())

/proc/generate_transparent_falsewalls()
	var/list/icon_alphas = list()
	for(var/obj/structure/falsewall/false_type as anything in typesof(/obj/structure/falsewall))
		var/icon/make_transparent = initial(false_type.fake_icon)
		if(icon_alphas[make_transparent])
			continue
		var/icon/alpha_icon = icon(make_transparent)
		// I am SO sorry (makes any full black pixels transparent)
		alpha_icon.SwapColor("#000000FF", rgb(0, 0, 0, 0))
		icon_alphas[make_transparent] = alpha_icon
	return icon_alphas

/// Static mask we use to hide the bits of falsewalls that would be "below" the floor when opening/closing
/obj/effect/falsewall_mask
	icon = 'icons/effects/32x48.dmi'
	icon_state = "white"
	vis_flags = VIS_INHERIT_ID
	appearance_flags = parent_type::appearance_flags | KEEP_TOGETHER | RESET_TRANSFORM

/obj/effect/falsewall_mask/Initialize(mapload)
	. = ..()
	render_target = "*falsewall_mask"

/// Duplicates our parent falsewall's rendering behavior
/// But renders walls as overlays instead of with splitvis
/// In viscontents to make separation of concerns easier
/obj/effect/falsewall_floating
	vis_flags = VIS_INHERIT_PLANE|VIS_INHERIT_ID
	appearance_flags = parent_type::appearance_flags | KEEP_TOGETHER | RESET_ALPHA
	/// The icon to fake ourselves as
	var/icon/fake_icon
	/// If darkness in our sprite is visible or not
	/// Exists so we can make falsewalls fall "into" the floor
	/// Potentially breaks art but the usecase is so minimal I will accept it
	var/opaque_darkness = TRUE
	var/static/obj/effect/falsewall_mask/trim

/obj/effect/falsewall_floating/proc/set_fake_icon(icon/fake_icon)
	if(src.fake_icon == fake_icon)
		return
	src.fake_icon = fake_icon
	update_appearance()

/obj/effect/falsewall_floating/proc/set_darkness_opacity(opaque_darkness)
	if(src.opaque_darkness == opaque_darkness)
		return
	src.opaque_darkness = opaque_darkness
	update_appearance()

/obj/effect/falsewall_floating/set_smoothed_icon_state(new_junction)
	. = ..()
	update_appearance()

/// Runs an animation that masks off the bottom of our sprite
/obj/effect/falsewall_floating/proc/trim_base(delay)
	if(!trim)
		trim = new(src)
	vis_contents += trim
	add_filter("trim_mask", 1, alpha_mask_filter(y = -40, render_source = trim.render_target, flags = MASK_INVERSE))
	transition_filter("trim_mask", alpha_mask_filter(y = -16, render_source = trim.render_target, flags = MASK_INVERSE), time = delay)

/// Runs an animation that slowly reveals the bottom of our sprite
/obj/effect/falsewall_floating/proc/untrim_base(delay)
	if(!trim)
		trim = new(src)
	vis_contents += trim
	add_filter("trim_mask", 1, alpha_mask_filter(y = -16, render_source = trim.render_target, flags = MASK_INVERSE))
	transition_filter("trim_mask", alpha_mask_filter(y = -40, render_source = trim.render_target, flags = MASK_INVERSE), time = delay)

/obj/effect/falsewall_floating/update_overlays()
	. = ..()
	// If we smooth north then as we open there's gonna be a weird hole left by the lack of blackness from above. this should help? compensate for that.
	if(smoothing_junction & NORTH_JUNCTION && opaque_darkness)
		var/mutable_appearance/black_backdrop = mutable_appearance('icons/turf/walls/wall_blackness.dmi', "wall_background")
		black_backdrop.pixel_z = 16
		. += black_backdrop

	var/icon/working_fake_icon = opaque_darkness ? fake_icon : GLOB.falsewall_alpha_icons[fake_icon]
	. += generate_joined_wall(working_fake_icon, smoothing_junction, draw_darkness = opaque_darkness)

/obj/structure/falsewall
	name = "wall"
	desc = "A huge chunk of metal used to separate rooms."
	anchored = TRUE
	icon = 'icons/turf/walls/false_walls.dmi'
	icon_state = "wall"
	base_icon_state = "wall"
	layer = LOW_OBJ_LAYER
	density = TRUE
	opacity = TRUE
	max_integrity = 100
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_WALLS + SMOOTH_GROUP_TALL_WALLS + SMOOTH_GROUP_CLOSED_TURFS
	canSmoothWith = SMOOTH_GROUP_WALLS
	can_be_unanchored = FALSE
	can_atmos_pass = ATMOS_PASS_DENSITY
	rad_insulation = RAD_MEDIUM_INSULATION
	material_flags = MATERIAL_EFFECTS
	// Complex appearance gotta use render targets
	blocks_emissive = EMISSIVE_BLOCK_UNIQUE
	/// The object we are using to fake being a wall
	var/obj/effect/falsewall_floating/visuals
	/// Our usual smoothing groups
	var/list/usual_groups
	/// The icon this falsewall is faking being. we'll switch out our icon with this when we're in fake mode
	var/fake_icon = 'icons/turf/walls/metal_wall.dmi'
	var/mineral = /obj/item/stack/sheet/iron
	var/mineral_amount = 2
	var/walltype = /turf/closed/wall
	var/girder_type = /obj/structure/girder/displaced
	var/opening = FALSE

/obj/structure/falsewall/Initialize(mapload)
	. = ..()
	visuals = new(src)
	visuals.set_fake_icon(fake_icon)
	AddElement(/datum/element/split_visibility, fake_icon, color)
	var/obj/item/stack/initialized_mineral = new mineral // Okay this kinda sucks.
	set_custom_materials(initialized_mineral.mats_per_unit, mineral_amount)
	qdel(initialized_mineral)
	set_opacity(TRUE) // walls cannot be transparent fuck u materials
	air_update_turf(TRUE, TRUE)

/obj/structure/falsewall/Destroy(force)
	QDEL_NULL(visuals)
	return ..()

/obj/structure/falsewall/set_smoothed_icon_state(new_junction)
	. = ..()
	visuals.set_smoothed_icon_state(new_junction)

/obj/structure/falsewall/attack_hand(mob/user, list/modifiers)
	if(opening)
		return
	. = ..()
	if(.)
		return

	if(!density)
		var/srcturf = get_turf(src)
		for(var/mob/living/obstacle in srcturf) //Stop people from using this as a shield
			return
	INVOKE_ASYNC(src, PROC_REF(toggle_open))

/obj/structure/falsewall/proc/toggle_open()
	opening = TRUE
	if(density)
		open()
	else
		close()
	opening = FALSE

/obj/structure/falsewall/proc/open()
	vis_contents += visuals
	RemoveElement(/datum/element/split_visibility, fake_icon, color)
	visuals.trim_base(1 SECONDS)
	animate(src, pixel_z = -24, time = 1 SECONDS)
	usual_groups = smoothing_groups
	smoothing_groups = list()
	QUEUE_SMOOTH_NEIGHBORS(src) // Update any walls around us
	sleep(0.2 SECONDS)
	set_opacity(FALSE)
	sleep(0.8 SECONDS)
	visuals.set_darkness_opacity(FALSE)
	set_density(FALSE)
	air_update_turf(TRUE, TRUE)

/obj/structure/falsewall/proc/close()
	set_density(TRUE)
	air_update_turf(TRUE, FALSE)
	visuals.untrim_base(1 SECONDS)
	animate(src, pixel_z = 0, time = 1 SECONDS)
	visuals.set_darkness_opacity(TRUE)
	sleep(0.3 SECONDS)
	set_opacity(TRUE)
	smoothing_groups = usual_groups
	usual_groups = null
	QUEUE_SMOOTH_NEIGHBORS(src)
	sleep(0.7 SECONDS)
	vis_contents -= visuals
	AddElement(/datum/element/split_visibility, fake_icon, color)

/obj/structure/falsewall/update_icon(updates=ALL)
	. = ..()
	if(!(updates & UPDATE_SMOOTHING))
		return
	QUEUE_SMOOTH(src)

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
		playsound(src, 'sound/items/welder.ogg', 100, TRUE)
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
	icon_state = "reinforced_wall"
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
	icon_state = "uranium_wall"
	base_icon_state = "uranium_wall"
	mineral = /obj/item/stack/sheet/mineral/uranium
	walltype = /turf/closed/wall/mineral/uranium
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_URANIUM_WALLS + SMOOTH_GROUP_WALLS + SMOOTH_GROUP_TALL_WALLS
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
	icon_state = "gold_wall"
	base_icon_state = "gold_wall"
	mineral = /obj/item/stack/sheet/mineral/gold
	walltype = /turf/closed/wall/mineral/gold
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_GOLD_WALLS + SMOOTH_GROUP_WALLS + SMOOTH_GROUP_TALL_WALLS
	canSmoothWith = SMOOTH_GROUP_GOLD_WALLS

/obj/structure/falsewall/silver
	name = "silver wall"
	desc = "A wall with silver plating. Shiny."
	fake_icon = 'icons/turf/walls/silver_wall.dmi'
	icon_state = "silver_wall"
	base_icon_state = "silver_wall"
	mineral = /obj/item/stack/sheet/mineral/silver
	walltype = /turf/closed/wall/mineral/silver
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_SILVER_WALLS + SMOOTH_GROUP_WALLS + SMOOTH_GROUP_TALL_WALLS
	canSmoothWith = SMOOTH_GROUP_SILVER_WALLS

/obj/structure/falsewall/diamond
	name = "diamond wall"
	desc = "A wall with diamond plating. You monster."
	fake_icon = 'icons/turf/walls/diamond_wall.dmi'
	icon_state = "diamond_wall"
	base_icon_state = "diamond_wall"
	mineral = /obj/item/stack/sheet/mineral/diamond
	walltype = /turf/closed/wall/mineral/diamond
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_DIAMOND_WALLS + SMOOTH_GROUP_WALLS + SMOOTH_GROUP_TALL_WALLS
	canSmoothWith = SMOOTH_GROUP_DIAMOND_WALLS
	max_integrity = 800

/obj/structure/falsewall/plasma
	name = "plasma wall"
	desc = "A wall with plasma plating. This is definitely a bad idea."
	fake_icon = 'icons/turf/walls/plasma_wall.dmi'
	icon_state = "plasma_wall"
	base_icon_state = "plasma_wall"
	mineral = /obj/item/stack/sheet/mineral/plasma
	walltype = /turf/closed/wall/mineral/plasma
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_PLASMA_WALLS + SMOOTH_GROUP_WALLS + SMOOTH_GROUP_TALL_WALLS
	canSmoothWith = SMOOTH_GROUP_PLASMA_WALLS

/obj/structure/falsewall/bananium
	name = "bananium wall"
	desc = "A wall with bananium plating. Honk!"
	fake_icon = 'icons/turf/walls/bananium_wall.dmi'
	icon_state = "bananium_wall"
	base_icon_state = "bananium_wall"
	mineral = /obj/item/stack/sheet/mineral/bananium
	walltype = /turf/closed/wall/mineral/bananium
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_BANANIUM_WALLS + SMOOTH_GROUP_WALLS + SMOOTH_GROUP_TALL_WALLS
	canSmoothWith = SMOOTH_GROUP_BANANIUM_WALLS


/obj/structure/falsewall/sandstone
	name = "sandstone wall"
	desc = "A wall with sandstone plating. Rough."
	fake_icon = 'icons/turf/walls/sandstone_wall.dmi'
	icon_state = "sandstone_wall"
	base_icon_state = "sandstone_wall"
	mineral = /obj/item/stack/sheet/mineral/sandstone
	walltype = /turf/closed/wall/mineral/sandstone
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_SANDSTONE_WALLS + SMOOTH_GROUP_WALLS + SMOOTH_GROUP_TALL_WALLS
	canSmoothWith = SMOOTH_GROUP_SANDSTONE_WALLS

/obj/structure/falsewall/wood
	name = "wooden wall"
	desc = "A wall with wooden plating. Stiff."
	fake_icon = 'icons/turf/walls/wood_wall.dmi'
	icon_state = "wood_wall"
	base_icon_state = "wood_wall"
	mineral = /obj/item/stack/sheet/mineral/wood
	walltype = /turf/closed/wall/mineral/wood
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_WOOD_WALLS + SMOOTH_GROUP_WALLS + SMOOTH_GROUP_TALL_WALLS
	canSmoothWith = SMOOTH_GROUP_WOOD_WALLS

/obj/structure/falsewall/bamboo
	name = "bamboo wall"
	desc = "A wall with bamboo finish. Zen."
	fake_icon = 'icons/turf/walls/bamboo_wall.dmi'
	icon_state = "bamboo_wall"
	base_icon_state = "bamboo_wall"
	mineral = /obj/item/stack/sheet/mineral/bamboo
	walltype = /turf/closed/wall/mineral/bamboo
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_BAMBOO_WALLS + SMOOTH_GROUP_WALLS + SMOOTH_GROUP_TALL_WALLS + SMOOTH_GROUP_CLOSED_TURFS
	canSmoothWith = SMOOTH_GROUP_BAMBOO_WALLS

/obj/structure/falsewall/meat
	name = "meat wall"
	desc = "A wall of somone's compacted meat."
	fake_icon = 'icons/turf/walls/meat_wall.dmi'
	icon_state = "meat_wall"
	base_icon_state = "meat_wall"
	mineral = /obj/item/stack/sheet/meat
	walltype = /turf/closed/wall/mineral/meat
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_MEAT_WALLS + SMOOTH_GROUP_WALLS + SMOOTH_GROUP_TALL_WALLS + SMOOTH_GROUP_CLOSED_TURFS
	canSmoothWith = SMOOTH_GROUP_MEAT_WALLS

/obj/structure/falsewall/pizza
	name = "pepperoni wallzza"
	desc = "It's a delicious pepperoni wallzza!"
	fake_icon = 'icons/turf/walls/pizza_wall.dmi'
	icon_state = "pizza_wall"
	base_icon_state = "pizza_wall"
	mineral = /obj/item/stack/sheet/pizza
	walltype = /turf/closed/wall/mineral/pizza
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_PIZZA_WALLS + SMOOTH_GROUP_WALLS + SMOOTH_GROUP_TALL_WALLS + SMOOTH_GROUP_CLOSED_TURFS
	canSmoothWith = SMOOTH_GROUP_PIZZA_WALLS

/obj/structure/falsewall/iron
	name = "rough iron wall"
	desc = "A wall with rough metal plating."
	fake_icon = 'icons/turf/walls/iron_wall.dmi'
	icon_state = "iron_wall"
	base_icon_state = "iron_wall"
	mineral = /obj/item/stack/rods
	mineral_amount = 5
	walltype = /turf/closed/wall/mineral/iron
	base_icon_state = "iron_wall"
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_IRON_WALLS + SMOOTH_GROUP_WALLS + SMOOTH_GROUP_TALL_WALLS
	canSmoothWith = SMOOTH_GROUP_IRON_WALLS

/obj/structure/falsewall/abductor
	name = "alien wall"
	desc = "A wall with alien alloy plating."
	fake_icon = 'icons/turf/walls/abductor_wall.dmi'
	icon_state = "abductor_wall"
	base_icon_state = "abductor_wall"
	mineral = /obj/item/stack/sheet/mineral/abductor
	walltype = /turf/closed/wall/mineral/abductor
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_ABDUCTOR_WALLS + SMOOTH_GROUP_WALLS + SMOOTH_GROUP_TALL_WALLS
	canSmoothWith = SMOOTH_GROUP_ABDUCTOR_WALLS

/obj/structure/falsewall/titanium
	name = "wall"
	desc = "A light-weight titanium wall used in shuttles."
	fake_icon = 'icons/turf/walls/shuttle_wall.dmi'
	icon_state = "shuttle_wall"
	base_icon_state = "shuttle_wall"
	mineral = /obj/item/stack/sheet/mineral/titanium
	walltype = /turf/closed/wall/mineral/titanium
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_TITANIUM_WALLS + SMOOTH_GROUP_TALL_WALLS
	canSmoothWith = SMOOTH_GROUP_TITANIUM_WALLS

/obj/structure/falsewall/plastitanium
	name = "wall"
	desc = "An evil wall of plasma and titanium."
	fake_icon = 'icons/turf/walls/plastitanium_wall.dmi'
	icon_state = "plastitanium_wall"
	base_icon_state = "plastitanium_wall"
	mineral = /obj/item/stack/sheet/mineral/plastitanium
	walltype = /turf/closed/wall/mineral/plastitanium
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_PLASTITANIUM_WALLS + SMOOTH_GROUP_TALL_WALLS
	canSmoothWith = SMOOTH_GROUP_PLASTITANIUM_WALLS

/obj/structure/falsewall/material
	name = "wall"
	desc = "A huge chunk of material used to separate rooms."
	fake_icon = 'icons/turf/walls/material_wall.dmi'
	icon_state = "material_wall"
	base_icon_state = "material_wall"
	walltype = /turf/closed/wall/material
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_WALLS + SMOOTH_GROUP_TALL_WALLS + SMOOTH_GROUP_CLOSED_TURFS + SMOOTH_GROUP_MATERIAL_WALLS
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

// wallening todo: does this work??
/obj/structure/falsewall/material/ChangeToWall(delete = 1)
	var/turf/current_turf = get_turf(src)
	var/turf/closed/wall/material/new_wall = current_turf.place_on_top(/turf/closed/wall/material)
	new_wall.set_custom_materials(custom_materials)
	if(delete)
		qdel(src)
	return current_turf

// Wallening todo: do we want this?
/*
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
*/


