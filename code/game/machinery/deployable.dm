#define SINGLE "single"
#define VERTICAL "vertical"
#define HORIZONTAL "horizontal"

#define METAL 1
#define WOOD 2
#define SAND 3

//Barricades/cover

/obj/structure/barricade
	name = "chest high wall"
	desc = "Looks like this would make good cover."
	anchored = TRUE
	density = TRUE
	max_integrity = 100
	// The probability for a projectile to pass through the barrier. Lower values result in less projectiles passing through.
	var/proj_pass_rate = 50
	// What type of material is our barricade made from?
	var/bar_material = METAL

/obj/structure/barricade/atom_deconstruct(disassembled = TRUE)
	make_debris()

/// Spawn debris & stuff upon deconstruction
/obj/structure/barricade/proc/make_debris()
	PROTECTED_PROC(TRUE)

	return

/obj/structure/barricade/welder_act(mob/living/user, obj/item/tool)
	if(user.combat_mode)
		return ITEM_INTERACT_SKIP_TO_ATTACK

	if(bar_material != METAL)
		return ITEM_INTERACT_BLOCKING

	if(atom_integrity >= max_integrity)
		balloon_alert(user, "already full integrity!")
		return ITEM_INTERACT_BLOCKING

	user.balloon_alert_to_viewers("repairing [src]...", "repairing...")

	if(!tool.use_tool(src, user, 4 SECONDS, amount = 10, volume=50))
		return ITEM_INTERACT_BLOCKING

	balloon_alert(user, "repaired")
	repair_damage(20)
	return ITEM_INTERACT_SUCCESS

/obj/structure/barricade/CanAllowThrough(atom/movable/mover, border_dir)//So bullets will fly over and stuff.
	. = ..()
	if(locate(/obj/structure/barricade) in get_turf(mover))
		return TRUE
	else if(isprojectile(mover))
		if(!anchored)
			return TRUE
		var/obj/projectile/proj = mover
		if(proj.firer && Adjacent(proj.firer))
			return TRUE
		if(prob(proj_pass_rate))
			return TRUE
		return FALSE

/////BARRICADE TYPES///////
/obj/structure/barricade/wooden
	name = "wooden barricade"
	desc = "This space is blocked off by a wooden barricade."
	icon = 'icons/obj/structures.dmi'
	icon_state = "woodenbarricade"
	resistance_flags = FLAMMABLE
	bar_material = WOOD
	/// When destroyed or deconstructed, how many planks of wood does our barricade drop? Also determines how many it takes to repair the barricade and by how much.
	var/drop_amount = 3

/obj/structure/barricade/wooden/Initialize(mapload)
	. = ..()

	var/static/list/tool_behaviors = list(TOOL_CROWBAR = list(SCREENTIP_CONTEXT_LMB = "Deconstruct"))
	AddElement(/datum/element/contextual_screentip_tools, tool_behaviors)
	register_context()

/obj/structure/barricade/wooden/item_interaction(mob/living/user, obj/item/stack/sheet/mineral/wood/our_wood, list/modifiers)
	if(user.combat_mode)
		return ITEM_INTERACT_SKIP_TO_ATTACK

	if(!istype(our_wood,/obj/item/stack/sheet/mineral/wood))
		return NONE

	if(our_wood.amount < 5)
		balloon_alert(user, "not enough wood!")
		to_chat(user, span_warning("You need at least five wooden planks to make a barricade!"))
		return ITEM_INTERACT_BLOCKING


	to_chat(user, span_notice("You start adding [our_wood] to [src]..."))
	playsound(src, 'sound/items/hammering_wood.ogg', 50, vary = TRUE)
	if(!do_after(user, 5 SECONDS, target=src))
		balloon_alert(user, "interrupted!")
		return ITEM_INTERACT_BLOCKING

	if(!our_wood.use(drop_amount))
		balloon_alert(user, "interrupted!")
		return ITEM_INTERACT_BLOCKING
	repair_damage(20 * drop_amount)
	return ITEM_INTERACT_SUCCESS

/obj/structure/barricade/wooden/crowbar_act(mob/living/user, obj/item/tool)
	balloon_alert(user, "deconstructing barricade...")
	if(!tool.use_tool(src, user, 2 SECONDS, volume=50))
		return
	loc.balloon_alert(user, "barricade deconstructed")
	tool.play_tool_sound(src)
	new /obj/item/stack/sheet/mineral/wood(get_turf(src), drop_amount)
	qdel(src)
	return ITEM_INTERACT_SUCCESS

