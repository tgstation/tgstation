/// Max number of unanchored items that will be moved from a tile when attempting to add a window to a grille.
#define CLEAR_TILE_MOVE_LIMIT 20

/obj/structure/grille
	desc = "A flimsy framework of iron rods."
	name = "grille"
	icon = 'icons/obj/structures.dmi'
	icon_state = "grille"
	base_icon_state = "grille"
	density = TRUE
	anchored = TRUE
	pass_flags_self = PASSGRILLE | PASSWINDOW
	obj_flags = CONDUCTS_ELECTRICITY | CAN_BE_HIT | IGNORE_DENSITY
	pressure_resistance = 5*ONE_ATMOSPHERE
	armor_type = /datum/armor/structure_grille
	max_integrity = 50
	integrity_failure = 0.4
	var/rods_type = /obj/item/stack/rods
	var/rods_amount = 2
	/// Whether or not we're disappearing but dramatically
	var/dramatically_disappearing = FALSE

/datum/armor/structure_grille
	melee = 50
	bullet = 70
	laser = 70
	energy = 100
	bomb = 10

/obj/structure/grille/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/atmos_sensitive, mapload)

/obj/structure/grille/Destroy()
	update_cable_icons_on_turf(get_turf(src))
	return ..()

/obj/structure/grille/take_damage(damage_amount, damage_type = BRUTE, damage_flag = 0, sound_effect = 1, attack_dir)
	. = ..()
	update_appearance()

/obj/structure/grille/update_appearance(updates)
	if(QDELETED(src))
		return
	. = ..()
	if((updates & UPDATE_SMOOTHING) && (smoothing_flags & USES_SMOOTHING))
		QUEUE_SMOOTH(src)

/obj/structure/grille/update_icon_state()
	if (broken)
		icon_state = "broken[base_icon_state]"
	else
		icon_state = "[base_icon_state][((atom_integrity / max_integrity) <= 0.5) ? "50_[rand(0, 3)]" : null]"
	return ..()

/obj/structure/grille/examine(mob/user)
	. = ..()
	if(resistance_flags & INDESTRUCTIBLE)
		return
	if(anchored)
		. += span_notice("It's secured in place with <b>screws</b>. The rods look like they could be <b>cut</b> through.")
	else
		. += span_notice("The anchoring screws are <i>unscrewed</i>. The rods look like they could be <b>cut</b> through.")

/obj/structure/grille/rcd_vals(mob/user, obj/item/construction/rcd/the_rcd)
	switch(the_rcd.mode)
		if(RCD_DECONSTRUCT)
			return list("delay" = 2 SECONDS, "cost" = 5)
		if(RCD_WINDOWGRILLE)
			var/cost = 0
			var/delay = 0

			if(the_rcd.rcd_design_path  == /obj/structure/window)
				cost = 4
				delay = 2 SECONDS
			else if(the_rcd.rcd_design_path  == /obj/structure/window/reinforced)
				cost = 6
				delay = 2.5 SECONDS
			else if(the_rcd.rcd_design_path  == /obj/structure/window/fulltile)
				cost = 8
				delay = 3 SECONDS
			else if(the_rcd.rcd_design_path  == /obj/structure/window/reinforced/fulltile)
				cost = 12
				delay = 4 SECONDS
			if(!cost)
				return FALSE

			return rcd_result_with_memory(
				list("delay" = delay, "cost" = cost),
				get_turf(src), RCD_MEMORY_WINDOWGRILLE,
			)
	return FALSE

/obj/structure/grille/rcd_act(mob/user, obj/item/construction/rcd/the_rcd, list/rcd_data)
	switch(rcd_data["[RCD_DESIGN_MODE]"])
		if(RCD_DECONSTRUCT)
			qdel(src)
			return TRUE
		if(RCD_WINDOWGRILLE)
			if(!isturf(loc))
				return FALSE
			var/turf/T = loc

			if(repair_grille())
				balloon_alert(user, "grille rebuilt")
			if(!clear_tile(user))
				return FALSE

			var/obj/structure/window/window_path = rcd_data["[RCD_DESIGN_PATH]"]
			if(!ispath(window_path))
				CRASH("Invalid window path type in RCD: [window_path]")

			//checks if its a valid build direction
			if(!initial(window_path.fulltile))
				if(!valid_build_direction(loc, user.dir, is_fulltile = FALSE))
					balloon_alert(user, "window already here!")
					return FALSE

			var/obj/structure/window/WD = new window_path(T, user.dir)
			WD.set_anchored(TRUE)
			return TRUE
	return FALSE

