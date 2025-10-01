/* Tables and Racks
 * Contains:
 * Tables
 * Glass Tables
 * Wooden Tables
 * Reinforced Tables
 * Racks
 * Rack Parts
 */

/*
 * Tables
 */

/obj/structure/table
	name = "table"
	desc = "A square piece of iron standing on four metal legs. It can not move."
	icon = 'icons/obj/smooth_structures/table.dmi'
	icon_state = "table-0"
	base_icon_state = "table"
	density = TRUE
	anchored = TRUE
	pass_flags_self = PASSTABLE | LETPASSTHROW
	layer = TABLE_LAYER
	obj_flags = CAN_BE_HIT | IGNORE_DENSITY
	custom_materials = list(/datum/material/iron =SHEET_MATERIAL_AMOUNT)
	max_integrity = 100
	integrity_failure = 0.33
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = SMOOTH_GROUP_TABLES
	canSmoothWith = SMOOTH_GROUP_TABLES
	var/static/list/turf_traits = list(TRAIT_TURF_IGNORE_SLOWDOWN, TRAIT_TURF_IGNORE_SLIPPERY, TRAIT_IMMERSE_STOPPED)
	///a bit fucky, I know. but this is needed to get sorted on init smoothing groups stored
	var/list/on_init_smoothed_vars
	var/frame = /obj/structure/table_frame
	var/framestack = /obj/item/stack/rods
	var/glass_shard_type = /obj/item/shard
	var/buildstack = /obj/item/stack/sheet/iron
	var/busy = FALSE
	var/buildstackamount = 1
	var/framestackamount = 2
	var/deconstruction_ready = TRUE
	///Whether or not the table could be flipped or not
	var/can_flip = TRUE
	///Whether or not the table is flipped
	var/is_flipped = FALSE
	/// Whether or not when flipped, it ignores PASS_GLASS flag
	var/is_transparent = FALSE
	/// If you don't have sprites for flipped tables, you can use matrices instead. looks ever-slightly worse.
	var/use_matrices_instead = FALSE
	/// Matrix to return to on unflipping table
	var/matrix/before_flipped_matrix
	/// Do we place people onto the table rather than slamming them?
	var/slam_gently = FALSE
	/// Where icon is our flipped table located in?
	var/flipped_table_icon = 'icons/obj/flipped_tables.dmi'
	/// What sound does the table make when unflipped?
	var/unflip_table_sound = 'sound/items/trayhit/trayhit2.ogg'
	/// What sound does the table make when we flip the table?
	var/flipped_table_sound = 'sound/items/trayhit/trayhit1.ogg'

/obj/structure/table/Initialize(mapload, obj/structure/table_frame/frame_used, obj/item/stack/stack_used)
	. = ..()
	if(frame_used)
		apply_frame_properties(frame_used)
	if(stack_used)
		apply_stack_properties(stack_used)

	before_flipped_matrix = transform
	on_init_smoothed_vars = list(smoothing_groups, canSmoothWith)

	var/static/list/loc_connections = list(
		COMSIG_ATOM_EXIT = PROC_REF(on_exit),
	)

	AddElement(/datum/element/connect_loc, loc_connections)
	register_context()

	if(can_flip)
		AddElement( \
			/datum/element/contextual_screentip_bare_hands, \
			rmb_text = "Flip", \
		)

	ADD_TRAIT(src, TRAIT_COMBAT_MODE_SKIP_INTERACTION, INNATE_TRAIT)

	if(can_flip && is_flipped)
		flip_table(dir)
		return

	make_climbable()
	AddElement(/datum/element/give_turf_traits, string_list(turf_traits))
	AddElement(/datum/element/footstep_override, priority = STEP_SOUND_TABLE_PRIORITY)
	AddComponent(/datum/component/table_smash, gentle_push = slam_gently, after_smash = CALLBACK(src, PROC_REF(after_smash)))

/// Called after someone is harmfully smashed into us
/obj/structure/table/proc/after_smash(mob/living/smashed)
	return // This is mostly for our children

/// Applies additional properties based on the frame used to construct this table.
/obj/structure/table/proc/apply_frame_properties(obj/structure/table_frame/frame_used)
	frame = frame_used.type
	framestack = frame_used.framestack
	framestackamount = frame_used.framestackamount

/// Applies additional properties based on the stack used to construct this table.
/obj/structure/table/proc/apply_stack_properties(obj/item/stack/stack_used)
	return

///Adds the element used to make the object climbable, and also the one that shift the mob buckled to it up.
/obj/structure/table/proc/make_climbable()
	AddComponent(/datum/component/climb_walkable)
	AddElement(/datum/element/climbable)
	AddElement(/datum/element/elevation, pixel_shift = 12)

//proc that adds elements present in normal tables
/obj/structure/table/proc/unflip_table()
	playsound(src, unflip_table_sound, 100)
	make_climbable()
	AddElement(/datum/element/give_turf_traits, turf_traits)
	AddElement(/datum/element/footstep_override, priority = STEP_SOUND_TABLE_PRIORITY)
	//resets vars from table being flipped
	layer = TABLE_LAYER
	smoothing_flags |= SMOOTH_BITMASK
	pass_flags_self |= PASSTABLE
	if(use_matrices_instead)
		animate(src, transform = before_flipped_matrix, time = 0)
	else
		icon = initial(icon)
	icon_state = initial(icon_state)
	smoothing_groups = on_init_smoothed_vars[1]
	canSmoothWith = on_init_smoothed_vars[2]
	update_appearance()
	is_flipped = FALSE

//proc that removes elements present in now-flipped tables
/obj/structure/table/proc/flip_table(new_dir = SOUTH)
	playsound(src, flipped_table_sound, 100)
	qdel(GetComponent(/datum/component/climb_walkable))
	RemoveElement(/datum/element/climbable)
	RemoveElement(/datum/element/footstep_override, priority = STEP_SOUND_TABLE_PRIORITY)
	RemoveElement(/datum/element/give_turf_traits, turf_traits)
	RemoveElement(/datum/element/elevation, pixel_shift = 12)

	//change icons
	layer = LOW_ITEM_LAYER
	if(new_dir & EAST) // Dirs need to be part of the 4 main cardinal directions so proc/CanAllowThrough isn't fucky wucky
		new_dir = EAST
	else if(new_dir & WEST)
		new_dir = WEST
	dir = new_dir
	if(new_dir == SOUTH)
		layer = ABOVE_MOB_LAYER

	var/turf/throw_target = get_step(src, src.dir)
	if(!isnull(throw_target))
		for(var/atom/movable/movable_entity in src.loc)
			if(is_able_to_throw(src, movable_entity))
				movable_entity.safe_throw_at(throw_target, range = 1, speed = 1, force = MOVE_FORCE_NORMAL, gentle = TRUE)

	smoothing_flags &= ~SMOOTH_BITMASK
	smoothing_groups = null
	canSmoothWith = null
	pass_flags_self &= ~PASSTABLE

	if(use_matrices_instead)
		icon_state = initial(icon_state)
		before_flipped_matrix = transform
		var/matrix/transform_matrix = matrix(1, 0, 0, 0, 0.350, 9) // "flips" the table
		//there's probably a nicer way to do this but whatever. rotates the table according to the dir
		if(dir == EAST)
			transform_matrix.Turn(90)
		if(dir == SOUTH)
			transform_matrix.Turn(180)
		if(dir == WEST)
			transform_matrix.Turn(270)
		animate(src, transform = transform_matrix, time = 0)
	else
		icon = flipped_table_icon
		icon_state = base_icon_state

	update_appearance()
	QUEUE_SMOOTH_NEIGHBORS(src)

	is_flipped = TRUE

