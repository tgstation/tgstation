/// Ratwood's earth (turfs/open/floor/roguefloor.dm, items/rogueitems/natural/dirtclod.dm, roguejobs/gravedigger/tools.dm).
/// A free hand takes a clod with the right button: of dirt (three to a tile, then it is a road), of sand, of snow (the
/// snow left patchy). The shovel's scoop breaks dirt and grass into a road and a road into a hole (burial/graves.dm), digs
/// a hole deeper and fills it back with the clod it carries; a clod on the blade mends a road into dirt, sinks in water,
/// or drops where the shovel is put. The scoop takes snow off the dirt under it, sand into a clod, a clod off the ground.
/// A clod thrown down where three more lie heaps them into a pile the shovel takes from and puts back. A road by water is
/// mud, slow to walk; all dirt cakes the shoes of who walks it, and muddy shoes leave footprints (Ratwood human Move()).
/// Not ported: digging on in a loop (Ratwood's middle click on dirt), the snow clod (until the porter brings
/// /obj/item/natural/dirtclod/snow a hand takes no snow), the sand pile, dirt turning to mud in water and rain (Ratwood
/// water_level), snow footprints and the steps' sound in mud, the walking stick and Longstrider against the mud.

/// The ground a shovel digs (Ratwood shovel attack_turf()): dirt and the grasses.
GLOBAL_LIST_INIT(rogue_diggable_ground, typecacheof(list(
	/turf/open/floor/rogue/dirt,
	/turf/open/floor/rogue/grass,
	/turf/open/floor/rogue/grassred,
	/turf/open/floor/rogue/grassyel,
	/turf/open/floor/rogue/grasscold,
	/turf/open/floor/rogue/grasspurple,
	/turf/open/floor/rogue/grassgrey,
)))

/// Snow a shovel scoops off the dirt under it.
GLOBAL_LIST_INIT(rogue_scoopable_snow, typecacheof(list(
	/turf/open/floor/rogue/snow,
	/turf/open/floor/rogue/snowrough,
	/turf/open/floor/rogue/snowpatchy,
)))

// --- The shovel

/obj/item/rogueweapon/shovel
	/// The clod on the blade (Ratwood heldclod): dug up, waiting to be thrown somewhere.
	var/obj/item/natural/dirtclod/rogue_clod

/obj/item/rogueweapon/shovel/Destroy()
	QDEL_NULL(rogue_clod)
	return ..()

/obj/item/rogueweapon/shovel/Exited(atom/movable/gone, direction)
	. = ..()
	if(gone != rogue_clod)
		return
	rogue_clod = null
	update_appearance(UPDATE_ICON_STATE)

/// Ratwood dropped(): set down on the ground, the shovel lets its clod fall.
/obj/item/rogueweapon/shovel/dropped(mob/user, silent)
	. = ..()
	if(isturf(loc))
		rogue_lose_clod(loc)

/// Ratwood update_icon(): the blade carries earth ("dirt<state>").
/obj/item/rogueweapon/shovel/update_icon_state()
	. = ..()
	icon_state = rogue_clod ? "dirt[initial(icon_state)]" : initial(icon_state)

/obj/item/rogueweapon/shovel/examine(mob/user)
	. = ..()
	if(rogue_clod)
		. += span_info("There is \a [rogue_clod] on the blade.")

/// Puts a fresh clod of earth on the blade.
/obj/item/rogueweapon/shovel/proc/rogue_take_clod(clod_type = /obj/item/natural/dirtclod)
	if(rogue_clod)
		return
	rogue_clod = new clod_type(src)
	update_appearance(UPDATE_ICON_STATE)

/// Throws the clod off the blade: onto the ground where, or into nothing (water, a hole, a pile) without.
/obj/item/rogueweapon/shovel/proc/rogue_lose_clod(atom/where)
	if(!rogue_clod)
		return
	if(where)
		rogue_clod.forceMove(where)
	else
		qdel(rogue_clod)
	rogue_clod = null
	update_appearance(UPDATE_ICON_STATE)

