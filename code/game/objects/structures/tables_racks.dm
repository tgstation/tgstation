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
	var/frame = /obj/structure/table_frame
	var/framestack = /obj/item/stack/rods
	var/buildstack = /obj/item/stack/sheet/iron
	var/busy = FALSE
	var/buildstackamount = 1
	var/framestackamount = 2
	var/deconstruction_ready = 1
	custom_materials = list(/datum/material/iron = 2000)
	max_integrity = 100
	integrity_failure = 0.33
	smoothing_flags = SMOOTH_BITMASK
	smoothing_groups = list(SMOOTH_GROUP_TABLES)
	canSmoothWith = list(SMOOTH_GROUP_TABLES)

/obj/structure/table/Initialize(mapload, _buildstack)
	. = ..()
	if(_buildstack)
		buildstack = _buildstack
	AddElement(/datum/element/climbable)
	var/static/list/loc_connections = list(
		COMSIG_CARBON_DISARM_COLLIDE = .proc/table_carbon,
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/structure/table/examine(mob/user)
	. = ..()
	. += deconstruction_hints(user)

/obj/structure/table/proc/deconstruction_hints(mob/user)
	return span_notice("The top is <b>screwed</b> on, but the main <b>bolts</b> are also visible.")

/obj/structure/table/update_icon(updates=ALL)
	. = ..()
	if((updates & UPDATE_SMOOTHING) && (smoothing_flags & (SMOOTH_CORNERS|SMOOTH_BITMASK)))
		QUEUE_SMOOTH(src)
		QUEUE_SMOOTH_NEIGHBORS(src)

/obj/structure/table/narsie_act()
	var/atom/A = loc
	qdel(src)
	new /obj/structure/table/wood(A)

/obj/structure/table/attack_paw(mob/user, list/modifiers)
	return attack_hand(user, modifiers)

/obj/structure/table/attack_hand(mob/living/user, list/modifiers)
	if(Adjacent(user) && user.pulling)
		if(isliving(user.pulling))
			var/mob/living/pushed_mob = user.pulling
			if(pushed_mob.buckled)
				to_chat(user, span_warning("[pushed_mob] is buckled to [pushed_mob.buckled]!"))
				return
			if(user.combat_mode)
				switch(user.grab_state)
					if(GRAB_PASSIVE)
						to_chat(user, span_warning("You need a better grip to do that!"))
						return
					if(GRAB_AGGRESSIVE)
						tablepush(user, pushed_mob)
					if(GRAB_NECK to GRAB_KILL)
						tablelimbsmash(user, pushed_mob)
			else
				pushed_mob.visible_message(span_notice("[user] begins to place [pushed_mob] onto [src]..."), \
									span_userdanger("[user] begins to place [pushed_mob] onto [src]..."))
				if(do_after(user, 3.5 SECONDS, target = pushed_mob))
					tableplace(user, pushed_mob)
				else
					return
			user.stop_pulling()
		else if(user.pulling.pass_flags & PASSTABLE)
			user.Move_Pulled(src)
			if (user.pulling.loc == loc)
				user.visible_message(span_notice("[user] places [user.pulling] onto [src]."),
					span_notice("You place [user.pulling] onto [src]."))
				user.stop_pulling()
	return ..()

/obj/structure/table/attackby_secondary(obj/item/weapon, mob/user, params)
	if(istype(weapon, /obj/item/toy/cards/deck))
		var/obj/item/toy/cards/deck/deck = weapon 
		var/obj/item/toy/cards/singlecard/card = deck.draw_card(user, deck.cards, place_on_table=TRUE)
		src.attackby(card, user, params)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	..()
	return SECONDARY_ATTACK_CONTINUE_CHAIN

/obj/structure/table/attack_tk(mob/user)
	return


/obj/structure/table/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(.)
		return
	if(mover.throwing)
		return TRUE
	if(locate(/obj/structure/table) in get_turf(mover))
		return TRUE

/obj/structure/table/CanAStarPass(obj/item/card/id/ID, to_dir, atom/movable/caller)
	. = !density
	if(istype(caller))
		. = . || (caller.pass_flags & PASSTABLE)

/obj/structure/table/proc/tableplace(mob/living/user, mob/living/pushed_mob)
	pushed_mob.forceMove(loc)
	pushed_mob.set_resting(TRUE, TRUE)
	pushed_mob.visible_message(span_notice("[user] places [pushed_mob] onto [src]."), \
								span_notice("[user] places [pushed_mob] onto [src]."))
	log_combat(user, pushed_mob, "places", null, "onto [src]")

/obj/structure/table/proc/tablepush(mob/living/user, mob/living/pushed_mob)
	if(HAS_TRAIT(user, TRAIT_PACIFISM))
		to_chat(user, span_danger("Throwing [pushed_mob] onto the table might hurt them!"))
		return
	var/added_passtable = FALSE
	if(!(pushed_mob.pass_flags & PASSTABLE))
		added_passtable = TRUE
		pushed_mob.pass_flags |= PASSTABLE
	for (var/obj/obj in user.loc.contents)
		if(!obj.CanAllowThrough(pushed_mob))
			return
	pushed_mob.Move(src.loc)
	if(added_passtable)
		pushed_mob.pass_flags &= ~PASSTABLE
	if(pushed_mob.loc != loc) //Something prevented the tabling
		return
	pushed_mob.Knockdown(30)
	pushed_mob.apply_damage(10, BRUTE)
	pushed_mob.apply_damage(40, STAMINA)
	if(user.mind?.martial_art.smashes_tables && user.mind?.martial_art.can_use(user))
		deconstruct(FALSE)
	playsound(pushed_mob, 'sound/effects/tableslam.ogg', 90, TRUE)
	pushed_mob.visible_message(span_danger("[user] slams [pushed_mob] onto \the [src]!"), \
								span_userdanger("[user] slams you onto \the [src]!"))
	log_combat(user, pushed_mob, "tabled", null, "onto [src]")
	SEND_SIGNAL(pushed_mob, COMSIG_ADD_MOOD_EVENT, "table", /datum/mood_event/table)

/obj/structure/table/proc/tablelimbsmash(mob/living/user, mob/living/pushed_mob)
	pushed_mob.Knockdown(30)
	var/obj/item/bodypart/banged_limb = pushed_mob.get_bodypart(user.zone_selected) || pushed_mob.get_bodypart(BODY_ZONE_HEAD)
	var/extra_wound = 0
	if(HAS_TRAIT(user, TRAIT_HULK))
		extra_wound = 20
	banged_limb?.receive_damage(30, wound_bonus = extra_wound)
	pushed_mob.apply_damage(60, STAMINA)
	take_damage(50)
	if(user.mind?.martial_art.smashes_tables && user.mind?.martial_art.can_use(user))
		deconstruct(FALSE)
	playsound(pushed_mob, 'sound/effects/bang.ogg', 90, TRUE)
	pushed_mob.visible_message(span_danger("[user] smashes [pushed_mob]'s [banged_limb.name] against \the [src]!"),
								span_userdanger("[user] smashes your [banged_limb.name] against \the [src]"))
	log_combat(user, pushed_mob, "head slammed", null, "against [src]")
	SEND_SIGNAL(pushed_mob, COMSIG_ADD_MOOD_EVENT, "table", /datum/mood_event/table_limbsmash, banged_limb)

/obj/structure/table/attackby(obj/item/I, mob/living/user, params)
	var/list/modifiers = params2list(params)
	if(!(flags_1 & NODECONSTRUCT_1) && LAZYACCESS(modifiers, RIGHT_CLICK))
		if(I.tool_behaviour == TOOL_SCREWDRIVER && deconstruction_ready)
			to_chat(user, span_notice("You start disassembling [src]..."))
			if(I.use_tool(src, user, 20, volume=50))
				deconstruct(TRUE)
			return

		if(I.tool_behaviour == TOOL_WRENCH && deconstruction_ready)
			to_chat(user, span_notice("You start deconstructing [src]..."))
			if(I.use_tool(src, user, 40, volume=50))
				playsound(src.loc, 'sound/items/deconstruct.ogg', 50, TRUE)
				deconstruct(TRUE, 1)
			return

	if(istype(I, /obj/item/storage/bag/tray))
		var/obj/item/storage/bag/tray/T = I
		if(T.contents.len > 0) // If the tray isn't empty
			for(var/x in T.contents)
				var/obj/item/item = x
				AfterPutItemOnTable(item, user)
			SEND_SIGNAL(I, COMSIG_TRY_STORAGE_QUICK_EMPTY, drop_location())
			user.visible_message(span_notice("[user] empties [I] on [src]."))
			return
		// If the tray IS empty, continue on (tray will be placed on the table like other items)

	if(istype(I, /obj/item/riding_offhand))
		var/obj/item/riding_offhand/riding_item = I
		var/mob/living/carried_mob = riding_item.rider
		if(carried_mob == user) //Piggyback user.
			return
		if(user.combat_mode)
			user.unbuckle_mob(carried_mob)
			tablelimbsmash(user, carried_mob)
		else
			var/tableplace_delay = 3.5 SECONDS
			var/skills_space = ""
			if(HAS_TRAIT(user, TRAIT_QUICKER_CARRY))
				tableplace_delay = 2 SECONDS
				skills_space = " expertly"
			else if(HAS_TRAIT(user, TRAIT_QUICK_CARRY))
				tableplace_delay = 2.75 SECONDS
				skills_space = " quickly"
			carried_mob.visible_message(span_notice("[user] begins to[skills_space] place [carried_mob] onto [src]..."),
				span_userdanger("[user] begins to[skills_space] place [carried_mob] onto [src]..."))
			if(do_after(user, tableplace_delay, target = carried_mob))
				user.unbuckle_mob(carried_mob)
				tableplace(user, carried_mob)
		return TRUE

	if(!user.combat_mode && !(I.item_flags & ABSTRACT))
		if(user.transferItemToLoc(I, drop_location(), silent = FALSE))
			//Center the icon where the user clicked.
			if(!LAZYACCESS(modifiers, ICON_X) || !LAZYACCESS(modifiers, ICON_Y))
				return
			//Clamp it so that the icon never moves more than 16 pixels in either direction (thus leaving the table turf)
			I.pixel_x = clamp(text2num(LAZYACCESS(modifiers, ICON_X)) - 16, -(world.icon_size/2), world.icon_size/2)
			I.pixel_y = clamp(text2num(LAZYACCESS(modifiers, ICON_Y)) - 16, -(world.icon_size/2), world.icon_size/2)
			AfterPutItemOnTable(I, user)
			return TRUE
	else
		return ..()

/obj/structure/table/proc/AfterPutItemOnTable(obj/item/I, mob/living/user)
	return

/obj/structure/table/deconstruct(disassembled = TRUE, wrench_disassembly = 0)
	if(!(flags_1 & NODECONSTRUCT_1))
		var/turf/T = get_turf(src)
		if(buildstack)
			new buildstack(T, buildstackamount)
		else
			for(var/i in custom_materials)
				var/datum/material/M = i
				new M.sheet_type(T, FLOOR(custom_materials[M] / MINERAL_MATERIAL_AMOUNT, 1))
		if(!wrench_disassembly)
			new frame(T)
		else
			new framestack(T, framestackamount)
	qdel(src)

/obj/structure/table/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	switch(the_rcd.mode)
		if(RCD_DECONSTRUCT)
			return list("mode" = RCD_DECONSTRUCT, "delay" = 24, "cost" = 16)
	return FALSE

/obj/structure/table/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, passed_mode)
	switch(passed_mode)
		if(RCD_DECONSTRUCT)
			to_chat(user, span_notice("You deconstruct the table."))
			qdel(src)
			return TRUE
	return FALSE

