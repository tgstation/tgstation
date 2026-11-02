/// Ratwood post_buckle_mob() of its beds: the one lying on a bed lies this far up on it.
#define ROCKHILL_BED_BUCKLE_SHIFT 5
#define ROCKHILL_BED_BUCKLE_SOURCE "rockhill_bed_buckle"
/// Ratwood's table ongive(): a hand of cards laid out face up is fanned out, each card this far from the last.
#define ROCKHILL_CARD_FAN_STEP 8
/// ...starting this far left of the middle for each card after the first.
#define ROCKHILL_CARD_FAN_START 2

/obj/structure/table/wood/rockhill
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/tables.dmi'
	icon_state = "tablewood"
	smoothing_flags = NONE
	smoothing_groups = null
	canSmoothWith = null
	/// What is left when the table is taken apart with tools (Ratwood buildstack): a small log for a wooden one, nothing for
	/// stone and fine tables, whose Ratwood types have none.
	var/rockhill_buildstack

/obj/structure/table/wood/rockhill/wood
	rockhill_buildstack = /obj/item/grown/log/tree/small

/obj/structure/table/wood/rockhill/Initialize(mapload)
	. = ..()
	apply_rockhill_look()
	AddComponent(/datum/component/rockhill_hiding_spot)

/// Ratwood deconstruct(): taken apart with a screwdriver or a wrench, the table leaves its buildstack and no frame. Broken, it
/// leaves what destruction leaves (rockhill/destruction.dm).
/obj/structure/table/wood/rockhill/atom_deconstruct(disassembled = TRUE)
	if(!disassembled)
		return ..()
	if(rockhill_buildstack)
		new rockhill_buildstack(get_turf(src))

/// Ratwood's table ongive(), on the right click: a hand of cards is laid out face up and fanned so the cards do not stack, a
/// single card goes down face up.
/obj/structure/table/wood/rockhill/item_interaction_secondary(mob/living/user, obj/item/tool, list/modifiers)
	if(user.combat_mode || is_flipped)
		return ..()
	if(istype(tool, /obj/item/toy/cards/cardhand))
		lay_out_hand(user, tool)
		return ITEM_INTERACT_SUCCESS
	if(istype(tool, /obj/item/toy/singlecard))
		var/obj/item/toy/singlecard/card = tool
		if(!card.flipped)
			card.Flip(CARD_FACEUP)
		return table_place_act(user, card, modifiers)
	return ..()

/obj/structure/table/wood/rockhill/proc/lay_out_hand(mob/living/user, obj/item/toy/cards/cardhand/hand)
	var/turf/table_turf = get_turf(src)
	var/list/obj/item/toy/singlecard/cards = hand.fetch_card_atoms()
	if(!table_turf || !length(cards))
		return
	user.visible_message(span_notice("[user] lays [user.p_their()] hand of cards face-up on the table."), span_notice("I lay my cards face-up on the table."))
	var/offset = -(length(cards) - 1) * ROCKHILL_CARD_FAN_START
	for(var/obj/item/toy/singlecard/card as anything in cards.Copy())
		hand.card_atoms -= card
		card.forceMove(table_turf)
		card.Flip(CARD_FACEUP)
		card.pixel_x = offset
		card.pixel_y = 0
		offset += ROCKHILL_CARD_FAN_STEP
	qdel(hand)

/obj/structure/chair/wood/rockhill
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "chair2"
	max_integrity = 100
	item_chair = null

/obj/structure/chair/wood/rockhill/Initialize(mapload)
	. = ..()
	apply_rockhill_look()

/obj/structure/chair/wood/rockhill/proc/knock_over()
	if(QDELETED(src) || !item_chair || !isturf(loc))
		return FALSE
	playsound(loc, 'modular_redtard/rockhill/sound/furniture/chairfall.ogg', 100, FALSE)
	var/obj/item/chair_item = new item_chair(loc)
	item_chair = null
	chair_item.set_custom_materials(custom_materials)
	TransferComponents(chair_item)
	chair_item.update_integrity(get_integrity())
	chair_item.setDir(dir)
	qdel(src)
	return TRUE