/obj/structure/table/add_context(atom/source, list/context, obj/item/held_item, mob/living/user)
	. = ..()

	if(isnull(held_item))
		return NONE

	if(istype(held_item, /obj/item/toy/cards/deck))
		var/obj/item/toy/cards/deck/dealer_deck = held_item
		if(HAS_TRAIT(dealer_deck, TRAIT_WIELDED))
			context[SCREENTIP_CONTEXT_LMB] = "Deal card"
			context[SCREENTIP_CONTEXT_RMB] = "Deal card faceup"
			. = CONTEXTUAL_SCREENTIP_SET

	if(deconstruction_ready)
		if(held_item.tool_behaviour == TOOL_SCREWDRIVER)
			context[SCREENTIP_CONTEXT_RMB] = "Disassemble"
			. = CONTEXTUAL_SCREENTIP_SET
		if(held_item.tool_behaviour == TOOL_WRENCH)
			context[SCREENTIP_CONTEXT_RMB] = "Deconstruct"
			. = CONTEXTUAL_SCREENTIP_SET

	return . || NONE

/obj/structure/table/examine(mob/user)
	. = ..()
	if(is_flipped)
		. += span_notice("It's been flipped on its side!")
	. += deconstruction_hints(user)

/obj/structure/table/proc/deconstruction_hints(mob/user)
	return span_notice("The top is <b>screwed</b> on, but the main <b>bolts</b> are also visible.")

/obj/structure/table/proc/on_exit(datum/source, atom/movable/leaving, direction)
	SIGNAL_HANDLER
	if(!is_flipped)
		return

	if(leaving.movement_type & PHASING)
		return

	if(leaving == src)
		return
	if(is_transparent) //Glass table, jolly ranchers pass
		if(istype(leaving) && (leaving.pass_flags & PASSGLASS))
			return

	if(istype(leaving, /obj/projectile))
		return

	if(direction == dir)
		leaving.Bump(src)
		return COMPONENT_ATOM_BLOCK_EXIT

/obj/structure/table/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(.)
		return

	if(!is_flipped)
		return FALSE

	if(is_transparent) //Glass table, jolly ranchers pass
		if(istype(mover) && (mover.pass_flags & PASSGLASS))
			return TRUE
	if(isprojectile(mover))
		var/obj/projectile/proj = mover
		//Lets through bullets shot from behind the cover of the table
		if(proj.movement_vector && angle2dir_cardinal(proj.movement_vector.angle) == dir)
			return TRUE
		return FALSE
	if(border_dir == dir)
		return FALSE

	return TRUE

/obj/structure/table/update_icon(updates=ALL)
	. = ..()
	if((updates & UPDATE_SMOOTHING) && (smoothing_flags & USES_SMOOTHING))
		QUEUE_SMOOTH(src)
		QUEUE_SMOOTH_NEIGHBORS(src)

/obj/structure/table/narsie_act()
	var/atom/A = loc
	qdel(src)
	new /obj/structure/table/wood(A)

/obj/structure/table/attack_paw(mob/user, list/modifiers)
	return attack_hand(user, modifiers)

/obj/structure/table/attack_hand(mob/living/user, list/modifiers)
	if(is_flipped)
		return
	return ..()

/obj/structure/table/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if (. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return

	if(!istype(user) || !user.can_interact_with(src))
		return

	if(!can_flip)
		return

	var/interaction_key = "table_flip_[REF(src)]"
	if(!is_flipped)
		if(!LAZYACCESS(user.do_afters, interaction_key)) // To avoid balloon alert spam
			user.balloon_alert_to_viewers("flipping table...")
		if(do_after(user, max_integrity * 0.25, src, interaction_key = interaction_key))
			flip_table(get_dir(user, src))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	if(!LAZYACCESS(user.do_afters, interaction_key)) // To avoid balloon alert spam
		user.balloon_alert_to_viewers("flipping table upright...")
	if(do_after(user, max_integrity * 0.25, src, interaction_key = interaction_key))
		unflip_table()
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/structure/table/proc/is_able_to_throw(obj/structure/table, atom/movable/movable_entity)
	if (movable_entity == table) //Thing is not the table
		return FALSE
	if (movable_entity.anchored) //Thing isn't anchored
		return FALSE
	if(!isliving(movable_entity) && !isobj(movable_entity)) //Thing isn't an obj or mob
		return FALSE
	if(movable_entity.throwing || (movable_entity.movement_type & (FLOATING|FLYING)) || HAS_TRAIT(movable_entity, TRAIT_IGNORE_ELEVATION)) //Thing isn't flying/floating
		return FALSE

	return TRUE

/obj/structure/table/attack_tk(mob/user)
	return

/obj/structure/table/CanAStarPass(to_dir, datum/can_pass_info/pass_info)
	if(!density)
		return TRUE
	if(pass_info.pass_flags & PASSTABLE)
		return TRUE
	return FALSE

/obj/structure/table/screwdriver_act_secondary(mob/living/user, obj/item/tool)
	if(!deconstruction_ready)
		return NONE
	to_chat(user, span_notice("You start disassembling [src]..."))
	if(tool.use_tool(src, user, 2 SECONDS, volume=50))
		deconstruct(TRUE)
	return ITEM_INTERACT_SUCCESS

/obj/structure/table/wrench_act_secondary(mob/living/user, obj/item/tool)
	if(!deconstruction_ready)
		return NONE
	to_chat(user, span_notice("You start deconstructing [src]..."))
	if(tool.use_tool(src, user, 4 SECONDS, volume=50))
		playsound(loc, 'sound/items/deconstruct.ogg', 50, TRUE)
		frame = null
		deconstruct(TRUE)
	return ITEM_INTERACT_SUCCESS

// This extends base item interaction because tables default to blocking 99% of interactions
/obj/structure/table/base_item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	. = ..()
	if(.)
		return .

	if(is_flipped)
		return .

	if(istype(tool, /obj/item/toy/cards/deck))
		. = deck_act(user, tool, modifiers, !!LAZYACCESS(modifiers, RIGHT_CLICK))
	if(istype(tool, /obj/item/storage/bag/tray))
		. = tray_act(user, tool)

	// Continue to placing if we don't do anything else
	if(.)
		return .

	if(!user.combat_mode || (tool.item_flags & NOBLUDGEON))
		return table_place_act(user, tool, modifiers)

	return NONE

/obj/structure/table/proc/tray_act(mob/living/user, obj/item/storage/bag/tray/used_tray)
	if(used_tray.contents.len <= 0)
		return NONE // If the tray IS empty, continue on (tray will be placed on the table like other items)

	for(var/obj/item/thing in used_tray.contents)
		AfterPutItemOnTable(thing, user)
	used_tray.atom_storage.remove_all(drop_location())
	user.visible_message(span_notice("[user] empties [used_tray] on [src]."))
	return ITEM_INTERACT_SUCCESS

/obj/structure/table/proc/deck_act(mob/living/user, obj/item/toy/cards/deck/dealer_deck, list/modifiers, flip)
	if(!HAS_TRAIT(dealer_deck, TRAIT_WIELDED))
		return NONE

	var/obj/item/toy/singlecard/card = dealer_deck.draw(user)
	if(isnull(card))
		return ITEM_INTERACT_BLOCKING
	if(flip)
		card.Flip()
	return table_place_act(user, card, modifiers)

// Where putting things on tables is handled.
/obj/structure/table/proc/table_place_act(mob/living/user, obj/item/tool, list/modifiers)
	if(tool.item_flags & ABSTRACT)
		return NONE

	var/x_offset = 0
	var/y_offset = 0
	// Items are centered by default, but we move them if click ICON_X and ICON_Y are available
	if(LAZYACCESS(modifiers, ICON_X) && LAZYACCESS(modifiers, ICON_Y))
		// Clamp it so that the icon never moves more than 16 pixels in either direction (thus leaving the table turf)
		x_offset = clamp(text2num(LAZYACCESS(modifiers, ICON_X)) - 16, -(ICON_SIZE_X*0.5), ICON_SIZE_X*0.5)
		y_offset = clamp(text2num(LAZYACCESS(modifiers, ICON_Y)) - 16, -(ICON_SIZE_Y*0.5), ICON_SIZE_Y*0.5)

	if(!user.transfer_item_to_turf(tool, get_turf(src), x_offset, y_offset, silent = FALSE))
		return ITEM_INTERACT_BLOCKING
	AfterPutItemOnTable(tool, user)
	return ITEM_INTERACT_SUCCESS

/obj/structure/table/proc/AfterPutItemOnTable(obj/item/thing, mob/living/user)
	return

/obj/structure/table/atom_deconstruct(disassembled = TRUE)
	var/turf/target_turf = get_turf(src)
	if(buildstack)
		new buildstack(target_turf, buildstackamount)
	else
		for(var/datum/material/mat in custom_materials)
			new mat.sheet_type(target_turf, FLOOR(custom_materials[mat] / SHEET_MATERIAL_AMOUNT, 1))

	if(frame)
		new frame(target_turf)
	else
		new framestack(get_turf(src), framestackamount)

/obj/structure/table/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	if(the_rcd.mode == RCD_DECONSTRUCT)
		return list("delay" = 2.4 SECONDS, "cost" = 16)
	return FALSE

/obj/structure/table/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, list/rcd_data)
	if(rcd_data["[RCD_DESIGN_MODE]"] == RCD_DECONSTRUCT)
		qdel(src)
		return TRUE
	return FALSE