/obj/structure/table/proc/table_carbon(datum/source, mob/living/carbon/shover, mob/living/carbon/target, shove_blocked)
	SIGNAL_HANDLER
	if(!shove_blocked)
		return
	target.Knockdown(SHOVE_KNOCKDOWN_TABLE)
	target.visible_message(span_danger("[shover.name] shoves [target.name] onto \the [src]!"),
		span_userdanger("You're shoved onto \the [src] by [shover.name]!"), span_hear("You hear aggressive shuffling followed by a loud thud!"), COMBAT_MESSAGE_RANGE, src)
	to_chat(shover, span_danger("You shove [target.name] onto \the [src]!"))
	target.throw_at(src, 1, 1, null, FALSE) //1 speed throws with no spin are basically just forcemoves with a hard collision check
	log_combat(src, target, "shoved", "onto [src] (table)")
	return COMSIG_CARBON_SHOVE_HANDLED

/obj/structure/table/greyscale
	icon = 'icons/obj/smooth_structures/table_greyscale.dmi'
	icon_state = "table_greyscale-0"
	base_icon_state = "table_greyscale"
	material_flags = MATERIAL_EFFECTS | MATERIAL_ADD_PREFIX | MATERIAL_COLOR | MATERIAL_AFFECT_STATISTICS
	buildstack = null //No buildstack, so generate from mat datums

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
	var/list/attached_items = list()