/obj/structure/chair/wood/rockhill/wood/rogue/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(COMSIG_ATOM_EXIT = PROC_REF(on_exit))
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/structure/chair/wood/rockhill/wood/rogue/proc/trips(atom/movable/mover)
	var/mob/living/walker = mover
	return item_chair && isliving(walker) && walker.body_position == STANDING_UP && !walker.throwing && !walker.buckled

/obj/structure/chair/wood/rockhill/wood/rogue/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(REVERSE_DIR(border_dir) == dir && trips(mover))
		addtimer(CALLBACK(src, PROC_REF(knock_over)), 0, TIMER_UNIQUE)
		return FALSE

/obj/structure/chair/wood/rockhill/wood/rogue/proc/on_exit(datum/source, atom/movable/leaving, direction)
	SIGNAL_HANDLER
	if(direction != REVERSE_DIR(dir) || !trips(leaving))
		return
	addtimer(CALLBACK(src, PROC_REF(knock_over)), 0, TIMER_UNIQUE)
	return COMPONENT_ATOM_BLOCK_EXIT

/obj/structure/chair/wood/rockhill/wood/rogue/take_damage(damage_amount, damage_type = BRUTE, damage_flag = "", sound_effect = TRUE, attack_dir, armour_penetration = 0)
	if(damage_amount > 5 && knock_over())
		return 0
	return ..()

/obj/structure/chair/wood/rockhill/wood/rogue/attack_hand_secondary(mob/living/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN || !isliving(user) || !user.combat_mode || !item_chair)
		return
	user.changeNext_move(CLICK_CD_MELEE)
	user.do_attack_animation(src)
	user.visible_message(span_warning("[user] kicks [src] over!"), span_notice("I kick [src] over!"))
	knock_over()
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/structure/chair/wood/rockhill/wood/rogue/post_buckle_mob(mob/living/buckled)
	. = ..()
	set_density(TRUE)

/obj/structure/chair/wood/rockhill/wood/rogue/post_unbuckle_mob(mob/living/buckled)
	. = ..()
	set_density(FALSE)

/obj/structure/chair/wood/rockhill/bench/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/rockhill_hiding_spot)
	var/static/list/loc_connections = list(COMSIG_ATOM_EXIT = PROC_REF(on_exit))
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/structure/chair/wood/rockhill/bench/handle_layer()
	layer = dir == NORTH ? ABOVE_MOB_LAYER : OBJ_LAYER

/obj/structure/chair/wood/rockhill/bench/CanAllowThrough(atom/movable/mover, border_dir)
	. = ..()
	if(REVERSE_DIR(border_dir) == dir)
		return FALSE

/obj/structure/chair/wood/rockhill/bench/proc/on_exit(datum/source, atom/movable/leaving, direction)
	SIGNAL_HANDLER
	if(direction != REVERSE_DIR(dir) || isprojectile(leaving))
		return
	leaving.Bump(src)
	return COMPONENT_ATOM_BLOCK_EXIT

/obj/structure/chair/wood/rockhill/bench/post_buckle_mob(mob/living/buckled)
	. = ..()
	set_density(TRUE)

/obj/structure/chair/wood/rockhill/bench/post_unbuckle_mob(mob/living/buckled)
	. = ..()
	set_density(FALSE)

/obj/structure/bed/rockhill
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/beds.dmi'
	icon_state = "bed"
	resistance_flags = FLAMMABLE
	build_stack_type = /obj/item/stack/sheet/mineral/wood

/obj/structure/bed/rockhill/Initialize(mapload)
	. = ..()
	apply_rockhill_look()
	AddComponent(/datum/component/rockhill_hiding_spot)