/obj/structure/grille/proc/clear_tile(mob/user)
	var/at_users_feet = get_turf(user)

	var/unanchored_items_on_tile
	var/obj/item/last_item_moved
	for(var/obj/item/item_to_move in loc.contents)
		if(!item_to_move.anchored)
			if(unanchored_items_on_tile <= CLEAR_TILE_MOVE_LIMIT)
				item_to_move.forceMove(at_users_feet)
				last_item_moved = item_to_move
			unanchored_items_on_tile++

	if(!unanchored_items_on_tile)
		return TRUE

	to_chat(user, span_notice("You move [unanchored_items_on_tile == 1 ? "[last_item_moved]" : "some things"] out of the way."))

	if(unanchored_items_on_tile - CLEAR_TILE_MOVE_LIMIT > 0)
		to_chat(user, span_warning("There's still too much stuff in the way!"))
		return FALSE

	return TRUE

/obj/structure/grille/Bumped(atom/movable/AM)
	if(!ismob(AM))
		return
	var/mob/M = AM
	shock(M, 70)

/obj/structure/grille/attack_animal(mob/user, list/modifiers)
	. = ..()
	if(!.)
		return
	if(!shock(user, 70) && !QDELETED(src)) //Last hit still shocks but shouldn't deal damage to the grille
		take_damage(rand(5,10), BRUTE, MELEE, 1)

/obj/structure/grille/attack_paw(mob/user, list/modifiers)
	return attack_hand(user, modifiers)

/obj/structure/grille/hulk_damage()
	return 60

/obj/structure/grille/attack_hulk(mob/living/carbon/human/user)
	if(shock(user, 70))
		return
	. = ..()

/obj/structure/grille/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src, ATTACK_EFFECT_KICK)
	user.visible_message(span_warning("[user] hits [src]."), null, null, COMBAT_MESSAGE_RANGE)
	log_combat(user, src, "hit")
	if(!shock(user, 70))
		take_damage(rand(5,10), BRUTE, MELEE, 1)

/obj/structure/grille/attack_alien(mob/living/user, list/modifiers)
	user.do_attack_animation(src)
	user.changeNext_move(CLICK_CD_MELEE)
	user.visible_message(span_warning("[user] mangles [src]."), null, null, COMBAT_MESSAGE_RANGE)
	if(!shock(user, 70))
		take_damage(20, BRUTE, MELEE, 1)

/obj/structure/grille/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(!. && isprojectile(mover))
		return prob(30)

/obj/structure/grille/CanAStarPass(to_dir, datum/can_pass_info/pass_info)
	if(!density)
		return TRUE
	if(pass_info.pass_flags & PASSGRILLE)
		return TRUE
	return FALSE

/obj/structure/grille/wirecutter_act(mob/living/user, obj/item/tool)
	add_fingerprint(user)
	if(shock(user, 100))
		return
	tool.play_tool_sound(src, 100)
	deconstruct(TRUE)
	return ITEM_INTERACT_SUCCESS

/obj/structure/grille/screwdriver_act(mob/living/user, obj/item/tool)
	if(!isturf(loc))
		return FALSE
	add_fingerprint(user)
	if(shock(user, 90))
		return FALSE
	if(!tool.use_tool(src, user, 0, volume=100))
		return FALSE
	set_anchored(!anchored)
	user.visible_message(span_notice("[user] [anchored ? "fastens" : "unfastens"] [src]."), \
		span_notice("You [anchored ? "fasten [src] to" : "unfasten [src] from"] the floor."))
	return ITEM_INTERACT_SUCCESS