/obj/structure/table/rolling/AfterPutItemOnTable(obj/item/I, mob/living/user)
	. = ..()
	attached_items += I
	RegisterSignal(I, COMSIG_MOVABLE_MOVED, .proc/RemoveItemFromTable) //Listen for the pickup event, unregister on pick-up so we aren't moved

/obj/structure/table/rolling/proc/RemoveItemFromTable(datum/source, newloc, dir)
	SIGNAL_HANDLER

	if(newloc != loc) //Did we not move with the table? because that shit's ok
		return FALSE
	attached_items -= source
	UnregisterSignal(source, COMSIG_MOVABLE_MOVED)

/obj/structure/table/rolling/Moved(atom/OldLoc, Dir)
	. = ..()
	if(!loc)
		return
	for(var/mob/living/living_mob in OldLoc.contents)//Kidnap everyone on top
		living_mob.forceMove(loc)
	for(var/x in attached_items)
		var/atom/movable/AM = x
		if(!AM.Move(loc))
			RemoveItemFromTable(AM, AM.loc)

/*
 * Glass tables
 */
/obj/structure/table/glass
	name = "glass table"
	desc = "What did I say about leaning on the glass tables? Now you need surgery."
	icon = 'icons/obj/smooth_structures/glass_table.dmi'
	icon_state = "glass_table-0"
	base_icon_state = "glass_table"
	custom_materials = list(/datum/material/glass = 2000)
	buildstack = /obj/item/stack/sheet/glass
	smoothing_groups = list(SMOOTH_GROUP_GLASS_TABLES)
	canSmoothWith = list(SMOOTH_GROUP_GLASS_TABLES)
	max_integrity = 70
	resistance_flags = ACID_PROOF
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, FIRE = 80, ACID = 100)
	var/list/debris = list()