/obj/structure/table/greyscale
	icon = 'icons/obj/smooth_structures/table_greyscale.dmi'
	icon_state = "table_greyscale-0"
	base_icon_state = "table_greyscale"
	material_flags = MATERIAL_EFFECTS | MATERIAL_ADD_PREFIX | MATERIAL_COLOR | MATERIAL_AFFECT_STATISTICS
	buildstack = null //No buildstack, so generate from mat datums

/obj/structure/table/greyscale/apply_stack_properties(obj/item/stack/stack_used)
	if(!stack_used.material_type)
		return
	set_custom_materials(list(stack_used.material_type = SHEET_MATERIAL_AMOUNT))

/obj/structure/table/greyscale/finalize_material_effects(list/materials)
	. = ..()
	var/english_list = get_material_english_list(materials)
	desc = "A square [(length(materials) > 1) ? "amalgamation" : "piece"] of [english_list] on four legs. It can not move."

///Table on wheels
/obj/structure/table/rolling
	name = "Rolling table"
	desc = "An NT brand \"Rolly poly\" rolling table. It can and will move."
	anchored = FALSE
	smoothing_flags = NONE
	smoothing_groups = null
	canSmoothWith = null
	icon = 'icons/obj/smooth_structures/rollingtable.dmi'
	icon_state = "rollingtable"
	/// Lazylist of the items that we have on our surface.
	var/list/attached_items = null
	can_flip = FALSE

/obj/structure/table/rolling/Initialize(mapload, obj/structure/table_frame/frame_used, obj/item/stack/stack_used)
	. = ..()
	AddElement(/datum/element/noisy_movement)

/obj/structure/table/rolling/Destroy()
	for(var/item in attached_items)
		clear_item_reference(item)
	LAZYNULL(attached_items) // safety
	return ..()

/obj/structure/table/rolling/item_interaction(mob/living/user, obj/item/rolling_table_dock/rable, list/modifiers)
	. = NONE
	if(!istype(rable))
		return

	if(rable.loaded)
		to_chat(user, span_warning("You already have \a [rable.loaded] docked!"))
		return ITEM_INTERACT_FAILURE

	if(locate(/mob/living) in loc.get_all_contents())
		to_chat(user, span_warning("You can't collect \the [src] with that much on top!"))
		return ITEM_INTERACT_FAILURE

	rable.loaded = src
	forceMove(rable)
	user.visible_message(span_notice("[user] collects \the [src]."), span_notice("You collect \the [src]."))
	return ITEM_INTERACT_SUCCESS

/obj/structure/table/rolling/AfterPutItemOnTable(obj/item/thing, mob/living/user)
	. = ..()
	LAZYADD(attached_items, thing)
	RegisterSignal(thing, COMSIG_MOVABLE_MOVED, PROC_REF(on_item_moved))

/// Handles cases where any attached item moves, with or without the table. If we get picked up or anything, unregister the signal so we don't move with the table after removal from the surface.
/obj/structure/table/rolling/proc/on_item_moved(datum/source, atom/old_loc, dir, forced, list/old_locs, momentum_change)
	SIGNAL_HANDLER

	var/atom/thing = source // let it runtime if it doesn't work because that is mad wack
	if(thing.loc == loc) // if we move with the table, move on
		return

	clear_item_reference(thing)

/// Handles movement of the table itself, as well as moving along any atoms we have on our surface.
/obj/structure/table/rolling/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()

	if(isnull(loc)) // aw hell naw
		return

	for(var/mob/living/living_mob in old_loc.contents)//Kidnap everyone on top
		living_mob.forceMove(loc)

	for(var/atom/movable/attached_movable as anything in attached_items)
		if(!attached_movable.Move(loc)) // weird
			clear_item_reference(attached_movable) // we check again in on_item_moved() just in case something's wacky tobaccy

/// Removes the signal and the entrance from the list.
/obj/structure/table/rolling/proc/clear_item_reference(obj/item/thing)
	UnregisterSignal(thing, COMSIG_MOVABLE_MOVED)
	LAZYREMOVE(attached_items, thing)

/*
 * Glass tables
 */
/obj/structure/table/glass
	name = "glass table"
	desc = "What did I say about leaning on the glass tables? Now you need surgery."
	icon = 'icons/obj/smooth_structures/glass_table.dmi'
	icon_state = "glass_table-0"
	base_icon_state = "glass_table"
	custom_materials = list(/datum/material/glass = SHEET_MATERIAL_AMOUNT)
	buildstack = /obj/item/stack/sheet/glass
	smoothing_groups = SMOOTH_GROUP_GLASS_TABLES
	canSmoothWith = SMOOTH_GROUP_GLASS_TABLES
	max_integrity = 70
	resistance_flags = ACID_PROOF
	armor_type = /datum/armor/table_glass

