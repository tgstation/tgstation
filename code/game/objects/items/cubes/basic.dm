// Basic random colors
/obj/item/cube/colorful
	name = "pretty cube"
	desc = "It's a wonderful shade of... whatever that is!"
	rarity = UNCOMMON_CUBE

/obj/item/cube/colorful/Initialize(mapload)
	. = ..()
	randcolor()

/obj/item/cube/colorful/isometric
	name = "isometric cube"
	desc = "Some madman turned this cube 45 degrees, now it looks all weird!"
	icon_state = "isometric"
	rarity = UNCOMMON_CUBE

/obj/item/cube/colorful/huge
	name = "huge cube"
	desc = "THAT is one BIG cube. It would probably hurt a lot if it fell on someone's head..."
	icon_state = "massive"
	rarity = RARE_CUBE
	w_class = WEIGHT_CLASS_HUGE

/obj/item/cube/colorful/huge/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/falling_hazard, damage = 15, wound_bonus = 5, hardhat_safety = FALSE, crushes = TRUE)

/obj/item/cube/colorful/voxel
	name = "voxel"
	desc = "Cubes just don't get any smaller."
	icon_state = "voxel"
	w_class = WEIGHT_CLASS_SMALL
	rarity = RARE_CUBE

/obj/item/cube/colorful/voxel/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/undertile, invisibility_trait = TRAIT_T_RAY_VISIBLE, invisibility_level = INVISIBILITY_OBSERVER, tilt_tile = TRUE)

/obj/item/cube/colorful/pixel
	name = "pixel"
	desc = "Technically a square, but close enough if you squint. Try not to lose it!"
	icon_state = "pixel"
	w_class = WEIGHT_CLASS_TINY
	rarity = EPIC_CUBE
	/// Who is holding the cube
	var/datum/weakref/owner
	/// Used for the render_target of the underfloor overlay
	var/obj/effect/abstract/underfloor_bulge/mob_alpha
	/// Held so we can remove it
	var/mutable_appearance/holder_overlay

/obj/item/cube/colorful/pixel/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/undertile, TRAIT_T_RAY_VISIBLE, INVISIBILITY_OBSERVER)
	RegisterSignal(src, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))

/obj/item/cube/colorful/pixel/Destroy(force)
	UnregisterSignal(src, COMSIG_MOVABLE_MOVED)
	handle_dropping()
	return ..()

/// Check if we were picked up by a mob, keep them as a weakref, and apply the undertile element to them
/obj/item/cube/colorful/pixel/proc/on_moved(atom/movable/source, atom/oldloc, direction, forced, list/old_locs)
	SIGNAL_HANDLER

	var/mob/living/existing_user = owner?.resolve()
	var/mob/living/carbon/human/holder = get_held_mob()
	if(existing_user)
		if(!holder)
			handle_dropping()
			return
		if(existing_user == holder)
			return
	else if(holder)
		if(!ishuman(holder))
			handle_dropping()
			return
		owner = WEAKREF(holder)
		holder_overlay = make_mutable_bulge_overlay(holder)
		holder.AddElement(/datum/element/undertile, invisibility_trait = TRAIT_T_RAY_VISIBLE, invisibility_level = INVISIBILITY_OBSERVER, use_anchor = TRUE, tile_overlay = holder_overlay)
		RegisterSignal(holder, COMSIG_OBJ_HIDE, PROC_REF(go_under))
		balloon_alert(holder, "you feel flatter")

/// For that "popping out of the floor" look
/obj/item/cube/colorful/pixel/proc/make_mutable_bulge_overlay(mob/user)
	// Needs to be a physical object for us to get its render_target
	// This has snowflake cases for mobs who's held/worn overlays are rendered strangely, but for /human/ subtypes it works fine
	// Sorry drones & gorillas :[.
	mob_alpha = new /obj/effect/abstract/underfloor_bulge(get_turf(src))
	mob_alpha.appearance = user.appearance
	mob_alpha.setDir(SOUTH)
	mob_alpha.mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	mob_alpha.render_target = "*undercube_[REF(user)]"

	var/mutable_appearance/owner_overlay = new(user.appearance)
	owner_overlay.setDir(SOUTH)
	owner_overlay.pixel_y = 2
	owner_overlay.add_filter("owner_overlay_color", 4, color_matrix_filter("#04080F19"))
	owner_overlay.add_filter("owner_overlay_alpha", 5, alpha_mask_filter(render_source = mob_alpha.render_target, y=2, flags = MASK_INVERSE))
	owner_overlay.add_filter("owner_overlay_dropshadow", 6, drop_shadow_filter(x=0.01, y=-2, size=1, offset=0.1, color="#04080F80"))
	return owner_overlay


