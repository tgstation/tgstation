/// Ratwood's farm tools (code/modules/farming/tools.dm, plough.dm): the hoe tills the ground into soil, the plough does it as it
/// is dragged along, the sickle reaps, the thresher beats the grain out of stalks, the pitchfork carries stalks and turns
/// compost (farming/threshing.dm, composter.dm).

/// What tilling makes of this tile (Ratwood rogueweapon attack_turf() with the till intent, plough user_tries_tilling()):
/// snow becomes tundra grass (not with a plough), grass becomes dirt (only the four green kinds with a plough), dirt becomes soil.
/// Null - nothing to till here. Ratwood's desert grass is not on the Rockhill map and not ported.
/proc/rogue_tilled_into(turf/tile, plough = FALSE)
	if(istype(tile, /turf/open/floor/rogue/dirt))
		return /obj/structure/soil
	if(istype(tile, /turf/open/floor/rogue/grass) || istype(tile, /turf/open/floor/rogue/grassred) || istype(tile, /turf/open/floor/rogue/grassyel) || istype(tile, /turf/open/floor/rogue/grasscold))
		return /turf/open/floor/rogue/dirt
	if(plough)
		return null
	if(istype(tile, /turf/open/floor/rogue/grasspurple) || istype(tile, /turf/open/floor/rogue/grassgrey))
		return /turf/open/floor/rogue/dirt
	if(istype(tile, /turf/open/floor/rogue/snow) || istype(tile, /turf/open/floor/rogue/snowrough) || istype(tile, /turf/open/floor/rogue/snowpatchy))
		return /turf/open/floor/rogue/grasscold
	return null

/// Tills a tile (after the work is done): grass and snow change, dirt gets soil or its soil is tilled again. TRUE if it did.
/proc/rogue_till_tile(turf/tile, mob/living/user, plough = FALSE)
	var/result = rogue_tilled_into(tile, plough)
	if(!result)
		return FALSE
	playsound(tile, ROGUE_DIG_SOUND, 100, TRUE)
	if(ispath(result, /turf))
		user.rogue_farming_fatigue(rogue_value("farm_work_fatigue"))
		tile.ChangeTurf(result, flags = CHANGETURF_INHERIT_AIR)
		return TRUE
	var/obj/structure/soil/soil = locate() in tile
	if(soil)
		soil.user_till_soil(user)
	else
		user.rogue_farming_fatigue(rogue_value("farm_work_fatigue"))
		new /obj/structure/soil(tile)
	return TRUE

/obj/item/rogueweapon/hoe/examine(mob/user)
	. = ..()
	. += span_notice("TILT intent allows you to make new plots for plants. Using it (on any intent) on a plot that already has something planted removes WEEDS.")

/// Deciseconds this hoe takes to till a tile (Ratwood work_time); a legendary farmer is quick with any.
/obj/item/rogueweapon/hoe/proc/rogue_till_time(mob/living/user)
	if(user.rogue_learned_rank(ROGUE_FARMING_SKILL) >= ROGUE_RANK_LEGENDARY)
		return rogue_value("farm_hoe_legendary_time")
	return rogue_value("farm_hoe_time")

/// Damage each tilling deals this hoe (Ratwood hoe_damage).
/obj/item/rogueweapon/hoe/proc/rogue_till_wear()
	return 0

/obj/item/rogueweapon/hoe/stone/rogue_till_time(mob/living/user)
	if(user.rogue_learned_rank(ROGUE_FARMING_SKILL) >= ROGUE_RANK_LEGENDARY)
		return rogue_value("farm_hoe_legendary_time")
	return rogue_value("farm_stone_hoe_time")

/obj/item/rogueweapon/hoe/stone/rogue_till_wear()
	return rogue_value("farm_stone_hoe_wear")

/// Ratwood rogueweapon attack_turf() with the till intent: the hoe works the ground of the clicked tile.
/obj/item/rogueweapon/hoe/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!isturf(interacting_with) || !isliving(user) || !istype(user.rogue_active_intent(), /datum/intent/till))
		return ..()
	var/turf/tile = interacting_with
	if(!rogue_tilled_into(tile))
		return ..()
	user.changeNext_move(CLICK_CD_MELEE)
	playsound(tile, ROGUE_DIG_SOUND, 100, TRUE)
	if(!do_after(user, rogue_till_time(user), target = tile))
		return ITEM_INTERACT_BLOCKING
	if(!rogue_till_tile(tile, user))
		return ITEM_INTERACT_BLOCKING
	var/wear = rogue_till_wear()
	if(wear)
		to_chat(user, span_warning("[src] degrades."))
		take_damage(wear, BRUTE, MELEE)
	return ITEM_INTERACT_SUCCESS

/obj/item/rogueweapon/sickle/examine(mob/user)
	. = ..()
	. += span_notice("Use on any plant to instantly harvest it. HERBS turn to fiber when attacked.")