/datum/armor/table_glass
	fire = 80
	acid = 100

/obj/structure/table/glass/Initialize(mapload, obj/structure/table_frame/frame_used, obj/item/stack/stack_used)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/structure/table/glass/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER

	if(!isliving(AM))
		return
	// Don't break if they're just flying past
	if(AM.throwing)
		addtimer(CALLBACK(src, PROC_REF(throw_check), AM), 0.5 SECONDS)
	else
		check_break(AM)

/obj/structure/table/glass/proc/throw_check(mob/living/M)
	if(M.loc == get_turf(src))
		check_break(M)

/obj/structure/table/glass/proc/check_break(mob/living/M)
	if(is_flipped)
		return FALSE
	if(M.has_gravity() && M.mob_size > MOB_SIZE_SMALL && !(M.movement_type & MOVETYPES_NOT_TOUCHING_GROUND))
		table_shatter(M)

/obj/structure/table/glass/proc/table_shatter(mob/living/victim)
	visible_message(span_warning("[src] breaks!"),
		span_danger("You hear breaking glass."))

	playsound(loc, SFX_SHATTER, 50, TRUE)

	new frame(loc)

	var/obj/item/shard/shard = new glass_shard_type(loc)
	shard.throw_impact(victim)

	victim.Paralyze(100)
	qdel(src)

/obj/structure/table/glass/atom_deconstruct(disassembled = TRUE)
	if(disassembled)
		..()
		return
	else
		var/turf/T = get_turf(src)
		playsound(T, SFX_SHATTER, 50, TRUE)

		new frame(loc)
		new glass_shard_type(loc)

/obj/structure/table/glass/narsie_act()
	color = NARSIE_WINDOW_COLOUR

/obj/structure/table/glass/plasmaglass
	name = "plasma glass table"
	desc = "Someone thought this was a good idea."
	icon = 'icons/obj/smooth_structures/plasmaglass_table.dmi'
	icon_state = "plasmaglass_table-0"
	base_icon_state = "plasmaglass_table"
	custom_materials = list(/datum/material/alloy/plasmaglass = SHEET_MATERIAL_AMOUNT)
	buildstack = /obj/item/stack/sheet/plasmaglass
	glass_shard_type = /obj/item/shard/plasma
	max_integrity = 100

/*
 * Wooden tables
 */

/obj/structure/table/wood
	name = "wooden table"
	desc = "Do not apply fire to this. Rumour says it burns easily."
	icon = 'icons/obj/smooth_structures/wood_table.dmi'
	icon_state = "wood_table-0"
	base_icon_state = "wood_table"
	frame = /obj/structure/table_frame/wood
	framestack = /obj/item/stack/sheet/mineral/wood
	buildstack = /obj/item/stack/sheet/mineral/wood
	resistance_flags = FLAMMABLE
	max_integrity = 70
	smoothing_groups = SMOOTH_GROUP_WOOD_TABLES //Don't smooth with SMOOTH_GROUP_TABLES
	canSmoothWith = SMOOTH_GROUP_WOOD_TABLES
	custom_materials = list(/datum/material/wood = SHEET_MATERIAL_AMOUNT)

/obj/structure/table/wood/after_smash(mob/living/smashed)
	if(QDELETED(src) || prob(66))
		return
	visible_message(
		span_warning("[src] smashes into bits!"),
		blind_message = span_hear("You hear the loud cracking of wood being split."),
	)

	playsound(src, 'sound/effects/wounds/crack2.ogg', 50, TRUE)
	smashed.Knockdown(10 SECONDS)
	smashed.Paralyze(2 SECONDS)
	smashed.apply_damage(20, BRUTE)
	deconstruct(FALSE)

/obj/structure/table/wood/narsie_act(total_override = TRUE)
	if(!total_override)
		..()

/obj/structure/table/wood/poker //No specialties, Just a mapping object.
	name = "gambling table"
	desc = "A seedy table for seedy dealings in seedy places."
	icon = 'icons/obj/smooth_structures/poker_table.dmi'
	icon_state = "poker_table-0"
	base_icon_state = "poker_table"
	buildstack = /obj/item/stack/tile/carpet

/obj/structure/table/wood/poker/apply_stack_properties(obj/item/stack/stack_used)
	buildstack = stack_used.type

/obj/structure/table/wood/poker/narsie_act()
	..(FALSE)

/obj/structure/table/wood/fancy
	name = "fancy table"
	desc = "A standard metal table frame covered with an amazingly fancy, patterned cloth."
	icon = 'icons/obj/smooth_structures/fancy_table.dmi'
	icon_state = "fancy_table-0"
	base_icon_state = "fancy_table"
	frame = /obj/structure/table_frame
	framestack = /obj/item/stack/rods
	buildstack = /obj/item/stack/tile/carpet
	smoothing_groups = SMOOTH_GROUP_FANCY_WOOD_TABLES //Don't smooth with SMOOTH_GROUP_TABLES or SMOOTH_GROUP_WOOD_TABLES
	canSmoothWith = SMOOTH_GROUP_FANCY_WOOD_TABLES

/obj/structure/table/wood/fancy/Initialize(mapload, obj/structure/table_frame/frame_used, obj/item/stack/stack_used)
	. = ..()
	// Needs to be set dynamically because table smooth sprites are 32x34,
	// which the editor treats as a two-tile-tall object. The sprites are that
	// size so that the north/south corners look nice - examine the detail on
	// the sprites in the editor to see why.

/obj/structure/table/wood/fancy/apply_stack_properties(obj/item/stack/stack_used)
	buildstack = stack_used.type

/obj/structure/table/wood/fancy/black
	icon_state = "fancy_table_black-0"
	base_icon_state = "fancy_table_black"
	buildstack = /obj/item/stack/tile/carpet/black
	icon = 'icons/obj/smooth_structures/fancy_table_black.dmi'

/obj/structure/table/wood/fancy/blue
	icon_state = "fancy_table_blue-0"
	base_icon_state = "fancy_table_blue"
	buildstack = /obj/item/stack/tile/carpet/blue
	icon = 'icons/obj/smooth_structures/fancy_table_blue.dmi'

/obj/structure/table/wood/fancy/cyan
	icon_state = "fancy_table_cyan-0"
	base_icon_state = "fancy_table_cyan"
	buildstack = /obj/item/stack/tile/carpet/cyan
	icon = 'icons/obj/smooth_structures/fancy_table_cyan.dmi'

/obj/structure/table/wood/fancy/green
	icon_state = "fancy_table_green-0"
	base_icon_state = "fancy_table_green"
	buildstack = /obj/item/stack/tile/carpet/green
	icon = 'icons/obj/smooth_structures/fancy_table_green.dmi'

/obj/structure/table/wood/fancy/orange
	icon_state = "fancy_table_orange-0"
	base_icon_state = "fancy_table_orange"
	buildstack = /obj/item/stack/tile/carpet/orange
	icon = 'icons/obj/smooth_structures/fancy_table_orange.dmi'