/// Ratwood's beds (structures/beds_chairs/roguechair.dm): the one lying on one lies a little up on it.
/obj/structure/bed/rockhill/rogue/post_buckle_mob(mob/living/buckled)
	. = ..()
	buckled.add_offsets(ROCKHILL_BED_BUCKLE_SOURCE, y_add = ROCKHILL_BED_BUCKLE_SHIFT)

/obj/structure/bed/rockhill/rogue/post_unbuckle_mob(mob/living/buckled)
	. = ..()
	buckled.remove_offsets(ROCKHILL_BED_BUCKLE_SOURCE)

/obj/structure/rack/rockhill
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "rack"
	resistance_flags = FLAMMABLE

/obj/structure/rack/rockhill/Initialize(mapload)
	. = ..()
	apply_rockhill_look()
	if(!density)
		RemoveElement(/datum/element/climbable)

/obj/structure/closet/crate/wooden/rockhill
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "chest3s"
	base_icon_state = "chest3s"
	var/keylock = FALSE
	var/lockid
	var/lockdifficulty = 1
	var/lock_strength = 100
	var/list/rockhill_contents
	var/list/rockhill_loot
	var/rockhill_loot_chance = 100

/obj/structure/closet/crate/wooden/rockhill/Initialize(mapload)
	. = ..()
	apply_rockhill_look()

/obj/structure/closet/crate/wooden/rockhill/PopulateContents()
	. = ..()
	for(var/item_type in rockhill_contents)
		new item_type(src)
	if(length(rockhill_loot) && prob(rockhill_loot_chance))
		var/item_type = pick_weight(rockhill_loot)
		new item_type(src)

/obj/structure/closet/crate/wooden/rockhill/examine(mob/user)
	. = ..()
	if(keylock)
		. += span_notice("It has a keyhole[locked ? " and is locked" : ""].")

/obj/structure/closet/crate/wooden/rockhill/can_open(mob/living/user, force = FALSE)
	. = ..()
	if(!. && locked && user && !force)
		to_chat(user, span_warning("Locked."))
		playsound(src, 'modular_redtard/rockhill/sound/doors/lockrattle.ogg', 100)

/obj/structure/closet/crate/wooden/rockhill/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(keylock && !opened && !(user in contents))
		if(istype(tool, /obj/item/roguekey) || istype(tool, /obj/item/storage/keyring))
			use_key(user, tool)
			return ITEM_INTERACT_SUCCESS
		if(tool.picklvl)
			INVOKE_ASYNC(src, PROC_REF(pick_lock), user, tool)
			return ITEM_INTERACT_SUCCESS
	return ..()

/obj/structure/closet/crate/wooden/rockhill/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN || !keylock || opened || !user.can_perform_action(src))
		return
	var/obj/item/key = rockhill_find_key(user, lockid, TRUE)
	if(key)
		use_key(user, key)
	else
		to_chat(user, span_warning("I don't have the right key for [src]."))
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/structure/closet/crate/wooden/rockhill/proc/use_key(mob/living/user, obj/item/key)
	if(!rockhill_key_fits(key, lockid, TRUE))
		to_chat(user, span_warning("This is not the key to [src]."))
		playsound(src, 'modular_redtard/rockhill/sound/doors/lockrattle.ogg', 100)
		return
	toggle_key_lock(user)

/obj/structure/closet/crate/wooden/rockhill/proc/toggle_key_lock(mob/living/user)
	user.changeNext_move(CLICK_CD_MELEE)
	locked = !locked
	playsound(src, 'modular_redtard/rockhill/sound/doors/lock.ogg', 100)
	user.visible_message(span_warning("[user] [locked ? "locks" : "unlocks"] [src]."), span_notice("I [locked ? "lock" : "unlock"] [src]."))
	update_appearance()

/obj/structure/closet/crate/wooden/rockhill/proc/pick_lock(mob/living/user, obj/item/lockpick)
	if(opened || !keylock)
		return
	if(rockhill_pick_lock(user, lockpick, src, lockdifficulty, lock_strength))
		toggle_key_lock(user)