/obj/structure/table/glass/Initialize(mapload)
	. = ..()
	debris += new frame
	if(buildstack == /obj/item/stack/sheet/plasmaglass)
		debris += new /obj/item/shard/plasma
	else
		debris += new /obj/item/shard
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/structure/table/glass/Destroy()
	QDEL_LIST(debris)
	. = ..()

/obj/structure/table/glass/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER
	if(flags_1 & NODECONSTRUCT_1)
		return
	if(!isliving(AM))
		return
	// Don't break if they're just flying past
	if(AM.throwing)
		addtimer(CALLBACK(src, .proc/throw_check, AM), 5)
	else
		check_break(AM)

/obj/structure/table/glass/proc/throw_check(mob/living/M)
	if(M.loc == get_turf(src))
		check_break(M)

/obj/structure/table/glass/proc/check_break(mob/living/M)
	if(M.has_gravity() && M.mob_size > MOB_SIZE_SMALL && !(M.movement_type & FLYING))
		table_shatter(M)

/obj/structure/table/glass/proc/table_shatter(mob/living/L)
	visible_message(span_warning("[src] breaks!"),
		span_danger("You hear breaking glass."))
	var/turf/T = get_turf(src)
	playsound(T, "shatter", 50, TRUE)
	for(var/I in debris)
		var/atom/movable/AM = I
		AM.forceMove(T)
		debris -= AM
		if(istype(AM, /obj/item/shard))
			AM.throw_impact(L)
	L.Paralyze(100)
	qdel(src)