/// Ratwood shovel attack_turf() and dirtclod attackby() with the scoop intent: the shovel at work on the ground.
/obj/item/rogueweapon/shovel/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if(!isliving(user) || !istype(user.rogue_active_intent(), /datum/intent/shovelscoop))
		return ..()
	var/obj/item/natural/dirtclod/clod = interacting_with
	if(istype(clod))
		if(rogue_clod || !isturf(clod.loc))
			return ..()
		playsound(clod, ROGUE_BURIAL_DIG_SOUND, 100, TRUE)
		clod.forceMove(src)
		rogue_clod = clod
		update_appearance(UPDATE_ICON_STATE)
		return ITEM_INTERACT_SUCCESS
	if(!isturf(interacting_with))
		return ..()
	var/datum/intent/scoop = user.rogue_active_intent()
	if(!rogue_dig(interacting_with, user))
		return ..()
	user.changeNext_move(scoop.clickcd)
	return ITEM_INTERACT_SUCCESS

/// Ratwood attack_turf() with the scoop: digs, fills, scoops or throws the clod on the ground. TRUE if it did anything.
/obj/item/rogueweapon/shovel/proc/rogue_dig(turf/ground, mob/living/user)
	if(is_type_in_typecache(ground, GLOB.rogue_diggable_ground))
		var/obj/structure/closet/crate/wooden/rockhill/dirthole/hole = locate() in ground
		if(!rogue_clod && user.rogue_rmb_is(/datum/rogue_rmb_intent/strong) && HAS_TRAIT(user, TRAIT_GRAVEROBBER))
			if(!hole || hole.rogue_stage < ROGUE_HOLE_PIT)
				INVOKE_ASYNC(src, PROC_REF(rogue_tear_pit), ground, user)
			return TRUE
		if(rogue_clod)
			if(hole && hole.rogue_stage < ROGUE_HOLE_GRAVE)
				hole.rogue_shovel(src, user)
				return TRUE
			if(istype(ground, /turf/open/floor/rogue/dirt/road))
				rogue_lose_clod()
				ground.ChangeTurf(/turf/open/floor/rogue/dirt, flags = CHANGETURF_INHERIT_AIR)
			else
				rogue_lose_clod(ground)
			playsound(ground, ROGUE_BURIAL_EMPTY_SOUND, 100, TRUE)
			return TRUE
		if(hole)
			hole.rogue_shovel(src, user)
			return TRUE
		rogue_break_ground(ground)
		user.log_message("started digging a hole with [src]", LOG_GAME)
		rogue_take_clod()
		playsound(ground, ROGUE_BURIAL_DIG_SOUND, 100, TRUE)
		return TRUE
	if(istype(ground, /turf/open/floor/rogue/AzureSand))
		if(rogue_clod)
			rogue_lose_clod(ground)
			playsound(ground, ROGUE_BURIAL_EMPTY_SOUND, 100, TRUE)
		else
			rogue_take_clod(/obj/item/natural/dirtclod/sand)
			playsound(ground, ROGUE_BURIAL_DIG_SOUND, 100, TRUE)
		return TRUE
	if(rogue_clod)
		rogue_lose_clod(istype(ground, /turf/open/water) ? null : ground)
		playsound(ground, ROGUE_BURIAL_EMPTY_SOUND, 100, TRUE)
		return TRUE
	if(is_type_in_typecache(ground, GLOB.rogue_scoopable_snow))
		ground.ChangeTurf(/turf/open/floor/rogue/dirt, flags = CHANGETURF_INHERIT_AIR)
		to_chat(user, span_warning("You scoop away the snow!"))
		return TRUE
	return FALSE

/// Ratwood: the first scoop breaks dirt or grass into a road, the next opens a hole in the road.
/obj/item/rogueweapon/shovel/proc/rogue_break_ground(turf/ground)
	if(istype(ground, /turf/open/floor/rogue/dirt/road))
		new /obj/structure/closet/crate/wooden/rockhill/dirthole(ground)
		return
	ground.ChangeTurf(/turf/open/floor/rogue/dirt/road, flags = CHANGETURF_INHERIT_AIR)