/// Ratwood CtrlShiftClick(): the skittish dive into a crate (TG's Skittish quirk). Running into one dives in as well, by TG's
/// skittish element.
/obj/structure/closet/crate/wooden/rockhill/click_ctrl_shift(mob/user)
	if(!isliving(user) || !HAS_TRAIT(user, TRAIT_SKITTISH) || !divable || !isturf(user.loc))
		return NONE
	dive_into(user)
	return CLICK_ACTION_SUCCESS

/// Ratwood dive_into(): open the crate, step in, lie down and pull the lid shut over oneself. Ratwood unlocks a locked crate for
/// the dive and locks it after; a key lock here stays as it is, so a locked crate does not let one in.
/obj/structure/closet/crate/wooden/rockhill/proc/dive_into(mob/living/user)
	var/turf/crate_turf = get_turf(src)
	if(!opened && (locked || !open(user)))
		to_chat(user, span_warning("It won't budge!"))
		return
	step_towards(user, crate_turf)
	if(get_turf(user) != crate_turf)
		return
	user.set_resting(TRUE, silent = TRUE, instant = TRUE)
	if(!close(user))
		to_chat(user, span_warning("I can't get [src] to close!"))
		user.set_resting(FALSE, silent = TRUE, instant = TRUE)
		return
	user.set_resting(FALSE, silent = TRUE, instant = TRUE)
	crate_turf.visible_message(span_warning("[user] dives into [src]!"))

/obj/structure/chair/wood/rockhill
	var/sleepy = 0

/obj/structure/bed/rockhill
	var/sleepy = 0

/// Ratwood's toilet (structures/toilet.dm): small things put in outside combat mode lie hidden in it until a hand fishes
/// one out.
/obj/structure/rockhill/toilet
	name = "toilet"
	icon = 'modular_redtard/rockhill/icons/roguetown/misc/structure.dmi'
	icon_state = "toilet"
	/// The combined w_class of what lies inside.
	var/w_items = 0

/obj/structure/rockhill/toilet/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(!length(contents))
		to_chat(user, span_notice("The toilet is empty."))
		return TRUE
	var/obj/item/found = pick(contents)
	if(!user.put_in_hands(found))
		found.forceMove(drop_location())
	to_chat(user, span_notice("I find [found] in the toilet."))
	return TRUE

/obj/structure/rockhill/toilet/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(user.combat_mode)
		return NONE
	if(tool.w_class > WEIGHT_CLASS_NORMAL)
		to_chat(user, span_warning("[tool] does not fit!"))
		return ITEM_INTERACT_BLOCKING
	if(w_items + tool.w_class > WEIGHT_CLASS_HUGE)
		to_chat(user, span_warning("The toilet is full!"))
		return ITEM_INTERACT_BLOCKING
	if(!user.transferItemToLoc(tool, src))
		to_chat(user, span_warning("[tool] is stuck to my hand!"))
		return ITEM_INTERACT_BLOCKING
	to_chat(user, span_notice("I carefully place [tool] into the toilet."))
	return ITEM_INTERACT_SUCCESS

/obj/structure/rockhill/toilet/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(isitem(arrived))
		var/obj/item/thing = arrived
		w_items += thing.w_class

/obj/structure/rockhill/toilet/Exited(atom/movable/gone, direction)
	. = ..()
	if(isitem(gone))
		var/obj/item/thing = gone
		w_items -= thing.w_class

/obj/structure/rockhill/toilet/atom_deconstruct(disassembled = TRUE)
	for(var/atom/movable/thing as anything in contents)
		thing.forceMove(drop_location())

#undef ROCKHILL_BED_BUCKLE_SHIFT
#undef ROCKHILL_BED_BUCKLE_SOURCE
#undef ROCKHILL_CARD_FAN_STEP
#undef ROCKHILL_CARD_FAN_START