/obj/structure/table/glass/deconstruct(disassembled = TRUE, wrench_disassembly = 0)
	if(!(flags_1 & NODECONSTRUCT_1))
		if(disassembled)
			..()
			return
		else
			var/turf/T = get_turf(src)
			playsound(T, "shatter", 50, TRUE)
			for(var/X in debris)
				var/atom/movable/AM = X
				AM.forceMove(T)
				debris -= AM
	qdel(src)

/obj/structure/table/glass/narsie_act()
	color = NARSIE_WINDOW_COLOUR
	for(var/obj/item/shard/S in debris)
		S.color = NARSIE_WINDOW_COLOUR

/obj/structure/table/glass/plasmaglass
	name = "plasma glass table"
	desc = "Someone thought this was a good idea."
	icon = 'icons/obj/smooth_structures/plasmaglass_table.dmi'
	icon_state = "plasmaglass_table-0"
	base_icon_state = "plasmaglass_table"
	custom_materials = list(/datum/material/alloy/plasmaglass = 2000)
	buildstack = /obj/item/stack/sheet/plasmaglass
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
	smoothing_groups = list(SMOOTH_GROUP_WOOD_TABLES) //Don't smooth with SMOOTH_GROUP_TABLES
	canSmoothWith = list(SMOOTH_GROUP_WOOD_TABLES)

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

/obj/structure/table/wood/poker/narsie_act()
	..(FALSE)

/obj/structure/table/wood/fancy
	name = "fancy table"
	desc = "A standard metal table frame covered with an amazingly fancy, patterned cloth."
	icon = 'icons/obj/structures.dmi'
	icon_state = "fancy_table"
	base_icon_state = "fancy_table"
	frame = /obj/structure/table_frame
	framestack = /obj/item/stack/rods
	buildstack = /obj/item/stack/tile/carpet
	smoothing_groups = list(SMOOTH_GROUP_FANCY_WOOD_TABLES) //Don't smooth with SMOOTH_GROUP_TABLES or SMOOTH_GROUP_WOOD_TABLES
	canSmoothWith = list(SMOOTH_GROUP_FANCY_WOOD_TABLES)
	var/smooth_icon = 'icons/obj/smooth_structures/fancy_table.dmi' // see Initialize()

/obj/structure/table/wood/fancy/Initialize(mapload)
	. = ..()
	// Needs to be set dynamically because table smooth sprites are 32x34,
	// which the editor treats as a two-tile-tall object. The sprites are that
	// size so that the north/south corners look nice - examine the detail on
	// the sprites in the editor to see why.
	icon = smooth_icon

/obj/structure/table/wood/fancy/black
	icon_state = "fancy_table_black"
	base_icon_state = "fancy_table_black"
	buildstack = /obj/item/stack/tile/carpet/black
	smooth_icon = 'icons/obj/smooth_structures/fancy_table_black.dmi'

/obj/structure/table/wood/fancy/blue
	icon_state = "fancy_table_blue"
	base_icon_state = "fancy_table_blue"
	buildstack = /obj/item/stack/tile/carpet/blue
	smooth_icon = 'icons/obj/smooth_structures/fancy_table_blue.dmi'