/// Ratwood: a grave robber's strong scoop tears a whole pit out of the earth in five seconds, clods flying about.
/obj/item/rogueweapon/shovel/proc/rogue_tear_pit(turf/ground, mob/living/user)
	to_chat(user, span_notice("I tear into the earth, carving out a pit!"))
	if(!do_after(user, rogue_value("graverobber_pit_time"), target = ground) || rogue_clod)
		return
	if(!is_type_in_typecache(ground, GLOB.rogue_diggable_ground))
		return
	var/obj/structure/closet/crate/wooden/rockhill/dirthole/hole = locate() in ground
	if(hole && hole.rogue_stage >= ROGUE_HOLE_PIT)
		return
	if(!hole)
		if(!istype(ground, /turf/open/floor/rogue/dirt/road))
			ground = ground.ChangeTurf(/turf/open/floor/rogue/dirt/road, flags = CHANGETURF_INHERIT_AIR)
		hole = new(ground)
	hole.rogue_stage = ROGUE_HOLE_PIT
	hole.rogue_faildirt = 0
	hole.locked = FALSE
	hole.rogue_update_look()
	rogue_take_clod()
	var/clods_left = rogue_value("graverobber_pit_clods")
	for(var/turf/spot in list(get_turf(user), get_step(user, NORTH), get_step(user, SOUTH), get_step(user, EAST), get_step(user, WEST)))
		if(clods_left <= 0)
			break
		new /obj/item/natural/dirtclod(spot)
		clods_left--
	playsound(ground, ROGUE_BURIAL_DIG_SOUND, 100, TRUE)
	user.log_message("tore open a grave-sized pit with [src]", LOG_GAME)

// --- Clods of earth

/obj/item/natural/dirtclod/Initialize(mapload)
	. = ..()
	icon_state = "clod[rand(1, 2)]"

/obj/item/natural/dirtclod/sand/Initialize(mapload)
	. = ..()
	icon_state = "sand[rand(1, 2)]"

/// Ratwood dirtclod attack_self(): the clod is scattered.
/obj/item/natural/dirtclod/attack_self(mob/user, modifiers)
	. = ..()
	if(.)
		return
	user.visible_message(span_warning("[user] scatters [src]."))
	qdel(src)
	return TRUE

/// Ratwood dirtclod Moved(): a clod thrown down onto a pile goes into it; thrown where three more lie, they heap into a pile
/// (Ratwood counts the clods there, this one too, plus one, and piles at five).
/obj/item/natural/dirtclod/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(QDELETED(src) || !isturf(loc) || istype(src, /obj/item/natural/dirtclod/sand))
		return
	var/most = rogue_value("clodpile_clods")
	var/obj/structure/fluff/clodpile/pile = locate() in loc
	if(pile)
		pile.rogue_dirt = min(pile.rogue_dirt + 1, most)
		qdel(src)
		return
	var/list/clods = list()
	for(var/obj/item/natural/dirtclod/clod in loc)
		clods += clod
	if(length(clods) + 1 < most)
		return
	var/turf/spot = loc
	clods -= src
	QDEL_LIST(clods)
	new /obj/structure/fluff/clodpile(spot)
	qdel(src)

/obj/structure/fluff/clodpile
	/// Clods of earth in the pile (Ratwood dirtamt).
	var/rogue_dirt = 5

/// Ratwood clodpile attackby(): the scoop takes a clod from the pile, or throws the clod it carries back onto it.
/obj/structure/fluff/clodpile/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	var/obj/item/rogueweapon/shovel/shovel = tool
	if(!istype(shovel) || !istype(user.rogue_active_intent(), /datum/intent/shovelscoop))
		return ..()
	if(shovel.rogue_clod)
		playsound(src, ROGUE_BURIAL_EMPTY_SOUND, 100, TRUE)
		shovel.rogue_lose_clod()
		rogue_dirt = min(rogue_dirt + 1, rogue_value("clodpile_clods"))
		return ITEM_INTERACT_SUCCESS
	playsound(src, ROGUE_BURIAL_DIG_SOUND, 100, TRUE)
	shovel.rogue_take_clod()
	rogue_dirt--
	if(rogue_dirt <= 0)
		qdel(src)
	return ITEM_INTERACT_SUCCESS

// --- Clods by hand

/// Ratwood attack_right() of dirt, sand and snow: a clod in the active hand, if the hand is free.
/turf/open/floor/rogue/proc/rogue_hand_clod(mob/living/user, clod_type, taking)
	if(!isliving(user) || user.stat != STABLE || !ispath(clod_type, /obj/item))
		return FALSE
	var/obj/item/clod = new clod_type(src)
	if(!user.put_in_active_hand(clod))
		qdel(clod)
		return FALSE
	user.visible_message(span_warning("[user] [taking]."))
	return TRUE

