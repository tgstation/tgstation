/// Ratwood's hand cart (structures/roguetown/handcart.dm): a wooden cart pulled by hand that carries things and people. An
/// item weighs its size class, a creature handcart_creature_weight, and the cart takes up to handcart_capacity of them, more
/// with a wooden cog in its wheel. Items go in from the hand or from one's own tile at a click, anything on a tile by being
/// dragged onto the cart; a right click tips everything out.
/obj/structure/handcart
	anchored = FALSE
	/// What it carries (Ratwood stuff_shit).
	var/list/atom/movable/cargo = list()
	/// The weight it carries now.
	var/current_capacity = 0
	/// The weight it can carry; a cog in the wheel raises it.
	var/maximum_capacity = 0
	/// The wheelbrace fitted: 0 none or a plain cog, 1 a reliable cog, 2 an unstable one (Ratwood upgrade_level).
	var/upgrade_level = 0

/obj/structure/handcart/Initialize(mapload)
	. = ..()
	if(. == INITIALIZE_HINT_QDEL)
		return
	maximum_capacity = rogue_value("handcart_capacity")
	update_appearance()
	if(mapload)
		return INITIALIZE_HINT_LATELOAD

/// Ratwood: what the map put on the cart's tile is loaded into it.
/obj/structure/handcart/LateInitialize()
	take_contents()

/obj/structure/handcart/Destroy()
	dump_contents()
	return ..()

/obj/structure/handcart/examine(mob/user)
	. = ..()
	. += span_info("Clicking and dragging an item onto the handcart from the tile you are on will put every items from the tile you can into the cart.")
	if(upgrade_level)
		. += span_notice("This cart has a <i>level [upgrade_level]</i> woodcutters wheelbrace installed.")

/obj/structure/handcart/update_icon_state()
	. = ..()
	icon_state = length(cargo) ? "cart-full" : "cart-empty"

/obj/structure/handcart/update_overlays()
	. = ..()
	switch(upgrade_level)
		if(1)
			. += mutable_appearance(icon, "ov_upgrade")
		if(2)
			. += mutable_appearance(icon, "ov_upgrade2")

/// Pulled along, the cart turns to go the way its puller goes.
/obj/structure/handcart/Moved(atom/old_loc, movement_dir, forced, list/old_locs, momentum_change = TRUE)
	. = ..()
	if(pulledby && dir != pulledby.dir)
		setDir(pulledby.dir)

/obj/structure/handcart/Exited(atom/movable/gone, direction)
	. = ..()
	if(!(gone in cargo))
		return
	cargo -= gone
	current_capacity = max(current_capacity - cargo_weight(gone), 0)
	if(!QDELETED(src))
		update_appearance()

/obj/structure/handcart/container_resist_act(mob/living/user)
	user.forceMove(drop_location())

/obj/structure/handcart/attack_hand(mob/living/user, list/modifiers)
	. = ..()
	if(. || !isliving(user) || user.combat_mode)
		return
	var/turf/user_turf = get_turf(user)
	if(!isturf(user_turf))
		return
	user.changeNext_move(CLICK_CD_MELEE)
	var/loaded = FALSE
	for(var/obj/item/thing in user_turf)
		if(insertion_allowed(thing) && put_in(thing))
			loaded = TRUE
	if(loaded)
		playsound(loc, 'modular_redtard/rockhill/sound/foley/cartadd.ogg', 100, FALSE, -1)
	return TRUE

/obj/structure/handcart/attack_hand_secondary(mob/living/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN || !isliving(user))
		return
	user.changeNext_move(CLICK_CD_MELEE)
	if(length(cargo))
		dump_contents()
		visible_message(span_info("[user] dumps out [src]!"))
		playsound(loc, 'modular_redtard/rockhill/sound/foley/cartdump.ogg', 100, FALSE, -1)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/structure/handcart/item_interaction(mob/living/user, obj/item/tool, list/modifiers)
	if(istype(tool, /obj/item/roguegear/wood))
		return fit_cog(user, tool)
	if(user.combat_mode)
		return NONE
	if(!insertion_allowed(tool))
		return ITEM_INTERACT_BLOCKING
	if(put_in(tool, user))
		playsound(loc, 'modular_redtard/rockhill/sound/foley/cartadd.ogg', 100, FALSE, -1)
	return ITEM_INTERACT_SUCCESS

/obj/structure/handcart/mouse_drop_receive(atom/dropped, mob/user, params)
	. = ..()
	var/atom/movable/cargo_item = dropped
	if(!istype(cargo_item) || !isturf(cargo_item.loc) || !isliving(user) || user.incapacitated)
		return
	var/mob/living/loader = user
	if(!Adjacent(user) || !user.Adjacent(cargo_item))
		return
	if(user == cargo_item)
		// Ratwood: one lying down rolls into the cart; standing, one climbs it instead, which the port does not do.
		if(loader.body_position == LYING_DOWN)
			INVOKE_ASYNC(src, PROC_REF(load_creature), user, user)
		return
	if(loader.combat_mode || !insertion_allowed(cargo_item))
		return
	if(isliving(cargo_item))
		INVOKE_ASYNC(src, PROC_REF(load_creature), cargo_item, user)
		return
	if(put_in(cargo_item))
		playsound(loc, 'modular_redtard/rockhill/sound/foley/cartadd.ogg', 100, FALSE, -1)