/obj/structure/table/wood/fancy/cyan
	icon_state = "fancy_table_cyan"
	base_icon_state = "fancy_table_cyan"
	buildstack = /obj/item/stack/tile/carpet/cyan
	smooth_icon = 'icons/obj/smooth_structures/fancy_table_cyan.dmi'

/obj/structure/table/wood/fancy/green
	icon_state = "fancy_table_green"
	base_icon_state = "fancy_table_green"
	buildstack = /obj/item/stack/tile/carpet/green
	smooth_icon = 'icons/obj/smooth_structures/fancy_table_green.dmi'

/obj/structure/table/wood/fancy/orange
	icon_state = "fancy_table_orange"
	base_icon_state = "fancy_table_orange"
	buildstack = /obj/item/stack/tile/carpet/orange
	smooth_icon = 'icons/obj/smooth_structures/fancy_table_orange.dmi'

/obj/structure/table/wood/fancy/purple
	icon_state = "fancy_table_purple"
	base_icon_state = "fancy_table_purple"
	buildstack = /obj/item/stack/tile/carpet/purple
	smooth_icon = 'icons/obj/smooth_structures/fancy_table_purple.dmi'

/obj/structure/table/wood/fancy/red
	icon_state = "fancy_table_red"
	base_icon_state = "fancy_table_red"
	buildstack = /obj/item/stack/tile/carpet/red
	smooth_icon = 'icons/obj/smooth_structures/fancy_table_red.dmi'

/obj/structure/table/wood/fancy/royalblack
	icon_state = "fancy_table_royalblack"
	base_icon_state = "fancy_table_royalblack"
	buildstack = /obj/item/stack/tile/carpet/royalblack
	smooth_icon = 'icons/obj/smooth_structures/fancy_table_royalblack.dmi'

/obj/structure/table/wood/fancy/royalblue
	icon_state = "fancy_table_royalblue"
	base_icon_state = "fancy_table_royalblue"
	buildstack = /obj/item/stack/tile/carpet/royalblue
	smooth_icon = 'icons/obj/smooth_structures/fancy_table_royalblue.dmi'

/*
 * Reinforced tables
 */
/obj/structure/table/reinforced
	name = "reinforced table"
	desc = "A reinforced version of the four legged table."
	icon = 'icons/obj/smooth_structures/reinforced_table.dmi'
	icon_state = "reinforced_table-0"
	base_icon_state = "reinforced_table"
	deconstruction_ready = 0
	buildstack = /obj/item/stack/sheet/plasteel
	max_integrity = 200
	integrity_failure = 0.25
	armor = list(MELEE = 10, BULLET = 30, LASER = 30, ENERGY = 100, BOMB = 20, BIO = 0, FIRE = 80, ACID = 70)

/obj/structure/table/reinforced/deconstruction_hints(mob/user)
	if(deconstruction_ready)
		return span_notice("The top cover has been <i>welded</i> loose and the main frame's <b>bolts</b> are exposed.")
	else
		return span_notice("The top cover is firmly <b>welded</b> on.")

/obj/structure/table/reinforced/attackby_secondary(obj/item/weapon, mob/user, params)
	if(weapon.tool_behaviour == TOOL_WELDER)
		if(weapon.tool_start_check(user, amount = 0))
			if(deconstruction_ready)
				to_chat(user, span_notice("You start strengthening the reinforced table..."))
				if (weapon.use_tool(src, user, 50, volume = 50))
					to_chat(user, span_notice("You strengthen the table."))
					deconstruction_ready = FALSE
			else
				to_chat(user, span_notice("You start weakening the reinforced table..."))
				if (weapon.use_tool(src, user, 50, volume = 50))
					to_chat(user, span_notice("You weaken the table."))
					deconstruction_ready = TRUE
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	else
		. = ..()