/obj/structure/table/wood/fancy/purple
	icon_state = "fancy_table_purple-0"
	base_icon_state = "fancy_table_purple"
	buildstack = /obj/item/stack/tile/carpet/purple
	icon = 'icons/obj/smooth_structures/fancy_table_purple.dmi'

/obj/structure/table/wood/fancy/red
	icon_state = "fancy_table_red-0"
	base_icon_state = "fancy_table_red"
	buildstack = /obj/item/stack/tile/carpet/red
	icon = 'icons/obj/smooth_structures/fancy_table_red.dmi'

/obj/structure/table/wood/fancy/royalblack
	icon_state = "fancy_table_royalblack-0"
	base_icon_state = "fancy_table_royalblack"
	buildstack = /obj/item/stack/tile/carpet/royalblack
	icon = 'icons/obj/smooth_structures/fancy_table_royalblack.dmi'

/obj/structure/table/wood/fancy/royalblue
	icon_state = "fancy_table_royalblue-0"
	base_icon_state = "fancy_table_royalblue"
	buildstack = /obj/item/stack/tile/carpet/royalblue
	icon = 'icons/obj/smooth_structures/fancy_table_royalblue.dmi'

/*
 * Reinforced tables
 */
/obj/structure/table/reinforced
	name = "reinforced table"
	desc = "A reinforced version of the four legged table."
	icon = 'icons/obj/smooth_structures/reinforced_table.dmi'
	icon_state = "reinforced_table-0"
	base_icon_state = "reinforced_table"
	deconstruction_ready = FALSE
	buildstack = /obj/item/stack/sheet/plasteel
	max_integrity = 200
	integrity_failure = 0.25
	armor_type = /datum/armor/table_reinforced
	can_flip = FALSE

/datum/armor/table_reinforced
	melee = 10
	bullet = 30
	laser = 30
	energy = 100
	bomb = 20
	fire = 80
	acid = 70

/obj/structure/table/reinforced/add_context(atom/source, list/context, obj/item/held_item, mob/living/user)
	. = ..()

	if(isnull(held_item))
		return NONE

	if(held_item.tool_behaviour == TOOL_WELDER)
		context[SCREENTIP_CONTEXT_RMB] = deconstruction_ready ? "Strengthen" : "Weaken"
		. = CONTEXTUAL_SCREENTIP_SET

	return . || NONE

/obj/structure/table/reinforced/deconstruction_hints(mob/user)
	if(deconstruction_ready)
		return span_notice("The top cover has been <i>welded</i> loose and the main frame's <b>bolts</b> are exposed.")
	else
		return span_notice("The top cover is firmly <b>welded</b> on.")

/obj/structure/table/reinforced/welder_act_secondary(mob/living/user, obj/item/tool)
	if(tool.tool_start_check(user, amount = 0))
		if(attempt_electrocution(user))
			return ITEM_INTERACT_BLOCKING

		if(deconstruction_ready)
			to_chat(user, span_notice("You start strengthening the reinforced table..."))
			if (tool.use_tool(src, user, 50, volume = 50))
				to_chat(user, span_notice("You strengthen the table."))
				deconstruction_ready = FALSE
				return ITEM_INTERACT_SUCCESS
		else
			to_chat(user, span_notice("You start weakening the reinforced table..."))
			if (tool.use_tool(src, user, 50, volume = 50))
				to_chat(user, span_notice("You weaken the table."))
				deconstruction_ready = TRUE
				return ITEM_INTERACT_SUCCESS
	return ITEM_INTERACT_BLOCKING

/obj/structure/table/reinforced/item_interaction_secondary(mob/living/user, obj/item/tool, list/modifiers)
	if(tool.tool_behaviour == TOOL_WELDER)
		return NONE

	return ..()

/obj/structure/table/reinforced/screwdriver_act_secondary(mob/living/user, obj/item/tool)
	if(deconstruction_ready && attempt_electrocution(user))
		return ITEM_INTERACT_BLOCKING
	return ..()

/obj/structure/table/reinforced/wrench_act_secondary(mob/living/user, obj/item/tool)
	if(deconstruction_ready && attempt_electrocution(user))
		return ITEM_INTERACT_BLOCKING
	return ..()

/// Attempts to shock the user, given the table is hooked up and they're within range.
/// Returns TRUE on successful electrocution, FALSE otherwise.
/obj/structure/table/reinforced/proc/attempt_electrocution(mob/user)
	if(!anchored) // If for whatever reason it's not anchored, it can't be shocked either.
		return FALSE
	if(!in_range(src, user)) // To prevent TK and mech users from getting shocked.
		return FALSE

	var/turf/our_turf = get_turf(src)
	if(our_turf.overfloor_placed) // Can't have a floor in the way.
		return FALSE

	var/obj/structure/cable/cable_node = our_turf.get_cable_node()
	if(isnull(cable_node))
		return FALSE
	if(!electrocute_mob(user, cable_node, src, 1, TRUE))
		return FALSE

	var/datum/effect_system/spark_spread/sparks = new /datum/effect_system/spark_spread
	sparks.set_up(3, TRUE, src)
	sparks.start()

	return TRUE

/obj/structure/table/bronze
	name = "bronze table"
	desc = "A solid table made out of bronze."
	icon = 'icons/obj/smooth_structures/brass_table.dmi'
	icon_state = "brass_table-0"
	base_icon_state = "brass_table"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	buildstack = /obj/item/stack/sheet/bronze
	smoothing_groups = SMOOTH_GROUP_BRONZE_TABLES //Don't smooth with SMOOTH_GROUP_TABLES
	canSmoothWith = SMOOTH_GROUP_BRONZE_TABLES
	can_flip = FALSE

/obj/structure/table/bronze/after_smash(mob/living/pushed_mob)
	playsound(src, 'sound/effects/magic/clockwork/fellowship_armory.ogg', 50, TRUE)

/obj/structure/table/reinforced/rglass
	name = "reinforced glass table"
	desc = "A reinforced version of the glass table."
	icon = 'icons/obj/smooth_structures/rglass_table.dmi'
	icon_state = "rglass_table-0"
	base_icon_state = "rglass_table"
	custom_materials = list(/datum/material/glass = SHEET_MATERIAL_AMOUNT, /datum/material/iron = SHEET_MATERIAL_AMOUNT)
	buildstack = /obj/item/stack/sheet/rglass
	max_integrity = 150

/obj/structure/table/reinforced/plasmarglass
	name = "reinforced plasma glass table"
	desc = "A reinforced version of the plasma glass table."
	icon = 'icons/obj/smooth_structures/rplasmaglass_table.dmi'
	icon_state = "rplasmaglass_table-0"
	base_icon_state = "rplasmaglass_table"
	custom_materials = list(/datum/material/alloy/plasmaglass = SHEET_MATERIAL_AMOUNT, /datum/material/iron = SHEET_MATERIAL_AMOUNT)
	buildstack = /obj/item/stack/sheet/plasmarglass