/obj/structure/grille/attackby(obj/item/W, mob/user, list/modifiers, list/attack_modifiers)
	user.changeNext_move(CLICK_CD_MELEE)
	if(istype(W, /obj/item/stack/rods) && broken && do_after(user, 1 SECONDS, target = src))
		if(shock(user, 90))
			return
		var/obj/item/stack/rods/R = W
		user.visible_message(span_notice("[user] rebuilds the broken grille."), \
			span_notice("You rebuild the broken grille."))
		repair_grille()
		R.use(1)
		return TRUE

//window placing begin
	else if(is_glass_sheet(W) || istype(W, /obj/item/stack/sheet/bronze))
		if (!broken)
			var/obj/item/stack/ST = W
			if (ST.get_amount() < 2)
				to_chat(user, span_warning("You need at least two sheets of glass for that!"))
				return
			var/dir_to_set = SOUTHWEST
			if(!anchored)
				to_chat(user, span_warning("[src] needs to be fastened to the floor first!"))
				return
			for(var/obj/structure/window/WINDOW in loc)
				to_chat(user, span_warning("There is already a window there!"))
				return
			if(!clear_tile(user))
				return
			to_chat(user, span_notice("You start placing the window..."))
			if(do_after(user,20, target = src))
				if(!src.loc || !anchored) //Grille broken or unanchored while waiting
					return
				for(var/obj/structure/window/WINDOW in loc) //Another window already installed on grille
					return
				if(!clear_tile(user))
					return
				var/obj/structure/window/WD
				if(istype(W, /obj/item/stack/sheet/plasmarglass))
					WD = new/obj/structure/window/reinforced/plasma/fulltile(drop_location()) //reinforced plasma window
				else if(istype(W, /obj/item/stack/sheet/plasmaglass))
					WD = new/obj/structure/window/plasma/fulltile(drop_location()) //plasma window
				else if(istype(W, /obj/item/stack/sheet/rglass))
					WD = new/obj/structure/window/reinforced/fulltile(drop_location()) //reinforced window
				else if(istype(W, /obj/item/stack/sheet/titaniumglass))
					WD = new/obj/structure/window/reinforced/shuttle(drop_location())
				else if(istype(W, /obj/item/stack/sheet/plastitaniumglass))
					WD = new/obj/structure/window/reinforced/plasma/plastitanium(drop_location())
				else if(istype(W, /obj/item/stack/sheet/bronze))
					WD = new/obj/structure/window/bronze/fulltile(drop_location())
				else
					WD = new/obj/structure/window/fulltile(drop_location()) //normal window
				WD.setDir(dir_to_set)
				WD.set_anchored(FALSE)
				WD.state = 0
				ST.use(2)
				to_chat(user, span_notice("You place [WD] on [src]."))
			return
//window placing end

	else if((W.obj_flags & CONDUCTS_ELECTRICITY) && shock(user, 70))
		return

	return ..()

/obj/structure/grille/play_attack_sound(damage_amount, damage_type = BRUTE, damage_flag = 0)
	switch(damage_type)
		if(BRUTE)
			if(damage_amount)
				playsound(src, 'sound/effects/grillehit.ogg', 80, TRUE)
			else
				playsound(src, 'sound/items/weapons/tap.ogg', 50, TRUE)
		if(BURN)
			playsound(src, 'sound/items/tools/welder.ogg', 80, TRUE)


/obj/structure/grille/atom_deconstruct(disassembled = TRUE)
	var/obj/rods = new rods_type(drop_location(), rods_amount)
	transfer_fingerprints_to(rods)

/obj/structure/grille/atom_break()
	. = ..()
	if(broken)
		return
	set_density(FALSE)
	atom_integrity = 20
	broken = TRUE
	rods_amount = 1
	var/obj/item/dropped_rods = new rods_type(drop_location(), rods_amount)
	transfer_fingerprints_to(dropped_rods)
	update_appearance()

/obj/structure/grille/proc/repair_grille()
	if(!broken)
		return FALSE

	set_density(TRUE)
	atom_integrity = max_integrity
	broken = FALSE
	rods_amount = 2
	update_appearance()
	return TRUE

// shock user with probability prb (if all connections & power are working)
// returns 1 if shocked, 0 otherwise