/obj/structure/table/bronze
	name = "bronze table"
	desc = "A solid table made out of bronze."
	icon = 'icons/obj/smooth_structures/brass_table.dmi'
	icon_state = "brass_table-0"
	base_icon_state = "brass_table"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	buildstack = /obj/item/stack/sheet/bronze
	smoothing_groups = list(SMOOTH_GROUP_BRONZE_TABLES) //Don't smooth with SMOOTH_GROUP_TABLES
	canSmoothWith = list(SMOOTH_GROUP_BRONZE_TABLES)

/obj/structure/table/bronze/tablepush(mob/living/user, mob/living/pushed_mob)
	..()
	playsound(src, 'sound/magic/clockwork/fellowship_armory.ogg', 50, TRUE)

/obj/structure/table/reinforced/rglass
	name = "reinforced glass table"
	desc = "A reinforced version of the glass table."
	icon = 'icons/obj/smooth_structures/rglass_table.dmi'
	icon_state = "rglass_table-0"
	base_icon_state = "rglass_table"
	custom_materials = list(/datum/material/glass = 2000, /datum/material/iron = 2000)
	buildstack = /obj/item/stack/sheet/rglass
	max_integrity = 150

/obj/structure/table/reinforced/plasmarglass
	name = "reinforced plasma glass table"
	desc = "A reinforced version of the plasma glass table."
	icon = 'icons/obj/smooth_structures/rplasmaglass_table.dmi'
	icon_state = "rplasmaglass_table-0"
	base_icon_state = "rplasmaglass_table"
	custom_materials = list(/datum/material/alloy/plasmaglass = 2000, /datum/material/iron = 2000)
	buildstack = /obj/item/stack/sheet/plasmarglass

/obj/structure/table/reinforced/titaniumglass
	name = "titanium glass table"
	desc = "A titanium reinforced glass table, with a fresh coat of NT white paint."
	icon = 'icons/obj/smooth_structures/titaniumglass_table.dmi'
	icon_state = "titaniumglass_table-o"
	base_icon_state = "titaniumglass_table"
	custom_materials = list(/datum/material/alloy/titaniumglass = 2000)
	buildstack = /obj/item/stack/sheet/titaniumglass
	max_integrity = 250

/obj/structure/table/reinforced/plastitaniumglass
	name = "plastitanium glass table"
	desc = "A table made of titanium reinforced silica-plasma composite. About as durable as it sounds."
	icon = 'icons/obj/smooth_structures/plastitaniumglass_table.dmi'
	icon_state = "plastitaniumglass_table-0"
	base_icon_state = "plastitaniumglass_table"
	custom_materials = list(/datum/material/alloy/plastitaniumglass = 2000)
	buildstack = /obj/item/stack/sheet/plastitaniumglass
	max_integrity = 300

/*
 * Surgery Tables
 */

/obj/structure/table/optable
	name = "operating table"
	desc = "Used for advanced medical procedures."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "optable"
	buildstack = /obj/item/stack/sheet/mineral/silver
	smoothing_flags = NONE
	smoothing_groups = null
	canSmoothWith = null
	can_buckle = 1
	buckle_lying = NO_BUCKLE_LYING
	buckle_requires_restraints = TRUE
	custom_materials = list(/datum/material/silver = 2000)
	var/mob/living/carbon/human/patient = null
	var/obj/machinery/computer/operating/computer = null

/obj/structure/table/optable/Initialize(mapload)
	. = ..()
	for(var/direction in GLOB.alldirs)
		computer = locate(/obj/machinery/computer/operating) in get_step(src, direction)
		if(computer)
			computer.table = src
			break

/obj/structure/table/optable/Destroy()
	. = ..()
	if(computer && computer.table == src)
		computer.table = null

/obj/structure/table/optable/tablepush(mob/living/user, mob/living/pushed_mob)
	pushed_mob.forceMove(loc)
	pushed_mob.set_resting(TRUE, TRUE)
	visible_message(span_notice("[user] lays [pushed_mob] on [src]."))
	get_patient()

/obj/structure/table/optable/proc/get_patient()
	var/mob/living/carbon/M = locate(/mob/living/carbon) in loc
	if(M)
		if(M.resting)
			set_patient(M)
	else
		set_patient(null)