/obj/structure/table/reinforced/titaniumglass
	name = "titanium glass table"
	desc = "A titanium reinforced glass table, with a fresh coat of NT white paint."
	icon = 'icons/obj/smooth_structures/titaniumglass_table.dmi'
	icon_state = "titaniumglass_table-0"
	base_icon_state = "titaniumglass_table"
	custom_materials = list(/datum/material/alloy/titaniumglass = SHEET_MATERIAL_AMOUNT)
	buildstack = /obj/item/stack/sheet/titaniumglass
	max_integrity = 250

/obj/structure/table/reinforced/plastitaniumglass
	name = "plastitanium glass table"
	desc = "A table made of titanium reinforced silica-plasma composite. About as durable as it sounds."
	icon = 'icons/obj/smooth_structures/plastitaniumglass_table.dmi'
	icon_state = "plastitaniumglass_table-0"
	base_icon_state = "plastitaniumglass_table"
	custom_materials = list(/datum/material/alloy/plastitaniumglass = SHEET_MATERIAL_AMOUNT)
	buildstack = /obj/item/stack/sheet/plastitaniumglass
	max_integrity = 300

/*
 * Surgery Tables
 */

/obj/structure/table/optable
	name = "operating table"
	desc = "Used for advanced medical procedures."
	icon = 'icons/obj/medical/surgery_table.dmi'
	icon_state = "surgery_table"
	buildstack = /obj/item/stack/sheet/mineral/silver
	smoothing_flags = NONE
	smoothing_groups = null
	canSmoothWith = null
	can_buckle = TRUE
	buckle_lying = 90
	custom_materials = list(/datum/material/silver = SHEET_MATERIAL_AMOUNT)
	can_flip = FALSE
	slam_gently = TRUE
	/// Mob currently lying on the table
	var/mob/living/carbon/patient = null
	/// Operating computer we're linked to, to sync operations from
	var/obj/machinery/computer/operating/computer = null
	/// Tank attached under the table
	var/obj/item/tank/air_tank = null
	/// Mask attached *to* the table, doesn't mean its inside the table as it can be worn by the patient
	var/obj/item/clothing/mask/breath/breath_mask = null

/obj/structure/table/optable/Initialize(mapload, obj/structure/table_frame/frame_used, obj/item/stack/stack_used)
	. = ..()
	for(var/direction in GLOB.alldirs)
		computer = locate(/obj/machinery/computer/operating) in get_step(src, direction)
		if(computer)
			computer.table = src
			break

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(mark_patient),
		COMSIG_ATOM_EXITED = PROC_REF(unmark_patient),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

	for (var/mob/living/carbon/potential_patient in loc)
		mark_patient(potential_patient)

/obj/structure/table/optable/Destroy()
	if(computer && computer.table == src)
		computer.table = null
	patient = null
	QDEL_NULL(air_tank)
	if (breath_mask?.loc == src)
		qdel(breath_mask)
	breath_mask = null
	return ..()

/obj/structure/table/optable/buckle_feedback(mob/living/being_buckled, mob/buckler)
	if(HAS_TRAIT(being_buckled, TRAIT_RESTRAINED))
		return ..()

	if(being_buckled == buckler)
		being_buckled.visible_message(
			span_notice("[buckler] lays down on [src]."),
			span_notice("You lay down on [src]."),
			visible_message_flags = ALWAYS_SHOW_SELF_MESSAGE,
		)
	else
		being_buckled.visible_message(
			span_notice("[buckler] lays [being_buckled] down on [src]."),
			span_notice("[buckler] lays you down on [src]."),
			visible_message_flags = ALWAYS_SHOW_SELF_MESSAGE,
		)

/obj/structure/table/optable/unbuckle_feedback(mob/living/being_unbuckled, mob/unbuckler)
	if(HAS_TRAIT(being_unbuckled, TRAIT_RESTRAINED))
		return ..()

	if(being_unbuckled == unbuckler)
		being_unbuckled.visible_message(
			span_notice("[unbuckler] gets up from [src]."),
			span_notice("You get up from [src]."),
			visible_message_flags = ALWAYS_SHOW_SELF_MESSAGE,
		)
	else
		being_unbuckled.visible_message(
			span_notice("[unbuckler] pulls [being_unbuckled] up from [src]."),
			span_notice("[unbuckler] pulls you up from [src]."),
			visible_message_flags = ALWAYS_SHOW_SELF_MESSAGE,
		)

/obj/structure/table/optable/add_context(atom/source, list/context, obj/item/held_item, mob/living/user)
	. = ..()
	if(isnull(held_item))
		if (breath_mask?.loc == src)
			context[SCREENTIP_CONTEXT_RMB] = "Take mask"
			. |= CONTEXTUAL_SCREENTIP_SET
		return

	if(breath_mask && breath_mask != held_item)
		if (held_item.tool_behaviour == TOOL_SCREWDRIVER)
			context[SCREENTIP_CONTEXT_LMB] = "Detach mask"
			. |= CONTEXTUAL_SCREENTIP_SET
	else if (istype(held_item, /obj/item/clothing/mask/breath))
		context[SCREENTIP_CONTEXT_LMB] = "Attach mask"
		. |= CONTEXTUAL_SCREENTIP_SET

	if(air_tank)
		if (held_item.tool_behaviour == TOOL_WRENCH)
			context[SCREENTIP_CONTEXT_LMB] = "Detach tank"
			. |= CONTEXTUAL_SCREENTIP_SET
	else if (istype(held_item, /obj/item/tank))
		var/obj/item/tank/as_tank = held_item
		if (as_tank.tank_holder_icon_state)
			context[SCREENTIP_CONTEXT_LMB] = "Attach tank"
			. |= CONTEXTUAL_SCREENTIP_SET

/obj/structure/table/optable/atom_deconstruct(disassembled)
	. = ..()
	var/atom/drop_loc = drop_location()
	if (!drop_loc)
		return

	if (air_tank)
		air_tank.forceMove(drop_loc)
		air_tank = null

	if (!breath_mask)
		return
	UnregisterSignal(breath_mask, list(COMSIG_MOVABLE_MOVED, COMSIG_ITEM_DROPPED))
	if (breath_mask.loc == src)
		breath_mask.forceMove(drop_loc)
	else if (breath_mask.loc)
		UnregisterSignal(breath_mask.loc, COMSIG_MOVABLE_MOVED)
	breath_mask = null

/obj/structure/table/optable/make_climbable()
	AddElement(/datum/element/elevation, pixel_shift = 12)

///Align the mob with the table when buckled.
/obj/structure/table/optable/post_buckle_mob(mob/living/buckled)
	buckled.add_offsets(type, z_add = 6)

///Disalign the mob with the table when unbuckled.
/obj/structure/table/optable/post_unbuckle_mob(mob/living/buckled)
	buckled.remove_offsets(type)

/// Any mob that enters our tile will be marked as a potential patient. They will be turned into a patient if they lie down.
/obj/structure/table/optable/proc/mark_patient(datum/source, mob/living/carbon/potential_patient)
	SIGNAL_HANDLER
	if(!istype(potential_patient))
		return
	RegisterSignal(potential_patient, COMSIG_LIVING_SET_BODY_POSITION, PROC_REF(recheck_patient))
	recheck_patient(potential_patient) // In case the mob is already lying down before they entered.

