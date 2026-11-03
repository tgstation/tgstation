/// Ratwood's coins (code/game/objects/items/rogueitems/coins.dm) on TG's stack: a pile of up to twenty coins of one kind that
/// merges with its kind on the floor, in a pouch and in the hand, splits by hand and, as a single coin, flips. The porter grafts
/// the Ratwood branch onto /obj/item/stack (config.json, graft_overrides) and carries Ratwood's names, sprites and sellprice: a
/// zenny is worth 1 mammon, a ziliqua 5, a zenar 10, an old psilen 3.
/obj/item/roguecoin
	abstract_type = /obj/item/roguecoin
	gender = NEUTER
	singular_name = "coin"
	merge_type = /obj/item/roguecoin
	max_amount = ROGUE_COIN_PILE_MAX
	full_w_class = WEIGHT_CLASS_TINY
	resistance_flags = FIRE_PROOF
	drop_sound = ROGUE_SOUND_COIN_DROP
	simpleton_price = TRUE
	static_price = TRUE
	/// Letter of the coin's sprites in valuable.dmi (Ratwood base_type): c, s, g, a.
	var/base_type
	/// What more than one of these coins is called (Ratwood plural_name).
	var/plural_name
	/// The coin lies heads up; a pair shows one face when both agree (Ratwood heads_tails, last_merged_heads_tails).
	var/heads_tails = TRUE
	var/last_merged_heads_tails = TRUE
	/// The next flip lands on this side: 1 heads, 2 tails (Ratwood rigged_outcome, the Blackleg trait of Xylix).
	var/rigged_outcome = 0
	/// One or two coins are drawn at a fifth of their size on the floor (Ratwood dropshrink).
	var/shrunk = FALSE
	COOLDOWN_DECLARE(flip_cooldown)

/obj/item/roguecoin/get_real_price()
	return sellprice * get_amount()

/obj/item/roguecoin/update_name(updates)
	var/single = get_amount() <= 1
	name = single ? initial(name) : plural_name
	gender = single ? NEUTER : PLURAL
	return ..()

/// Ratwood's pile sprites: a coin shows its face, two coins a pair, more a heap that grows at 3, 4, 6, 11 and 16 coins.
/obj/item/roguecoin/update_icon_state()
	. = ..()
	if(!base_type)
		return
	switch(get_amount())
		if(0 to 1)
			icon_state = "[base_type][heads_tails]"
		if(2)
			icon_state = heads_tails == last_merged_heads_tails ? "[base_type][heads_tails]1" : "[base_type]m"
		if(3)
			icon_state = "[base_type]2"
		if(4 to 5)
			icon_state = "[base_type]3"
		if(6 to 10)
			icon_state = "[base_type]5"
		if(11 to 15)
			icon_state = "[base_type]10"
		else
			icon_state = "[base_type]15"
	update_coin_state()

/// A single coin goes in the mouth and clinks; a pile does neither, and one or two coins shrink on the floor (TG's item_scaling).
/obj/item/roguecoin/proc/update_coin_state()
	var/single = get_amount() <= 1
	slot_flags = single ? initial(slot_flags) : NONE
	drop_sound = single ? ROGUE_SOUND_COIN_DROP : ROGUE_SOUND_COINS
	var/small = get_amount() <= 2
	if(small == shrunk)
		return
	shrunk = small
	if(small)
		AddElement(/datum/element/item_scaling, 0.2, 1)
		// The element shrinks on attach and rescales only on the next move; in a hand or a pouch the coin keeps its size.
		if(!isturf(loc))
			transform = null
		return
	RemoveElement(/datum/element/item_scaling, 0.2, 1)
	transform = null

/obj/item/roguecoin/merge_without_del(obj/item/stack/target_stack, limit)
	. = ..()
	if(!. || !istype(target_stack, /obj/item/roguecoin))
		return
	var/obj/item/roguecoin/target = target_stack
	target.last_merged_heads_tails = heads_tails
	target.rigged_outcome = 0
	rigged_outcome = 0
	target.update_appearance(UPDATE_ICON)
	playsound(target, ROGUE_SOUND_COINS, 100, TRUE, -2)

/obj/item/roguecoin/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	playsound(src, ROGUE_SOUND_COINS, 100, TRUE, -2)
	return ..()

/// Use in hand flips a single coin (Ratwood attack_self), once in three seconds; a rigged coin lands as rigged.
/obj/item/roguecoin/interact(mob/user)
	if(get_amount() > 1 || !base_type || !COOLDOWN_FINISHED(src, flip_cooldown))
		return FALSE
	COOLDOWN_START(src, flip_cooldown, 3 SECONDS)
	playsound(user, ROGUE_SOUND_COIN_DROP, 100, FALSE)
	heads_tails = rigged_outcome ? rigged_outcome == 1 : prob(50)
	rigged_outcome = 0
	user.visible_message(span_info("[user] flips the coin. [heads_tails ? "Heads" : "Tails"]!"))
	update_appearance(UPDATE_ICON)
	return TRUE