/obj/structure/barricade/wooden/crude
	name = "crude plank barricade"
	desc = "This space is blocked off by a crude assortment of planks."
	icon_state = "plankbarricade"
	drop_amount = 1
	max_integrity = 50
	proj_pass_rate = 65
	layer = SIGN_LAYER

/obj/structure/barricade/wooden/crude/snow
	desc = "This space is blocked off by a crude assortment of planks. It seems to be covered in a layer of snow."
	icon_state = "plankbarricade_snow"
	max_integrity = 75

/obj/structure/barricade/wooden/make_debris()
	new /obj/item/stack/sheet/mineral/wood(get_turf(src), drop_amount)

/obj/structure/barricade/sandbags
	name = "sandbags"
	desc = "Bags of sand. Self explanatory."
	icon = 'icons/obj/smooth_structures/sandbags.dmi'
	icon_state = "sandbags-0"
	base_icon_state = "sandbags"
	max_integrity = 280
	proj_pass_rate = 20
	pass_flags_self = LETPASSTHROW
	bar_material = SAND
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_SANDBAGS
	canSmoothWith = SMOOTH_GROUP_SANDBAGS + SMOOTH_GROUP_SECURITY_BARRICADE + SMOOTH_GROUP_WALLS

/obj/structure/barricade/sandbags/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/climbable)
	AddElement(/datum/element/elevation, pixel_shift = 12)

/obj/structure/barricade/security
	name = "security barrier"
	desc = "A deployable barrier. Provides good cover in fire fights."
	icon = 'icons/obj/structures.dmi'
	icon_state = "barrier1"
	max_integrity = 180
	proj_pass_rate = 20
	armor_type = /datum/armor/barricade_security

/datum/armor/barricade_security
	melee = 10
	bullet = 50
	laser = 50
	energy = 50
	bomb = 10
	fire = 10

/obj/item/grenade/barrier
	name = "barrier grenade"
	desc = "Instant cover."
	icon = 'icons/obj/weapons/grenade.dmi'
	icon_state = "wallbang"
	inhand_icon_state = "flashbang"
	actions_types = list(/datum/action/item_action/toggle_barrier_spread)
	var/mode = SINGLE

/obj/item/grenade/barrier/examine(mob/user)
	. = ..()
	. += span_notice("Alt-click to toggle modes.")

/obj/item/grenade/barrier/click_alt(mob/living/carbon/user)
	toggle_mode(user)
	return CLICK_ACTION_SUCCESS

/obj/item/grenade/barrier/proc/toggle_mode(mob/user)
	switch(mode)
		if(SINGLE)
			mode = VERTICAL
		if(VERTICAL)
			mode = HORIZONTAL
		if(HORIZONTAL)
			mode = SINGLE

	to_chat(user, span_notice("[src] is now in [mode] mode."))

/obj/item/grenade/barrier/detonate(mob/living/lanced_by)
	. = ..()
	if(!.)
		return

	new /obj/structure/barricade/security(get_turf(src.loc))
	switch(mode)
		if(VERTICAL)
			var/turf/target_turf = get_step(src, NORTH)
			if(!target_turf.is_blocked_turf())
				new /obj/structure/barricade/security(target_turf)

			var/turf/target_turf2 = get_step(src, SOUTH)
			if(!target_turf2.is_blocked_turf())
				new /obj/structure/barricade/security(target_turf2)
		if(HORIZONTAL)
			var/turf/target_turf = get_step(src, EAST)
			if(!target_turf.is_blocked_turf())
				new /obj/structure/barricade/security(target_turf)

			var/turf/target_turf2 = get_step(src, WEST)
			if(!target_turf2.is_blocked_turf())
				new /obj/structure/barricade/security(target_turf2)
	qdel(src)

/obj/item/grenade/barrier/ui_action_click(mob/user)
	toggle_mode(user)

/obj/item/deployable_turret_folded
	name = "folded heavy machine gun"
	desc = "A folded and unloaded heavy machine gun, ready to be deployed and used."
	icon = 'icons/obj/weapons/turrets.dmi'
	icon_state = "folded_hmg"
	inhand_icon_state = "folded_hmg"
	max_integrity = 250
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK

/obj/item/deployable_turret_folded/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/deployable, 5 SECONDS, /obj/machinery/deployable_turret/hmg)

#undef SINGLE
#undef VERTICAL
#undef HORIZONTAL

#undef METAL
#undef WOOD
#undef SAND