/obj/structure/table/optable/proc/set_patient(new_patient)
	if(patient)
		UnregisterSignal(patient, COMSIG_PARENT_QDELETING)
	patient = new_patient
	if(patient)
		RegisterSignal(patient, COMSIG_PARENT_QDELETING, .proc/patient_deleted)

/obj/structure/table/optable/proc/patient_deleted(datum/source)
	SIGNAL_HANDLER
	set_patient(null)

/obj/structure/table/optable/proc/check_eligible_patient()
	get_patient()
	if(!patient)
		return FALSE
	if(ishuman(patient))
		return TRUE
	return FALSE

/*
 * Racks
 */
/obj/structure/rack
	name = "rack"
	desc = "Different from the Middle Ages version."
	icon = 'icons/obj/objects.dmi'
	icon_state = "rack"
	layer = TABLE_LAYER
	density = TRUE
	anchored = TRUE
	pass_flags_self = LETPASSTHROW //You can throw objects over this, despite it's density.
	max_integrity = 20

/obj/structure/rack/examine(mob/user)
	. = ..()
	. += span_notice("It's held together by a couple of <b>bolts</b>.")

/obj/structure/rack/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(.)
		return
	if(istype(mover) && (mover.pass_flags & PASSTABLE))
		return TRUE

/obj/structure/rack/MouseDrop_T(obj/O, mob/user)
	. = ..()
	if ((!( istype(O, /obj/item) ) || user.get_active_held_item() != O))
		return
	if(!user.dropItemToGround(O))
		return
	if(O.loc != src.loc)
		step(O, get_dir(O, src))

/obj/structure/rack/attackby(obj/item/W, mob/living/user, params)
	var/list/modifiers = params2list(params)
	if (W.tool_behaviour == TOOL_WRENCH && !(flags_1&NODECONSTRUCT_1) && LAZYACCESS(modifiers, RIGHT_CLICK))
		W.play_tool_sound(src)
		deconstruct(TRUE)
		return
	if(user.combat_mode)
		return ..()
	if(user.transferItemToLoc(W, drop_location()))
		return 1

/obj/structure/rack/attack_paw(mob/living/user, list/modifiers)
	attack_hand(user, modifiers)

/obj/structure/rack/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(user.body_position == LYING_DOWN || user.usable_legs < 2)
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
				playsound(loc, 'sound/weapons/tap.ogg', 50, TRUE)
		if(BURN)
			playsound(loc, 'sound/items/welder.ogg', 40, TRUE)

/*
 * Rack destruction
 */

/obj/structure/rack/deconstruct(disassembled = TRUE)
	if(!(flags_1&NODECONSTRUCT_1))
		set_density(FALSE)
		var/obj/item/rack_parts/newparts = new(loc)
		transfer_fingerprints_to(newparts)
	qdel(src)


/*
 * Rack Parts
 */

/obj/item/rack_parts
	name = "rack parts"
	desc = "Parts of a rack."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "rack_parts"
	flags_1 = CONDUCT_1
	custom_materials = list(/datum/material/iron=2000)
	var/building = FALSE

/obj/item/rack_parts/attackby(obj/item/W, mob/user, params)
	if (W.tool_behaviour == TOOL_WRENCH)
		new /obj/item/stack/sheet/iron(user.loc)
		qdel(src)
	else
		. = ..()

/obj/item/rack_parts/attack_self(mob/user)
	if(building)
		return
	building = TRUE
	to_chat(user, span_notice("You start constructing a rack..."))
	if(do_after(user, 50, target = user, progress=TRUE))
		if(!user.temporarilyRemoveItemFromInventory(src))
			return
		var/obj/structure/rack/R = new /obj/structure/rack(user.loc)
		user.visible_message("<span class='notice'>[user] assembles \a [R].\
			</span>", span_notice("You assemble \a [R]."))
		R.add_fingerprint(user)
		qdel(src)
	building = FALSE