/// Unmark the potential patient.
/obj/structure/table/optable/proc/unmark_patient(datum/source, mob/living/carbon/potential_patient)
	SIGNAL_HANDLER
	if(!istype(potential_patient))
		return
	if(potential_patient == patient)
		recheck_patient(patient) // Can just set patient to null, but doing the recheck lets us find a replacement patient.
	UnregisterSignal(potential_patient, COMSIG_LIVING_SET_BODY_POSITION)

/// Someone on our tile just lied down, got up, moved in, or moved out.
/// potential_patient is the mob that had one of those four things change.
/// The check is a bit broad so we can find a replacement patient.
/obj/structure/table/optable/proc/recheck_patient(mob/living/carbon/potential_patient)
	SIGNAL_HANDLER

	if(patient && patient != potential_patient)
		return

	if(potential_patient.body_position == LYING_DOWN && potential_patient.loc == loc)
		set_patient(potential_patient)
		return

	// Find another lying mob as a replacement.
	for (var/mob/living/carbon/replacement_patient in loc.contents)
		if(replacement_patient.body_position == LYING_DOWN)
			set_patient(replacement_patient)
			return

	set_patient(null)

/obj/structure/table/optable/proc/set_patient(mob/living/carbon/new_patient)
	if (patient)
		UnregisterSignal(patient, list(COMSIG_MOB_SURGERY_STARTED, COMSIG_MOB_SURGERY_FINISHED))
		if (patient.external && patient.external == air_tank)
			patient.close_externals()

	patient = new_patient
	update_appearance()
	if (!patient)
		return
	RegisterSignal(patient, COMSIG_MOB_SURGERY_STARTED, PROC_REF(on_surgery_change))
	RegisterSignal(patient, COMSIG_MOB_SURGERY_FINISHED, PROC_REF(on_surgery_change))

/obj/structure/table/optable/proc/on_surgery_change(datum/source)
	SIGNAL_HANDLER
	update_appearance()

/obj/structure/table/optable/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if (istype(tool, /obj/item/clothing/mask/breath))
		if (breath_mask && breath_mask != tool)
			balloon_alert(user, "mask already attached!")
			return ITEM_INTERACT_BLOCKING

		if (!user.transferItemToLoc(tool, src))
			return ITEM_INTERACT_BLOCKING

		if (breath_mask != tool)
			breath_mask = tool
			RegisterSignal(breath_mask, COMSIG_MOVABLE_MOVED, PROC_REF(on_mask_moved))

		balloon_alert(user, "mask attached")
		playsound(src, 'sound/machines/click.ogg', 50, TRUE)
		update_appearance()
		return ITEM_INTERACT_SUCCESS

	if (!istype(tool, /obj/item/tank))
		return NONE

	if (air_tank)
		balloon_alert(user, "tank already attached!")
		return ITEM_INTERACT_BLOCKING

	var/obj/item/tank/as_tank = tool
	if (!as_tank.tank_holder_icon_state)
		balloon_alert(user, "does not fit!")
		return ITEM_INTERACT_BLOCKING

	if (!user.transferItemToLoc(tool, src))
		return ITEM_INTERACT_BLOCKING

	air_tank = as_tank
	balloon_alert(user, "tank attached")
	playsound(src, 'sound/machines/click.ogg', 50, TRUE)
	update_appearance()
	return ITEM_INTERACT_SUCCESS

/obj/structure/table/optable/screwdriver_act(mob/living/user, obj/item/tool)
	if (!breath_mask)
		return NONE

	if (breath_mask.loc != src)
		return ITEM_INTERACT_BLOCKING

	breath_mask.forceMove(drop_location())
	tool.play_tool_sound(src, 50)
	balloon_alert(user, "mask detached")
	UnregisterSignal(breath_mask, list(COMSIG_MOVABLE_MOVED, COMSIG_ITEM_DROPPED))
	if (user.CanReach(breath_mask))
		user.put_in_hands(breath_mask)
	breath_mask = null
	update_appearance()
	return ITEM_INTERACT_SUCCESS

/obj/structure/table/optable/wrench_act(mob/living/user, obj/item/tool)
	if (!air_tank)
		return NONE
	balloon_alert(user, "detaching the tank...")
	if (!tool.use_tool(src, user, 3 SECONDS))
		return ITEM_INTERACT_BLOCKING
	air_tank.forceMove(drop_location())
	tool.play_tool_sound(src, 50)
	balloon_alert(user, "tank detached")
	if (user.CanReach(air_tank))
		user.put_in_hands(air_tank)
	if (patient?.external && patient.external == air_tank)
		patient.close_externals()
	air_tank = null
	update_appearance()
	return ITEM_INTERACT_SUCCESS

/obj/structure/table/optable/attack_hand_secondary(mob/living/user, list/modifiers)
	. = ..()
	if (. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return

	if (detach_mask(user))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/structure/table/optable/examine(mob/user)
	. = ..()
	if (air_tank)
		. += span_notice("It has \a [air_tank] secured to it with a couple of [EXAMINE_HINT("bolts")].")
		if (patient)
			. += span_info("You can connect [patient]'s internals to \the [air_tank] by dragging \the [src] onto them.")
	else
		. += span_notice("It has an attachment slot for an air tank underneath.")
	if (breath_mask)
		. += span_notice("It has \a [breath_mask] attached to its side, the tube secured with a single [EXAMINE_HINT("screw")].")
		if (breath_mask.loc == src)
			. += span_info("You can detach the mask by right-clicking \the [src] with an empty hand.")
	else
		. += span_notice("There's a port for a breathing mask tube on its side.")

/obj/structure/table/optable/proc/detach_mask(mob/living/user)
	if (!istype(user) || !user.CanReach(src) || !user.can_interact_with(src))
		return FALSE

	if (!breath_mask)
		balloon_alert(user, "no mask attached!")
		return TRUE

	if (!user.put_in_hands(breath_mask))
		balloon_alert(user, "hands busy!")
		return TRUE

	to_chat(user, span_notice("You pull out \the [breath_mask] from \the [src]."))
	update_appearance()
	return TRUE

/obj/structure/table/optable/mouse_drop_dragged(atom/over, mob/living/user, src_location, over_location, params)
	if (over != patient || !istype(user) || !user.CanReach(src) || !user.can_interact_with(src))
		return

	if (!air_tank)
		balloon_alert(user, "no tank attached!")
		return

	var/internals = patient.can_breathe_internals()
	if (!internals)
		balloon_alert(user, "no internals connector!")
		return

	user.visible_message(span_notice("[user] begins connecting [src]'s [air_tank] to [patient]'s [internals]."), span_notice("You begin connecting [src]'s [air_tank] to [patient]'s [internals]..."), ignored_mobs = patient)
	to_chat(patient, span_userdanger("[user] begins connecting [src]'s [air_tank] to your [internals]!"))

	if (!do_after(user, 4 SECONDS, patient))
		return

	if (!air_tank || patient != over || !patient.can_breathe_internals())
		return

	patient.open_internals(air_tank, is_external = TRUE)
	to_chat(user, span_notice("You connect [src]'s [air_tank] to [patient]'s [internals]."))
	to_chat(patient, span_userdanger("[user] connects [src]'s [air_tank] to your [internals]!"))

/obj/structure/table/optable/proc/on_mask_moved(datum/source, atom/oldloc, direction)
	SIGNAL_HANDLER
	if (oldloc != src)
		UnregisterSignal(oldloc, COMSIG_MOVABLE_MOVED)
	if (breath_mask.loc && breath_mask.loc != src)
		RegisterSignal(breath_mask.loc, COMSIG_MOVABLE_MOVED, PROC_REF(check_mask_range))
	check_mask_range()

/obj/structure/table/optable/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	. = ..()
	if (breath_mask)
		check_mask_range()

/obj/structure/table/optable/proc/check_mask_range()
	SIGNAL_HANDLER

	// Check if the mask is inside of us, or if its being *directly held* by someone and not in their backpack
	if (breath_mask.loc == src || (isturf(breath_mask.loc?.loc) && in_range(breath_mask, src)))
		return

	if(isliving(loc))
		var/mob/living/user = loc
		to_chat(user, span_warning("[breath_mask]'s tube overextends and it comes out of your hands!"))
	else
		visible_message(span_notice("[breath_mask] snaps back into \the [src]."))
	snap_mask_back()

/obj/structure/table/optable/proc/snap_mask_back()
	SIGNAL_HANDLER
	if (ismob(breath_mask.loc))
		var/mob/as_mob = breath_mask.loc
		as_mob.temporarilyRemoveItemFromInventory(breath_mask, force = TRUE)
	breath_mask.forceMove(src)
	update_appearance()

/obj/structure/table/optable/update_overlays()
	. = ..()
	if (air_tank)
		. += mutable_appearance(icon, air_tank.tank_holder_icon_state)
	if (breath_mask?.loc == src)
		. += mutable_appearance(icon, "mask_[breath_mask.icon_state]")
	if (!length(patient?.surgeries))
		return
	. += mutable_appearance(icon, "[icon_state]_[computer ? "" : "un"]linked")
	if (computer)
		. += emissive_appearance(icon, "[icon_state]_linked", src, alpha = 175)

/*
 * Racks
 */
/obj/structure/rack
	name = "rack"
	desc = "Different from the Middle Ages version."
	icon = 'icons/obj/structures.dmi'
	icon_state = "rack"
	layer = TABLE_LAYER
	density = TRUE
	anchored = TRUE
	pass_flags_self = LETPASSTHROW //You can throw objects over this, despite its density.
	max_integrity = 20
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT)