/obj/structure/grille/proc/shock(mob/user, prb)
	if(!anchored || broken) // anchored/broken grilles are never connected
		return FALSE
	if(!prob(prb))
		return FALSE
	if(!in_range(src, user))//To prevent TK and mech users from getting shocked
		return FALSE
	var/turf/T = get_turf(src)
	if(T.overfloor_placed)//cant be a floor in the way!
		return FALSE

	var/obj/structure/cable/cable_node = T.get_cable_node()
	if(isnull(cable_node))
		return FALSE
	if(!electrocute_mob(user, cable_node, src, 1, TRUE))
		return FALSE
	if(prob(50)) // Shocking hurts the grille (to weaken monkey powersinks)
		take_damage(1, BURN, FIRE, sound_effect = FALSE)
	var/datum/effect_system/spark_spread/sparks = new /datum/effect_system/spark_spread
	sparks.set_up(3, 1, src)
	sparks.start()

	return TRUE

/obj/structure/grille/should_atmos_process(datum/gas_mixture/air, exposed_temperature)
	return exposed_temperature > T0C + 1500 && !broken

/obj/structure/grille/atmos_expose(datum/gas_mixture/air, exposed_temperature)
	take_damage(1, BURN, 0, 0)

/obj/structure/grille/hitby(atom/movable/AM, skipcatch, hitpush, blocked, datum/thrownthing/throwingdatum)
	if(isobj(AM))
		if(prob(50) && anchored && !broken)
			var/obj/O = AM
			if(O.throwforce != 0)//don't want to let people spam tesla bolts, this way it will break after time
				var/turf/T = get_turf(src)
				if(T.overfloor_placed)
					return FALSE
				var/obj/structure/cable/C = T.get_cable_node()
				if(C)
					playsound(src, 'sound/effects/magic/lightningshock.ogg', 100, TRUE, extrarange = 5)
					tesla_zap(source = src, zap_range = 3, power = C.newavail() * 0.01, cutoff = 1e3, zap_flags = ZAP_MOB_DAMAGE | ZAP_OBJ_DAMAGE | ZAP_MOB_STUN | ZAP_LOW_POWER_GEN | ZAP_ALLOW_DUPLICATES) //Zap for 1/100 of the amount of power. At a million watts in the grid, it will be as powerful as a tesla revolver shot.
					C.add_delayedload(C.newavail() * 0.0375) // you can gain up to 3.5 via the 4x upgrades power is halved by the pole so thats 2x then 1X then .5X for 3.5x the 3 bounces shock. // What do you mean by this?
	return ..()

/obj/structure/grille/get_dumping_location()
	return null

/obj/structure/grille/proc/temporary_shatter(time_to_go = 0 SECONDS, time_to_return = 4 SECONDS)
	if(dramatically_disappearing)
		return

	//disappear in 1 second
	dramatically_disappearing = TRUE
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom/movable, moveToNullspace)), time_to_go) //woosh

	// come back in 1 + 4 seconds
	addtimer(VARSET_CALLBACK(src, atom_integrity, atom_integrity), time_to_go + time_to_return) //set the health back (icon is updated on move)
	addtimer(CALLBACK(src, TYPE_PROC_REF(/atom/movable, forceMove), loc), time_to_go + time_to_return) //we back boys
	addtimer(VARSET_CALLBACK(src, dramatically_disappearing, FALSE), time_to_go + time_to_return) //also set the var back

/// Do some very specific checks to see if we *would* get shocked. Returns TRUE if it's shocked
/obj/structure/grille/proc/is_shocked()
	var/turf/turf = get_turf(src)
	var/obj/structure/cable/cable = turf.get_cable_node()
	var/list/powernet_info = get_powernet_info_from_source(cable)

	if(!powernet_info)
		return FALSE

	var/datum/powernet/powernet = powernet_info["powernet"]
	return !!powernet.get_electrocute_damage()

/obj/structure/grille/broken // Pre-broken grilles for map placement
	icon_state = "brokengrille"
	density = FALSE
	broken = TRUE
	rods_amount = 1

/obj/structure/grille/broken/Initialize(mapload)
	. = ..()
	take_damage(max_integrity * 0.6)

#undef CLEAR_TILE_MOVE_LIMIT