/turf/open/floor/rogue/dirt
	/// Clods a hand has taken from this dirt (Ratwood dirt_amt counts them down): at dirt_clods it is a road.
	var/rogue_clods_taken = 0
	/// Sodden into mud (Ratwood muddy).
	var/rogue_muddy = FALSE

/// Ratwood dirt attack_right(): a handful of earth; the road gives none.
/turf/open/floor/rogue/dirt/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN || istype(src, /turf/open/floor/rogue/dirt/road))
		return
	if(!rogue_hand_clod(user, /obj/item/natural/dirtclod, "picks up some dirt"))
		return
	rogue_clods_taken++
	if(rogue_clods_taken >= rogue_value("dirt_clods"))
		ChangeTurf(/turf/open/floor/rogue/dirt/road, flags = CHANGETURF_INHERIT_AIR)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/// Ratwood snow attack_right(): a handful of snow leaves it patchy. Ratwood's packed snow is not ported yet, so until
/// the porter brings it the hand finds nothing to take.
/turf/open/floor/rogue/snow/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(!rogue_hand_clod(user, text2path("/obj/item/natural/dirtclod/snow"), "picks up some snow"))
		return
	ChangeTurf(/turf/open/floor/rogue/snowpatchy, flags = CHANGETURF_INHERIT_AIR)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/// Ratwood AzureSand attack_right(): a handful of sand, as many as one likes.
/turf/open/floor/rogue/AzureSand/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(rogue_hand_clod(user, /obj/item/natural/dirtclod/sand, "scoops up some sand"))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

// --- Mud

/// Ratwood road update_water() as the road loads: a road by water is mud.
/turf/open/floor/rogue/dirt/road/Initialize(mapload)
	. = ..()
	for(var/direction in GLOB.cardinals)
		if(istype(get_step(src, direction), /turf/open/water))
			rogue_become_muddy()
			return

/// Ratwood become_muddy(): mud, slow to walk.
/turf/open/floor/rogue/dirt/proc/rogue_become_muddy()
	if(rogue_muddy)
		return
	rogue_muddy = TRUE
	name = "mud"
	icon_state = "mud[rand(1, 3)]"
	slowdown = rogue_value("mud_slowdown")

/// Ratwood dirt Crossed(): walking dirt - a road, mud - cakes the shoes with it; a light step keeps them clean.
/turf/open/floor/rogue/dirt/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(!ishuman(arrived))
		return
	var/mob/living/carbon/human/walker = arrived
	var/obj/item/clothing/shoes/shoes = walker.shoes
	if(!istype(shoes) || HAS_TRAIT(walker, TRAIT_LIGHT_STEP) || (walker.movement_type & MOVETYPES_NOT_TOUCHING_GROUND))
		return
	var/mud = rogue_value("dirt_mud_per_step")
	if(mud <= 0)
		return
	var/datum/component/rogue_muddy_soles/soles = shoes.LoadComponent(/datum/component/rogue_muddy_soles)
	soles?.add_mud(mud)

/// Mud on a pair of shoes (Ratwood bloody_shoes[BLOOD_STATE_MUD]). Each step of whoever wears them, standing, wears some
/// off and leaves muddy footprints where none are yet, while there is enough (Ratwood human Move()); washing cleans it.
/datum/component/rogue_muddy_soles
	dupe_mode = COMPONENT_DUPE_UNIQUE
	/// How much mud the soles carry (Ratwood MAX_SHOE_BLOODINESS at most).
	var/mud = 0
	/// Who wears the shoes now.
	var/mob/living/carbon/human/wearer

/datum/component/rogue_muddy_soles/Initialize()
	if(!istype(parent, /obj/item/clothing/shoes))
		return COMPONENT_INCOMPATIBLE

/datum/component/rogue_muddy_soles/RegisterWithParent()
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equipped))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_dropped))
	RegisterSignal(parent, COMSIG_COMPONENT_CLEAN_ACT, PROC_REF(on_clean))
	var/obj/item/clothing/shoes/shoes = parent
	var/mob/living/carbon/human/holder = shoes.loc
	if(istype(holder) && holder.shoes == shoes)
		set_wearer(holder)

/datum/component/rogue_muddy_soles/UnregisterFromParent()
	UnregisterSignal(parent, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED, COMSIG_COMPONENT_CLEAN_ACT))
	set_wearer(null)