/// Right click with an empty hand: a pile splits off as many coins as asked (half by default, Ratwood's split), a single coin is
/// rigged for its next flip by one of Xylix's Blackleg (Ratwood attack_right).
/obj/item/roguecoin/attack_hand_secondary(mob/user, list/modifiers)
	if(!user.can_perform_action(src, NEED_DEXTERITY))
		return SECONDARY_ATTACK_CONTINUE_CHAIN
	var/count = get_amount()
	if(count <= 1)
		if(!HAS_TRAIT(user, TRAIT_BLACKLEG))
			return SECONDARY_ATTACK_CONTINUE_CHAIN
		var/choice = tgui_alert(user, "What will you rig the next coin flip to?", "XYLIX", list("Heads", "Tails", "Play fair"))
		if(QDELETED(src) || !choice)
			return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
		rigged_outcome = choice == "Heads" ? 1 : (choice == "Tails" ? 2 : 0)
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	var/split = tgui_input_number(user, "How many [plural_name] to split? (1 to [count])", "Split coins", round(count / 2), max_value = count, min_value = 1)
	if(!split || QDELETED(user) || QDELETED(src) || !user.can_perform_action(src, FORBID_TELEKINESIS_REACH))
		return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN
	var/obj/item/roguecoin/taken = split_n_take(user, clamp(round(split), 1, get_amount()))
	if(taken)
		taken.heads_tails = last_merged_heads_tails
		taken.update_appearance(UPDATE_ICON)
		playsound(taken, taken.get_amount() > 1 ? ROGUE_SOUND_COINS : ROGUE_SOUND_COIN_TAKE, 100, TRUE, -2)
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/item/roguecoin/copper
	merge_type = /obj/item/roguecoin/copper
	base_type = "c"
	plural_name = "zennies"

/obj/item/roguecoin/silver
	merge_type = /obj/item/roguecoin/silver
	base_type = "s"
	plural_name = "ziliquae"

/obj/item/roguecoin/gold
	merge_type = /obj/item/roguecoin/gold
	base_type = "g"
	plural_name = "zenarii"

/// Dungeon coinage of a fallen kingdom, worth something to collectors; machines refuse it.
/obj/item/roguecoin/gilbranze
	merge_type = /obj/item/roguecoin/gilbranze
	base_type = "a"
	plural_name = "psila"

/// The Otavan marque of the Inquisition (Ratwood inqcoin, CTYPE_ICOIN): worth nothing to the realm, it buys at the MARQUETTE.
/obj/item/roguecoin/inqcoin
	merge_type = /obj/item/roguecoin/inqcoin
	base_type = "i"
	plural_name = "otavan marques"

/// Ratwood's piles: 4 to 19 coins unless a number is given.
/obj/item/roguecoin/copper/pile/Initialize(mapload, new_amount = rand(4, 19), merge = TRUE, list/mat_override, mat_amt = 1)
	return ..(mapload, new_amount, merge, mat_override, mat_amt)

/obj/item/roguecoin/silver/pile/Initialize(mapload, new_amount = rand(4, 19), merge = TRUE, list/mat_override, mat_amt = 1)
	return ..(mapload, new_amount, merge, mat_override, mat_amt)

/obj/item/roguecoin/gold/pile/Initialize(mapload, new_amount = rand(4, 19), merge = TRUE, list/mat_override, mat_amt = 1)
	return ..(mapload, new_amount, merge, mat_override, mat_amt)

/obj/item/roguecoin/gilbranze/pile/Initialize(mapload, new_amount = rand(4, 19), merge = TRUE, list/mat_override, mat_amt = 1)
	return ..(mapload, new_amount, merge, mat_override, mat_amt)

/// Twenty mammons in silver for those who were ready at round start (Ratwood readyuppile).
/obj/item/roguecoin/silver/pile/readyuppile/Initialize(mapload, new_amount = 4, merge = TRUE, list/mat_override, mat_amt = 1)
	return ..(mapload, new_amount, merge, mat_override, mat_amt)

/// A virtue's purse: 8 to 12 zenarii (Ratwood virtuepile).
/obj/item/roguecoin/gold/virtuepile/Initialize(mapload, new_amount = rand(8, 12), merge = TRUE, list/mat_override, mat_amt = 1)
	return ..(mapload, new_amount, merge, mat_override, mat_amt)

/// Coin kinds a machine pays out, largest first (Ratwood budget2change()).
GLOBAL_LIST_INIT(rogue_coin_kinds, list(
	ROGUE_COIN_GOLD = /obj/item/roguecoin/gold,
	ROGUE_COIN_SILVER = /obj/item/roguecoin/silver,
	ROGUE_COIN_BRONZE = /obj/item/roguecoin/copper,
))

/// Worth of one coin of a kind in mammons.
/proc/rogue_coin_value(kind)
	var/obj/item/roguecoin/coin_type = GLOB.rogue_coin_kinds[kind]
	return coin_type ? max(1, initial(coin_type.sellprice)) : 0

/// Machines take zennies, ziliquae and zenarii, not dungeon psila (Ratwood: every machine refuses gilbranze).
/proc/rogue_coin_accepted(obj/item/thing)
	return istype(thing, /obj/item/roguecoin) && !istype(thing, /obj/item/roguecoin/gilbranze)

/**
 * Pays mammons out as coins at the user's feet (or at a spot when nobody takes them), piles of at most twenty, each pile offered
 * to the user's hands (Ratwood budget2change()).
 * With a kind, only that coin; otherwise the fewest coins: zenarii, then ziliquae, then zennies.
 * Returns the mammons paid, which is less than asked when the kind does not divide the amount.
 */
/proc/rogue_coins_out(amount, mob/user, kind, atom/where)
	amount = floor(amount)
	var/turf/spot = get_turf(user || where)
	if(amount <= 0 || !spot)
		return 0
	var/paid = 0
	for(var/each in (kind ? list(kind) : GLOB.rogue_coin_kinds))
		var/coin_type = GLOB.rogue_coin_kinds[each]
		var/value = rogue_coin_value(each)
		if(!coin_type || !value)
			continue
		var/count = floor((amount - paid) / value)
		while(count > 0)
			var/pile = min(count, ROGUE_COIN_PILE_MAX)
			var/obj/item/roguecoin/coins = new coin_type(spot, pile, FALSE)
			count -= pile
			paid += pile * value
			user?.put_in_hands(coins)
	if(paid)
		playsound(spot, ROGUE_SOUND_COIN_DISPENSE, 100, FALSE, -1)
	return paid