/// Loading a creature, or oneself, takes a moment (Ratwood do_after_mob).
/obj/structure/handcart/proc/load_creature(mob/living/creature, mob/living/user)
	if(!do_after(user, rogue_value("handcart_load_time"), target = creature))
		return
	if(QDELETED(creature) || !isturf(creature.loc) || !Adjacent(creature) || (creature != user && !insertion_allowed(creature)))
		return
	if(put_in(creature))
		playsound(loc, 'modular_redtard/rockhill/sound/foley/cartadd.ogg', 100, FALSE, -1)

/// Ratwood's wheelbrace: a plain cog raises the cart's capacity, a reliable one too unless it already has a better one, an
/// unstable one unless it has one already; the cog is used up.
/obj/structure/handcart/proc/fit_cog(mob/living/user, obj/item/roguegear/wood/cog)
	if(cog.ulevel && ((cog.ulevel == 1 && upgrade_level) || (cog.ulevel == 2 && upgrade_level == 2)))
		to_chat(user, span_warning("This [cog] is obsolete."))
		return ITEM_INTERACT_BLOCKING
	upgrade_level = cog.ulevel
	maximum_capacity = cog.cart_capacity()
	to_chat(user, span_warning("[cog.name] inserted!"))
	qdel(cog)
	playsound(src, pick('modular_redtard/rockhill/sound/combat/hits/onwood/fence_hit1.ogg', 'modular_redtard/rockhill/sound/combat/hits/onwood/fence_hit2.ogg', 'modular_redtard/rockhill/sound/combat/hits/onwood/fence_hit3.ogg'), 100, FALSE)
	shake_camera(user, 1, 1)
	update_appearance()
	return ITEM_INTERACT_SUCCESS

/// The weight a thing takes up in the cart.
/obj/structure/handcart/proc/cargo_weight(atom/movable/thing)
	if(isliving(thing))
		return rogue_value("handcart_creature_weight")
	if(isitem(thing))
		var/obj/item/item_thing = thing
		return item_thing.w_class
	return 0

/// Puts one thing in if it still fits: from the user's hand when one is given.
/obj/structure/handcart/proc/put_in(atom/movable/thing, mob/user)
	var/weight = cargo_weight(thing)
	if(current_capacity + weight > maximum_capacity)
		return FALSE
	if(user && isitem(thing) && user.is_holding(thing))
		if(!user.transferItemToLoc(thing, src))
			return FALSE
	else
		if(isliving(thing))
			var/mob/living/creature = thing
			creature.stop_pulling()
		thing.pulledby?.stop_pulling()
		thing.forceMove(src)
	if(thing.loc != src)
		return FALSE
	cargo += thing
	current_capacity += weight
	update_appearance()
	return TRUE

/// Ratwood dump_contents(): everything goes onto the cart's tile.
/obj/structure/handcart/dump_contents()
	var/atom/drop_spot = drop_location()
	for(var/atom/movable/thing as anything in cargo.Copy())
		thing.forceMove(drop_spot)
	cargo.Cut()
	current_capacity = 0
	if(!QDELETED(src))
		update_appearance()

/// Ratwood take_contents(): what lies on the tile goes in until the cart is full.
/obj/structure/handcart/proc/take_contents()
	for(var/atom/movable/thing in loc)
		if(thing == src || !(isitem(thing) || isliving(thing)) || !insertion_allowed(thing))
			continue
		if(!put_in(thing))
			break

/// Ratwood insertion_allowed(): loose items and small or lying creatures; nothing fixed in place, held, ghostly or buckled.
/obj/structure/handcart/proc/insertion_allowed(atom/movable/thing)
	if(ismob(thing))
		if(!isliving(thing))
			return FALSE
		var/mob/living/creature = thing
		if(creature.anchored || (creature.buckled && creature.buckled != src) || creature.incorporeal_move || creature.has_buckled_mobs())
			return FALSE
		if(creature.mob_size > MOB_SIZE_TINY && creature.density)
			return FALSE
		return TRUE
	if(!isobj(thing) || thing.density || thing.anchored || thing.has_buckled_mobs())
		return FALSE
	if(isitem(thing))
		var/obj/item/item_thing = thing
		if(HAS_TRAIT(item_thing, TRAIT_NODROP) || (item_thing.item_flags & ABSTRACT))
			return FALSE
	return TRUE

/// Ratwood's wooden cogs: how far one raises a hand cart's capacity, and the wheelbrace level it makes.
/obj/item/roguegear/wood
	/// 0 a plain cog, 1 a reliable one, 2 an unstable one (Ratwood ulevel).
	var/ulevel = 0

/// The weight a cart carries with this cog in its wheel (Ratwood cart_capacity).
/obj/item/roguegear/wood/proc/cart_capacity()
	return rogue_value("handcart_cog_capacity")

/obj/item/roguegear/wood/reliable
	ulevel = 1

/obj/item/roguegear/wood/reliable/cart_capacity()
	return rogue_value("handcart_reliable_cog_capacity")

/obj/item/roguegear/wood/unstable
	ulevel = 2

/obj/item/roguegear/wood/unstable/cart_capacity()
	return rogue_value("handcart_unstable_cog_capacity")