/// Ratwood's plough: dragged by someone sneaking, it tills every grass or dirt tile it passes over.
/obj/structure/plough
	anchored = FALSE
	drag_slowdown = 2

/obj/structure/plough/examine(mob/user)
	. = ..()
	. += span_notice("TILTS any dirt/grass tile it's dragged over - requires user to drag it while having SNEAK active.")

/obj/structure/plough/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	var/mob/living/carbon/human/puller = pulledby
	if(istype(puller) && puller.rogue_sneaking && isturf(loc))
		rogue_till_tile(loc, puller, plough = TRUE)

/obj/item/rogueweapon/thresher/examine(mob/user)
	. = ..()
	. += span_notice("Use on STRIKE intent to break up produce for seeds. THRESH on stalks to beat out grains.")

/// Ratwood thresher afterattack() with the thresh intent: every bundle of stalks on the tile of whatever is struck is threshed.
/obj/item/rogueweapon/thresher/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!isliving(user) || isliving(interacting_with) || !istype(user.rogue_active_intent(), /datum/intent/flailthresh))
		return ..()
	var/turf/tile = isturf(interacting_with) ? interacting_with : interacting_with.loc
	if(!isturf(tile))
		return ..()
	var/found = FALSE
	for(var/obj/item/natural/chaff/stalks in tile)
		found = TRUE
		stalks.thresh()
	user.changeNext_move(CLICK_CD_MELEE)
	if(!found)
		return ITEM_INTERACT_BLOCKING
	playsound(tile, pick(ROGUE_PLANTCROSS_SOUNDS), 100, FALSE)
	playsound(tile, pick('modular_redtard/rockhill/sound/combat/hits/smashlimb (1).ogg', 'modular_redtard/rockhill/sound/combat/hits/smashlimb (2).ogg', 'modular_redtard/rockhill/sound/combat/hits/smashlimb (3).ogg'), 50, FALSE)
	user.visible_message(span_notice("[user] threshes the stalks!"), span_notice("I thresh the stalks."))
	return ITEM_INTERACT_SUCCESS

/obj/item/rogueweapon/pitchfork
	/// Stalks carried on the tines (Ratwood forked): picked up with the scoop intent while wielded, dumped on a tile.
	var/list/rogue_forked

/obj/item/rogueweapon/pitchfork/examine(mob/user)
	. = ..()
	. += span_notice("Use RIGHT CLICK to flip compost in the bin. While wielded SCOOP intent allows you to pick up large amount (19) stalks.")

/obj/item/rogueweapon/pitchfork/Destroy()
	rogue_dump_stalks(drop_location())
	return ..()

/obj/item/rogueweapon/pitchfork/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone in rogue_forked)
		LAZYREMOVE(rogue_forked, gone)
		update_appearance(UPDATE_ICON_STATE)

/obj/item/rogueweapon/pitchfork/update_icon_state()
	icon_state = LAZYLEN(rogue_forked) ? "[initial(icon_state)]stuff" : initial(icon_state)
	return ..()

/// Ratwood pitchfork afterattack(): wielded, it dumps what it carries on the clicked tile.
/obj/item/rogueweapon/pitchfork/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!rogue_wielded || !isopenturf(interacting_with) || !LAZYLEN(rogue_forked))
		return ..()
	rogue_dump_stalks(interacting_with)
	to_chat(user, span_warning("I dump the stalks."))
	return ITEM_INTERACT_SUCCESS

/// Ratwood ungrip(): letting go of the shaft drops what the tines carry.
/obj/item/rogueweapon/pitchfork/rogue_on_unwield(obj/item/source, mob/living/user)
	. = ..()
	rogue_dump_stalks(user ? get_turf(user) : drop_location())

/// Ratwood chaff attackby() with the pitchfork's scoop intent: the stalks on the tile go onto the tines, as many as they hold.
/obj/item/rogueweapon/pitchfork/proc/rogue_scoop(turf/tile, mob/living/user)
	var/scooped = 0
	var/capacity = rogue_value("farm_fork_capacity")
	for(var/obj/item/natural/chaff/stalks in tile)
		if(LAZYLEN(rogue_forked) >= capacity)
			break
		stalks.forceMove(src)
		LAZYADD(rogue_forked, stalks)
		scooped++
	if(scooped)
		to_chat(user, span_notice("I pick up the stalks with the pitchfork."))
	else
		to_chat(user, span_warning("I'm carrying enough with the pitchfork."))
	update_appearance(UPDATE_ICON_STATE)

/obj/item/rogueweapon/pitchfork/proc/rogue_dump_stalks(atom/spot)
	if(!LAZYLEN(rogue_forked))
		return
	for(var/obj/item/stalks as anything in rogue_forked.Copy())
		stalks.forceMove(spot)
	rogue_forked = null
	update_appearance(UPDATE_ICON_STATE)