/datum/component/rogue_muddy_soles/Destroy(force)
	set_wearer(null)
	return ..()

/datum/component/rogue_muddy_soles/proc/set_wearer(mob/living/carbon/human/new_wearer)
	if(wearer)
		UnregisterSignal(wearer, list(COMSIG_MOVABLE_MOVED, COMSIG_QDELETING))
	wearer = new_wearer
	if(wearer)
		RegisterSignal(wearer, COMSIG_MOVABLE_MOVED, PROC_REF(on_moved))
		RegisterSignal(wearer, COMSIG_QDELETING, PROC_REF(on_wearer_deleted))

/datum/component/rogue_muddy_soles/proc/on_equipped(obj/item/source, mob/equipper, slot)
	SIGNAL_HANDLER
	set_wearer(ishuman(equipper) && (slot & ITEM_SLOT_FEET) ? equipper : null)

/datum/component/rogue_muddy_soles/proc/on_dropped(obj/item/source, mob/dropper)
	SIGNAL_HANDLER
	set_wearer(null)

/datum/component/rogue_muddy_soles/proc/on_wearer_deleted(datum/source)
	SIGNAL_HANDLER
	set_wearer(null)

/// Ratwood clean_blood(): washing takes the mud off.
/datum/component/rogue_muddy_soles/proc/on_clean(datum/source, clean_types)
	SIGNAL_HANDLER
	if(!mud || !(clean_types & CLEAN_TYPE_BLOOD))
		return NONE
	mud = 0
	return COMPONENT_CLEANED

/datum/component/rogue_muddy_soles/proc/add_mud(amount)
	mud = min(mud + amount, rogue_value("shoe_mud_max"))

/// Ratwood human Move(): a step onto a tile with no muddy prints wears mud off the soles and, while enough is left, leaves
/// prints there; the prints of the tile left behind show the way out.
/datum/component/rogue_muddy_soles/proc/on_moved(mob/living/carbon/human/source, atom/old_loc, movement_dir, forced, list/old_locs, momentum_change)
	SIGNAL_HANDLER
	if(mud <= 0 || source.body_position == LYING_DOWN || (source.movement_type & MOVETYPES_NOT_TOUCHING_GROUND))
		return
	if(isturf(old_loc))
		var/obj/effect/decal/cleanable/rogue_mud_prints/old_prints = locate() in old_loc
		old_prints?.rogue_step(source.dir, leaving = TRUE)
	var/turf/here = source.loc
	if(!isopenturf(here) || isgroundlessturf(here))
		return
	var/obj/effect/decal/cleanable/rogue_mud_prints/prints = locate() in here
	if(prints)
		prints.rogue_step(source.dir)
		return
	mud = max(mud - rogue_value("shoe_mud_per_step"), 0)
	if(mud <= rogue_value("shoe_mud_print_above"))
		return
	prints = new(here)
	if(!QDELETED(prints))
		prints.rogue_step(source.dir)

/// Ratwood's muddy footprints (decals/cleanable/humans.dm footprints/mud): which ways muddy feet came onto the tile and
/// left it.
/obj/effect/decal/cleanable/rogue_mud_prints
	name = "footprints"
	desc = ""
	icon = 'modular_redtard/burial/icons/footprints.dmi'
	icon_state = "mud1"
	alpha = 140
	/// Ways muddy feet came in (Ratwood entered_dirs) and went out (exited_dirs).
	var/entered_dirs = NONE
	var/exited_dirs = NONE

/obj/effect/decal/cleanable/rogue_mud_prints/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	icon_state = ""

/obj/effect/decal/cleanable/rogue_mud_prints/proc/rogue_step(direction, leaving = FALSE)
	if(!direction)
		return
	if(leaving)
		if(exited_dirs & direction)
			return
		exited_dirs |= direction
	else
		if(entered_dirs & direction)
			return
		entered_dirs |= direction
	update_appearance(UPDATE_OVERLAYS)

/// Ratwood footprints update_icon(): a print of feet coming in ("mud1") or going out ("mud2") per way.
/obj/effect/decal/cleanable/rogue_mud_prints/update_overlays()
	. = ..()
	for(var/direction in GLOB.cardinals)
		if(entered_dirs & direction)
			. += image(icon, "mud1", dir = direction)
		if(exited_dirs & direction)
			. += image(icon, "mud2", dir = direction)