/obj/structure/rack/skeletal
	name = "skeletal minibar"
	desc = "Rattle me boozes!"
	icon = 'icons/obj/fluff/general.dmi'
	icon_state = "minibar"
	custom_materials = list(/datum/material/bone = SHEET_MATERIAL_AMOUNT)

/obj/structure/rack/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/climbable)
	AddElement(/datum/element/elevation, pixel_shift = 12)
	register_context()
	ADD_TRAIT(src, TRAIT_COMBAT_MODE_SKIP_INTERACTION, INNATE_TRAIT)

/obj/structure/rack/add_context(atom/source, list/context, obj/item/held_item, mob/living/user)
	if(isnull(held_item))
		return NONE

	if(held_item.tool_behaviour == TOOL_WRENCH)
		context[SCREENTIP_CONTEXT_RMB] = "Deconstruct"
		return CONTEXTUAL_SCREENTIP_SET

	return NONE

/obj/structure/rack/examine(mob/user)
	. = ..()
	. += span_notice("It's held together by a couple of <b>bolts</b>.")

/obj/structure/rack/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(.)
		return
	if(istype(mover) && (mover.pass_flags & PASSTABLE))
		return TRUE

/obj/structure/rack/wrench_act_secondary(mob/living/user, obj/item/tool)
	tool.play_tool_sound(src)
	deconstruct(TRUE)
	return ITEM_INTERACT_SUCCESS

/obj/structure/rack/base_item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	. = ..()
	if(.)
		return .
	if((tool.item_flags & ABSTRACT) || (user.combat_mode && !(tool.item_flags & NOBLUDGEON)))
		return NONE
	if(user.transfer_item_to_turf(tool, get_turf(src), silent = FALSE))
		return ITEM_INTERACT_SUCCESS
	return ITEM_INTERACT_BLOCKING

/obj/structure/rack/attack_paw(mob/living/user, list/modifiers)
	attack_hand(user, modifiers)

/obj/structure/rack/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!user.combat_mode || user.body_position == LYING_DOWN || user.usable_legs < 2)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src, ATTACK_EFFECT_KICK)
	user.visible_message(span_danger("[user] kicks [src]."), null, null, COMBAT_MESSAGE_RANGE)
	take_damage(rand(4,8), BRUTE, MELEE, 1)

/obj/structure/rack/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(loc, 'sound/items/dodgeball.ogg', 80, TRUE)
			else
				playsound(loc, 'sound/items/weapons/tap.ogg', 50, TRUE)
		if(BURN)
			playsound(loc, 'sound/items/tools/welder.ogg', 40, TRUE)

/*
 * Rack destruction
 */

/obj/structure/rack/atom_deconstruct(disassembled = TRUE)
	set_density(FALSE)
	var/obj/item/rack_parts/newparts = new(loc)
	transfer_fingerprints_to(newparts)


/*
 * Rack Parts
 */

/obj/item/rack_parts
	name = "rack parts"
	desc = "Parts of a rack."
	icon = 'icons/obj/structures.dmi'
	icon_state = "rack_parts"
	inhand_icon_state = "rack_parts"
	obj_flags = CONDUCTS_ELECTRICITY
	custom_materials = list(/datum/material/iron = SHEET_MATERIAL_AMOUNT)
	var/building = FALSE

/obj/item/rack_parts/Initialize(mapload)
	. = ..()
	register_context()

/obj/item/rack_parts/add_context(atom/source, list/context, obj/item/held_item, mob/living/user)
	if(isnull(held_item))
		return NONE

	if(held_item == src)
		context[SCREENTIP_CONTEXT_LMB] = "Construct Rack"
		return CONTEXTUAL_SCREENTIP_SET

	if(held_item.tool_behaviour == TOOL_WRENCH)
		context[SCREENTIP_CONTEXT_LMB] = "Deconstruct"
		return CONTEXTUAL_SCREENTIP_SET

	return NONE

/obj/item/rack_parts/wrench_act(mob/living/user, obj/item/tool)
	tool.play_tool_sound(src)
	deconstruct(TRUE)
	return ITEM_INTERACT_SUCCESS

/obj/item/rack_parts/atom_deconstruct(disassembled = TRUE)
	new /obj/item/stack/sheet/iron(drop_location())

/obj/item/rack_parts/attack_self(mob/user)
	if(building)
		return
	building = TRUE
	to_chat(user, span_notice("You start constructing a rack..."))
	if(do_after(user, 5 SECONDS, target = user, progress=TRUE))
		if(!user.temporarilyRemoveItemFromInventory(src))
			return
		var/obj/structure/rack/R = new /obj/structure/rack(get_turf(src))
		user.visible_message(span_notice("[user] assembles \a [R]."), span_notice("You assemble \a [R]."))
		R.add_fingerprint(user)
		qdel(src)
	building = FALSE