// like [/dropped()] but only if it leaves the inventory
/obj/item/cube/colorful/pixel/proc/handle_dropping()
	var/mob/living/carbon/human/user = owner?.resolve()
	if(!user)
		return
	user.RemoveElement(/datum/element/undertile, invisibility_trait = TRAIT_T_RAY_VISIBLE, invisibility_level = INVISIBILITY_OBSERVER, use_anchor = TRUE, tile_overlay = holder_overlay)
	balloon_alert(user, "you feel less flat")
	UnregisterSignal(user, COMSIG_OBJ_HIDE)
	QDEL_NULL(mob_alpha)
	QDEL_NULL(holder_overlay)
	owner = null

/obj/item/cube/colorful/pixel/proc/go_under(atom/movable/source, underfloor_accessibility)
	SIGNAL_HANDLER

	var/mob/living/carbon/human/user = owner?.resolve()
	if(!user)
		return
	if(underfloor_accessibility < UNDERFLOOR_INTERACTABLE)
		if(mob_alpha)
			mob_alpha.forceMove(get_turf(user))

/obj/effect/abstract/underfloor_bulge
	name = "underfloor bulge"
	desc = "Assistant for visuals when a mob goes underfloor. You shouldn't be able to see this."
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE
	resistance_flags = INDESTRUCTIBLE


/obj/item/cube/colorful/plane
	name = "plane"
	desc = "A flattened cube."
	icon_state = "plane"
	rarity = UNCOMMON_CUBE

/obj/item/cube/colorful/plane/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/undertile, TRAIT_T_RAY_VISIBLE, INVISIBILITY_OBSERVER)

/obj/item/cube/colorful/meta
	name = "billboarded Cube"
	desc = "It's always facing directly towards the camera. Rude!"
	icon_state = "billboard"
	rarity = EPIC_CUBE

/obj/item/cube/colorful/meta/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/undertile, TRAIT_T_RAY_VISIBLE, INVISIBILITY_OBSERVER)

// Sphere [disgusting]
/obj/item/cube/colorful/sphere
	name = "sphere"
	desc = "I think I'm gonna be sick."
	icon_state = "sphere"
	rarity = LEGENDARY_CUBE

/obj/item/cube/colorful/sphere/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return .
	throw_at(get_edge_target_turf(src, get_dir(user, src)), 7, 1, user)
	user.do_attack_animation(src)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN


// Material cubes
/obj/item/cube/material
	name = "material cube"
	desc = "Before the invention of material silos, stations all over the galaxy used to store their materials in the form of ultra-dense cubes."
	w_class = WEIGHT_CLASS_SMALL
	material_flags = MATERIAL_EFFECTS | MATERIAL_ADD_PREFIX | MATERIAL_COLOR | MATERIAL_AFFECT_STATISTICS
	custom_materials = list()
	rarity = RARE_CUBE

/obj/item/cube/material/Initialize(mapload)
	name = "cube"
	var/datum/material/cube_mat = pick(GLOB.typecache_material)
	custom_materials[cube_mat] = max(SHEET_MATERIAL_AMOUNT * (1+(cube_mat.mineral_rarity/10)),1)
	give_random_icon()
	. = ..()

// Pill cubes
/obj/item/reagent_containers/applicator/pill/cube
	icon = 'icons/obj/cubes.dmi'
	icon_state = "pill_cube"
	fill_icon = 'icons/obj/cubes.dmi'
	fill_icon_thresholds = list(0)
	/// Pass for the component
	var/cube_rarity = COMMON_CUBE

/obj/item/reagent_containers/applicator/pill/cube/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/cuboid, cube_rarity = cube_rarity, ismapload = mapload)

/obj/item/reagent_containers/applicator/pill/cube/ice
	name = "ice cube"
	desc = "The most common form of recreational ice, rivaled only by skating rinks."
	icon_state = "small"
	list_reagents = list(/datum/reagent/consumable/ice = 15)
	// Hoping this means it won't melt when left out
	reagent_flags = NO_REACT
	alpha = 175
	cube_rarity = UNCOMMON_CUBE

/obj/item/reagent_containers/applicator/pill/cube/ice/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/slippery, knockdown = 1 SECONDS, lube_flags = NO_SLIP_WHEN_WALKING)

/obj/item/reagent_containers/applicator/pill/cube/sugar
	name = "sugar cube"
	desc = "Perfect for those who love a good cup of tea."
	icon_state = "small"
	list_reagents = list(/datum/reagent/consumable/sugar = 15)
	cube_rarity = UNCOMMON_CUBE

/obj/item/reagent_containers/applicator/pill/cube/salt
	name = "salt cube"
	desc = "Perfect for those who <span class='danger'>despise</span> a good cup of tea."
	icon_state = "small"
	list_reagents = list(/datum/reagent/consumable/salt = 15)
	cube_rarity = UNCOMMON_CUBE

/obj/item/reagent_containers/applicator/pill/cube/pepper
	name = "pepper cube"
	desc = "Perfect for those who want a <span class='sans'>really confusing</span> cup of tea."
	icon_state = "small"
	list_reagents = list(/datum/reagent/consumable/blackpepper = 15)
	cube_rarity = UNCOMMON_CUBE

/obj/item/reagent_containers/applicator/pill/cube/chili
	name = "chili pepper cube"
	desc = "Perfect for those who want a <span class='rose'>spicy</span> cup of tea."
	icon_state = "small"
	list_reagents = list(/datum/reagent/consumable/capsaicin = 15)
	cube_rarity = UNCOMMON_CUBE

/obj/item/reagent_containers/applicator/pill/cube/chilly
	name = "chilly pepper cube"
	desc = "Perfect for those who want a <span class='medradio'>freezing</span> cup of tea."
	icon_state = "small"
	list_reagents = list(/datum/reagent/consumable/frostoil = 15)
	cube_rarity = UNCOMMON_CUBE


// Stock part cubes
/obj/item/stock_parts/micro_laser/cubic
	name = "cubic micro-laser"
	icon_state = "quadultra_micro_laser"
	desc = "A tiny laser used in certain devices."
	rating = 5
	energy_rating = 10
	custom_materials = list(/datum/material/iron=SMALL_MATERIAL_AMOUNT*0.1, /datum/material/glass=SMALL_MATERIAL_AMOUNT*0.2)

/// Monkeycube subtypes
/obj/item/food/monkeycube/spaceman
	name = "spaceman cube"
	desc = "Did it just blink at you?"
	icon = 'icons/obj/cubes.dmi'
	icon_state = "spaceman"
	bite_consumption = 20
	food_reagents = list(
		/datum/reagent/consumable/liquidgibs = 30,
		/datum/reagent/medicine/strange_reagent = 1,
	)
	tastes = list("chicken" = 1, "an old lover" = 1, "iron" = 1)
	spawned_mob = /mob/living/carbon/human/monkeybrain

/obj/item/food/monkeycube/spaceman/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/cuboid, cube_rarity = EPIC_CUBE, ismapload = mapload)

/obj/item/food/monkeycube/spaceman/examine(mob/user)
	. = ..()
	. += span_tinynotice("The bottom says: <b>Just add water!</b>")

// So ffreracking souvvl.....
/obj/item/food/monkeycube/spessman
	name = "spessman cube"
	desc = "Where have you seen this before...?"
	icon = 'icons/obj/cubes.dmi'
	icon_state = "spessman"
	bite_consumption = 20
	food_reagents = list(
		/datum/reagent/medicine/omnizine = 30,
		/datum/reagent/medicine/strange_reagent = 1,
	)
	tastes = list("nostalgia" = 1, "sovl" = 1, "the good times" = 1)
	spawned_mob = /mob/living/basic/spaceman

/obj/item/food/monkeycube/spessman/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/cuboid, cube_rarity = LEGENDARY_CUBE, ismapload = mapload)

/obj/item/food/monkeycube/spessman/examine(mob/user)
	. = ..()
	. += span_tinynotice("The bottom says: <b>Just add water!</b>")
